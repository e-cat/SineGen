object fmOutputSetup: TfmOutputSetup
  Left = 697
  Top = 540
  BorderStyle = bsDialog
  BorderWidth = 3
  Caption = 'Output setup'
  ClientHeight = 192
  ClientWidth = 289
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poMainFormCenter
  ShowHint = True
  OnCreate = FormCreate
  OnShortCut = FormShortCut
  PixelsPerInch = 100
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 121
    Width = 289
    Height = 3
    Align = alTop
    Shape = bsSpacer
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 289
    Height = 121
    Align = alTop
    Caption = 'Flow'
    TabOrder = 0
    object Bevel2: TBevel
      Left = 2
      Top = 65
      Width = 285
      Height = 3
      Align = alTop
      Shape = bsSpacer
    end
    object gbBufferTime: TGroupBox
      Left = 2
      Top = 15
      Width = 285
      Height = 50
      Align = alTop
      Caption = 'Buffer time'
      TabOrder = 0
      object labelBufferTime: TLabel
        Left = 2
        Top = 35
        Width = 281
        Height = 13
        Align = alTop
        Alignment = taCenter
      end
      object slBufferTime: TTrackBar
        Left = 2
        Top = 15
        Width = 281
        Height = 20
        Hint = 'Increase if you listen clicks; decrase if control is too slow'
        Align = alTop
        Max = 500
        Min = 10
        PageSize = 10
        Position = 25
        TabOrder = 0
        ThumbLength = 16
        TickMarks = tmBoth
        TickStyle = tsNone
        OnChange = slBufferTimeChange
      end
    end
    object gbPrebufferTime: TGroupBox
      Left = 2
      Top = 68
      Width = 285
      Height = 50
      Align = alTop
      Caption = 'Pre-buffer time'
      TabOrder = 1
      object labelPrebufferTime: TLabel
        Left = 2
        Top = 35
        Width = 281
        Height = 13
        Align = alTop
        Alignment = taCenter
      end
      object slPrebufferTime: TTrackBar
        Left = 2
        Top = 15
        Width = 281
        Height = 20
        Align = alTop
        Max = 1000
        Min = 100
        PageSize = 100
        Position = 100
        TabOrder = 0
        ThumbLength = 16
        TickMarks = tmBoth
        TickStyle = tsNone
        OnChange = slPrebufferTimeChange
      end
    end
  end
  object btnReset: TButton
    Left = 1
    Top = 168
    Width = 75
    Height = 23
    Caption = 'Reset'
    TabOrder = 2
    OnClick = btnResetClick
  end
  object btnOK: TButton
    Left = 134
    Top = 168
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 213
    Top = 168
    Width = 75
    Height = 23
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
    OnClick = btnResetClick
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 124
    Width = 289
    Height = 39
    Align = alTop
    Caption = 'Formats'
    TabOrder = 1
    object editFormats: TEdit
      Left = 2
      Top = 15
      Width = 285
      Height = 21
      Hint = 'bits/kHz [m]; ...'
      MaxLength = 80
      TabOrder = 0
    end
  end
end
