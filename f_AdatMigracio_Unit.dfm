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
    ExplicitWidth = 818
    inherited bb_kilep: TBitBtn
      Left = 839
      ExplicitLeft = 774
    end
    inherited bb_ok: TBitBtn
      Left = 797
      Visible = False
      ExplicitLeft = 732
    end
    inherited bb_nyomtat: TBitBtn
      Left = 755
      Visible = False
      ExplicitLeft = 690
    end
    inherited bb_excel: TBitBtn
      Left = 713
      ExplicitLeft = 648
    end
    inherited cb_uj: TCheckBox
      Left = 553
      ExplicitLeft = 488
    end
    inherited bb_csv: TBitBtn
      Left = 670
      Visible = False
      ExplicitLeft = 605
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
    ExplicitLeft = 774
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
    ExplicitWidth = 133
  end
  object BitBtn2: TBitBtn [5]
    Left = 16
    Top = 44
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Szervezetek'
    TabOrder = 5
    OnClick = BitBtn2Click
    ExplicitWidth = 133
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
    ExplicitLeft = 168
  end
  object BitBtn3: TBitBtn [7]
    Left = 16
    Top = 75
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Csarnok b'#233'rl'#337'k'
    TabOrder = 7
    OnClick = BitBtn3Click
    ExplicitWidth = 133
  end
  object BitBtn4: TBitBtn [8]
    Left = 16
    Top = 106
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Lak'#225'sok'
    TabOrder = 8
    ExplicitWidth = 133
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
    ExplicitWidth = 133
  end
  object BitBtn6: TBitBtn [10]
    Left = 16
    Top = 168
    Width = 198
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Szerz'#337'd'#233'sek'
    TabOrder = 10
    ExplicitWidth = 133
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
    ExplicitWidth = 133
  end
  inherited SZURESds: TDataSource
    Left = 332
    Top = 56
  end
  inherited SZURES: TADOQuery
    Connection = AdatModul.JURTA
  end
end
