unit MainFrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
  StdCtrls, ComCtrls, ExtCtrls, ActnList, IniPropStorage;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    actAdd: TAction;
    actRemove: TAction;
    alMain: TActionList;
    btnAdd: TButton;
    btnRemove: TButton;
    Button1: TButton;
    chkCustomConf: TCheckBox;
    edtLazDir: TDirectoryEdit;
    edtName: TEdit;
    edtConfDir: TDirectoryEdit;
    edtVersion: TEdit;
    ipsMain: TIniPropStorage;
    lvLazEntries: TListView;
    Panel1: TPanel;
    procedure actAddExecute(Sender: TObject);
    procedure actAddUpdate(Sender: TObject);
    procedure actRemoveExecute(Sender: TObject);
    procedure actRemoveUpdate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure chkCustomConfChange(Sender: TObject);
    procedure edtLazDirChange(Sender: TObject);
    procedure lvLazEntriesColumnClick(Sender: TObject; Column: TListColumn);
  private
    procedure AddEntry;
  public

  end;

  { TODO -oRequion : add edit function }
  { TODO -oRequion : think about usage of a db for enties and settings }
  { TODO -oRequion : think about settings which could be saved to a db :D }
  { TODO -oRequion : function to add desktop icon for specific entry }

var
  FrmMain: TFrmMain;

implementation

{$R *.lfm}

{ TFrmMain }

procedure TFrmMain.edtLazDirChange(Sender: TObject);
var
  TempFile: TStringList;
  DirName, FileNameVersion, FileNameLaz, VersionStr: string;
begin
  edtName.Clear;
  edtVersion.Clear;

  DirName := (Sender as TDirectoryEdit).Directory;
  if DirectoryExists(DirName) then
  begin
    FileNameVersion := DirName + PathDelim + 'ide' + PathDelim + 'version.inc';
    FileNameLaz := DirName + PathDelim + 'lazarus';

    {$IfDef Windows}
    FileNameLaz := FileNameLaz + '.exe';
    {$EndIf}

    if FileExists(FileNameLaz) and FileExists(FileNameVersion) then
    begin
      TempFile := TStringList.Create;
      try
        TempFile.LoadFromFile(FileNameVersion);

        VersionStr := StringReplace(TempFile[0], '''', '',
          [rfIgnoreCase, rfReplaceAll]);

        edtName.Text := 'Lazarus_' + VersionStr;
        edtVersion.Text := VersionStr;
      finally
        TempFile.Free;
      end;
    end;
  end;
end;

procedure TFrmMain.lvLazEntriesColumnClick(Sender: TObject; Column: TListColumn);
begin
  (Sender as TListView).SortColumn := Column.Index;
  (Sender as TListView).Sort;
end;

procedure TFrmMain.AddEntry;
var
  li: TListItem;
begin
  li := lvLazEntries.Items.Add;
  li.Caption := edtName.Text;
  li.SubItems.Add(edtVersion.Text);
  li.SubItems.Add(edtLazDir.Directory);
  if chkCustomConf.Checked and not SameText(edtConfDir.Directory, '') and
    DirectoryExists(edtConfDir.Directory) then
    li.SubItems.Add(edtConfDir.Directory)
  else
    li.SubItems.Add('(Standard)');
end;

procedure TFrmMain.chkCustomConfChange(Sender: TObject);
begin
  edtConfDir.Enabled := chkCustomConf.Checked;
  if chkCustomConf.Checked then
    edtConfDir.Directory := ''
  else
    edtConfDir.Directory := '(Standard)';
end;

procedure TFrmMain.actAddExecute(Sender: TObject);
var
  LiFound: TListItem;
begin
  LiFound := lvLazEntries.Items.FindCaption(0, edtName.Text, True, True, False);

  if not Assigned(LiFound) then
  begin
    AddEntry;
  end
  else
  begin
    ShowMessage(LiFound.SubItems[0]);
    ShowMessage(LiFound.SubItems[1]);
    ShowMessage(LiFound.SubItems[2]);
    if SameText(LiFound.SubItems[0], edtVersion.Text) and
      SameText(LiFound.SubItems[1], edtLazDir.Directory) and
      SameText(LiFound.SubItems[2], edtConfDir.Directory) then
      ShowMessage('Eintrag bereits vorhanden.')
    else
      AddEntry;
  end;

  //edtLazDir.Clear;
  //edtName.Clear;
  //edtVersion.Clear;
  //edtConfDir.Clear;
  //chkCustomConf.Checked := False;
end;

procedure TFrmMain.actAddUpdate(Sender: TObject);
begin
  btnAdd.Enabled := not SameText(edtLazDir.Directory, '') and not
    SameText(edtName.Text, '') and not SameText(edtVersion.Text, '');
end;

procedure TFrmMain.actRemoveExecute(Sender: TObject);
begin
  lvLazEntries.Items[lvLazEntries.ItemIndex].Delete;
end;

procedure TFrmMain.actRemoveUpdate(Sender: TObject);
begin
  actRemove.Enabled := (lvLazEntries.Items.Count > 0) and (lvLazEntries.ItemIndex > -1);
end;

procedure TFrmMain.Button1Click(Sender: TObject);
var
  blafoo: TStringList;
  I: integer;
begin
  { TODO -oRequion : add functionality to search fs for installations }
  blafoo := FindAllFiles('/home', 'lazarus');

  for I := 0 to blafoo.Count - 1 do
  begin
    if Pos('MacOS', blafoo[I]) = 0 then
      ShowMessage(blafoo[I]);
  end;
end;

end.
