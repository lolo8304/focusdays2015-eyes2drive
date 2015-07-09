///////////////////////////////////////////////////
//
//        Luxand FaceSDK Library Samples
//
//  Copyright(c) 2005-2007 Luxand Development
//           http://www.luxand.com
//
///////////////////////////////////////////////////

program Lookalikes;

uses
  Forms,
  uMain in 'uMain.pas' {MainForm},
  LuxandFaceSDK in 'LuxandFaceSDK.pas',
  uOptions in 'uOptions.pas' {frmOptions},
  uResults in 'uResults.pas' {frmSearchResults};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TfrmOptions, frmOptions);
  Application.CreateForm(TfrmSearchResults, frmSearchResults);
  Application.Run;
end.
