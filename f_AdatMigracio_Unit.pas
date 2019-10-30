unit f_AdatMigracio_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, AlapSzures_Unit, Data.DB,
  Data.Win.ADODB, Vcl.WinXCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ExtCtrls, Alap, Alapfuggveny, System.StrUtils;

type
  Tf_AdatMigracio = class(TAlapSzures)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    m: TMemo;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    BitBtn9: TBitBtn;
    BitBtn10: TBitBtn;
    BitBtn11: TBitBtn;
    BitBtn12: TBitBtn;
    BitBtn13: TBitBtn;
    ADOQuery1: TADOQuery;
    ADOQuery2: TADOQuery;
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  f_AdatMigracio: Tf_AdatMigracio;

implementation

{$R *.dfm}

uses AlapAdat;

procedure Tf_AdatMigracio.BitBtn2Click(Sender: TObject);
var s,t,u: String;
    l: TStringList;
begin
  inherited;
  l := TStringList.Create;
  SZURES.Active:=False;
  SZURES.SQL.Text:=
    'Select a.* From JurtaTV_teszt.dbo.Nberlok a Where a.AKTIV=1 Order By a.NEV ';
  SZURES.Active:=True;
  SZURES.First;
  while not SZURES.Eof do
  begin
    s:=''; t:=''; u:='';
    //Nincs a TIR-ben
//    if SZURES.FieldByName('SZERVEZET_ID').AsString='' then
    begin
      if SZURES.FieldByName('FIZETESMOD').AsString='Átutalás' then s:='1';
      if SZURES.FieldByName('FIZETESMOD').AsString='Csekk' then s:='3';
      if SZURES.FieldByName('TIPUS').AsString='Személy' then t:='42';
      if SZURES.FieldByName('TEVEKENYSEG').AsString<>'' then
      begin
        LISTA.SQL.Text:=
          'Select tev_id From tevekenyseg Where tev_nev='+
          IDCHAR+SZURES.FieldByName('TEVEKENYSEG').AsString+IDCHAR;
        LISTA.Active:=True;
        if LISTA.RecordCount>0 then u:=LISTA.FieldByName('tev_id').AsString;
      end;
