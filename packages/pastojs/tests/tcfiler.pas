{
    This file is part of the Free Component Library (FCL)
    Copyright (c) 2014 by Michael Van Canneyt

    Unit tests for Pascal-to-Javascript precompile class.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************

 Examples:
   ./testpas2js --suite=TTestPrecompile.TestPC_EmptyUnit
}
unit tcfiler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry,
  PasTree, PScanner, PasResolver, PasResolveEval, PParser,
  FPPas2Js, Pas2JsFiler,
  tcmodules;

type

  { TCustomTestPrecompile }

  TCustomTestPrecompile = Class(TCustomTestModule)
  private
    FInitialFlags: TPJUInitialFlags;
    FPJUReader: TPJUReader;
    FPJUWriter: TPJUWriter;
    procedure OnFilerGetSrc(Sender: TObject; aFilename: string; out p: PChar;
      out Count: integer);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure WriteReadUnit; virtual;
    procedure StartParsing; override;
    procedure CheckRestoredResolver(Original, Restored: TPas2JSResolver); virtual;
    procedure CheckRestoredDeclarations(const Path: string; Orig, Rest: TPasDeclarations); virtual;
    procedure CheckRestoredSection(const Path: string; Orig, Rest: TPasSection); virtual;
    procedure CheckRestoredModule(const Path: string; Orig, Rest: TPasModule); virtual;
    procedure CheckRestoredModuleScope(const Path: string; Orig, Rest: TPasModuleScope); virtual;
    procedure CheckRestoredIdentifierScope(const Path: string; Orig, Rest: TPasIdentifierScope); virtual;
    procedure CheckRestoredSectionScope(const Path: string; Orig, Rest: TPasSectionScope); virtual;
    procedure CheckRestoredCustomData(const Path: string; El: TPasElement; Orig, Rest: TObject); virtual;
    procedure CheckRestoredElement(const Path: string; Orig, Rest: TPasElement); virtual;
    procedure CheckRestoredElementList(const Path: string; Orig, Rest: TFPList); virtual;
    procedure CheckRestoredPasExpr(const Path: string; Orig, Rest: TPasExpr); virtual;
    procedure CheckRestoredUnaryExpr(const Path: string; Orig, Rest: TUnaryExpr); virtual;
    procedure CheckRestoredBinaryExpr(const Path: string; Orig, Rest: TBinaryExpr); virtual;
    procedure CheckRestoredPrimitiveExpr(const Path: string; Orig, Rest: TPrimitiveExpr); virtual;
    procedure CheckRestoredBoolConstExpr(const Path: string; Orig, Rest: TBoolConstExpr); virtual;
    procedure CheckRestoredParamsExpr(const Path: string; Orig, Rest: TParamsExpr); virtual;
    procedure CheckRestoredRecordValues(const Path: string; Orig, Rest: TRecordValues); virtual;
    procedure CheckRestoredPasExprArray(const Path: string; Orig, Rest: TPasExprArray); virtual;
    procedure CheckRestoredArrayValues(const Path: string; Orig, Rest: TArrayValues); virtual;
    procedure CheckRestoredResString(const Path: string; Orig, Rest: TPasResString); virtual;
    procedure CheckRestoredAliasType(const Path: string; Orig, Rest: TPasAliasType); virtual;
    procedure CheckRestoredPointerType(const Path: string; Orig, Rest: TPasPointerType); virtual;
    procedure CheckRestoredSpecializedType(const Path: string; Orig, Rest: TPasSpecializeType); virtual;
    procedure CheckRestoredInlineSpecializedExpr(const Path: string; Orig, Rest: TInlineSpecializeExpr); virtual;
    procedure CheckRestoredRangeType(const Path: string; Orig, Rest: TPasRangeType); virtual;
    procedure CheckRestoredArrayType(const Path: string; Orig, Rest: TPasArrayType); virtual;
    procedure CheckRestoredFileType(const Path: string; Orig, Rest: TPasFileType); virtual;
    procedure CheckRestoredEnumValue(const Path: string; Orig, Rest: TPasEnumValue); virtual;
    procedure CheckRestoredEnumType(const Path: string; Orig, Rest: TPasEnumType); virtual;
    procedure CheckRestoredSetType(const Path: string; Orig, Rest: TPasSetType); virtual;
    procedure CheckRestoredVariant(const Path: string; Orig, Rest: TPasVariant); virtual;
    procedure CheckRestoredRecordType(const Path: string; Orig, Rest: TPasRecordType); virtual;
    procedure CheckRestoredClassType(const Path: string; Orig, Rest: TPasClassType); virtual;
    procedure CheckRestoredArgument(const Path: string; Orig, Rest: TPasArgument); virtual;
    procedure CheckRestoredProcedureType(const Path: string; Orig, Rest: TPasProcedureType); virtual;
    procedure CheckRestoredResultElement(const Path: string; Orig, Rest: TPasResultElement); virtual;
    procedure CheckRestoredFunctionType(const Path: string; Orig, Rest: TPasFunctionType); virtual;
    procedure CheckRestoredStringType(const Path: string; Orig, Rest: TPasStringType); virtual;
    procedure CheckRestoredVariable(const Path: string; Orig, Rest: TPasVariable); virtual;
    procedure CheckRestoredExportSymbol(const Path: string; Orig, Rest: TPasExportSymbol); virtual;
    procedure CheckRestoredConst(const Path: string; Orig, Rest: TPasConst); virtual;
    procedure CheckRestoredProperty(const Path: string; Orig, Rest: TPasProperty); virtual;
    procedure CheckRestoredProcedure(const Path: string; Orig, Rest: TPasProcedure); virtual;
    procedure CheckRestoredOperator(const Path: string; Orig, Rest: TPasOperator); virtual;
    procedure CheckRestoredReference(const Path: string; Orig, Rest: TPasElement); virtual;
  public
    property PJUWriter: TPJUWriter read FPJUWriter write FPJUWriter;
    property PJUReader: TPJUReader read FPJUReader write FPJUReader;
    property InitialFlags: TPJUInitialFlags read FInitialFlags;
  end;

  { TTestPrecompile }

  TTestPrecompile = class(TCustomTestPrecompile)
  published
    procedure Test_Base256VLQ;
    procedure TestPC_EmptyUnit;

    procedure TestPC_Const;
  end;

