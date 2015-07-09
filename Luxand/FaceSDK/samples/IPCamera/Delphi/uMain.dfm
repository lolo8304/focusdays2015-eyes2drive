object Form1: TForm1
  Left = 371
  Top = 184
  AutoSize = True
  BorderStyle = bsDialog
  Caption = 'IP Camera Face Tracking'
  ClientHeight = 650
  ClientWidth = 1089
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = OnClose
  OnCreate = OnCreate
  DesignSize = (
    1089
    650)
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 1089
    Height = 617
    Anchors = []
    AutoSize = True
    Proportional = True
  end
  object AddressLabel: TLabel
    Left = 6
    Top = 628
    Width = 40
    Height = 13
    Caption = 'address:'
  end
  object UserLabel: TLabel
    Left = 614
    Top = 628
    Width = 49
    Height = 13
    Caption = 'username:'
  end
  object PasswordLabel: TLabel
    Left = 798
    Top = 628
    Width = 48
    Height = 13
    Caption = 'password:'
  end
  object Button1: TButton
    Left = 998
    Top = 625
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = Button1Click
  end
  object AddressBox: TEdit
    Left = 54
    Top = 628
    Width = 553
    Height = 21
    TabOrder = 1
  end
  object UserNameBox: TEdit
    Left = 670
    Top = 628
    Width = 121
    Height = 21
    TabOrder = 2
    Text = 'admin'
  end
  object PassworBox: TEdit
    Left = 854
    Top = 628
    Width = 121
    Height = 21
    TabOrder = 3
  end
end