//      m.Lines.Add(
//        'Insert Into SZERVEZET Values(Null,Null,'+
//        IDCHAR+SZURES.FieldByName('NEV').AsString+IDCHAR+',Null,Null,'+
//        IDCHAR+SZURES.FieldByName('ADOSZAM').AsString+IDCHAR+','+
//        IDCHAR+SZURES.FieldByName('CEGJEGYZEKSZAM').AsString+IDCHAR+','+
//        IDCHAR+SZURES.FieldByName('BANKSZAMLA').AsString+IDCHAR+',Null,'+
//        IDCHAR+'21001231'+IDCHAR+','+
//        IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR+')');
      try
        SZER_ID:=Beszuras('SZERVEZET',[
          'szervezet_nev='+SZURES.FieldByName('NEV').AsString,
          'adoszam='+SZURES.FieldByName('ADOSZAM').AsString,
          'cegjegyzekszam='+SZURES.FieldByName('CEGJEGYZEKSZAM').AsString,
          'bankszamlaszam='+SZURES.FieldByName('BANKSZAMLA').AsString,
          'szervezet_kezdete='+'20060101',
          'szervezet_vege='+StrDate(MAXDAT),
          'fm_id='+s,
          'tev_id='+u,
          'szervezet_tipus_id='+t,
          'megjegyzes='+SZURES.FieldByName('MEGJEGYZES').AsString,
          'jurta_kod='+SZURES.FieldByName('KOD').AsString
          ]);
      except
        if Length(SZURES.FieldByName('CEGJEGYZEKSZAM').AsString)>12 then
          m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz cégjegyzékszám!');
        if Length(SZURES.FieldByName('ADOSZAM').AsString)>13 then
          m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz adószám!');
        SZURES.Next;
        Continue;
      end;
      LISTA.SQL.Text:=
        'Select szervezet_id From szervezet Where jurta_kod='+
        SZURES.FieldByName('KOD').AsString;
      LISTA.Active:=True;
      if LISTA.FieldByName('szervezet_id').AsString<>'' then
      begin
        SZER_ID:=LISTA.FieldByName('szervezet_id').AsString;
        if TrimStr(SZURES.FieldByName('TELEFON').AsString)<>'' then
        begin
          //Van már telefon (5) elérése?
          LISTA.SQL.Text:=
            'Select b.eleres_id From szervezet_eleres a, eleres b Where '+
            'a.eleres_id=b.eleres_id and b.eleres_tipus_id=5 and '+
            'a.szervezet_id='+SZER_ID;
          LISTA.Active:=True;
          if LISTA.RecordCount>0 then //Ha igen, akkor módosíjuk
          begin
            Modositas('eleres',[
              'eleres_nev='+SZURES.FieldByName('telefon').AsString
            ],'eleres_id='+LISTA.FieldByName('eleres_id').AsString);
          end
          else
          begin
            ELE_ID:=Beszuras('eleres',[
              'eleres_nev='+SZURES.FieldByName('telefon').AsString,
              'eleres_megjegyzes='+'JURTA adatkonvertálás',
              'eleres_tipus_id=5',
              'eleres_kezdete='+'20000101',
              'eleres_vege='+StrDate(MAXDAT)
            ]);
            Beszuras('szervezet_eleres',[
              'szer_eleres_sorszam=0',
              'szervezet_id='+SZER_ID,
              'eleres_id='+ELE_ID,
              'szer_eleres_kezdete='+'20000101',
              'szer_eleres_vege='+StrDate(MAXDAT)
            ]);
          end;
        end;
        if TrimStr(SZURES.FieldByName('EMAIL').AsString)<>'' then
        begin
          //Van már e-mail (9) elérése?
          LISTA.SQL.Text:=
            'Select b.eleres_id From szervezet_eleres a, eleres b Where '+
            'a.eleres_id=b.eleres_id and b.eleres_tipus_id=9 and '+
            'a.szervezet_id='+SZER_ID;
          LISTA.Active:=True;
          if LISTA.RecordCount>0 then //Ha igen, akkor módosíjuk
          begin
            Modositas('eleres',[
              'eleres_nev='+SZURES.FieldByName('email').AsString
            ],'eleres_id='+LISTA.FieldByName('eleres_id').AsString);
          end
          else
          begin
            ELE_ID:=Beszuras('eleres',[
              'eleres_nev='+SZURES.FieldByName('email').AsString,
              'eleres_megjegyzes='+'JURTA adatkonvertálás',
              'eleres_tipus_id=9',
              'eleres_kezdete='+'20000101',
              'eleres_vege='+StrDate(MAXDAT)
            ]);
            Beszuras('szervezet_eleres',[
              'szer_eleres_sorszam=0',
              'szervezet_id='+SZER_ID,
              'eleres_id='+ELE_ID,
              'szer_eleres_kezdete='+'20000101',
              'szer_eleres_vege='+StrDate(MAXDAT)
            ]);
          end;
        end;
        if TrimStr(SZURES.FieldByName('IRSZ').AsString)<>'' then
        begin
          //Van már levelezési (postai) cím (8) elérése?
          LISTA.SQL.Text:=
            'Select b.eleres_id From szervezet_eleres a, eleres b Where '+
            'a.eleres_id=b.eleres_id and b.eleres_tipus_id=8 and '+
            'a.szervezet_id='+SZER_ID;
          LISTA.Active:=True;
          if LISTA.RecordCount>0 then //Ha igen, akkor módosíjuk
          begin
            Modositas('eleres',[
              'eleres_nev='+SZURES.FieldByName('IRSZ').AsString+' '+SZURES.FieldByName('helyseg').AsString+', '+SZURES.FieldByName('utca').AsString
            ],'eleres_id='+LISTA.FieldByName('eleres_id').AsString);
          end
          else
          begin
            //Most "csak" az elérés táblában rögzítjük és nem lesz CIM tábla kapcsolata
            ELE_ID:=Beszuras('eleres',[
              'eleres_nev='+SZURES.FieldByName('IRSZ').AsString+' '+SZURES.FieldByName('helyseg').AsString+', '+SZURES.FieldByName('utca').AsString,
              'eleres_megjegyzes='+'JURTA adatkonvertálás',
              'eleres_tipus_id=8',
              'eleres_kezdete='+'20000101',
              'eleres_vege='+StrDate(MAXDAT)
            ]);
            Beszuras('szervezet_eleres',[
              'szer_eleres_sorszam=0',
              'szervezet_id='+SZER_ID,
              'eleres_id='+ELE_ID,
              'szer_eleres_kezdete='+'20000101',
              'szer_eleres_vege='+StrDate(MAXDAT)
            ]);
          end;
        end;
        if TrimStr(SZURES.FieldByName('SZEKHELY').AsString)<>'' then
        begin
          //Van már székhely cím (12) elérése?
          LISTA.SQL.Text:=
            'Select b.eleres_id From szervezet_eleres a, eleres b Where '+
            'a.eleres_id=b.eleres_id and b.eleres_tipus_id=12 and '+
            'a.szervezet_id='+SZER_ID;
          LISTA.Active:=True;
          if LISTA.RecordCount>0 then //Ha igen, akkor módosíjuk
          begin
            Modositas('eleres',[
              'eleres_nev='+SZURES.FieldByName('szekhely').AsString
            ],'eleres_id='+LISTA.FieldByName('eleres_id').AsString);
          end
          else
          begin
            //Most "csak" az elérés táblában rögzítjük és nem lesz CIM tábla kapcsolata
            ELE_ID:=Beszuras('eleres',[
              'eleres_nev='+SZURES.FieldByName('szekhely').AsString,
              'eleres_megjegyzes='+'JURTA adatkonvertálás',
              'eleres_tipus_id=12',
              'eleres_kezdete='+'20000101',
              'eleres_vege='+StrDate(MAXDAT)
            ]);
            Beszuras('szervezet_eleres',[
              'szer_eleres_sorszam=0',
              'szervezet_id='+SZER_ID,
              'eleres_id='+ELE_ID,
              'szer_eleres_kezdete='+'20000101',
              'szer_eleres_vege='+StrDate(MAXDAT)
            ]);
          end;
        end;
        //Képviselõi adatok kezelése
        if TrimStr(SZURES.FieldByName('KEPVISELO').AsString)<>'' then
        begin
          //Rögzíteni személyként
          l.Clear;
          l:=ParseString(SZURES.FieldByName('KEPVISELO').AsString,' ',False,'',1);
          s:=LeftStr(l[0],20);
          t:=LeftStr(l[1],20);
          try
            SZEM_ID:=Beszuras('szemely',[
              'szerepkor_id=22',
              'vezetekneve1='+s,
              'keresztneve1='+t,
              'anyja_neve='+SZURES.FieldByName('ANYJANEVE').AsString,
              'szemely_teljes_neve='+SZURES.FieldByName('KEPVISELO').AsString,
              'szemely_megjegyzes='+'JURTA adatkonvertálás',
              'szuletesi_hely='+SZURES.FieldByName('SZULETESIHELY').AsString,
              'szemelyi_szam='+LeftStr(SZURES.FieldByName('SZIGSZAM').AsString,11),
              'szemely_kezdete='+'20000101',
              'szemely_vege='+StrDate(MAXDAT)
            ]);
          except
            if s='' then
              m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz vagy hiányos vezetéknév!');
            if t='' then
              m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz vagy hiányos keresztnév!');
            SZURES.Next;
            Continue;
          end;
          Beszuras('szervezet_szemely',[
            'szervezet_id='+SZER_ID,
            'szemely_id='+SZEM_ID,
            'szerepkor_id=22',
            'szsz_mettol='+'20000101',
            'szsz_meddig='+StrDate(MAXDAT)
          ]);
          //Most "csak" az elérés táblában rögzítjük és nem lesz CIM tábla kapcsolata
          if TrimStr(SZURES.FieldByName('LAKCIM').AsString)<>'' then
          begin
            ELE_ID:=Beszuras('eleres',[
              'eleres_nev='+SZURES.FieldByName('LAKCIM').AsString,
              'eleres_megjegyzes='+'JURTA adatkonvertálás',
              'eleres_tipus_id=8',
              'eleres_kezdete='+'20000101',
              'eleres_vege='+StrDate(MAXDAT)
            ]);
            Beszuras('szemely_eleres',[
              'szem_eleres_sorszam=0',
              'szemely_id='+SZEM_ID,
              'eleres_id='+ELE_ID,
              'szem_eleres_kezdete='+'20000101',
              'szem_eleres_vege='+StrDate(MAXDAT)
            ]);
          end;
        end;
        //Ügyintézõ adatok kezelése
        if TrimStr(SZURES.FieldByName('UGYINTEZO').AsString)<>'' then
        begin
          //Rögzíteni személyként
          l.Clear;
          l:=ParseString(SZURES.FieldByName('UGYINTEZO').AsString,' ',False,'',1);
          s:=LeftStr(l[0],20);
          t:=LeftStr(l[1],20);
          try
            SZEM_ID:=Beszuras('szemely',[
              'szerepkor_id=8', //ügyintézõ
              'vezetekneve1='+s,
              'keresztneve1='+t,
              'szemely_teljes_neve='+SZURES.FieldByName('UGYINTEZO').AsString,
              'szemely_megjegyzes='+'JURTA adatkonvertálás',
              'szemely_kezdete='+'20000101',
              'szemely_vege='+StrDate(MAXDAT)
            ]);
          except
            if s='' then
              m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz vagy hiányos vezetéknév!');
            if t='' then
              m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz vagy hiányos keresztnév!');
            SZURES.Next;
            Continue;
          end;
          Beszuras('szervezet_szemely',[
            'szervezet_id='+SZER_ID,
            'szemely_id='+SZEM_ID,
            'szerepkor_id=8',
            'szsz_mettol='+'20000101',
            'szsz_meddig='+StrDate(MAXDAT)
          ]);
        end;
        //Kapcsolattartó adatok kezelése
        if TrimStr(SZURES.FieldByName('levelnev').AsString)<>'' then
        begin
          //Rögzíteni személyként
          l.Clear;
          l:=ParseString(SZURES.FieldByName('levelnev').AsString,' ',False,'',1);
          s:=LeftStr(l[0],20);
          t:=LeftStr(l[1],20);
          try
            SZEM_ID:=Beszuras('szemely',[
              'szerepkor_id=23', //kapcsolattartó
              'vezetekneve1='+s,
              'keresztneve1='+t,
              'szemely_teljes_neve='+SZURES.FieldByName('levelnev').AsString,
              'szemely_megjegyzes='+'JURTA adatkonvertálás',
              'szemely_kezdete='+'20000101',
              'szemely_vege='+StrDate(MAXDAT)
            ]);
          except
            if s='' then
              m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz vagy hiányos vezetéknév!');
            if t='' then
              m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz vagy hiányos keresztnév!');
            SZURES.Next;
            Continue;
          end;
          Beszuras('szervezet_szemely',[
            'szervezet_id='+SZER_ID,
            'szemely_id='+SZEM_ID,
            'szerepkor_id=23',
            'szsz_mettol='+'20000101',
            'szsz_meddig='+StrDate(MAXDAT)
          ]);
        end;
      end;
    end;
    SZURES.Next;
  end;
  //Csarnok bérlõk feldolgozása

