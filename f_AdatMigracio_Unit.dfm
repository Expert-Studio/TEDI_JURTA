inherited f_AdatMigracio: Tf_AdatMigracio
  Caption = 'Adatmigr'#225'ci'#243
  ClientHeight = 509
  ClientWidth = 883
  ExplicitWidth = 899
  ExplicitHeight = 548
  PixelsPerInch = 96
  TextHeight = 13
  inherited Panel1: TPanel
    Top = 461
    Width = 883
    ExplicitTop = 461
    ExplicitWidth = 883
    inherited bb_kilep: TBitBtn
      Left = 839
      ExplicitLeft = 839
    end
    inherited bb_ok: TBitBtn
      Left = 797
      Visible = False
      ExplicitLeft = 797
    end
    inherited bb_nyomtat: TBitBtn
      Left = 755
      Visible = False
      ExplicitLeft = 755
    end
    inherited bb_excel: TBitBtn
      Left = 713
      ExplicitLeft = 713
    end
    inherited cb_uj: TCheckBox
      Left = 553
      ExplicitLeft = 553
    end
    inherited bb_csv: TBitBtn
      Left = 670
      Visible = False
      ExplicitLeft = 670
    end
  end
  inherited dbg_lista: TDBGrid
    Left = 233
    Width = 642
    Height = 279
    Anchors = [akTop, akRight, akBottom]
  end
  inherited bb_uj: TBitBtn
    Left = 839
    Visible = False
    ExplicitLeft = 839
  end
  inherited p_keres: TPanel
    Left = 256
    Top = 171
    ExplicitLeft = 256
    ExplicitTop = 171
  end
  object BitBtn1: TBitBtn [4]
    Left = 16
    Top = 13
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Szem'#233'lyek'
    TabOrder = 4
  end
  object szervezet: TBitBtn [5]
    Left = 16
    Top = 44
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Szervezetek'
    TabOrder = 5
    OnClick = szervezetClick
  end
  object m: TMemo [6]
    Left = 233
    Top = 8
    Width = 642
    Height = 157
    Anchors = [akTop, akRight]
    ScrollBars = ssBoth
    TabOrder = 6
    WordWrap = False
  end
  object csarnokberlo: TBitBtn [7]
    Left = 16
    Top = 75
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Csarnok b'#233'rl'#337'k'
    TabOrder = 7
    OnClick = csarnokberloClick
  end
  object BitBtn4: TBitBtn [8]
    Left = 16
    Top = 106
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Lak'#225'sok'
    TabOrder = 8
  end
  object BitBtn5: TBitBtn [9]
    Left = 16
    Top = 137
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Helyis'#233'gek '#233's csarnok'
    TabOrder = 9
    OnClick = BitBtn5Click
  end
  object BitBtn6: TBitBtn [10]
    Left = 16
    Top = 168
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Lak'#225's szerz'#337'd'#233'sek'
    TabOrder = 10
  end
  object BitBtn7: TBitBtn [11]
    Left = 16
    Top = 420
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Hibalista ment'#233'se'
    TabOrder = 11
    OnClick = BitBtn7Click
  end
  object helyisegszerz: TBitBtn [12]
    Left = 16
    Top = 199
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Helyis'#233'g szerz'#337'd'#233'sek'
    TabOrder = 12
    OnClick = helyisegszerzClick
  end
  object BitBtn9: TBitBtn [13]
    Left = 16
    Top = 230
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Csarnok szerz'#337'd'#233'sek'
    TabOrder = 13
  end
  object BitBtn10: TBitBtn [14]
    Left = 16
    Top = 261
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Lak'#225's sz'#225'ml'#225'k'
    TabOrder = 14
  end
  object helyisegszamla: TBitBtn [15]
    Left = 16
    Top = 292
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Helyis'#233'g, csarnok sz'#225'ml'#225'k'
    TabOrder = 15
    OnClick = helyisegszamlaClick
  end
  object BitBtn12: TBitBtn [16]
    Left = 16
    Top = 323
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Lak'#225's befizet'#233'sek'
    TabOrder = 16
  end
  object bb_helyisegbefizetes: TBitBtn [17]
    Left = 16
    Top = 354
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Helyis'#233'g, csarnok befizet'#233'sek'
    TabOrder = 17
    OnClick = bb_helyisegbefizetesClick
  end
  inherited SZURESds: TDataSource
    Left = 332
    Top = 56
  end
  inherited SZURES: TADOQuery
    Connection = AdatModul.JURTA
  end
  object ADOQuery1: TADOQuery
    Connection = AdatModul.JURTA
    Parameters = <>
    Left = 284
    Top = 284
  end
  object ADOQuery2: TADOQuery
    Connection = AdatModul.JURTA
    Parameters = <>
    Left = 376
    Top = 252
  end
  object ADOQuery3: TADOQuery
    Connection = AdatModul.JURTA
    Parameters = <>
    Left = 452
    Top = 228
  end
end
