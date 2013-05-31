object TestForm: TTestForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'TestForm'
  ClientHeight = 355
  ClientWidth = 379
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object FillButton: TButton
    Left = 8
    Top = 284
    Width = 75
    Height = 25
    Caption = 'FillButton'
    TabOrder = 0
    OnClick = FillButtonClick
  end
  object CaseSensitiveCheckBox: TCheckBox
    Left = 10
    Top = 24
    Width = 161
    Height = 17
    Caption = 'CaseSensitiveCheckBox'
    TabOrder = 1
  end
  object AscendingCheckBox: TCheckBox
    Left = 10
    Top = 7
    Width = 161
    Height = 17
    Caption = 'AscendingCheckBox'
    TabOrder = 2
  end
  object DuplicatesCheckBox: TCheckBox
    Left = 10
    Top = 40
    Width = 161
    Height = 17
    Caption = 'DuplicatesCheckBox'
    TabOrder = 3
  end
  object SortedCheckBox: TCheckBox
    Left = 10
    Top = 56
    Width = 161
    Height = 17
    Caption = 'SortedCheckBox'
    TabOrder = 4
  end
  object UserListBox: TListBox
    Left = 10
    Top = 79
    Width = 161
    Height = 97
    ItemHeight = 13
    TabOrder = 5
  end
  object LoadButton: TButton
    Left = 8
    Top = 315
    Width = 75
    Height = 25
    Caption = 'LoadButton'
    TabOrder = 6
    OnClick = LoadButtonClick
  end
  object SaveButton: TButton
    Left = 89
    Top = 315
    Width = 75
    Height = 25
    Caption = 'SaveButton'
    TabOrder = 7
    OnClick = SaveButtonClick
  end
  object RoomListBox: TListBox
    Left = 202
    Top = 79
    Width = 161
    Height = 97
    ItemHeight = 13
    TabOrder = 8
  end
  object CaseSensitiveCheckBox2: TCheckBox
    Left = 202
    Top = 24
    Width = 161
    Height = 17
    Caption = 'CaseSensitiveCheckBox'
    TabOrder = 9
  end
  object AscendingCheckBox2: TCheckBox
    Left = 202
    Top = 7
    Width = 161
    Height = 17
    Caption = 'AscendingCheckBox'
    TabOrder = 10
  end
  object DuplicatesCheckBox2: TCheckBox
    Left = 202
    Top = 40
    Width = 161
    Height = 17
    Caption = 'DuplicatesCheckBox'
    TabOrder = 11
  end
  object SortedCheckBox2: TCheckBox
    Left = 202
    Top = 56
    Width = 161
    Height = 17
    Caption = 'SortedCheckBox'
    TabOrder = 12
  end
  object ClearButton: TButton
    Left = 89
    Top = 284
    Width = 75
    Height = 25
    Caption = 'ClearButton'
    TabOrder = 13
    OnClick = ClearButtonClick
  end
  object FindEdit: TEdit
    Left = 251
    Top = 286
    Width = 112
    Height = 21
    TabOrder = 14
  end
  object FindButton: TButton
    Left = 170
    Top = 284
    Width = 75
    Height = 25
    Caption = 'FindButton'
    TabOrder = 15
    OnClick = FindButtonClick
  end
  object UserListView: TListView
    Left = 8
    Top = 184
    Width = 355
    Height = 94
    Columns = <
      item
        Caption = 'Identifier'
      end
      item
        Caption = 'Full name'
        Width = 150
      end
      item
        Caption = 'E-Mail'
        Width = 150
      end>
    TabOrder = 16
    ViewStyle = vsReport
  end
  object FormButton: TButton
    Left = 170
    Top = 315
    Width = 75
    Height = 25
    Caption = 'FormButton'
    TabOrder = 17
    OnClick = FormButtonClick
  end
end