implementation

{ TCustomTestPrecompile }

procedure TCustomTestPrecompile.OnFilerGetSrc(Sender: TObject;
  aFilename: string; out p: PChar; out Count: integer);
var
  i: Integer;
  aModule: TTestEnginePasResolver;
  Src: String;
begin
  for i:=0 to ResolverCount-1 do
    begin
    aModule:=Resolvers[i];
    if aModule.Filename<>aFilename then continue;
    Src:=aModule.Source;
    p:=PChar(Src);
    Count:=length(Src);
    end;
end;

procedure TCustomTestPrecompile.SetUp;
begin
  inherited SetUp;
  FInitialFlags:=TPJUInitialFlags.Create;
end;

procedure TCustomTestPrecompile.TearDown;
begin
  FreeAndNil(FPJUWriter);
  FreeAndNil(FPJUReader);
  FreeAndNil(FInitialFlags);
  inherited TearDown;
end;

procedure TCustomTestPrecompile.WriteReadUnit;
var
  ms: TMemoryStream;
  PJU: string;
  ReadResolver: TTestEnginePasResolver;
  ReadFileResolver: TFileResolver;
  ReadScanner: TPascalScanner;
  ReadParser: TPasParser;
begin
  ConvertUnit;

  FPJUWriter:=TPJUWriter.Create;
  FPJUReader:=TPJUReader.Create;
  ms:=TMemoryStream.Create;
  ReadParser:=nil;
  ReadScanner:=nil;
  ReadResolver:=nil;
  ReadFileResolver:=nil;
  try
    try
      PJUWriter.OnGetSrc:=@OnFilerGetSrc;
      PJUWriter.WritePJU(Engine,InitialFlags,ms);
    except
      on E: Exception do
      begin
        {$IFDEF VerbosePas2JS}
        writeln('TCustomTestPrecompile.WriteReadUnit WRITE failed');
        {$ENDIF}
        Fail('Write failed('+E.ClassName+'): '+E.Message);
      end;
    end;

    try
      SetLength(PJU,ms.Size);
      System.Move(ms.Memory^,PJU[1],length(PJU));

      writeln('TCustomTestPrecompile.WriteReadUnit PJU START-----');
      writeln(PJU);
      writeln('TCustomTestPrecompile.WriteReadUnit PJU END-------');

      ReadFileResolver:=TFileResolver.Create;
      ReadScanner:=TPascalScanner.Create(ReadFileResolver);
      InitScanner(ReadScanner);
      ReadResolver:=TTestEnginePasResolver.Create;
      ReadResolver.Filename:=Engine.Filename;
      ReadResolver.AddObjFPCBuiltInIdentifiers(btAllJSBaseTypes,bfAllJSBaseProcs);
      //ReadResolver.OnFindUnit:=@OnPasResolverFindUnit;
      ReadParser:=TPasParser.Create(ReadScanner,ReadFileResolver,ReadResolver);
      ReadParser.Options:=po_tcmodules;
      ReadResolver.CurrentParser:=ReadParser;
      ms.Position:=0;
      PJUReader.ReadPJU(ReadResolver,ms);
    except
      on E: Exception do
      begin
        {$IFDEF VerbosePas2JS}
        writeln('TCustomTestPrecompile.WriteReadUnit READ failed');
        {$ENDIF}
        Fail('Read failed('+E.ClassName+'): '+E.Message);
      end;
    end;

    CheckRestoredResolver(Engine,ReadResolver);
  finally
    ReadParser.Free;
    ReadScanner.Free;
    ReadResolver.Free; // free parser before resolver
    ReadFileResolver.Free;
    ms.Free;
  end;
end;

procedure TCustomTestPrecompile.StartParsing;
begin
  inherited StartParsing;
  FInitialFlags.ParserOptions:=Parser.Options;
  FInitialFlags.ModeSwitches:=Scanner.CurrentModeSwitches;
  FInitialFlags.BoolSwitches:=Scanner.CurrentBoolSwitches;
  FInitialFlags.ConverterOptions:=Converter.Options;
  FInitialFlags.TargetPlatform:=Converter.TargetPlatform;
  FInitialFlags.TargetProcessor:=Converter.TargetProcessor;
  // ToDo: defines
end;

procedure TCustomTestPrecompile.CheckRestoredResolver(Original,
  Restored: TPas2JSResolver);
begin
  AssertNotNull('CheckRestoredResolver Original',Original);
  AssertNotNull('CheckRestoredResolver Restored',Restored);
  if Original.ClassType<>Restored.ClassType then
    Fail('CheckRestoredResolver Original='+Original.ClassName+' Restored='+Restored.ClassName);
  CheckRestoredElement('RootElement',Original.RootElement,Restored.RootElement);
end;

procedure TCustomTestPrecompile.CheckRestoredDeclarations(const Path: string;
  Orig, Rest: TPasDeclarations);
var
  i: Integer;
  OrigDecl, RestDecl: TPasElement;
  SubPath: String;
begin
  for i:=0 to Orig.Declarations.Count-1 do
    begin
    OrigDecl:=TPasElement(Orig.Declarations[i]);
    if i>=Rest.Declarations.Count then
      AssertEquals(Path+': Declarations.Count',Orig.Declarations.Count,Rest.Declarations.Count);
    RestDecl:=TPasElement(Rest.Declarations[i]);
    SubPath:=Path+'['+IntToStr(i)+']';
    if OrigDecl.Name<>'' then
      SubPath:=SubPath+'"'+OrigDecl.Name+'"'
    else
      SubPath:=SubPath+'?noname?';
    CheckRestoredElement(SubPath,OrigDecl,RestDecl);
    end;
  AssertEquals(Path+': Declarations.Count',Orig.Declarations.Count,Rest.Declarations.Count);
