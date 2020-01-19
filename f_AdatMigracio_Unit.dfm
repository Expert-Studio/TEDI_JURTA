inherited f_AdatMigracio: Tf_AdatMigracio
  Caption = 'Adatmigr'#225'ci'#243
  ClientHeight = 509
  ClientWidth = 875
  ExplicitWidth = 891
  ExplicitHeight = 548
  PixelsPerInch = 96
  TextHeight = 13
  inherited Panel1: TPanel
    Top = 461
    Width = 875
    ExplicitTop = 461
    ExplicitWidth = 875
    inherited bb_kilep: TBitBtn
      Left = 831
      ExplicitLeft = 831
    end
    inherited bb_ok: TBitBtn
      Left = 789
      Visible = False
      ExplicitLeft = 789
    end
    inherited bb_nyomtat: TBitBtn
      Left = 747
      Visible = False
      ExplicitLeft = 747
    end
    inherited bb_excel: TBitBtn
      Left = 705
      ExplicitLeft = 705
    end
    inherited cb_uj: TCheckBox
      Left = 545
      ExplicitLeft = 545
    end
    inherited bb_csv: TBitBtn
      Left = 662
      Visible = False
      ExplicitLeft = 662
    end
  end
  inherited dbg_lista: TDBGrid
    Left = 233
    Width = 634
    Height = 279
  end
  inherited bb_uj: TBitBtn
    Left = 831
    Visible = False
    ExplicitLeft = 831
  end
  inherited p_keres: TPanel
    Left = 256
    Top = 171
    ExplicitLeft = 256
    ExplicitTop = 171
  end
  object bb_szemely: TBitBtn [4]
    Left = 16
    Top = 13
    Width = 198
    Height = 25
    Caption = 'Szem'#233'lyek'
    TabOrder = 4
    OnClick = bb_szemelyClick
  end
  object szervezet: TBitBtn [5]
    Left = 16
    Top = 44
    Width = 198
    Height = 25
    Caption = 'Szervezetek'
    TabOrder = 5
    OnClick = szervezetClick
  end
  object m: TMemo [6]
    Left = 233
    Top = 8
    Width = 634
    Height = 157
    Anchors = [akLeft, akTop, akRight]
    ScrollBars = ssBoth
    TabOrder = 6
    WordWrap = False
  end
  object csarnokberlo: TBitBtn [7]
    Left = 16
    Top = 75
    Width = 198
    Height = 25
    Caption = 'Csarnok b'#233'rl'#337'k'
    TabOrder = 7
    OnClick = csarnokberloClick
  end
  object bb_lakasok: TBitBtn [8]
    Left = 16
    Top = 106
    Width = 198
    Height = 25
    Caption = 'Lak'#225'sok'
    TabOrder = 8
    OnClick = bb_lakasokClick
  end
  object helyisegadat: TBitBtn [9]
    Left = 16
    Top = 137
    Width = 198
    Height = 25
    Caption = 'Helyis'#233'gek '#233's csarnok'
    TabOrder = 9
    OnClick = helyisegadatClick
  end
  object bb_lakasszerz: TBitBtn [10]
    Left = 16
    Top = 168
    Width = 198
    Height = 25
    Caption = 'Lak'#225's szerz'#337'd'#233'sek'
    TabOrder = 10
    OnClick = bb_lakasszerzClick
  end
  object bb_hiba: TBitBtn [11]
    Left = 16
    Top = 420
    Width = 190
    Height = 25
    Caption = 'Hibalista ment'#233'se'
    TabOrder = 11
    OnClick = bb_hibaClick
  end
  object helyisegszerz: TBitBtn [12]
    Left = 16
    Top = 199
    Width = 198
    Height = 25
    Caption = 'Helyis'#233'g szerz'#337'd'#233'sek'
    TabOrder = 12
    OnClick = helyisegszerzClick
  end
  object csarnokszerzodes: TBitBtn [13]
    Left = 16
    Top = 230
    Width = 198
    Height = 25
    Caption = 'Csarnok szerz'#337'd'#233'sek'
    TabOrder = 13
    OnClick = csarnokszerzodesClick
  end
  object lakasszamlak: TBitBtn [14]
    Left = 16
    Top = 261
    Width = 198
    Height = 25
    Caption = 'Lak'#225's sz'#225'ml'#225'k'
    TabOrder = 14
    OnClick = lakasszamlakClick
  end
  object helyisegszamla: TBitBtn [15]
    Left = 16
    Top = 292
    Width = 198
    Height = 25
    Caption = 'Helyis'#233'g, csarnok sz'#225'ml'#225'k'
    TabOrder = 15
    OnClick = helyisegszamlaClick
  end
  object lakasvefiz: TBitBtn [16]
    Left = 16
    Top = 323
    Width = 198
    Height = 25
    Caption = 'Lak'#225's befizet'#233'sek'
    TabOrder = 16
    OnClick = lakasvefizClick
  end
  object bb_helyisegbefizetes: TBitBtn [17]
    Left = 16
    Top = 354
    Width = 198
    Height = 25
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
  inherited LISTA: TADOQuery
    Left = 456
    Top = 80
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
