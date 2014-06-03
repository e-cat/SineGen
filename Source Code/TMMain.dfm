object fmMain: TfmMain
  Left = 275
  Top = 109
  Width = 708
  Height = 632
  Caption = 'SineGen'
  Color = clAppWorkSpace
  ParentFont = True
  FormStyle = fsMDIForm
  Menu = MainMenu1
  OldCreateOrder = False
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShortCut = FormShortCut
  OnShow = FormShow
  PixelsPerInch = 100
  TextHeight = 13
  object snaiAccessIcon: TSNAIcon
    InfoBalloon.Icon = biUser
    InfoBalloon.Sound = False
    InfoBalloon.Timeout = 10
    InfoBalloon.Title = 'SineGen'
    PopupMenu = PopupMenu1
    OnMinimizeTo = snaiAccessIconMinimizeTo
    Left = 38
    Top = 2
  end
  object PopupMenu1: TPopupMenu
    Left = 70
    Top = 3
    object miActive: TMenuItem
      Caption = 'Active'
      OnClick = miActiveClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miExit: TMenuItem
      Caption = 'Exit'
      OnClick = miExitClick
    end
  end
  object MainMenu1: TMainMenu
    Left = 4
    Top = 3
    object Options1: TMenuItem
      Caption = '&Options'
      object miFadeIn: TMenuItem
        Caption = 'Fade-In'
        OnClick = miFadeInClick
      end
      object miFadeOut: TMenuItem
        Caption = 'Fade-Out'
        OnClick = miFadeOutClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object miFont: TMenuItem
        Caption = 'Font'
        ShortCut = 32838
        OnClick = miFontClick
      end
      object miMinimizeToSNA: TMenuItem
        AutoCheck = True
        Caption = 'Minimize to notification area'
        OnClick = miMinimizeToSNAClick
      end
    end
    object miAbout: TMenuItem
      Caption = '&About'
      OnClick = miAboutClick
    end
  end
  object dlgFont: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Microsoft Sans Serif'
    Font.Style = []
    MaxFontSize = 9
    Options = [fdAnsiOnly, fdEffects, fdLimitSize, fdApplyButton]
    OnApply = dlgFontApply
    Left = 103
    Top = 4
  end
end