end;

procedure TCustomTestPrecompile.CheckRestoredSection(const Path: string; Orig,
  Rest: TPasSection);
begin
  if length(Orig.UsesClause)>0 then
    ; // ToDo
  CheckRestoredDeclarations(Path,Rest,Orig);
end;

procedure TCustomTestPrecompile.CheckRestoredModule(const Path: string; Orig,
  Rest: TPasModule);
begin
  if not (Orig.CustomData is TPasModuleScope) then
    Fail(Path+'.CustomData is not TPasModuleScope'+GetObjName(Orig.CustomData));

  CheckRestoredElement(Path+'.InterfaceSection',Orig.InterfaceSection,Rest.InterfaceSection);
  CheckRestoredElement(Path+'.ImplementationSection',Orig.ImplementationSection,Rest.ImplementationSection);
  if Orig is TPasProgram then
    CheckRestoredElement(Path+'.ProgramSection',TPasProgram(Orig).ProgramSection,TPasProgram(Rest).ProgramSection)
  else if Orig is TPasLibrary then
    CheckRestoredElement(Path+'.LibrarySection',TPasLibrary(Orig).LibrarySection,TPasLibrary(Rest).LibrarySection);
  CheckRestoredElement(Path+'.InitializationSection',Orig.InitializationSection,Rest.InitializationSection);
  CheckRestoredElement(Path+'.FinalizationSection',Orig.FinalizationSection,Rest.FinalizationSection);
end;

procedure TCustomTestPrecompile.CheckRestoredModuleScope(const Path: string;
  Orig, Rest: TPasModuleScope);
begin
  AssertEquals(Path+': FirstName',Orig.FirstName,Rest.FirstName);
  if Orig.Flags<>Rest.Flags then
    Fail(Path+': Flags');
  if Orig.BoolSwitches<>Rest.BoolSwitches then
    Fail(Path+': BoolSwitches');
  CheckRestoredReference(Path+'.AssertClass',Orig.AssertClass,Rest.AssertClass);
  CheckRestoredReference(Path+'.AssertDefConstructor',Orig.AssertDefConstructor,Rest.AssertDefConstructor);
  CheckRestoredReference(Path+'.AssertMsgConstructor',Orig.AssertMsgConstructor,Rest.AssertMsgConstructor);
  CheckRestoredReference(Path+'.RangeErrorClass',Orig.RangeErrorClass,Rest.RangeErrorClass);
  CheckRestoredReference(Path+'.RangeErrorConstructor',Orig.RangeErrorConstructor,Rest.RangeErrorConstructor);
end;

procedure TCustomTestPrecompile.CheckRestoredIdentifierScope(
  const Path: string; Orig, Rest: TPasIdentifierScope);
var
  OrigList: TFPList;
  i: Integer;
  OrigIdentifier, RestIdentifier: TPasIdentifier;
begin
  OrigList:=nil;
  try
    OrigList:=Orig.GetLocalIdentifiers;
    for i:=0 to OrigList.Count-1 do
    begin
      OrigIdentifier:=TPasIdentifier(OrigList[i]);
      RestIdentifier:=Rest.FindLocalIdentifier(OrigIdentifier.Identifier);
      if RestIdentifier=nil then
        Fail(Path+'.Local['+OrigIdentifier.Identifier+'] Missing RestIdentifier Orig='+OrigIdentifier.Identifier);
      repeat
        AssertEquals(Path+'.Local.Identifier',OrigIdentifier.Identifier,RestIdentifier.Identifier);
        CheckRestoredReference(Path+'.Local',OrigIdentifier.Element,RestIdentifier.Element);
        if OrigIdentifier.Kind<>RestIdentifier.Kind then
          Fail(Path+'.Local['+OrigIdentifier.Identifier+'] Orig='+PJUIdentifierKindNames[OrigIdentifier.Kind]+' Rest='+PJUIdentifierKindNames[RestIdentifier.Kind]);
        if OrigIdentifier.NextSameIdentifier=nil then
        begin
          if RestIdentifier.NextSameIdentifier<>nil then
            Fail(Path+'.Local['+OrigIdentifier.Identifier+'] Too many RestIdentifier.NextSameIdentifier='+GetObjName(RestIdentifier.Element));
          break;
        end
        else begin
          if RestIdentifier.NextSameIdentifier=nil then
            Fail(Path+'.Local['+OrigIdentifier.Identifier+'] Missing RestIdentifier.NextSameIdentifier Orig='+GetObjName(OrigIdentifier.NextSameIdentifier.Element));
        end;
        if CompareText(OrigIdentifier.Identifier,OrigIdentifier.NextSameIdentifier.Identifier)<>0 then
          Fail(Path+'.Local['+OrigIdentifier.Identifier+'] Cur.Identifier<>Next.Identifier '+OrigIdentifier.Identifier+'<>'+OrigIdentifier.NextSameIdentifier.Identifier);
        OrigIdentifier:=OrigIdentifier.NextSameIdentifier;
        RestIdentifier:=RestIdentifier.NextSameIdentifier;
      until false;
    end;
  finally
    OrigList.Free;
  end;
end;

procedure TCustomTestPrecompile.CheckRestoredSectionScope(const Path: string;
  Orig, Rest: TPasSectionScope);
var
  i: Integer;
  OrigUses, RestUses: TPasSectionScope;