end;

procedure Tf_AdatMigracio.BitBtn3Click(Sender: TObject);
var s,t,u: String;
    l: TStringList;
begin
  inherited;
  l := TStringList.Create;
  SZURES.Active:=False;
  SZURES.SQL.Text:=
    'Select a.* From JurtaTV_teszt.dbo.Csberlok a Where a.AKTIV=1 Order By a.NEV ';
  SZURES.Active:=True;
  SZURES.First;
  while not SZURES.Eof do
  begin
    s:=''; t:=''; u:='';
    //Nincs a TIR-ben
//    if SZURES.FieldByName('SZERVEZET_ID').AsString='' then
    begin
      if SZURES.FieldByName('FIZETESMOD').AsString='Átutalás' then s:='1';
      if SZURES.FieldByName('FIZETESMOD').AsString='Csekk' then s:='3';
      if SZURES.FieldByName('TIPUS').AsString='Személy' then t:='42';
      if SZURES.FieldByName('TEVEKENYSEG').AsString<>'' then
      begin
        LISTA.SQL.Text:=
          'Select tev_id From tevekenyseg Where tev_nev='+
          IDCHAR+SZURES.FieldByName('TEVEKENYSEG').AsString+IDCHAR;
        LISTA.Active:=True;
        if LISTA.RecordCount>0 then u:=LISTA.FieldByName('tev_id').AsString;
      end;
