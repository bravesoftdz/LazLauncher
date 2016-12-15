unit MainFrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
  StdCtrls, ComCtrls, ExtCtrls, ActnList;

type

  { TForm1 }

  TForm1 = class(TForm)
    actAdd: TAction;
    actRemove: TAction;
    ActionList1: TActionList;
    btnAdd: TButton;
    btnDelete: TButton;
    chkCustomConf: TCheckBox;
    edtLazDir: TDirectoryEdit;
    edtName: TEdit;
    edtConfDir: TDirectoryEdit;
    edtVersion: TEdit;
    lvLazEntries: TListView;
    Panel1: TPanel;
    procedure actAddExecute(Sender: TObject);
    procedure actAddUpdate(Sender: TObject);
    procedure actRemoveExecute(Sender: TObject);
    procedure actRemoveUpdate(Sender: TObject);
    procedure chkCustomConfChange(Sender: TObject);
    procedure edtLazDirChange(Sender: TObject);
    procedure lvLazEntriesColumnClick(Sender: TObject; Column: TListColumn);
  private
    procedure AddEntry;


  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.edtLazDirChange(Sender: TObject);
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
    FileNameLaz := DirName + PathDelim + 'lazarus.exe';
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

procedure TForm1.lvLazEntriesColumnClick(Sender: TObject; Column: TListColumn);
begin
  (Sender as TListView).SortColumn := Column.Index;
  (Sender as TListView).Sort;
end;

procedure TForm1.AddEntry;
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

procedure TForm1.chkCustomConfChange(Sender: TObject);
begin
  edtConfDir.Enabled := chkCustomConf.Checked;
  if chkCustomConf.Checked then
    edtConfDir.Directory := ''
  else
    edtConfDir.Directory := '(Standard)';
end;

procedure TForm1.actAddExecute(Sender: TObject);
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

procedure TForm1.actAddUpdate(Sender: TObject);
begin
  btnAdd.Enabled := not SameText(edtLazDir.Directory, '') and not
    SameText(edtName.Text, '') and not SameText(edtVersion.Text, '');
end;

procedure TForm1.actRemoveExecute(Sender: TObject);
begin
  lvLazEntries.Items[lvLazEntries.ItemIndex].Delete;
end;

procedure TForm1.actRemoveUpdate(Sender: TObject);
begin
  actRemove.Enabled := (lvLazEntries.Items.Count > 0) and (lvLazEntries.ItemIndex > -1);
end;

end.
