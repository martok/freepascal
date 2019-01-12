{

    FPCRes - Free Pascal Resource Converter
    Part of the Free Pascal distribution
    Copyright (C) 2008 by Giulio Bernardi

    Source files handling

    See the file COPYING, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit sourcehandler;

{$MODE OBJFPC} {$H+}

interface

uses
  Classes, SysUtils, resource;

type
  ESourceFilesException = class(Exception);
  ECantOpenFileException = class(ESourceFilesException);
  EUnknownInputFormatException = class(ESourceFilesException);
  
type

  { TSourceFiles }

  TSourceFiles = class
  private
  protected
    fFileList : TStringList;
    fRCIncludeDirs: TStringList;
    fRCDefines: TStringList;
    fStreamList : TFPList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load(aResources : TResources);
    property FileList : TStringList read fFileList;
    property RCIncludeDirs: TStringList read fRCIncludeDirs;
    property RCDefines: TStringList read fRCDefines;
  end;
  
implementation

uses msghandler, closablefilestream, rcreader;

{ TSourceFiles }

constructor TSourceFiles.Create;
begin
  inherited Create;
  fFileList:=TStringList.Create;
  fStreamList:=TFPList.Create;
  fRCDefines:= TStringList.Create;
  fRCIncludeDirs:= TStringList.Create;
end;

destructor TSourceFiles.Destroy;
var i : integer;
begin
  fRCIncludeDirs.Free;
  fRCDefines.Free;
  fFileList.Free;
  for i:=0 to fStreamList.Count-1 do
    TStream(fStreamList[i]).Free;
  fStreamList.Free;
  inherited;
end;

procedure TSourceFiles.Load(aResources: TResources);
var aReader : TAbstractResourceReader;
    aStream : TClosableFileStream;
    i : integer;
    tmpres : TResources;
begin
  tmpres:=TResources.Create;
  try
    for i:=0 to fFileList.Count-1 do
    begin
      Messages.DoVerbose(Format('Trying to open file %s...',[fFileList[i]]));
      try
        aStream:=TClosableFileStream.Create(fFileList[i],fmOpenRead or fmShareDenyWrite);
      except
        raise ECantOpenFileException.Create(fFileList[i]);
      end;
      fStreamList.Add(aStream);
      try
        aReader:=TResources.FindReader(aStream);
      except
        raise EUnknownInputFormatException.Create(fFileList[i]);
      end;
      Messages.DoVerbose(Format('Chosen reader: %s',[aReader.Description]));
      try
        Messages.DoVerbose('Reading resource information...');
        if aReader is TRCResourceReader then begin
          TRCResourceReader(aReader).RCIncludeDirs.Assign(fRCIncludeDirs);
          TRCResourceReader(aReader).RCDefines.Assign(fRCDefines);
        end;
        tmpres.LoadFromStream(aStream,aReader);
        aResources.MoveFrom(tmpres);
        Messages.DoVerbose('Resource information read');
      finally
        aReader.Free;
      end;
    end;
    Messages.DoVerbose(Format('%d resources read.',[aResources.Count]));
  finally
    tmpres.Free;
  end;
end;

end.

