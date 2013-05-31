object ListViewForm: TListViewForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'ListViewForm'
  ClientHeight = 203
  ClientWidth = 329
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PageLabel: TLabel
    Left = 96
    Top = 164
    Width = 137
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = 'PageLabel'
  end
  object RoomListView: TListView
    Left = 8
    Top = 8
    Width = 313
    Height = 150
    Columns = <
      item
        Caption = 'Name'
        Width = 100
      end
      item
        Caption = 'Description'
        Width = 150
      end>
    TabOrder = 0
    ViewStyle = vsReport
  end
  object PreviousButton: TButton
    Left = 8
    Top = 164
    Width = 75
    Height = 25
    Caption = 'PreviousButton'
    TabOrder = 1
    OnClick = PreviousButtonClick
  end
  object NextButton: TButton
    Left = 246
    Top = 164
    Width = 75
    Height = 25
    Caption = 'NextButton'
    TabOrder = 2
    OnClick = NextButtonClick
  end
end
