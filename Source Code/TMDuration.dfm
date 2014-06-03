object fmDuration: TfmDuration
  Left = 272
  Top = 105
  BorderIcons = []
  BorderStyle = bsToolWindow
  BorderWidth = 3
  Caption = 'Duration (s)'
  ClientHeight = 49
  ClientWidth = 121
  Color = clBtnFace
  ParentFont = True
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  ScreenSnap = True
  Visible = True
  OnDeactivate = ControlExit
  PixelsPerInch = 100
  TextHeight = 13
  object Label1: TLabel
    Left = 2
    Top = 5
    Width = 49
    Height = 13
    Caption = 'Transition:'
  end
  object Label2: TLabel
    Left = 2
    Top = 30
    Width = 44
    Height = 13
    Caption = 'Passage:'
  end
  object editTransitionTime: TEdit
    Tag = 1
    Left = 57
    Top = 2
    Width = 64
    Height = 21
    TabOrder = 0
    OnChange = editTimeChange
    OnExit = ControlExit
  end
  object editPassageTime: TEdit
    Tag = 2
    Left = 57
    Top = 27
    Width = 64
    Height = 21
    TabOrder = 1
    OnChange = editTimeChange
    OnExit = ControlExit
  end
end
