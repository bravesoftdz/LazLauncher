unit MainFrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
  StdCtrls, ComCtrls, ExtCtrls, ActnList, IniPropStorage, MainDM;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    actAdd: TAction;
    actEdit: TAction;
    actAbort: TAction;
    actSearch: TAction;
    actSave: TAction;
    actRemove: TAction;
    alMain: TActionList;
    btnAdd: TButton;
    btnEdit: TButton;
    btnRemove: TButton;
    btnSave: TButton;
    btnSearch: TButton;
    btnAbort: TButton;
    chkCustomConf: TCheckBox;
    edtLazDir: TDirectoryEdit;
    edtName: TEdit;
    edtConfDir: TDirectoryEdit;
    edtVersion: TEdit;
    gbAddRem: TGroupBox;
    gbEdit: TGroupBox;
    ipsMain: TIniPropStorage;
    lvLazEntries: TListView;
    Panel1: TPanel;
    procedure actAbortExecute(Sender: TObject);
    procedure actAbortUpdate(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actAddUpdate(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
    procedure actRemoveExecute(Sender: TObject);
    procedure actRemoveUpdate(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actSaveUpdate(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure chkCustomConfChange(Sender: TObject);
    procedure edtLazDirChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure lvLazEntriesColumnClick(Sender: TObject; Column: TListColumn);
  private
    FdmMain: TdmMain;
    FModeEdit: boolean;
    FSelectedEntry: integer;
    procedure AddEntry;
    procedure DeleteEntry;
    procedure SearchLazInstall;
    procedure EditEntry;
    procedure SaveEntry;
    procedure AbortEdit;
    procedure FillInput(const ADirName: string);
    procedure ClearInput(ANewEntry: boolean = True);
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

uses
  ResStr;

{ TFrmMain }

procedure TFrmMain.edtLazDirChange(Sender: TObject);
begin
  if not FModeEdit then
    FillInput((Sender as TDirectoryEdit).Directory);
end;

procedure TFrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FdmMain.Free;
  CloseAction := caFree;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  FdmMain := TdmMain.Create;
  FModeEdit := False;
  FSelectedEntry := -1;
end;

procedure TFrmMain.lvLazEntriesColumnClick(Sender: TObject; Column: TListColumn);
begin
  (Sender as TListView).SortColumn := Column.Index;
  (Sender as TListView).Sort;
end;

procedure TFrmMain.FillInput(const ADirName: string);
begin
  ClearInput(False);
  if DirectoryExists(ADirName) then
  begin
    if FdmMain.FindFileLaz(ADirName) then
    begin
      edtName.Text := 'Lazarus_' + FdmMain.GetLazarusVersion(ADirName);
      edtVersion.Text := FdmMain.GetLazarusVersion(ADirName);
    end;
  end;
end;

procedure TFrmMain.AddEntry;
var
  li: TListItem;
begin
  li := lvLazEntries.Items.Add;
  li.Caption := edtName.Text;
  li.SubItems.Add(edtVersion.Text);
  li.SubItems.Add(edtLazDir.Directory);
  if chkCustomConf.Checked and DirectoryExists(edtConfDir.Directory) then
    li.SubItems.Add(edtConfDir.Directory)
  else
    li.SubItems.Add(rsDefault);
  ClearInput;
end;

procedure TFrmMain.EditEntry;
var
  LiEdit: TListItem;
begin
  FModeEdit := True;
  FSelectedEntry := lvLazEntries.ItemIndex;
  LiEdit := lvLazEntries.Items[FSelectedEntry];
  edtName.Text := LiEdit.Caption;
  edtVersion.Text := LiEdit.SubItems[0];
  edtLazDir.Directory := LiEdit.SubItems[1];
  if not SameText(LiEdit.SubItems[2], rsDefault) then
  begin
    chkCustomConf.Checked := True;
    edtConfDir.Directory := LiEdit.SubItems[2];
  end;
end;

procedure TFrmMain.SaveEntry;
var
  LiEdit: TListItem;
begin
  LiEdit := lvLazEntries.Items[FSelectedEntry];
  if not SameText(LiEdit.Caption, edtName.Text) then
    LiEdit.Caption := edtName.Text;
  if not SameText(LiEdit.SubItems[0], edtVersion.Text) then
    LiEdit.SubItems[0] := edtVersion.Text;
  if not SameText(LiEdit.SubItems[1], edtLazDir.Directory) then
    LiEdit.SubItems[1] := edtLazDir.Directory;
  if not SameText(LiEdit.SubItems[2], edtConfDir.Directory) then
    LiEdit.SubItems[2] := edtConfDir.Directory;

  FSelectedEntry := -1;
  FModeEdit := False;
  ClearInput;
end;

procedure TFrmMain.AbortEdit;
begin
  FSelectedEntry := -1;
  FModeEdit := False;
  ClearInput;
end;

procedure TFrmMain.DeleteEntry;
begin
  if MessageDlg('Delete?', mtConfirmation, mbYesNo, 0) = mrYes then
    lvLazEntries.Items[lvLazEntries.ItemIndex].Delete;
end;

procedure TFrmMain.SearchLazInstall;
var
  TmpLazFiles: TStringList;
  TmpDelArr: array of Integer;
  I: integer;
begin
  { TODO -oRequion : add functionality to search fs for installations }
  TmpLazFiles := FindAllFiles('/home', 'lazarus');

  SetLength(TmpDelArr, 0);

  for I := 0 to TmpLazFiles.Count - 1 do
  begin
    if Pos('MacOS', TmpLazFiles[I]) = 0 then
    begin
      SetLength(TmpDelArr, Length(TmpDelArr) + 1);
      TmpDelArr[Length(TmpDelArr) - 1] := I;
    end;
  end;

  if TmpLazFiles.Count > 0 then
  begin
    if MessageDlg(Format('%d installations found. Want to add?', [TmpLazFiles.Count]),
      mtConfirmation, mbYesNo, 0) = mrYes then
    begin
      for I := 0 to TmpLazFiles.Count - 1 do
      begin
        FillInput(ExtractFilePath(TmpLazFiles[I]));
        AddEntry;
      end;
    end;
  end;
end;

procedure TFrmMain.ClearInput(ANewEntry: boolean);
begin
  if ANewEntry then
    edtLazDir.Clear;

  edtName.Clear;
  edtVersion.Clear;
  edtConfDir.Directory := rsDefault;
  chkCustomConf.Checked := False;
end;

procedure TFrmMain.chkCustomConfChange(Sender: TObject);
begin
  edtConfDir.Enabled := chkCustomConf.Checked;
  if chkCustomConf.Checked then
    edtConfDir.Directory := ''
  else
    edtConfDir.Directory := rsDefault;
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
    if SameText(LiFound.SubItems[0], edtVersion.Text) and
      SameText(LiFound.SubItems[1], edtLazDir.Directory) and
      SameText(LiFound.SubItems[2], edtConfDir.Directory) then
      ShowMessage(rsEntryExists)
    else
      AddEntry;
  end;
end;

procedure TFrmMain.actAbortUpdate(Sender: TObject);
begin
  actAbort.Enabled := FModeEdit and (FSelectedEntry > -1);
end;

procedure TFrmMain.actAbortExecute(Sender: TObject);
begin
  AbortEdit;
end;

procedure TFrmMain.actAddUpdate(Sender: TObject);
begin
  actAdd.Enabled := not SameText(edtLazDir.Directory, '') and not
    SameText(edtName.Text, '') and not SameText(edtVersion.Text, '') and not FModeEdit;
end;

procedure TFrmMain.actEditExecute(Sender: TObject);
begin
  EditEntry;
end;

procedure TFrmMain.actEditUpdate(Sender: TObject);
begin
  actEdit.Enabled := (lvLazEntries.Items.Count > 0) and
    (lvLazEntries.ItemIndex > -1) and not FModeEdit;
end;

procedure TFrmMain.actRemoveExecute(Sender: TObject);
begin
  DeleteEntry;
end;

procedure TFrmMain.actRemoveUpdate(Sender: TObject);
begin
  actRemove.Enabled := (lvLazEntries.Items.Count > 0) and
    (lvLazEntries.ItemIndex > -1) and not FModeEdit;
end;

procedure TFrmMain.actSaveExecute(Sender: TObject);
begin
  SaveEntry;
end;

procedure TFrmMain.actSaveUpdate(Sender: TObject);
begin
  actSave.Enabled := FModeEdit and (FSelectedEntry > -1);
end;

procedure TFrmMain.actSearchExecute(Sender: TObject);
begin
  SearchLazInstall;
end;

end.