//      m.Lines.Add(
//        'Insert Into SZERVEZET Values(Null,Null,'+
//        IDCHAR+SZURES.FieldByName('NEV').AsString+IDCHAR+',Null,Null,'+
//        IDCHAR+SZURES.FieldByName('ADOSZAM').AsString+IDCHAR+','+
//        IDCHAR+SZURES.FieldByName('CEGJEGYZEKSZAM').AsString+IDCHAR+','+
//        IDCHAR+SZURES.FieldByName('BANKSZAMLA').AsString+IDCHAR+',Null,'+
//        IDCHAR+'21001231'+IDCHAR+','+
//        IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR+')');
      try
        SZER_ID:=Beszuras('SZERVEZET',[
          'szervezet_nev='+SZURES.FieldByName('NEV').AsString,
          'adoszam='+SZURES.FieldByName('ADOSZAM').AsString,
          'cegjegyzekszam='+SZURES.FieldByName('CEGJEGYZEKSZAM').AsString,
          'bankszamlaszam='+SZURES.FieldByName('BANKSZAMLA').AsString,
          'szervezet_kezdete='+'20060101',
          'szervezet_vege='+StrDate(MAXDAT),
          'vall_ig='+SZURES.FieldByName('VALLALKOZIG').AsString,
          'fm_id='+s,
          'tev_id='+u,
          'szervezet_tipus_id='+t,
          'megjegyzes='+SZURES.FieldByName('MEGJEGYZES').AsString,
          'jurta_kod='+SZURES.FieldByName('KOD').AsString
          ]);
      except
        if Length(SZURES.FieldByName('CEGJEGYZEKSZAM').AsString)>12 then
          m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz cégjegyzékszám!');
        if Length(SZURES.FieldByName('ADOSZAM').AsString)>13 then
          m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz adószám!');
        SZURES.Next;
        Continue;
      end;
      LISTA.SQL.Text:=
        'Select szervezet_id From szervezet Where jurta_kod='+
        SZURES.FieldByName('KOD').AsString;
      LISTA.Active:=True;
      if LISTA.FieldByName('szervezet_id').AsString<>'' then
      begin
        SZER_ID:=LISTA.FieldByName('szervezet_id').AsString;
        if TrimStr(SZURES.FieldByName('TELEFON').AsString)<>'' then
        begin
          //Van már telefon (5) elérése?
          LISTA.SQL.Text:=
            'Select b.eleres_id From szervezet_eleres a, eleres b Where '+
            'a.eleres_id=b.eleres_id and b.eleres_tipus_id=5 and '+
            'a.szervezet_id='+SZER_ID;
          LISTA.Active:=True;
          if LISTA.RecordCount>0 then //Ha igen, akkor módosíjuk
          begin
            Modositas('eleres',[
              'eleres_nev='+SZURES.FieldByName('telefon').AsString
            ],'eleres_id='+LISTA.FieldByName('eleres_id').AsString);
          end
          else
          begin
            ELE_ID:=Beszuras('eleres',[
              'eleres_nev='+SZURES.FieldByName('telefon').AsString,
              'eleres_megjegyzes='+'JURTA adatkonvertálás',
              'eleres_tipus_id=5',
              'eleres_kezdete='+'20000101',
              'eleres_vege='+StrDate(MAXDAT)
            ]);
            Beszuras('szervezet_eleres',[
              'szer_eleres_sorszam=0',
              'szervezet_id='+SZER_ID,
              'eleres_id='+ELE_ID,
              'szer_eleres_kezdete='+'20000101',
              'szer_eleres_vege='+StrDate(MAXDAT)
            ]);
          end;
        end;
        if TrimStr(SZURES.FieldByName('EMAIL').AsString)<>'' then
        begin
          //Van már e-mail (9) elérése?
          LISTA.SQL.Text:=
            'Select b.eleres_id From szervezet_eleres a, eleres b Where '+
            'a.eleres_id=b.eleres_id and b.eleres_tipus_id=9 and '+
            'a.szervezet_id='+SZER_ID;
          LISTA.Active:=True;
          if LISTA.RecordCount>0 then //Ha igen, akkor módosíjuk
          begin
            Modositas('eleres',[
              'eleres_nev='+SZURES.FieldByName('email').AsString
            ],'eleres_id='+LISTA.FieldByName('eleres_id').AsString);
          end
          else
          begin
            ELE_ID:=Beszuras('eleres',[
              'eleres_nev='+SZURES.FieldByName('email').AsString,
              'eleres_megjegyzes='+'JURTA adatkonvertálás',
              'eleres_tipus_id=9',
              'eleres_kezdete='+'20000101',
              'eleres_vege='+StrDate(MAXDAT)
            ]);
            Beszuras('szervezet_eleres',[
              'szer_eleres_sorszam=0',
              'szervezet_id='+SZER_ID,
              'eleres_id='+ELE_ID,
              'szer_eleres_kezdete='+'20000101',
              'szer_eleres_vege='+StrDate(MAXDAT)
            ]);
          end;
        end;
        if TrimStr(SZURES.FieldByName('IRSZ').AsString)<>'' then
        begin
          //Van már levelezési (postai) cím (8) elérése?
          LISTA.SQL.Text:=
            'Select b.eleres_id From szervezet_eleres a, eleres b Where '+
            'a.eleres_id=b.eleres_id and b.eleres_tipus_id=8 and '+
            'a.szervezet_id='+SZER_ID;
          LISTA.Active:=True;
          if LISTA.RecordCount>0 then //Ha igen, akkor módosíjuk
          begin
            Modositas('eleres',[
              'eleres_nev='+SZURES.FieldByName('IRSZ').AsString+' '+SZURES.FieldByName('helyseg').AsString+', '+SZURES.FieldByName('utca').AsString
            ],'eleres_id='+LISTA.FieldByName('eleres_id').AsString);
          end
          else
          begin
            //Most "csak" az elérés táblában rögzítjük és nem lesz CIM tábla kapcsolata
            ELE_ID:=Beszuras('eleres',[
              'eleres_nev='+SZURES.FieldByName('IRSZ').AsString+' '+SZURES.FieldByName('helyseg').AsString+', '+SZURES.FieldByName('utca').AsString,
              'eleres_megjegyzes='+'JURTA adatkonvertálás',
              'eleres_tipus_id=8',
              'eleres_kezdete='+'20000101',
              'eleres_vege='+StrDate(MAXDAT)
            ]);
            Beszuras('szervezet_eleres',[
              'szer_eleres_sorszam=0',
              'szervezet_id='+SZER_ID,
              'eleres_id='+ELE_ID,
              'szer_eleres_kezdete='+'20000101',
              'szer_eleres_vege='+StrDate(MAXDAT)
            ]);
          end;
        end;
        if TrimStr(SZURES.FieldByName('SZEKHELY').AsString)<>'' then
        begin
          //Van már székhely cím (12) elérése?
          LISTA.SQL.Text:=
            'Select b.eleres_id From szervezet_eleres a, eleres b Where '+
            'a.eleres_id=b.eleres_id and b.eleres_tipus_id=12 and '+
            'a.szervezet_id='+SZER_ID;
          LISTA.Active:=True;
          if LISTA.RecordCount>0 then //Ha igen, akkor módosíjuk
          begin
            Modositas('eleres',[
              'eleres_nev='+SZURES.FieldByName('szekhely').AsString
            ],'eleres_id='+LISTA.FieldByName('eleres_id').AsString);
          end
          else
          begin
            //Most "csak" az elérés táblában rögzítjük és nem lesz CIM tábla kapcsolata
            ELE_ID:=Beszuras('eleres',[
              'eleres_nev='+SZURES.FieldByName('szekhely').AsString,
              'eleres_megjegyzes='+'JURTA adatkonvertálás',
              'eleres_tipus_id=12',
              'eleres_kezdete='+'20000101',
              'eleres_vege='+StrDate(MAXDAT)
            ]);
            Beszuras('szervezet_eleres',[
              'szer_eleres_sorszam=0',
              'szervezet_id='+SZER_ID,
              'eleres_id='+ELE_ID,
              'szer_eleres_kezdete='+'20000101',
              'szer_eleres_vege='+StrDate(MAXDAT)
            ]);
          end;
        end;
        //Képviselõi adatok kezelése
        if TrimStr(SZURES.FieldByName('KEPVISELO').AsString)<>'' then
        begin
          //Rögzíteni személyként
          l.Clear;
          l:=ParseString(SZURES.FieldByName('KEPVISELO').AsString,' ',False,'',1);
          s:=LeftStr(l[0],20);
          t:=LeftStr(l[1],20);
          try
            SZEM_ID:=Beszuras('szemely',[
              'szerepkor_id=22',
              'vezetekneve1='+s,
              'keresztneve1='+t,
              'anyja_neve='+SZURES.FieldByName('ANYJANEVE').AsString,
              'szemely_teljes_neve='+SZURES.FieldByName('KEPVISELO').AsString,
              'szemely_megjegyzes='+'JURTA adatkonvertálás',
              'szuletesi_hely='+SZURES.FieldByName('SZULETESIHELY').AsString,
              'szemelyi_szam='+LeftStr(SZURES.FieldByName('SZIGSZAM').AsString,11),
              'szemely_kezdete='+'20000101',
              'szemely_vege='+StrDate(MAXDAT)
            ]);
          except
            if s='' then
              m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz vagy hiányos vezetéknév!');
            if t='' then
              m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz vagy hiányos keresztnév!');
            SZURES.Next;
            Continue;
          end;
          Beszuras('szervezet_szemely',[
            'szervezet_id='+SZER_ID,
            'szemely_id='+SZEM_ID,
            'szerepkor_id=22',
            'szsz_mettol='+'20000101',
            'szsz_meddig='+StrDate(MAXDAT)
          ]);
          //Most "csak" az elérés táblában rögzítjük és nem lesz CIM tábla kapcsolata
          if TrimStr(SZURES.FieldByName('KEPCIM').AsString)<>'' then
          begin
            ELE_ID:=Beszuras('eleres',[
              'eleres_nev='+SZURES.FieldByName('KEPCIM').AsString,
              'eleres_megjegyzes='+'JURTA adatkonvertálás',
              'eleres_tipus_id=8',
              'eleres_kezdete='+'20000101',
              'eleres_vege='+StrDate(MAXDAT)
            ]);
            Beszuras('szemely_eleres',[
              'szem_eleres_sorszam=0',
              'szemely_id='+SZEM_ID,
              'eleres_id='+ELE_ID,
              'szem_eleres_kezdete='+'20000101',
              'szem_eleres_vege='+StrDate(MAXDAT)
            ]);
          end;
        end;
        //Képviselõi adatok kezelése
        if TrimStr(SZURES.FieldByName('KEPVISELO2').AsString)<>'' then
        begin
          //Rögzíteni személyként
          l.Clear;
          l:=ParseString(SZURES.FieldByName('KEPVISELO2').AsString,' ',False,'',1);
          s:=LeftStr(l[0],20);
          t:=LeftStr(l[1],20);
          try
            SZEM_ID:=Beszuras('szemely',[
              'szerepkor_id=22',
              'vezetekneve1='+s,
              'keresztneve1='+t,
              'anyja_neve='+SZURES.FieldByName('ANYJANEVE').AsString,
              'szemely_teljes_neve='+SZURES.FieldByName('KEPVISELO').AsString,
              'szemely_megjegyzes='+'JURTA adatkonvertálás',
              'szuletesi_hely='+SZURES.FieldByName('SZULETESIHELY').AsString,
              'szemelyi_szam='+LeftStr(SZURES.FieldByName('SZIGSZAM').AsString,11),
              'szemely_kezdete='+'20000101',
              'szemely_vege='+StrDate(MAXDAT)
            ]);
          except
            if s='' then
              m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz vagy hiányos vezetéknév!');
            if t='' then
              m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz vagy hiányos keresztnév!');
            SZURES.Next;
            Continue;
          end;
          Beszuras('szervezet_szemely',[
            'szervezet_id='+SZER_ID,
            'szemely_id='+SZEM_ID,
            'szerepkor_id=22',
            'szsz_mettol='+'20000101',
            'szsz_meddig='+StrDate(MAXDAT)
          ]);
        end;
        //Ügyintézõ adatok kezelése
        if TrimStr(SZURES.FieldByName('UZLETVEZETO').AsString)<>'' then
        begin
          //Rögzíteni személyként
          l.Clear;
          l:=ParseString(SZURES.FieldByName('UZLETVEZETO').AsString,' ',False,'',1);
          s:=LeftStr(l[0],20);
          t:=LeftStr(l[1],20);
          try
            SZEM_ID:=Beszuras('szemely',[
              'szerepkor_id=8', //ügyintézõ
              'vezetekneve1='+s,
              'keresztneve1='+t,
              'szemely_teljes_neve='+SZURES.FieldByName('UZLETVEZETO').AsString,
              'szemely_megjegyzes='+'JURTA adatkonvertálás',
              'szemely_kezdete='+'20000101',
              'szemely_vege='+StrDate(MAXDAT)
            ]);
          except
            if s='' then
              m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz vagy hiányos vezetéknév!');
            if t='' then
              m.Lines.Add(SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString+' - Rossz vagy hiányos keresztnév!');
            SZURES.Next;
            Continue;
          end;
          Beszuras('szervezet_szemely',[
            'szervezet_id='+SZER_ID,
            'szemely_id='+SZEM_ID,
            'szerepkor_id=8',
            'szsz_mettol='+'20000101',
            'szsz_meddig='+StrDate(MAXDAT)
          ]);
          //Most "csak" az elérés táblában rögzítjük és nem lesz CIM tábla kapcsolata
          if TrimStr(SZURES.FieldByName('UZCIM').AsString)<>'' then
          begin
            ELE_ID:=Beszuras('eleres',[
              'eleres_nev='+SZURES.FieldByName('UZCIM').AsString,
              'eleres_megjegyzes='+'JURTA adatkonvertálás',
              'eleres_tipus_id=8',
              'eleres_kezdete='+'20000101',
              'eleres_vege='+StrDate(MAXDAT)
            ]);
            Beszuras('szemely_eleres',[
              'szem_eleres_sorszam=0',
              'szemely_id='+SZEM_ID,
              'eleres_id='+ELE_ID,
              'szem_eleres_kezdete='+'20000101',
              'szem_eleres_vege='+StrDate(MAXDAT)
            ]);
          end;
        end;
      end;
    end;
    SZURES.Next;
  end;
