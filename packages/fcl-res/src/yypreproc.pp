{%MainUnit rcparser.pas}

{$IFDEF INC_HEADER}

type
  typreproc = record
  const
    yp_maxlevels = 16;
  var
    Defines: TStringList;
    skip  : array[0..yp_maxlevels-1] of boolean;
    cheadermode: boolean;
    level : longint;
  public
    procedure init();
    procedure done();
    function isdefine(ident: string): boolean;
    function getdefine(ident: string): string;
    function useline(line: string): boolean;
    procedure newfile(fn: string);
  end;

var
  ypreproc: typreproc;

{$ELSE}

procedure typreproc.init();
begin
  Defines:= TStringList.Create;
  Defines.CaseSensitive:= False;
  level:= 0;
  cheadermode:= false;
  fillchar(skip,sizeof(skip),0);
end;

procedure typreproc.done();
begin
  FreeAndNil(Defines);
end;

function Copy2SpaceDelTrim(var s: string): string;
const
  whitespace = [#9, ' '];
var
  p: integer;
begin
  p:= PosSet(whitespace, s);
  if p <= 0 then begin
    result:= s;
    s:= '';
  end else begin
    result:= Copy(S, 1, p-1);
    while (p < Length(s)) and (s[p] in whitespace) do
      inc(p);
    Delete(s, 1, p-1);
  end;
end;

function Substring(s: string; First, Last: integer): string;
begin
  Result:= Copy(s, First, Last-First+1);
end;

function typreproc.isdefine(ident: string): boolean;
begin
  Result:= Defines.IndexOfName(ident) >= 0;
end;

function typreproc.getdefine(ident: string): string;
begin
  Result:= Defines.Values[ident];
end;

function typreproc.useline(line: string): boolean;
var
  w, word, arg1: string;
begin
  Result:= true;
  w:= trim(line);
  if (yystate <= 1) and
     (Length(w) > 2) and (w[1] = '#') then begin
    Delete(w, 1, 1);
    word:= Copy2SpaceDelTrim(w);
    case word of
      'ifdef': begin
        inc(Level);
        if Level >= yp_maxlevels then begin
          yyerror('Too many ifdef levels');
          exit;
        end;
        skip[level]:= (skip[level-1] or (not isdefine(w)));
      end;
      'ifndef': begin
        inc(Level);
        if Level >= yp_maxlevels then begin
          yyerror('Too many ifdef levels');
          exit;
        end;
        skip[level]:= (skip[level-1] or (isdefine(w)));
      end;
      'else': begin
        skip[level]:= skip[level-1] or (not skip[level]);
      end;
      'endif': begin
        skip[level]:= false;
        if Level = 0 then begin
          yyerror('Too many endif found');
          exit;
        end;
        dec(level);
      end;
    else
      if not skip[level] then
        case word of
          'pragma': begin
            if StartsStr('code_page(', w) then begin
              arg1:= Substring(w, Length('code_page(') + 1, Pos(')', w) - 1);
              PragmaCodePage(arg1);
            end;
          end;
          'define': begin
            arg1:= Copy2SpaceDelTrim(w);
            Defines.Values[arg1]:= w;
          end;
          'undef': begin
            Defines.Delete(Defines.IndexOfName(arg1));
          end;
          'include': begin
            arg1:= yinclude.expand(w);
            yinclude.push(arg1);
          end;
        end;
    end;
    Result:= false;
  end else begin
    Result:= (not cheadermode) and (not skip[level]);
  end;
end;

procedure typreproc.newfile(fn: string);
var
  ex: String;
begin
  ex:= UpperCase(ExtractFileExt(yyfilename));
  cheadermode:= (ex = '.C') or (ex = '.H');
end;


{$ENDIF}
