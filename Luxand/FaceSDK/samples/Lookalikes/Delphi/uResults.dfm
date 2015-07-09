object frmSearchResults: TfrmSearchResults
  Left = 388
  Top = 160
  BorderStyle = bsDialog
  Caption = 'Search Resuts'
  ClientHeight = 497
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  DesignSize = (
    418
    497)
  PixelsPerInch = 96
  TextHeight = 13
  object imgSource: TImage
    Left = 8
    Top = 8
    Width = 401
    Height = 249
    Anchors = [akLeft, akTop, akRight, akBottom]
    Proportional = True
  end
  object lblFacesMatched: TLabel
    Left = 8
    Top = 272
    Width = 77
    Height = 13
    Caption = 'Faces Matched:'
  end
  object grdMatchingResult: TDrawGrid
    Left = 8
    Top = 288
    Width = 401
    Height = 169
    ColCount = 1
    DefaultColWidth = 96
    DefaultRowHeight = 96
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 0
    OnDrawCell = grdMatchingResultDrawCell
  end
  object btnOK: TButton
    Left = 172
    Top = 464
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
