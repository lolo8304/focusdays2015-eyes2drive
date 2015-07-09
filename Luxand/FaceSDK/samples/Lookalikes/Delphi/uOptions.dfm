object frmOptions: TfrmOptions
  Left = 518
  Top = 338
  BorderStyle = bsDialog
  Caption = 'Options'
  ClientHeight = 122
  ClientWidth = 255
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lblMinimalFaceQuality: TLabel
    Left = 16
    Top = 20
    Width = 100
    Height = 13
    Caption = 'Minimal Face Quality:'
  end
  object lblFAR: TLabel
    Left = 16
    Top = 52
    Width = 129
    Height = 13
    Caption = 'False Acceptance Rate, %:'
  end
  object edtMinimalFaceQuality: TEdit
    Left = 168
    Top = 16
    Width = 57
    Height = 21
    TabOrder = 0
    Text = '3'
  end
  object edtFAR: TEdit
    Left = 168
    Top = 48
    Width = 57
    Height = 21
    TabOrder = 1
    Text = '100'
  end
  object udMinimalFaceQuality: TUpDown
    Left = 225
    Top = 16
    Width = 16
    Height = 21
    Associate = edtMinimalFaceQuality
    Min = 1
    Max = 30
    Position = 5
    TabOrder = 2
  end
  object udFAR: TUpDown
    Left = 225
    Top = 48
    Width = 16
    Height = 21
    Associate = edtFAR
    Position = 1
    TabOrder = 3
  end
  object btnOK: TBitBtn
    Left = 80
    Top = 88
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object btnCancel: TBitBtn
    Left = 168
    Top = 88
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
end
