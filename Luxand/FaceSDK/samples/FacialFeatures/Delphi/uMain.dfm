object Form1: TForm1
  Left = 272
  Top = 108
  BorderStyle = bsDialog
  Caption = 'Facial Features'
  ClientHeight = 567
  ClientWidth = 822
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object imgSource: TImage
    Left = 0
    Top = 0
    Width = 822
    Height = 514
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    Proportional = True
  end
  object Panel2: TPanel
    Left = 0
    Top = 526
    Width = 822
    Height = 41
    Align = alBottom
    TabOrder = 0
    object btnLoadImage: TButton
      Left = 366
      Top = 7
      Width = 80
      Height = 25
      Caption = 'Open Photo'
      TabOrder = 0
      OnClick = btnLoadImageClick
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 96
    Top = 522
  end
end
