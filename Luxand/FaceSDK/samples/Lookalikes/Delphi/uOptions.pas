unit uOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls;

type
  TfrmOptions = class(TForm)
    edtMinimalFaceQuality: TEdit;
    lblMinimalFaceQuality: TLabel;
    lblFAR: TLabel;
    edtFAR: TEdit;
    udMinimalFaceQuality: TUpDown;
    udFAR: TUpDown;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmOptions: TfrmOptions;

implementation

{$R *.dfm}

end.
