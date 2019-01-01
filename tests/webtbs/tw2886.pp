{ Source provided for Free Pascal Bug Report 2886 }
{ Submitted by "Mattias Gaertner" on  2004-01-08 }
{ e-mail: mattias@freepascal.org }
program WrongRTTIParams;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, TypInfo;

type
  TAnEvent = procedure(Sender: TObject) of object;

  TMyClass = class(TPersistent)
  private
    FMyEvent: TAnEvent;
  public
    procedure ShowRTTI;
  published
    property MyEvent: TAnEvent read FMyEvent write FMyEvent;
  end;

{ TMyClass }

procedure TMyClass.ShowRTTI;
type
  PParamFlags = ^TParamFlags;
var
  TypeData: PTypeData;
  ParamCount: Integer;
  Offset: Integer;
  Len: Integer;
  CurParamName: string;
  CurTypeIdentifier: string;
  CurFlags: TParamFlags;
  i: Integer;
begin
  TypeData:=GetTypeData(GetPropInfo(Self,'MyEvent')^.PropType);
  ParamCount:=TypeData^.ParamCount;
  Offset:=0;

  i:=0;
//  for i:=0 to ParamCount-1 do begin

    CurFlags := PParamFlags(@TypeData^.ParamList[0])^;
    // SizeOf(TParamFlags) is 4, but the data is only 1 byte
    //Len:=1; // typinfo.pp comment is wrong: SizeOf(TParamFlags)
    // Note by SB (2017-01-08): No longer true since typinfo uses packed sets
    Len:=SizeOf(TParamFlags);
    inc(Offset,Len);

    // read ParamName
    Len:=ord(TypeData^.ParamList[Offset]);
    SetLength(CurParamName,Len);
    if Len>0 then
      Move(TypeData^.ParamList[Offset+1],CurParamName[1],Len);
    inc(Offset,Len+1);

    // read ParamType
    Len:=ord(TypeData^.ParamList[Offset]);
    SetLength(CurTypeIdentifier,Len);
    if CurTypeIdentifier<>'' then
      Move(TypeData^.ParamList[Offset+1],CurTypeIdentifier[1],Len);
    inc(Offset,Len+1);

    writeln('Param ',i+1,'/',ParamCount,' ',CurParamName,':',CurTypeIdentifier);
    // Note by SB (2019-10-08): The first parameter might now be the hidden $self
    if ((pfSelf in CurFlags) and ((CurParamName<>'$self')  or (CurTypeIdentifier<>'Pointer'))) or
       (not (pfSelf in CurFlags) and ((CurParamName<>'Sender')  or (CurTypeIdentifier<>'TObject'))) then
      begin
        writeln('ERROR!');
        halt(1);
      end;

//  end;
end;

var
  MyClass: TMyClass;
begin
  MyClass:=TMyClass.Create;
  MyClass.ShowRTTI;
end.