end;

procedure Tf_AdatMigracio.BitBtn5Click(Sender: TObject);
var bf, es, r, bj, bs: Integer;
begin
  inherited;
  //Feltételezzük, hogy minden helyiség kód szerepel a TIR-ben egyszer
  SZURES.Active:=False;
  SZURES.SQL.Text:=
    'Select a.* From JurtaTV_teszt.dbo.Nemlakas a Where a.AKTIV=1 Order By a.CIM ';
  SZURES.Active:=True;
  SZURES.First;
  while not SZURES.Eof do
  begin
    //HRSZ
    LISTA.SQL.Text:='Select x.nem_lakas_id, x.osszes_terulet, '+
    '(Select y.helyrajziszam From helyrajzi_szamok y Where y.hrsz_id=x.hrsz_id) as hrsz '+
    'From B_NEM_LAKAS x Where x.JURTA_KOD='+IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR;
    LISTA.Active:=True;
    if LISTA.FieldByName('hrsz').AsString<>SZURES.FieldByName('hrsz').AsString+'/'+SZURES.FieldByName('albetet').AsString then
       m.Lines.Add('HRSZ hiba: '+SZURES.FieldByName('KOD').AsString+' ('+SZURES.FieldByName('hrsz').AsString+'/'+SZURES.FieldByName('albetet').AsString+') - '+
       LISTA.FieldByName('nem_lakas_id').AsString+' ('+LISTA.FieldByName('hrsz').AsString+')');
    //terület
    if LISTA.FieldByName('osszes_terulet').AsString<>SZURES.FieldByName('alapterulet').AsString then
       m.Lines.Add('Terület hiba: '+SZURES.FieldByName('KOD').AsString+' ('+SZURES.FieldByName('alapterulet').AsString+') - '+
       LISTA.FieldByName('nem_lakas_id').AsString+' ('+LISTA.FieldByName('osszes_terulet').AsString+')');
    //megjegyzés
    if SZURES.FieldByName('MEGJEGYZES').AsString<>'' then
       Beszuras('MEGJEGYZES',[
        'NEM_LAKAS_ID='+LISTA.FieldByName('nem_lakas_id').AsString,
        'FELH_ID='+FELHASZNALO_ID,
        'MEGJEGYZES='+SZURES.FieldByName('MEGJEGYZES').AsString,
        'MEGJEGYZES_DATUM='+'20191231'
       ],False);
    if LISTA.FieldByName('nem_lakas_id').AsString<>'' then
    begin
      if SZURES.FieldByName('VIZMERO').AsString='1' then
         Modositas('B_NEM_LAKAS',[
          'B_VIZ=1',
          'B_VIZ_DATUMA='+StrDate(SZURES.FieldByName('VIZORADATUM').AsString)
         ],'NEM_LAKAS_ID='+LISTA.FieldByName('nem_lakas_id').AsString);
    end;
    SZURES.Next;
  end;
  //Csarnok rögzítése bérleményként
  SZURES.Active:=False;
  SZURES.SQL.Text:=
    'Select a.* From JurtaTV_teszt.dbo.Csberlemenyek';
  SZURES.Active:=True;
  SZURES.First;
  while not SZURES.Eof do
  begin
    SZER_ID:=''; bf:=0; es:=0;
    //Bérlemény fajta
    case SZURES.FieldByName('BERLEMENYFAJTA').AsInteger of
    0: begin bf:=25; r:=2; end;
    1: begin bf:=23; r:=2; end;
    2: begin bf:=27; r:=2; end;
    3: begin bf:=14; r:=2; end;
    4: begin bf:=26; r:=4; end;
    end;
    //Állapot kód - státusz
    case SZURES.FieldByName('ALLAPOTKOD').AsInteger of
    0: begin es:=2; bj:=0; end;
    1: begin es:=3; bj:=1; end;
    2: begin es:=4; bj:=9; end;
    4: begin es:=11; bj:=5 end;
    end;
    //Bérlõ feldolgozása
    LISTA.SQL.Text:=
      'Select szervezet_id From SZERVEZET Where JURTA_KOD='+
      SZURES.FieldByName('BERLOKOD').AsString;
    LISTA.Active:=True;
    if LISTA.RecordCount>0 then  SZER_ID:=LISTA.FieldByName('szervezet_id').AsString
    else
      m.Lines.Add(
      'Nincs a '+SZURES.FieldByName('CIM').AsString+' csarnok esetében a '+
      SZURES.FieldByName('BERLONEV').AsString+' bérlõ a TIR rendszerben!');
    BERL_ID:=Beszuras('berlemeny',[
      'bf_id='+IntToStr(bf),
      'rend_id='+IntToStr(r),
      'es_id='+IntToStr(es),
      'berl_terulet='+SZURES.FieldByName('ALAPTERULET').AsString,
      'berl_kiegter='+SZURES.FieldByName('KAPCSOLT').AsString,
      'berl_kiemelt='+SZURES.FieldByName('KIEMELT').AsString,
      'berl_aktiv='+SZURES.FieldByName('AKTIV').AsString,
      'berl_nev='+SZURES.FieldByName('CIM').AsString,
      'berl_megj='+SZURES.FieldByName('MEGJEGYZES').AsString,
      'jurta_kod='+SZURES.FieldByName('KOD').AsString
    ]);
    if SZER_ID<>'' then
    begin
      BERLO_ID:=Beszuras('BERLO',['szervezet_id='+SZER_ID]);
      try
        if SZURES.FieldByName('AKTIV').Asinteger=1 then bs:=3 else bs:=1;
        ADOQuery1.SQL.Text:=
          'Select MIN(JOGCIMKEZDET) as kezd, MAX(JOGCIMVEG) as veg '+
          'From Csszerzodes Where KOD='+IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR+
          ' and BERLOKOD='+IDCHAR+SZURES.FieldByName('BERLOKOD').AsString+IDCHAR;
        ADOQuery1.Active:=True;
      except
        m.Lines.Add('A '+SZURES.FieldByName('KOD').AsString+' bérleménynek nem találom a szerõdés dátumait!');
      end;
      try
        Beszuras('BERLO_KAPCSOLAT',[
          'BERLESJOG_ID='+IntToStr(bj),
          'BSTATUSZ_ID='+IntToStr(bs),
          'BERLO_ID='+BERLO_ID,
          'berl_id='+BERL_ID,
          'BERLES_KEZDET_DATUMA='+ADOQuery1.FieldByName('kezd').AsString,
          'BERLES_VEGE_DATUMA='+ADOQuery1.FieldByName('veg').AsString,
          'HASZNALT_TERULET='+FloatToStr(SZURES.FieldByName('ALAPTERULET').AsFloat+SZURES.FieldByName('KAPCSOLT').AsFloat)
        ]);
      except
        m.Lines.Add('A '+SZURES.FieldByName('KOD').AsString+' bérlemény bérlõ kapcsolata nem lett rögzítve!');
      end;
    end;
    SZURES.Next;
  end;
