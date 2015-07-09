program LiveRecognition;

uses
  Forms,
  uMain in 'uMain.pas' {Form1},
  LuxandFaceSDK in 'LuxandFaceSDK.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
