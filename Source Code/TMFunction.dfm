object fmFunction: TfmFunction
  Left = 312
  Top = 100
  Width = 124
  Height = 56
  BorderIcons = []
  BorderStyle = bsSizeToolWin
  BorderWidth = 3
  Caption = 'Work function'
  Color = clBtnFace
  ParentFont = True
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  ScreenSnap = True
  Visible = True
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 100
  TextHeight = 13
  object cmbWorkFunction: TComboBox
    Left = 0
    Top = 0
    Width = 110
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnSelect = cmbWorkFunctionSelect
  end
end
