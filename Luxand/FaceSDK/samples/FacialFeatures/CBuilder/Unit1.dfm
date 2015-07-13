object Form1: TForm1
  Left = 338
  Top = 114
  BorderStyle = bsDialog
  Caption = 'Facial Features'
  ClientHeight = 515
  ClientWidth = 769
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 769
    Height = 473
  end
  object Button1: TButton
    Left = 344
    Top = 480
    Width = 81
    Height = 25
    Caption = 'Open Photo'
    TabOrder = 0
    OnClick = Button1Click
  end
  object OpenDialog1: TOpenDialog
    Left = 736
    Top = 24
  end
end