end;

procedure Tf_AdatMigracio.BitBtn7Click(Sender: TObject);
Var SD: TSaveDialog;
    F: TextFile;
    I: Integer;
begin
  SD:=TSaveDialog.Create(Self);
  SD.Filter:='Szöveges fájlok|*.txt';
  SD.DefaultExt:='*.txt';
  If SD.Execute Then
  Begin
    Szures.First;
    AssignFile(F, SD.FileName);
    ReWrite(F);
    For I:=0 To m.Lines.Count-1 Do
        Write(F, m.Lines[I], CRCHAR);
    WriteLn(F);
    CloseFile(F);
  End;
  FreeAndNil(SD);
end;

procedure Tf_AdatMigracio.BitBtn8Click(Sender: TObject);
var sza,bj,df, bs: Integer;
begin
  inherited;
  //Helyiség szerzõdések
  SZURES.SQL.Text:='Select * From Nszerzodes Where AKTIV=1';
  SZURES.Active:=True;
  while not SZURES.Eof do
  begin
    LISTA.SQL.Text:=
      'Select nem_lakas_id From B_NEM_LAKAS Where JURTA_KOD='+
      SZURES.FieldByName('KOD').AsString;
    LISTA.Active:=True;
    if LISTA.RecordCount=0 then
    begin
      m.Lines.Add('Nincs a TIR adatbázisban a '+SZURES.FieldByName('KOD').AsString+' érték!');
      SZURES.Next;
      Continue;
    end
    else
    begin
      NLAK_ID:=LISTA.FieldByName('nem_lakas_id').AsString;
      //Megvizsgálni, hogy feldolgoztuk-e már a szerzõdést
      LISTA.SQL.Text:=
        'Select count(bszerz_id) as db From berleti_szerzodes Where '+
        'jurta_kod='+SZURES.FieldByName('KAPCSOLT').AsString+
        ' or jurta_kod='+SZURES.FieldByName('SORSZAM').AsString;
      LISTA.Active:=True;
      if LISTA.RecordCount>0 then
      begin
        SZURES.Next;
        Continue;
      end;
      //Szerzõdés és hivatkozott szerzõdés, amibõl több is lehet
      ADOQuery1.SQL.Text:=
        'Select * From Nszerzodes Where '+
        'KAPCSOLT='+SZURES.FieldByName('KAPCSOLT').AsString+
        ' OR SORSZAM='+SZURES.FieldByName('KAPCSOLT').AsString+
        'Order By VALTOZAT';
      ADOQuery1.Active:=True;
      //Szerzõdés dátumai
      ADOQuery2.SQL.Text:=
        'Select MIN(jogcimkezdet) as kezd, MAX(jogcimveg) as veg '+
        'From Nszerzodes Where '+
        'KAPCSOLT='+SZURES.FieldByName('KAPCSOLT').AsString+
        ' OR SORSZAM='+SZURES.FieldByName('KAPCSOLT').AsString;
      ADOQuery2.Active:=True;
      //Bérlõ keresése a TIR-ben
      LISTA.SQL.Text:='Select szervezet_id From szervezet Where JURTA_KOD='+ADOQuery1.FieldByName('BERLOKOD').AsString;
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        m.Lines.Add('Nincs a TIR adatbázisban a '+SZURES.FieldByName('BERLOKOD').AsString+' szervezeti érték!');
        SZURES.Next;
        Continue;
      end
      else
      begin
        SZER_ID:=LISTA.FieldByName('szervezet_id').AsString;
        BERLO_ID:=Beszuras('BERLOK',['szervezet-id='+SZER_ID]);
        //Végig menni a szerzõdéseken, az elsõ lesz egy új szerzõdés a többi változás
        //Eredeti szerzõdés
        if ADOQuery1.FieldByName('VALTOZAT').AsInteger=0 then
        begin
          if ADOQuery2.FieldByName('veg').AsDateTime<date then sza:=6 else sza:=2;
          if ADOQuery2.FieldByName('veg').AsDateTime<date then bs:=3 else bs:=1;
          case ADOQuery1.FieldByName('JOGCIMKOD').AsInteger of
            1: bj:=1;
            2: bj:=3;
            3: bj:=12;
            6: bj:=9;
            7: bj:=13;
          end;
          if ADOQuery1.FieldByName('GYAKORISAG').AsInteger=1 then df:=5 else df:=2;
          BKAP_ID:=Beszuras('BERLO_KAPCSOLAT',[
            'berlo_id='+BERLO_ID,
            'berlesjog_id='+IntToStr(bj),
            'bstatusz_id='+IntToStr(bs),
            'nem_lakas_id='+NLAK_ID,
            'berles_kezdet_datuma='+ADOQuery2.FieldByName('kezd').AsString,
            'berles_vege_datuma='+ADOQuery2.FieldByName('veg').AsString
          ]);
          SZE_ID:=Beszuras('berleti_szerzodes',[
            'szi=2',
            'berlesjog_id='+IntToStr(bj),        //bérlésjog a jogcímbõl
            'sza_id='+IntToStr(sza),             //szerzõdés állapota
            'bt_id=2',                           //bérlemény típus = helyiség
            'dsz_id=2',                          //díjszámítás módja = piaci
            'df_id='+IntToStr(df),               //díjfizetés = havi
            'szerz_ev='+LeftStr(ADOQuery2.FieldByName('veg').AsString,4),
            'szerz_szam=0',
            'szerz_ter='+Valos(FloatToStr(SZURES.FieldByName('TERULET').AsFloat)),
            'bado_szama='+SZURES.FieldByName('HATAROZATSZAM').AsString,
            'bado_datuma='+SZURES.FieldByName('HATAROZATKELT').AsString,
            'berles_celja='+SZURES.FieldByName('CEL').AsString,
            'kiut_szama='+SZURES.FieldByName('KIUTALOSZAM').AsString,
            'kiut_datuma='+SZURES.FieldByName('KIUTALOKELT').AsString,
            'szerz_datum='+ADOQuery2.FieldByName('kezd').AsString,
            'szerz_mettol='+ADOQuery2.FieldByName('kezd').AsString,
            'szerz_meddig='+ADOQuery2.FieldByName('veg').AsString,
            'szerz_ovadek='+SZURES.FieldByName('OVADEK').AsString,
            'szerz_emeles='+SZURES.FieldByName('EMELESTILTAS').AsString,
            'szerz_automata='+SZURES.FieldByName('AUTOEMELES').AsString,
            'szerz_emelesszaz='+SZURES.FieldByName('emeles').AsString,
            'szerz_leiras='+SZURES.FieldByName('MEGJEGYZES').AsString,
            'berlo_id='+BERLO_ID,
            'jurta_kod='+SZURES.FieldByName('SORSZAM').AsString
          ],false);
          //Albérlõk kezelése
          if SZURES.FieldByName('AVEGE').AsDateTime>date then
          begin
            //Albérlõ keresése név alapján a TIR szervezetek között
            LISTA.SQL.Text:='Select szervezet_id From szervezet Where szervezet_nev='+SZURES.FieldByName('ALBERLO').AsString;
            LISTA.Active:=True;
            if LISTA.RecordCount=0 then
               SZER_ID:=Beszuras('szervezet',[
                'szervezet_nev='+SZURES.FieldByName('ALBERLO').AsString,
                'szervezet_kezdete='+ADOQuery2.FieldByName('kezd').AsString,
                'szervezet_vege='+StrDate(MAXDAT)
               ]);
            BERLO_ID:=Beszuras('berlok',[
              'szemely_id='+SZEM_ID,
              'szervezet_id='+SZER_ID
            ]);
            BKAP_ID:=Beszuras('berlo_kapcsolat',[
              'nem_lakas_id='+NLAK_ID,
              'berlo_id='+BERLO_ID,
              'berlesjog_id=5',
              'bstatusz_id=1',
              'berles_kezdet_datuma='+SZURES.FieldByName('JOGCIMKEZDET').AsString,
              'berles_vege_datuma='+SZURES.FieldByName('AVEGE').AsString,
              'hasznalt_terulet='+SZURES.FieldByName('ATERULET').AsString
            ]);
          end
          else
            //Ha lejárt az albérlet, akkor mint eseményt rögzítjük
            Beszuras('szerzodes_esemeny',[
              'bszerz_id='+SZE_ID,
              'felh_id=0',
              'sze_datum='+SZURES.FieldByName('AVEGE').AsString,
              'sze_leiras='+'Albérlõ: '+SZURES.FieldByName('ALBERLO').AsString+' - '+
                SZURES.FieldByName('ATELEPHELY').AsString+' - terület: '+
                SZURES.FieldByName('ATERULET').AsString
            ],false);
          //Szerzõdés események kezelée
          if SZURES.FieldByName('FELTETEL').AsString<>'' then
            Beszuras('szerzodes_esemeny',[
              'bszerz_id='+SZE_ID,
              'felh_id=0',
              'sze_datum='+ADOQuery2.FieldByName('kezd').AsString,
              'sze_leiras='+SZURES.FieldByName('FELTETEL').AsString
            ],false);
          if SZURES.FieldByName('VALTOZASOKA').AsString<>'' then
            Beszuras('szerzodes_esemeny',[
              'bszerz_id='+SZE_ID,
              'felh_id=0',
              'sze_datum='+SZURES.FieldByName('VALTOZASKELT').AsString,
              'sze_leiras='+SZURES.FieldByName('VALTOZASOKA').AsString
            ],false);
          if SZURES.FieldByName('RESZLETFIZETES').AsString='1' then
            Beszuras('szerzodes_esemeny',[
              'bszerz_id='+SZE_ID,
              'felh_id=0',
              'sze_datum='+SZURES.FieldByName('RESZLETKEZDET').AsString,
              'sze_leiras='+'Részletfizetés!'
            ],false);
          if SZURES.FieldByName('PERTIPUS').AsString='1' then
            Beszuras('szerzodes_esemeny',[
              'bszerz_id='+SZE_ID,
              'felh_id=0',
              'sze_datum='+SZURES.FieldByName('PERKEZDET').AsString,
              'sze_leiras='+SZURES.FieldByName('PERNEV').AsString
            ],false);
          //
        end;
        //Szerzõdés változások
        ADOQuery1.Next;
        while not ADOQuery1.Eof do
        begin
          Beszuras('berleti_szerzvalt',[
            'bszerz_id='+SZE_ID,
            'valtozas_szama='+ADOQuery1.FieldByName('VALTOZAT').AsString,
            'valtozas_datuma='+ADOQuery1.FieldByName('JOGCIMKEZDET').AsString,
            'valtozas_oka='+ADOQuery1.FieldByName('SORSZAM').AsString+' - '+
              'típus: '+ADOQuery1.FieldByName('TIPUS').AsString+' - '+
              'jogcím: '+ADOQuery1.FieldByName('JOGCIM').AsString+' - '+
              'ok: '+ADOQuery1.FieldByName('VALTOZASOKA').AsString+' - '+
              'megjegyzés: '+ADOQuery1.FieldByName('MEGJEGYZES').AsString
          ],false);
          ADOQuery1.Next;
        end;
      end;
    end;
    SZURES.Next;
  end;
end;

end.
