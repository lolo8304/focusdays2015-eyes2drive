object Form1: TForm1
  Left = 638
  Top = 237
  Width = 722
  Height = 514
  Caption = 'Live Recognition'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = OnClose
  OnCreate = OnCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 8
    Top = 8
    Width = 666
    Height = 394
    OnMouseMove = Image1MouseMove
    OnMouseUp = Image1MouseUp
  end
  object Label1: TLabel
    Left = 248
    Top = 408
    Width = 3
    Height = 13
    Alignment = taCenter
    AutoSize = False
  end
  object Button1: TButton
    Left = 320
    Top = 437
    Width = 67
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = Button1Click
  end
end
