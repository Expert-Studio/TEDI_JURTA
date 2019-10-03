inherited f_AdatMigracio: Tf_AdatMigracio
  Caption = 'Adatmigr'#225'ci'#243
  ClientHeight = 509
  ClientWidth = 818
  ExplicitWidth = 834
  ExplicitHeight = 548
  PixelsPerInch = 96
  TextHeight = 13
  inherited Panel1: TPanel
    Top = 461
    Width = 818
    ExplicitTop = 461
    ExplicitWidth = 818
    inherited bb_kilep: TBitBtn
      Left = 774
      ExplicitLeft = 774
    end
    inherited bb_ok: TBitBtn
      Left = 732
      Visible = False
      ExplicitLeft = 732
    end
    inherited bb_nyomtat: TBitBtn
      Left = 690
      Visible = False
      ExplicitLeft = 690
    end
    inherited bb_excel: TBitBtn
      Left = 648
      ExplicitLeft = 648
    end
    inherited cb_uj: TCheckBox
      Left = 488
      ExplicitLeft = 488
    end
    inherited bb_csv: TBitBtn
      Left = 605
      Visible = False
      ExplicitLeft = 605
    end
  end
  inherited dbg_lista: TDBGrid
    Left = 168
    Width = 642
    Height = 279
  end
  inherited bb_uj: TBitBtn
    Left = 774
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
    Width = 133
    Height = 25
    Caption = 'Szem'#233'lyek'
    TabOrder = 4
  end
  object BitBtn2: TBitBtn [5]
    Left = 16
    Top = 44
    Width = 133
    Height = 25
    Caption = 'Szervezetek'
    TabOrder = 5
    OnClick = BitBtn2Click
  end
  object m: TMemo [6]
    Left = 168
    Top = 8
    Width = 642
    Height = 157
    Anchors = [akLeft, akTop, akRight]
    ScrollBars = ssBoth
    TabOrder = 6
    WordWrap = False
  end
  object BitBtn3: TBitBtn [7]
    Left = 16
    Top = 75
    Width = 133
    Height = 25
    Caption = 'Csarnok b'#233'rl'#337'k'
    TabOrder = 7
  end
  object BitBtn4: TBitBtn [8]
    Left = 16
    Top = 106
    Width = 133
    Height = 25
    Caption = 'Lak'#225'sok'
    TabOrder = 8
  end
  object BitBtn5: TBitBtn [9]
    Left = 16
    Top = 137
    Width = 133
    Height = 25
    Caption = 'Helyis'#233'gek '#233's csarnok'
    TabOrder = 9
  end
  object BitBtn6: TBitBtn [10]
    Left = 16
    Top = 168
    Width = 133
    Height = 25
    Caption = 'Szerz'#337'd'#233'sek'
    TabOrder = 10
  end
  inherited SZURESds: TDataSource
    Left = 332
    Top = 56
  end
  inherited SZURES: TADOQuery
    Connection = nil
  end
end
