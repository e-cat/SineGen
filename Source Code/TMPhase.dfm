object fmPhase: TfmPhase
  Left = 899
  Top = 99
  Width = 149
  Height = 195
  BorderIcons = []
  BorderStyle = bsSizeToolWin
  BorderWidth = 3
  Caption = 'Phase ('#176')'
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
    Top = 83
    Width = 135
    Height = 3
    Align = alTop
    Shape = bsSpacer
  end
  object gbPhaseOffset: TGroupBox
    Left = 0
    Top = 86
    Width = 135
    Height = 75
    Align = alClient
    Caption = 'Offset'
    TabOrder = 1
    object paintPhaseOffset: TPaintBox
      Left = 2
      Top = 15
      Width = 131
      Height = 58
      Cursor = crSizeWE
      Align = alClient
      OnMouseDown = paintPhaseOffsetMouseDown
      OnMouseMove = paintPhaseOffsetMouseMove
      OnMouseUp = paintPhaseOffsetMouseUp
      OnPaint = paintPhaseOffsetPaint
    end
  end
  object gbPhaseDifference: TGroupBox
    Left = 0
    Top = 0
    Width = 135
    Height = 83
    Align = alTop
    Caption = 'Difference'
    TabOrder = 0
    object slPhaseDifference: TTrackBar
      Left = 2
      Top = 38
      Width = 131
      Height = 30
      Align = alTop
      Max = 1800
      Min = -1800
      PageSize = 150
      Frequency = 300
      TabOrder = 1
      OnChange = slPhaseDifferenceChange
    end
    object divPDTop: TPanel
      Left = 2
      Top = 15
      Width = 131
      Height = 23
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object editPhaseDifference: TEdit
        Left = 0
        Top = 0
        Width = 49
        Height = 21
        MaxLength = 15
        TabOrder = 0
        OnChange = editPhaseDifferenceChange
        OnExit = ControlExit
        OnKeyDown = editPhaseDifferenceKeyDown
      end
    end
  end
end
