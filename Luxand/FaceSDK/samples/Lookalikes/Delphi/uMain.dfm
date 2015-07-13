object MainForm: TMainForm
  Left = 230
  Top = 115
  Width = 869
  Height = 685
  Caption = 'Lookalikes'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = mnuMainMenu
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlFaceList: TPanel
    Left = 707
    Top = 0
    Width = 146
    Height = 627
    Align = alRight
    TabOrder = 0
    object lbFaceList: TListBox
      Left = 1
      Top = 1
      Width = 144
      Height = 625
      Style = lbOwnerDrawFixed
      Align = alRight
      ItemHeight = 96
      TabOrder = 0
      OnClick = lbFaceListClick
      OnDrawItem = lbFaceListDrawItem
    end
  end
  object pnlSourceImage: TPanel
    Left = 0
    Top = 0
    Width = 707
    Height = 627
    Align = alClient
    TabOrder = 1
    object imgSource: TImage
      Left = 1
      Top = 1
      Width = 705
      Height = 490
      Align = alTop
      Anchors = [akLeft, akTop, akRight, akBottom]
      Proportional = True
    end
    object LogMemo: TMemo
      Left = 1
      Top = 527
      Width = 705
      Height = 99
      Align = alBottom
      TabOrder = 0
    end
  end
  object OpenDialog1: TOpenDialog
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 592
    Top = 8
  end
  object mnuMainMenu: TMainMenu
    Left = 672
    Top = 8
    object File1: TMenuItem
      Caption = 'File'
      object EnrollPictures1: TMenuItem
        Caption = 'Enroll Face(s)...'
        OnClick = EnrollPictures1Click
      end
      object MatchPictures1: TMenuItem
        Caption = 'Match Face...'
        OnClick = MatchPictures1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object Options1: TMenuItem
      Caption = 'Tools'
      object Options2: TMenuItem
        Caption = 'Options...'
        OnClick = Options2Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object ClearDatabase1: TMenuItem
        Caption = 'Clear Database'
        OnClick = ClearDatabase1Click
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object About1: TMenuItem
        Caption = 'About'
        OnClick = About1Click
      end
    end
  end
  object OpenDialogMulti: TOpenDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 632
    Top = 8
  end
end