begin
  AssertEquals(Path+' UsesScopes.Count',Orig.UsesScopes.Count,Rest.UsesScopes.Count);
  for i:=0 to Orig.UsesScopes.Count-1 do
    begin
    OrigUses:=TPasSectionScope(Orig.UsesScopes[i]);
    if not (TObject(Rest.UsesScopes[i]) is TPasSectionScope) then
      Fail(Path+': Uses['+IntToStr(i)+'] Rest='+GetObjName(TObject(Rest.UsesScopes[i])));
    RestUses:=TPasSectionScope(Rest.UsesScopes[i]);
    if OrigUses.ClassType<>RestUses.ClassType then
      Fail(Path+': Uses['+IntToStr(i)+'] Orig='+GetObjName(OrigUses)+' Rest='+GetObjName(RestUses));
    CheckRestoredReference(Path+': Uses['+IntToStr(i)+']',OrigUses.Element,RestUses.Element);
    end;
  AssertEquals(Path+': Finished',Orig.Finished,Rest.Finished);
  CheckRestoredIdentifierScope(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredCustomData(const Path: string;
  El: TPasElement; Orig, Rest: TObject);
var
  C: TClass;
begin
  if Orig=nil then
    begin
    if Rest<>nil then
      Fail(Path+': Orig=nil Rest='+GetObjName(Rest));
    exit;
    end
  else if Rest=nil then
    Fail(Path+': Orig='+GetObjName(Orig)+' Rest=nil');
  if Orig.ClassType<>Rest.ClassType then
    Fail(Path+': Orig='+GetObjName(Orig)+' Rest='+GetObjName(Rest));

  C:=Orig.ClassType;
  if C=TPasModuleScope then
    CheckRestoredModuleScope(Path+'[TPasModuleScope]',TPasModuleScope(Orig),TPasModuleScope(Rest))
  else if C=TPasSectionScope then
    CheckRestoredSectionScope(Path+'[TPasSectionScope]',TPasSectionScope(Orig),TPasSectionScope(Rest))
  else
    Fail(Path+': unknown CustomData "'+GetObjName(Orig)+'" El='+GetObjName(El));
end;

procedure TCustomTestPrecompile.CheckRestoredElement(const Path: string; Orig,
  Rest: TPasElement);
var
  C: TClass;
begin
  if Orig=nil then
    begin
    if Rest<>nil then
      Fail(Path+': Orig=nil Rest='+GetObjName(Rest));
    exit;
    end
  else if Rest=nil then
    Fail(Path+': Orig='+GetObjName(Orig)+' Rest=nil');
  if Orig.ClassType<>Rest.ClassType then
    Fail(Path+': Orig='+GetObjName(Orig)+' Rest='+GetObjName(Rest));

  AssertEquals(Path+': Name',Orig.Name,Rest.Name);
  AssertEquals(Path+': SourceFilename',Orig.SourceFilename,Rest.SourceFilename);
  AssertEquals(Path+': SourceLinenumber',Orig.SourceLinenumber,Rest.SourceLinenumber);
  //AssertEquals(Path+': SourceEndLinenumber',Orig.SourceEndLinenumber,Rest.SourceEndLinenumber);
  if Orig.Visibility<>Rest.Visibility then
    Fail(Path+': Visibility '+PJUMemberVisibilityNames[Orig.Visibility]+' '+PJUMemberVisibilityNames[Rest.Visibility]);
  if Orig.Hints<>Rest.Hints then
    Fail(Path+': Hints');
  AssertEquals(Path+': HintMessage',Orig.HintMessage,Rest.HintMessage);

  if Orig.Parent=nil then
    begin
    if Rest.Parent<>nil then
      Fail(Path+': Orig.Parent=nil Rest.Parent='+GetObjName(Rest.Parent));
    end
  else if Rest.Parent=nil then
    Fail(Path+': Orig.Parent='+GetObjName(Orig.Parent)+' Rest.Parent=nil')
  else if Orig.Parent.ClassType<>Rest.Parent.ClassType then
    Fail(Path+': Orig.Parent='+GetObjName(Orig.Parent)+' Rest.Parent='+GetObjName(Rest.Parent));

  CheckRestoredCustomData(Path+'.CustomData',Rest,Orig.CustomData,Rest.CustomData);

  C:=Orig.ClassType;
  if C=TUnaryExpr then
    CheckRestoredUnaryExpr(Path,TUnaryExpr(Orig),TUnaryExpr(Rest))
  else if C=TBinaryExpr then
    CheckRestoredBinaryExpr(Path,TBinaryExpr(Orig),TBinaryExpr(Rest))
  else if C=TPrimitiveExpr then
    CheckRestoredPrimitiveExpr(Path,TPrimitiveExpr(Orig),TPrimitiveExpr(Rest))
  else if C=TBoolConstExpr then
    CheckRestoredBoolConstExpr(Path,TBoolConstExpr(Orig),TBoolConstExpr(Rest))
  else if (C=TNilExpr)
      or (C=TInheritedExpr)
      or (C=TSelfExpr) then
    CheckRestoredPasExpr(Path,TPasExpr(Orig),TPasExpr(Rest))
  else if C=TParamsExpr then
    CheckRestoredParamsExpr(Path,TParamsExpr(Orig),TParamsExpr(Rest))
  else if C=TRecordValues then
    CheckRestoredRecordValues(Path,TRecordValues(Orig),TRecordValues(Rest))
  else if C=TArrayValues then
    CheckRestoredArrayValues(Path,TArrayValues(Orig),TArrayValues(Rest))
  // TPasDeclarations is a base class
  // TPasUsesUnit is checked in usesclause
  // TPasSection is a base class
  else if C=TPasResString then
    CheckRestoredResString(Path,TPasResString(Orig),TPasResString(Rest))
  // TPasType is a base clas
  else if (C=TPasAliasType)
      or (C=TPasTypeAliasType)
      or (C=TPasClassOfType) then
    CheckRestoredAliasType(Path,TPasAliasType(Orig),TPasAliasType(Rest))
  else if C=TPasPointerType then
    CheckRestoredPointerType(Path,TPasPointerType(Orig),TPasPointerType(Rest))
  else if C=TPasSpecializeType then
    CheckRestoredSpecializedType(Path,TPasSpecializeType(Orig),TPasSpecializeType(Rest))
  else if C=TInlineSpecializeExpr then
    CheckRestoredInlineSpecializedExpr(Path,TInlineSpecializeExpr(Orig),TInlineSpecializeExpr(Rest))
  else if C=TPasRangeType then
    CheckRestoredRangeType(Path,TPasRangeType(Orig),TPasRangeType(Rest))
  else if C=TPasArrayType then
    CheckRestoredArrayType(Path,TPasArrayType(Orig),TPasArrayType(Rest))
  else if C=TPasFileType then
    CheckRestoredFileType(Path,TPasFileType(Orig),TPasFileType(Rest))
  else if C=TPasEnumValue then
    CheckRestoredEnumValue(Path,TPasEnumValue(Orig),TPasEnumValue(Rest))
  else if C=TPasEnumType then
    CheckRestoredEnumType(Path,TPasEnumType(Orig),TPasEnumType(Rest))
  else if C=TPasSetType then
    CheckRestoredSetType(Path,TPasSetType(Orig),TPasSetType(Rest))
  else if C=TPasVariant then
    CheckRestoredVariant(Path,TPasVariant(Orig),TPasVariant(Rest))
  else if C=TPasRecordType then
    CheckRestoredRecordType(Path,TPasRecordType(Orig),TPasRecordType(Rest))
  else if C=TPasClassType then
    CheckRestoredClassType(Path,TPasClassType(Orig),TPasClassType(Rest))
  else if C=TPasArgument then
    CheckRestoredArgument(Path,TPasArgument(Orig),TPasArgument(Rest))
  else if C=TPasProcedureType then
    CheckRestoredProcedureType(Path,TPasProcedureType(Orig),TPasProcedureType(Rest))
  else if C=TPasResultElement then
    CheckRestoredResultElement(Path,TPasResultElement(Orig),TPasResultElement(Rest))
  else if C=TPasFunctionType then
    CheckRestoredFunctionType(Path,TPasFunctionType(Orig),TPasFunctionType(Rest))
  else if C=TPasStringType then
    CheckRestoredStringType(Path,TPasStringType(Orig),TPasStringType(Rest))
  else if C=TPasVariable then
    CheckRestoredVariable(Path,TPasVariable(Orig),TPasVariable(Rest))
  else if C=TPasExportSymbol then
    CheckRestoredExportSymbol(Path,TPasExportSymbol(Orig),TPasExportSymbol(Rest))
  else if C=TPasConst then
    CheckRestoredConst(Path,TPasConst(Orig),TPasConst(Rest))
  else if C=TPasProperty then
    CheckRestoredProperty(Path,TPasProperty(Orig),TPasProperty(Rest))
  else if (C=TPasProcedure)
      or (C=TPasFunction)
      or (C=TPasConstructor)
      or (C=TPasClassConstructor)
      or (C=TPasDestructor)
      or (C=TPasClassDestructor)
      or (C=TPasClassProcedure)
      or (C=TPasClassFunction)
      then
    CheckRestoredProcedure(Path,TPasProcedure(Orig),TPasProcedure(Rest))
  else if (C=TPasOperator)
      or (C=TPasClassOperator) then
    CheckRestoredOperator(Path,TPasOperator(Orig),TPasOperator(Rest))
  else if (C=TPasModule)
        or (C=TPasProgram)
        or (C=TPasLibrary) then
    CheckRestoredModule(Path,TPasModule(Orig),TPasModule(Rest))
  else if C.InheritsFrom(TPasSection) then
    CheckRestoredSection(Path,TPasSection(Orig),TPasSection(Rest))
  else
    Fail(Path+': unknown class '+C.ClassName);
end;

procedure TCustomTestPrecompile.CheckRestoredElementList(const Path: string;
  Orig, Rest: TFPList);
var
  OrigItem, RestItem: TObject;
  i: Integer;
  SubPath: String;
begin
  if Orig=nil then
    begin
    if Rest=nil then
      exit;
    Fail(Path+' Orig=nil Rest='+GetObjName(Rest));
    end
  else if Rest=nil then
    Fail(Path+' Orig='+GetObjName(Orig)+' Rest=nil')
  else if Orig.ClassType<>Rest.ClassType then
    Fail(Path+' Orig='+GetObjName(Orig)+' Rest='+GetObjName(Rest));
  AssertEquals(Path+'.Count',Orig.Count,Rest.Count);
  for i:=0 to Orig.Count-1 do
    begin
    SubPath:=Path+'['+IntToStr(i)+']';
    OrigItem:=TObject(Orig[i]);
    if not (OrigItem is TPasElement) then
      Fail(SubPath+' Orig='+GetObjName(OrigItem));
    RestItem:=TObject(Rest[i]);
    if not (RestItem is TPasElement) then
      Fail(SubPath+' Rest='+GetObjName(RestItem));
    CheckRestoredElement(SubPath,TPasElement(OrigItem),TPasElement(RestItem));
    end;
end;

procedure TCustomTestPrecompile.CheckRestoredPasExpr(const Path: string; Orig,
  Rest: TPasExpr);
begin
  if Orig.Kind<>Rest.Kind then
    Fail(Path+'.Kind');
  if Orig.OpCode<>Rest.OpCode then
    Fail(Path+'.OpCode');
  CheckRestoredElement(Path+'.Format1',Orig.format1,Rest.format1);
  CheckRestoredElement(Path+'.Format2',Orig.format2,Rest.format2);
end;

procedure TCustomTestPrecompile.CheckRestoredUnaryExpr(const Path: string;
  Orig, Rest: TUnaryExpr);
begin
  CheckRestoredElement(Path+'.Operand',Orig.Operand,Rest.Operand);
  CheckRestoredPasExpr(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredBinaryExpr(const Path: string;
  Orig, Rest: TBinaryExpr);
begin
  CheckRestoredElement(Path+'.left',Orig.left,Rest.left);
  CheckRestoredElement(Path+'.right',Orig.right,Rest.right);
  CheckRestoredPasExpr(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredPrimitiveExpr(const Path: string;
  Orig, Rest: TPrimitiveExpr);
begin
  AssertEquals(Path+'.Value',Orig.Value,Rest.Value);
  CheckRestoredPasExpr(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredBoolConstExpr(const Path: string;
  Orig, Rest: TBoolConstExpr);
begin
  AssertEquals(Path+'.Value',Orig.Value,Rest.Value);
  CheckRestoredPasExpr(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredParamsExpr(const Path: string;
  Orig, Rest: TParamsExpr);
begin
  CheckRestoredElement(Path+'.Value',Orig.Value,Rest.Value);
  CheckRestoredPasExprArray(Path+'.Params',Orig.Params,Rest.Params);
  CheckRestoredPasExpr(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredRecordValues(const Path: string;
  Orig, Rest: TRecordValues);
var
  i: Integer;
begin
  AssertEquals(Path+'.Fields.length',length(Orig.Fields),length(Rest.Fields));
  for i:=0 to length(Orig.Fields)-1 do
    begin
    AssertEquals(Path+'.Field['+IntToStr(i)+'].Name',Orig.Fields[i].Name,Rest.Fields[i].Name);
    CheckRestoredElement(Path+'.Field['+IntToStr(i)+'].ValueExp',Orig.Fields[i].ValueExp,Rest.Fields[i].ValueExp);
    end;
  CheckRestoredPasExpr(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredPasExprArray(const Path: string;
  Orig, Rest: TPasExprArray);
var
  i: Integer;
begin
  AssertEquals(Path+'.length',length(Orig),length(Rest));
  for i:=0 to length(Orig)-1 do
    CheckRestoredElement(Path+'['+IntToStr(i)+']',Orig[i],Rest[i]);
end;

procedure TCustomTestPrecompile.CheckRestoredArrayValues(const Path: string;
  Orig, Rest: TArrayValues);
begin
  CheckRestoredPasExprArray(Path+'.Values',Orig.Values,Rest.Values);
  CheckRestoredPasExpr(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredResString(const Path: string;
  Orig, Rest: TPasResString);
begin
  CheckRestoredElement(Path+'.Expr',Orig.Expr,Rest.Expr);
end;

procedure TCustomTestPrecompile.CheckRestoredAliasType(const Path: string;
  Orig, Rest: TPasAliasType);
begin
  CheckRestoredElement(Path+'.DestType',Orig.DestType,Rest.DestType);
  CheckRestoredElement(Path+'.Expr',Orig.Expr,Rest.Expr);
end;

procedure TCustomTestPrecompile.CheckRestoredPointerType(const Path: string;
  Orig, Rest: TPasPointerType);
begin
  CheckRestoredElement(Path+'.DestType',Orig.DestType,Rest.DestType);
end;

procedure TCustomTestPrecompile.CheckRestoredSpecializedType(
  const Path: string; Orig, Rest: TPasSpecializeType);
begin
  CheckRestoredElementList(Path+'.Params',Orig.Params,Rest.Params);
  CheckRestoredElement(Path+'.DestType',Orig.DestType,Rest.DestType);
end;

procedure TCustomTestPrecompile.CheckRestoredInlineSpecializedExpr(
  const Path: string; Orig, Rest: TInlineSpecializeExpr);
begin
  CheckRestoredElement(Path+'.DestType',Orig.DestType,Rest.DestType);
end;

procedure TCustomTestPrecompile.CheckRestoredRangeType(const Path: string;
  Orig, Rest: TPasRangeType);
begin
  CheckRestoredElement(Path+'.RangeExpr',Orig.RangeExpr,Rest.RangeExpr);
end;

procedure TCustomTestPrecompile.CheckRestoredArrayType(const Path: string;
  Orig, Rest: TPasArrayType);
begin
  CheckRestoredPasExprArray(Path+'.Ranges',Orig.Ranges,Rest.Ranges);
  if Orig.PackMode<>Rest.PackMode then
    Fail(Path+'.PackMode Orig='+PJUPackModeNames[Orig.PackMode]+' Rest='+PJUPackModeNames[Rest.PackMode]);
  CheckRestoredElement(Path+'.ElType',Orig.ElType,Rest.ElType);
end;

procedure TCustomTestPrecompile.CheckRestoredFileType(const Path: string; Orig,
  Rest: TPasFileType);
begin
  CheckRestoredElement(Path+'.ElType',Orig.ElType,Rest.ElType);
end;

procedure TCustomTestPrecompile.CheckRestoredEnumValue(const Path: string;
  Orig, Rest: TPasEnumValue);
begin
  CheckRestoredElement(Path+'.Value',Orig.Value,Rest.Value);
end;

procedure TCustomTestPrecompile.CheckRestoredEnumType(const Path: string; Orig,
  Rest: TPasEnumType);
begin
  CheckRestoredElementList(Path+'.Values',Orig.Values,Rest.Values);
end;

procedure TCustomTestPrecompile.CheckRestoredSetType(const Path: string; Orig,
  Rest: TPasSetType);
begin
  CheckRestoredElement(Path+'.EnumType',Orig.EnumType,Rest.EnumType);
  AssertEquals(Path+'.IsPacked',Orig.IsPacked,Rest.IsPacked);
end;

procedure TCustomTestPrecompile.CheckRestoredVariant(const Path: string; Orig,
  Rest: TPasVariant);
begin
  CheckRestoredElementList(Path+'.Values',Orig.Values,Rest.Values);
  CheckRestoredElement(Path+'.Members',Orig.Members,Rest.Members);
end;

procedure TCustomTestPrecompile.CheckRestoredRecordType(const Path: string;
  Orig, Rest: TPasRecordType);
begin
  if Orig.PackMode<>Rest.PackMode then
    Fail(Path+'.PackMode Orig='+PJUPackModeNames[Orig.PackMode]+' Rest='+PJUPackModeNames[Rest.PackMode]);
  CheckRestoredElementList(Path+'.Members',Orig.Members,Rest.Members);
  CheckRestoredElement(Path+'.VariantEl',Orig.VariantEl,Rest.VariantEl);
  CheckRestoredElementList(Path+'.Variants',Orig.Variants,Rest.Variants);
  CheckRestoredElementList(Path+'.GenericTemplateTypes',Orig.GenericTemplateTypes,Rest.GenericTemplateTypes);
end;

procedure TCustomTestPrecompile.CheckRestoredClassType(const Path: string;
  Orig, Rest: TPasClassType);
begin
  if Orig.PackMode<>Rest.PackMode then
    Fail(Path+'.PackMode Orig='+PJUPackModeNames[Orig.PackMode]+' Rest='+PJUPackModeNames[Rest.PackMode]);
  if Orig.ObjKind<>Rest.ObjKind then
    Fail(Path+'.ObjKind Orig='+PJUObjKindNames[Orig.ObjKind]+' Rest='+PJUObjKindNames[Rest.ObjKind]);
  CheckRestoredElement(Path+'.AncestorType',Orig.AncestorType,Rest.AncestorType);
  CheckRestoredElement(Path+'.HelperForType',Orig.HelperForType,Rest.HelperForType);
  AssertEquals(Path+'.IsForward',Orig.IsForward,Rest.IsForward);
  AssertEquals(Path+'.IsExternal',Orig.IsExternal,Rest.IsExternal);
  // irrelevant: IsShortDefinition
  CheckRestoredElement(Path+'.GUIDExpr',Orig.GUIDExpr,Rest.GUIDExpr);
  CheckRestoredElementList(Path+'.Members',Orig.Members,Rest.Members);
  AssertEquals(Path+'.Modifiers',Orig.Modifiers.Text,Rest.Modifiers.Text);
  CheckRestoredElementList(Path+'.Interfaces',Orig.Interfaces,Rest.Interfaces);
  CheckRestoredElementList(Path+'.GenericTemplateTypes',Orig.GenericTemplateTypes,Rest.GenericTemplateTypes);
  AssertEquals(Path+'.ExternalNameSpace',Orig.ExternalNameSpace,Rest.ExternalNameSpace);
  AssertEquals(Path+'.ExternalName',Orig.ExternalName,Rest.ExternalName);
end;

procedure TCustomTestPrecompile.CheckRestoredArgument(const Path: string; Orig,
  Rest: TPasArgument);
begin
  if Orig.Access<>Rest.Access then
    Fail(Path+'.Access Orig='+PJUArgumentAccessNames[Orig.Access]+' Rest='+PJUArgumentAccessNames[Rest.Access]);
  CheckRestoredElement(Path+'.ArgType',Orig.ArgType,Rest.ArgType);
  CheckRestoredElement(Path+'.ValueExpr',Orig.ValueExpr,Rest.ValueExpr);
end;

procedure TCustomTestPrecompile.CheckRestoredProcedureType(const Path: string;
  Orig, Rest: TPasProcedureType);
begin
  CheckRestoredElementList(Path+'.Args',Orig.Args,Rest.Args);
  if Orig.CallingConvention<>Rest.CallingConvention then
    Fail(Path+'.CallingConvention Orig='+PJUCallingConventionNames[Orig.CallingConvention]+' Rest='+PJUCallingConventionNames[Rest.CallingConvention]);
  if Orig.Modifiers<>Rest.Modifiers then
    Fail(Path+'.Modifiers');
end;

procedure TCustomTestPrecompile.CheckRestoredResultElement(const Path: string;
  Orig, Rest: TPasResultElement);
begin
  CheckRestoredElement(Path+'.ResultType',Orig.ResultType,Rest.ResultType);
end;

procedure TCustomTestPrecompile.CheckRestoredFunctionType(const Path: string;
  Orig, Rest: TPasFunctionType);
begin
  CheckRestoredElement(Path+'.ResultEl',Orig.ResultEl,Rest.ResultEl);
  CheckRestoredProcedureType(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredStringType(const Path: string;
  Orig, Rest: TPasStringType);
begin
  AssertEquals(Path+'.LengthExpr',Orig.LengthExpr,Rest.LengthExpr);
end;

procedure TCustomTestPrecompile.CheckRestoredVariable(const Path: string; Orig,
  Rest: TPasVariable);
begin
  CheckRestoredElement(Path+'.VarType',Orig.VarType,Rest.VarType);
  if Orig.VarModifiers<>Rest.VarModifiers then
    Fail(Path+'.VarModifiers');
  CheckRestoredElement(Path+'.LibraryName',Orig.LibraryName,Rest.LibraryName);
  CheckRestoredElement(Path+'.ExportName',Orig.ExportName,Rest.ExportName);
  CheckRestoredElement(Path+'.AbsoluteExpr',Orig.AbsoluteExpr,Rest.AbsoluteExpr);
  CheckRestoredElement(Path+'.Expr',Orig.Expr,Rest.Expr);
end;

procedure TCustomTestPrecompile.CheckRestoredExportSymbol(const Path: string;
  Orig, Rest: TPasExportSymbol);
begin
  CheckRestoredElement(Path+'.ExportName',Orig.ExportName,Rest.ExportName);
  CheckRestoredElement(Path+'.ExportIndex',Orig.ExportIndex,Rest.ExportIndex);
end;

procedure TCustomTestPrecompile.CheckRestoredConst(const Path: string; Orig,
  Rest: TPasConst);
begin
  AssertEquals(Path+': IsConst',Orig.IsConst,Rest.IsConst);
  CheckRestoredVariable(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredProperty(const Path: string; Orig,
  Rest: TPasProperty);
begin
  CheckRestoredElement(Path+'.IndexExpr',Orig.IndexExpr,Rest.IndexExpr);
  CheckRestoredElement(Path+'.ReadAccessor',Orig.ReadAccessor,Rest.ReadAccessor);
  CheckRestoredElement(Path+'.WriteAccessor',Orig.WriteAccessor,Rest.WriteAccessor);
  CheckRestoredElement(Path+'.ImplementsFunc',Orig.ImplementsFunc,Rest.ImplementsFunc);
  CheckRestoredElement(Path+'.DispIDExpr',Orig.DispIDExpr,Rest.DispIDExpr);
  CheckRestoredElement(Path+'.StoredAccessor',Orig.StoredAccessor,Rest.StoredAccessor);
  CheckRestoredElement(Path+'.DefaultExpr',Orig.DefaultExpr,Rest.DefaultExpr);
  CheckRestoredElementList(Path+'.Args',Orig.Args,Rest.Args);
  // not needed: ReadAccessorName, WriteAccessorName, ImplementsName, StoredAccessorName
  AssertEquals(Path+'.DispIDReadOnly',Orig.DispIDReadOnly,Rest.DispIDReadOnly);
  AssertEquals(Path+'.IsDefault',Orig.IsDefault,Rest.IsDefault);
  AssertEquals(Path+'.IsNodefault',Orig.IsNodefault,Rest.IsNodefault);
  CheckRestoredVariable(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredProcedure(const Path: string;
  Orig, Rest: TPasProcedure);
begin
  CheckRestoredElement(Path+'.ProcType',Orig.ProcType,Rest.ProcType);
  CheckRestoredElement(Path+'.PublicName',Orig.PublicName,Rest.PublicName);
  CheckRestoredElement(Path+'.LibrarySymbolName',Orig.LibrarySymbolName,Rest.LibrarySymbolName);
  CheckRestoredElement(Path+'.LibraryExpr',Orig.LibraryExpr,Rest.LibraryExpr);
  CheckRestoredElement(Path+'.DispIDExpr',Orig.DispIDExpr,Rest.DispIDExpr);
  AssertEquals(Path+'.AliasName',Orig.AliasName,Rest.AliasName);
  if Orig.Modifiers<>Rest.Modifiers then
    Fail(Path+'.Modifiers');
  AssertEquals(Path+'.MessageName',Orig.MessageName,Rest.MessageName);
  if Orig.MessageType<>Rest.MessageType then
    Fail(Path+'.MessageType Orig='+PJUProcedureMessageTypeNames[Orig.MessageType]+' Rest='+PJUProcedureMessageTypeNames[Rest.MessageType]);
  // ToDo: Body
end;

procedure TCustomTestPrecompile.CheckRestoredOperator(const Path: string; Orig,
  Rest: TPasOperator);
begin
  if Orig.OperatorType<>Rest.OperatorType then
    Fail(Path+'.OperatorType Orig='+PJUOperatorTypeNames[Orig.OperatorType]+' Rest='+PJUOperatorTypeNames[Rest.OperatorType]);
  AssertEquals(Path+'.TokenBased',Orig.TokenBased,Rest.TokenBased);
  CheckRestoredProcedure(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredReference(const Path: string;
  Orig, Rest: TPasElement);
begin
  if Orig=nil then
    begin
    if Rest<>nil then
      Fail(Path+': Orig=nil Rest='+GetObjName(Rest));
    exit;
    end
  else if Rest=nil then
    Fail(Path+': Orig='+GetObjName(Orig)+' Rest=nil');
  if Orig.ClassType<>Rest.ClassType then
    Fail(Path+': Orig='+GetObjName(Orig)+' Rest='+GetObjName(Rest));
  AssertEquals(Path+': Name',Orig.Name,Rest.Name);

  if Orig is TPasUnresolvedSymbolRef then
    exit; // compiler types and procs are the same in every unit -> skip checking unit

  CheckRestoredReference(Path+'.Parent',Orig.Parent,Rest.Parent);
end;

{ TTestPrecompile }

procedure TTestPrecompile.Test_Base256VLQ;

  procedure Test(i: MaxPrecInt);
  var
    s: String;
    p: PByte;
    j: NativeInt;
  begin
    s:=EncodeVLQ(i);
    p:=PByte(s);
    j:=DecodeVLQ(p);
    if i<>j then
      Fail('Encode/DecodeVLQ OrigIndex='+IntToStr(i)+' Code="'+s+'" NewIndex='+IntToStr(j));
  end;

  procedure TestStr(i: MaxPrecInt; Expected: string);
  var
    Actual: String;
  begin
    Actual:=EncodeVLQ(i);
    AssertEquals('EncodeVLQ('+IntToStr(i)+')',Expected,Actual);
  end;

var
  i: Integer;
begin
  TestStr(0,#0);
  TestStr(1,#2);
  TestStr(-1,#3);
  for i:=-8200 to 8200 do
    Test(i);
  Test(High(MaxPrecInt));
  Test(High(MaxPrecInt)-1);
  Test(Low(MaxPrecInt)+2);
  Test(Low(MaxPrecInt)+1);
  //Test(Low(MaxPrecInt)); such a high number is not needed by pastojs
end;

procedure TTestPrecompile.TestPC_EmptyUnit;
begin
  StartUnit(false);
  Add([
  'interface',
  'implementation']);
  WriteReadUnit;
end;

procedure TTestPrecompile.TestPC_Const;
begin
  StartUnit(false);
  Add([
  'interface',
  'const c = 3;',
  'implementation']);
  WriteReadUnit;
end;

Initialization
  RegisterTests([TTestPrecompile]);
end.

