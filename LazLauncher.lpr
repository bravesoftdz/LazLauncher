program LazLauncher;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  MainFrm { you can add units after this }, sysutils, MainDM, ResStr, searchfrm;

{$R *.res}

begin
  if FileExists('heap.trc') then
    DeleteFile('heap.trc');
  SetHeapTraceOutput('heap.trc');

  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.



