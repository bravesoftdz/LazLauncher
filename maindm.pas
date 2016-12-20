unit MainDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TdmMain }

  TdmMain = class
  private
  public
    function GetLazarusVersion(const ADir: string): string;
    function FindFileLaz(const ADir: string): boolean;
  end;

implementation

uses
  ResStr;

{ TdmMain }

function TdmMain.GetLazarusVersion(const ADir: string): string;
var
  FileName: string;
  TmpTSFile: TStringList;
begin
  FileName := ADir + PathDelim + 'ide' + PathDelim + 'version.inc';
  if FileExists(FileName) then
  begin
    TmpTSFile := TStringList.Create;
    try
      TmpTSFile.LoadFromFile(FileName);
      Result := StringReplace(TmpTSFile[0], '''', '',
        [rfIgnoreCase, rfReplaceAll]);
    finally
      TmpTSFile.Free;
    end;
  end
  else
    Result := rsFileNotFound;

end;

function TdmMain.FindFileLaz(const ADir: string): boolean;
var
  FileName: string;
begin
  FileName := ADir + PathDelim + 'lazarus';
  {$IfDef Windows}
  FileName := FileName + '.exe';
  {$EndIf}
  Result := FileExists(FileName);
end;

end.

