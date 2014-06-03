object fmFrequency: TfmFrequency
  Left = 285
  Top = 108
  Width = 129
  Height = 214
  BorderIcons = []
  BorderWidth = 3
  Caption = 'Frequency (Hz)'
  Color = clBtnFace
  ParentFont = True
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  ScreenSnap = True
  Visible = True
  OnCreate = FormCreate
  OnDeactivate = ControlExit
  OnResize = FormResize
  PixelsPerInch = 100
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 94
    Width = 115
    Height = 3
    Align = alBottom
    Shape = bsSpacer
  end
  object Panel2: TPanel
    Left = 0
    Top = 69
    Width = 115
    Height = 25
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object btnNoteMatch: TButton
      Left = 92
      Top = 2
      Width = 23
      Height = 23
      Caption = '#'
      TabOrder = 2
      OnClick = btnNoteMatchClick
    end
    object btnDoubleFrequency: TButton
      Left = 69
      Top = 2
      Width = 23
      Height = 23
      Caption = '* 2'
      TabOrder = 1
      OnClick = btnDoubleFrequencyClick
    end
    object btnHalfFrequency: TButton
      Left = 46
      Top = 2
      Width = 23
      Height = 23
      Caption = '/ 2'
      TabOrder = 0
      OnClick = btnHalfFrequencyClick
    end
    object panFrequencyAdjustment: TPanel
      Left = 0
      Top = 2
      Width = 45
      Height = 23
      Cursor = crSizeNS
      Hint = 'Left is harder'
      BevelOuter = bvLowered
      Caption = 'Adjust'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnMouseDown = panFrequencyAdjustmentMouseDown
      OnMouseMove = panFrequencyAdjustmentMouseMove
      OnMouseUp = panFrequencyAdjustmentMouseUp
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 115
    Height = 23
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object editFrequency: TEdit
      Tag = 1
      Left = 0
      Top = 0
      Width = 115
      Height = 21
      MaxLength = 15
      TabOrder = 0
      OnChange = editFrequencyChange
      OnExit = ControlExit
      OnKeyDown = editKeyDown
    end
  end
  object slFrequency: TTrackBar
    Tag = 1
    Left = 0
    Top = 23
    Width = 30
    Height = 46
    Align = alLeft
    LineSize = 5
    Orientation = trVertical
    PageSize = 100
    TabOrder = 1
    TickStyle = tsManual
    OnChange = slFrequencyChange
    OnExit = ControlExit
  end
  object lbNote: TListBox
    Tag = 1
    Left = 60
    Top = 23
    Width = 55
    Height = 46
    Align = alRight
    ItemHeight = 13
    TabOrder = 2
    OnClick = lbNoteClick
    OnExit = ControlExit
  end
  object gbFrequencyDifference: TGroupBox
    Left = 0
    Top = 97
    Width = 115
    Height = 83
    Align = alBottom
    Caption = 'Difference (dB)'
    TabOrder = 4
    object Panel3: TPanel
      Left = 2
      Top = 15
      Width = 111
      Height = 23
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object editFrequencyDifference: TEdit
        Tag = 2
        Left = 0
        Top = 0
        Width = 109
        Height = 21
        MaxLength = 15
        TabOrder = 0
        OnChange = editFrequencyDifferenceChange
        OnExit = ControlExit
        OnKeyDown = editKeyDown
      end
    end
    object slFrequencyDifference: TTrackBar
      Tag = 2
      Left = 2
      Top = 38
      Width = 111
      Height = 30
      Align = alTop
      Max = 1000
      Min = -1000
      Frequency = 1000
      TabOrder = 1
      OnChange = slFrequencyDifferenceChange
      OnExit = ControlExit
    end
  end
end
