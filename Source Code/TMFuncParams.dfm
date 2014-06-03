object fmFuncParams: TfmFuncParams
  Left = 386
  Top = 280
  Width = 331
  Height = 266
  BorderIcons = []
  BorderStyle = bsSizeToolWin
  BorderWidth = 3
  Caption = 'Function parameters'
  Color = clBtnFace
  ParentFont = True
  FormStyle = fsMDIChild
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  Position = poDefault
  ScreenSnap = True
  Visible = True
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 100
  TextHeight = 13
  object tcWaves: TTabControl
    Left = 0
    Top = 0
    Width = 317
    Height = 232
    Align = alClient
    TabOrder = 0
    Tabs.Strings = (
      'Tone'
      'AM'
      'BM'
      'FM'
      'PDM')
    TabIndex = 0
    OnChange = tcWavesChange
    object panFuncGraph: TPanel
      Left = 4
      Top = 24
      Width = 309
      Height = 86
      Align = alClient
      BevelOuter = bvNone
      BorderStyle = bsSingle
      TabOrder = 0
      object pbFuncGraph: TPaintBox
        Left = 0
        Top = 0
        Width = 305
        Height = 82
        Align = alClient
        Constraints.MinHeight = 32
        OnPaint = pbFuncGraphPaint
      end
    end
    object PageControl1: TPageControl
      Left = 4
      Top = 110
      Width = 309
      Height = 118
      ActivePage = tsDCOffset
      Align = alBottom
      TabOrder = 1
      object tsDCOffset: TTabSheet
        Caption = 'DC offset'
        object divDCOTop: TPanel
          Left = 0
          Top = 0
          Width = 301
          Height = 23
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object editDCOffset: TEdit
            Tag = 1
            Left = 0
            Top = 0
            Width = 47
            Height = 21
            MaxLength = 15
            TabOrder = 0
            OnChange = ControlAction
          end
        end
        object slDCOffset: TTrackBar
          Tag = 1
          Left = 0
          Top = 23
          Width = 301
          Height = 30
          Align = alTop
          Max = 1000
          Min = -1000
          Frequency = 1000
          TabOrder = 1
          OnChange = ControlAction
        end
        object cbInv: TCheckBox
          Tag = 2
          Left = 5
          Top = 68
          Width = 50
          Height = 17
          Caption = 'Inv'
          TabOrder = 2
          OnClick = ControlAction
        end
        object cbAbs: TCheckBox
          Tag = 3
          Left = 65
          Top = 68
          Width = 52
          Height = 17
          Caption = 'Abs'
          TabOrder = 3
          OnClick = ControlAction
        end
      end
      object tsPower: TTabSheet
        Caption = 'Power'
        ImageIndex = 1
        object divPowerTop: TPanel
          Left = 0
          Top = 0
          Width = 301
          Height = 23
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object editPower: TEdit
            Tag = 4
            Left = 0
            Top = 0
            Width = 117
            Height = 21
            MaxLength = 15
            TabOrder = 0
            OnChange = ControlAction
          end
        end
        object slPower: TTrackBar
          Tag = 4
          Left = 0
          Top = 23
          Width = 301
          Height = 30
          Align = alTop
          TabOrder = 1
          TickStyle = tsManual
          OnChange = ControlAction
        end
      end
      object tsTweak: TTabSheet
        Caption = 'Tweak'
        ImageIndex = 2
        object divTweakTop: TPanel
          Left = 0
          Top = 0
          Width = 301
          Height = 47
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object editTweak: TEdit
            Tag = 5
            Left = 0
            Top = 25
            Width = 117
            Height = 21
            MaxLength = 15
            TabOrder = 2
            OnChange = ControlAction
          end
          object cbTweakSym: TCheckBox
            Tag = 6
            Left = 5
            Top = 3
            Width = 52
            Height = 17
            Caption = 'Sym'
            TabOrder = 0
            OnClick = ControlAction
          end
          object cbTweakCurved: TCheckBox
            Tag = 7
            Left = 65
            Top = 3
            Width = 57
            Height = 17
            Caption = 'Curved'
            TabOrder = 1
            OnClick = ControlAction
          end
        end
        object slTweak: TTrackBar
          Tag = 5
          Left = 0
          Top = 47
          Width = 301
          Height = 30
          Align = alTop
          Max = 1000
          Min = -1000
          Frequency = 1000
          TabOrder = 1
          OnChange = ControlAction
        end
      end
      object tsUnique: TTabSheet
        Caption = 'Unique'
        ImageIndex = 3
        object divParamTop: TPanel
          Left = 0
          Top = 0
          Width = 301
          Height = 47
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object cmbParam: TComboBox
            Left = 0
            Top = 0
            Width = 117
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 0
            OnChange = cmbParamChange
          end
          object editParam: TEdit
            Tag = 8
            Left = 0
            Top = 24
            Width = 117
            Height = 21
            MaxLength = 15
            TabOrder = 1
            OnChange = ControlAction
          end
        end
        object slParam: TTrackBar
          Tag = 8
          Left = 0
          Top = 47
          Width = 301
          Height = 30
          Align = alTop
          TabOrder = 1
          TickStyle = tsManual
          OnChange = ControlAction
        end
      end
      object TabSheet5: TTabSheet
        Caption = 'Table'
        ImageIndex = 4
        TabVisible = False
        object pbTable: TPaintBox
          Left = 0
          Top = 0
          Width = 301
          Height = 63
          Align = alClient
        end
        object Panel5: TPanel
          Left = 0
          Top = 63
          Width = 301
          Height = 27
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 0
          object btnBrowseTable: TButton
            Left = 2
            Top = 3
            Width = 23
            Height = 23
            Caption = '...'
            TabOrder = 0
          end
        end
      end
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 30
    OnTimer = Timer1Timer
    Left = 13
    Top = 30
  end
  object PopupMenu1: TPopupMenu
    Left = 111
    Top = 55
    object miReset: TMenuItem
      Caption = 'Reset'
      ShortCut = 16474
      OnClick = miResetClick
    end
  end
end
