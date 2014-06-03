object fmModulation: TfmModulation
  Left = 567
  Top = 401
  Width = 458
  Height = 145
  BorderIcons = []
  BorderStyle = bsSizeToolWin
  BorderWidth = 3
  Caption = 'Modulation'
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
  object Bevel5: TBevel
    Left = 107
    Top = 0
    Width = 3
    Height = 111
    Align = alLeft
    Shape = bsSpacer
  end
  object Bevel6: TBevel
    Left = 217
    Top = 0
    Width = 3
    Height = 111
    Align = alLeft
    Shape = bsSpacer
  end
  object Bevel7: TBevel
    Left = 327
    Top = 0
    Width = 3
    Height = 111
    Align = alLeft
    Shape = bsSpacer
  end
  object gbAM: TGroupBox
    Left = 0
    Top = 0
    Width = 107
    Height = 111
    Align = alLeft
    Caption = 'Amplitude'
    TabOrder = 0
    object Bevel1: TBevel
      Left = 32
      Top = 62
      Width = 21
      Height = 47
      Align = alLeft
      Shape = bsSpacer
    end
    object Panel1: TPanel
      Left = 2
      Top = 15
      Width = 103
      Height = 47
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object cmbAMWorkFunction: TComboBox
        Tag = 1
        Left = 0
        Top = 0
        Width = 101
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnSelect = cmbWorkFunctionSelect
      end
      object editAMLevel: TEdit
        Tag = 1
        Left = 0
        Top = 24
        Width = 49
        Height = 21
        MaxLength = 15
        TabOrder = 1
        OnChange = editChange
        OnExit = ControlExit
        OnKeyDown = editKeyDown
      end
      object editAMFrequency: TEdit
        Tag = 2
        Left = 52
        Top = 24
        Width = 49
        Height = 21
        MaxLength = 15
        TabOrder = 2
        OnChange = editChange
        OnExit = ControlExit
        OnKeyDown = editKeyDown
      end
    end
    object slAMFrequency: TTrackBar
      Tag = 2
      Left = 53
      Top = 62
      Width = 30
      Height = 47
      Align = alLeft
      LineSize = 5
      Orientation = trVertical
      PageSize = 100
      TabOrder = 2
      TickStyle = tsManual
      OnChange = slFrequencyChange
      OnExit = ControlExit
    end
    object slAMLevel: TTrackBar
      Tag = 1
      Left = 2
      Top = 62
      Width = 30
      Height = 47
      Align = alLeft
      Max = 0
      Min = -3000
      Orientation = trVertical
      PageSize = 300
      Frequency = 300
      TabOrder = 1
      OnChange = slLevelChange
      OnExit = ControlExit
    end
  end
  object gbFM: TGroupBox
    Left = 220
    Top = 0
    Width = 107
    Height = 111
    Align = alLeft
    Caption = 'Frequency'
    TabOrder = 2
    object Bevel3: TBevel
      Left = 32
      Top = 62
      Width = 21
      Height = 47
      Align = alLeft
      Shape = bsSpacer
    end
    object Panel2: TPanel
      Left = 2
      Top = 15
      Width = 103
      Height = 47
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object cmbFMWorkFunction: TComboBox
        Tag = 3
        Left = 0
        Top = 0
        Width = 101
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnSelect = cmbWorkFunctionSelect
      end
      object editFMLevel: TEdit
        Tag = 5
        Left = 0
        Top = 24
        Width = 49
        Height = 21
        MaxLength = 15
        TabOrder = 1
        OnChange = editChange
        OnExit = ControlExit
        OnKeyDown = editKeyDown
      end
      object editFMFrequency: TEdit
        Tag = 6
        Left = 52
        Top = 24
        Width = 49
        Height = 21
        MaxLength = 15
        TabOrder = 2
        OnChange = editChange
        OnExit = ControlExit
        OnKeyDown = editKeyDown
      end
    end
    object slFMFrequency: TTrackBar
      Tag = 6
      Left = 53
      Top = 62
      Width = 30
      Height = 47
      Align = alLeft
      LineSize = 5
      Orientation = trVertical
      PageSize = 100
      TabOrder = 2
      TickStyle = tsManual
      OnChange = slFrequencyChange
      OnExit = ControlExit
    end
    object slFMLevel: TTrackBar
      Tag = 5
      Left = 2
      Top = 62
      Width = 30
      Height = 47
      Align = alLeft
      Max = 0
      Min = -3000
      Orientation = trVertical
      PageSize = 300
      Frequency = 300
      TabOrder = 1
      OnChange = slLevelChange
      OnExit = ControlExit
    end
  end
  object gbPDM: TGroupBox
    Left = 330
    Top = 0
    Width = 107
    Height = 111
    Align = alLeft
    Caption = 'Phase difference'
    TabOrder = 3
    object Bevel4: TBevel
      Left = 32
      Top = 62
      Width = 21
      Height = 47
      Align = alLeft
      Shape = bsSpacer
    end
    object Panel3: TPanel
      Left = 2
      Top = 15
      Width = 103
      Height = 47
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object cmbPDMWorkFunction: TComboBox
        Tag = 4
        Left = 0
        Top = 0
        Width = 101
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnSelect = cmbWorkFunctionSelect
      end
      object editPDMAmplitude: TEdit
        Tag = 7
        Left = 0
        Top = 24
        Width = 49
        Height = 21
        MaxLength = 15
        TabOrder = 1
        OnChange = editPDMAmplitudeChange
        OnExit = ControlExit
        OnKeyDown = editKeyDown
      end
      object editPDMFrequency: TEdit
        Tag = 8
        Left = 52
        Top = 24
        Width = 49
        Height = 21
        MaxLength = 15
        TabOrder = 2
        OnChange = editChange
        OnExit = ControlExit
        OnKeyDown = editKeyDown
      end
    end
    object slPDMFrequency: TTrackBar
      Tag = 8
      Left = 53
      Top = 62
      Width = 30
      Height = 47
      Align = alLeft
      LineSize = 5
      Orientation = trVertical
      PageSize = 100
      TabOrder = 2
      TickStyle = tsManual
      OnChange = slFrequencyChange
      OnExit = ControlExit
    end
    object slPDMAmplitude: TTrackBar
      Tag = 7
      Left = 2
      Top = 62
      Width = 30
      Height = 47
      Align = alLeft
      Max = 0
      Min = -1800
      Orientation = trVertical
      PageSize = 150
      Frequency = 300
      TabOrder = 1
      OnChange = slPDMAmplitudeChange
      OnExit = ControlExit
    end
  end
  object gbBM: TGroupBox
    Left = 110
    Top = 0
    Width = 107
    Height = 111
    Align = alLeft
    Caption = 'Balance'
    TabOrder = 1
    object Bevel2: TBevel
      Left = 32
      Top = 62
      Width = 21
      Height = 47
      Align = alLeft
      Shape = bsSpacer
    end
    object Panel4: TPanel
      Left = 2
      Top = 15
      Width = 103
      Height = 47
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object cmbBMWorkFunction: TComboBox
        Tag = 2
        Left = 0
        Top = 0
        Width = 101
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnSelect = cmbWorkFunctionSelect
      end
      object editBMLevel: TEdit
        Tag = 3
        Left = 0
        Top = 24
        Width = 49
        Height = 21
        MaxLength = 15
        TabOrder = 1
        OnChange = editChange
        OnExit = ControlExit
        OnKeyDown = editKeyDown
      end
      object editBMFrequency: TEdit
        Tag = 4
        Left = 52
        Top = 24
        Width = 49
        Height = 21
        MaxLength = 15
        TabOrder = 2
        OnChange = editChange
        OnExit = ControlExit
        OnKeyDown = editKeyDown
      end
    end
    object slBMFrequency: TTrackBar
      Tag = 4
      Left = 53
      Top = 62
      Width = 30
      Height = 47
      Align = alLeft
      LineSize = 5
      Orientation = trVertical
      PageSize = 100
      TabOrder = 2
      TickStyle = tsManual
      OnChange = slFrequencyChange
      OnExit = ControlExit
    end
    object slBMLevel: TTrackBar
      Tag = 3
      Left = 2
      Top = 62
      Width = 30
      Height = 47
      Align = alLeft
      Max = 0
      Min = -3000
      Orientation = trVertical
      PageSize = 300
      Frequency = 300
      TabOrder = 1
      OnChange = slLevelChange
      OnExit = ControlExit
    end
  end
end
