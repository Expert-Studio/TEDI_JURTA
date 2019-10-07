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
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
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

end.
