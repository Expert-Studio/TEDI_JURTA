unit f_AdatMigracio_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, AlapSzures_Unit, Data.DB,
  Data.Win.ADODB, Vcl.WinXCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ExtCtrls, Alap, Alapfuggveny, System.StrUtils;

type
  Tf_AdatMigracio = class(TAlapSzures)
    bb_szemely: TBitBtn;
    szervezet: TBitBtn;
    m: TMemo;
    csarnokberlo: TBitBtn;
    bb_lakasok: TBitBtn;
    helyisegadat: TBitBtn;
    BitBtn6: TBitBtn;
    bb_hiba: TBitBtn;
    helyisegszerz: TBitBtn;
    csarnokszerzodes: TBitBtn;
    BitBtn10: TBitBtn;
    helyisegszamla: TBitBtn;
    BitBtn12: TBitBtn;
    bb_helyisegbefizetes: TBitBtn;
    ADOQuery1: TADOQuery;
    ADOQuery2: TADOQuery;
    ADOQuery3: TADOQuery;
    procedure szervezetClick(Sender: TObject);
    procedure bb_hibaClick(Sender: TObject);
    procedure csarnokberloClick(Sender: TObject);
    procedure helyisegadatClick(Sender: TObject);
    procedure helyisegszerzClick(Sender: TObject);
    procedure helyisegszamlaClick(Sender: TObject);
    procedure bb_helyisegbefizetesClick(Sender: TObject);
    procedure bb_szemelyClick(Sender: TObject);
    procedure bb_lakasokClick(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure csarnokszerzodesClick(Sender: TObject);
    procedure BitBtn10Click(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
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

procedure Tf_AdatMigracio.helyisegszamlaClick(Sender: TObject);
var
  i,de: Integer;
  fm, szt, af, me, se, ea: String;
begin
  inherited;
  //Végig járni a számlafej táblákat...
  m.Lines.Add('Helyiség számlák átvétele ______________________________');
  for i := 1 to 24 do
  begin
    //Számlafej - esetleg csak az aktív szerzõdéseknek megfelelõ számlák
    SZURES.Active:=False;
    SZURES.SQL.Text:=
      'Select a.* From JurtaTV_teszt.dbo.Szlfej'+SzamlaEv[i]+'N a Order By a.SORSZAM ';
    SZURES.Active:=True;
    SZURES.First;
    while not SZURES.Eof do
    begin
      //Bérlõ keresése a TIR-ben
      LISTA.SQL.Text:='Select szervezet_id From szervezet Where JURTA_KOD='+SZURES.FieldByName('BERLOKOD').AsString;
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        m.Lines.Add('- nincs a TIR adatbázisban a "'+SZURES.FieldByName('BERLOKOD').AsString+'" szervezeti érték!');
        SZURES.Next;
        Continue;
      end;
      SZER_ID:=LISTA.FieldByName('szervezet_id').AsString;
      //Bérlemény
      LISTA.SQL.Text:='Select nem_lakas_id From b_nem_lakas a Where a.JURTA_KOD='+SZURES.FieldByName('KOD').AsString;
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        m.Lines.Add('- nincs a TIR adatbázisban a "'+SZURES.FieldByName('KOD').AsString+'" helyiség érték!');
        SZURES.Next;
        Continue;
      end;
      BERL_ID:=LISTA.FieldByName('nem_lakas_id').AsString;
      //Szerzõdés keresése a TIR-ben bérlemény (BERL_ID) és bérlõ (BERLO_ID) alapján - bérleti szerzõdés
      LISTA.SQL.Text:=
        'Select a.bszerz_id From szerzodes_kapocs a, berleti_szerzodes b Where a.nem_lakas_id='+BERL_ID+' '+
        'and a.bszerz_id=a.bszerz_id and b.berlo_id=(Select x.berlo_id From berlok x Where x.szervezet_id='+SZER_ID+')';
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        m.Lines.Add('- nincs a TIR adatbázisban a "'+SZURES.FieldByName('KOD').AsString+'"-hoz tartozó szerzõdés érték!');
        SZURES.Next;
        Continue;
      end;
      SZE_ID:=LISTA.FieldByName('bszerz_id').AsString;
      //Fizetési mód
      if SZURES.FieldByName('FIZMOD').AsString='Átutalás' then fm:='1';
      if SZURES.FieldByName('FIZMOD').AsString='Csekk' then fm:='3';
      //Ha a számlaérték negatív, akkor sztornó számla
      if SZURES.FieldByName('SZAMLAERTEK').AsInteger<0 then szt:='3' else szt:='1';
      try
        SZAMLA_ID:=Beszuras('szamla',[
          'bszerz_id='+SZE_ID,
          'szt_id='+szt,
          'fm_id='+fm,
          'berlo_id='+BERLO_ID,
          'penz_id=2',             //magyar forint
          'felh_id='+FELHASZNALO_ID,
          'szamla_szama='+SZURES.FieldByName('SORSZAM').AsString,
          'szamla_kelte='+SZURES.FieldByName('KELT').AsString,
          'szamla_teljesites='+SZURES.FieldByName('TELJESITES').AsString,
          'szamla_hatarido='+SZURES.FieldByName('ESEDEKES').AsString,
          'szamla_osszdij='+SZURES.FieldByName('SZAMLAERTEK').AsString,
          'szamla_nyomtatva=1',
          'szamla_peldany='+SZURES.FieldByName('PELDANY').AsString,
          'szamla_ev='+SZURES.FieldByName('KONYVEV').AsString,
          'szamla_ho='+SZURES.FieldByName('KONYVHO').AsString
        ]);
      except
        m.Lines.Add('- hibás számla rögzítés ('+SZURES.FieldByName('SORSZAM').AsString+')');
      end;
      //Számlatörzs
      ADOQuery1.SQL.Text:='Select * From JurtaTV_teszt.dbo.szlsor'+SzamlaEv[i]+'N Where sorszam='+SZURES.FieldByName('SORSZAM').AsString;
      ADOQuery1.Active:=True;
      while not ADOQuery1.eof do
      begin
        //Díjelem átkódolás
        if ADOQuery1.FieldByName('DIJKOD').AsString = '0' then de:=1;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '01' then de:=1;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '02' then de:=2;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '03' then de:=3;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '04' then de:=4;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '05' then de:=5;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '06' then de:=6;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '10' then de:=9;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '11' then de:=12;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '20' then de:=10;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '21' then de:=13;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '30' then de:=11;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '50' then de:=14;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '07' then de:=7;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '60' then de:=8;
        //Mennyiségi keresés
        LISTA.SQL.Text:='Select me_id From szerzodes_dijelem Where szde_id='+IntToStr(de);
        LISTA.Active:=True;
        if LISTA.RecordCount=0 then
        begin
          m.Lines.Add('- nincs a TIR adatbázisban a "'+ADOQuery1.FieldByName('DIJKOD').AsString+'" díjelem nem található!');
          SZURES.Next;
          Continue;
        end
        else
        begin
          me:=LISTA.FieldByName('me_id').AsString;
          se:=LISTA.FieldByName('szdt_id').AsString;
          ea:=LISTA.FieldByName('szde_egysegar').AsString;
        end;
        //Áfakulcs keresés
        LISTA.SQL.Text:='Select afa_id From afa Where afa_szazalek='+ADOQuery1.FieldByName('afakulcs').AsString;
        LISTA.Active:=True;
        if LISTA.RecordCount=0 then
        begin
          m.Lines.Add('- nincs a TIR adatbázisban a "'+ADOQuery1.FieldByName('afakulcs').AsString+'" értékû ÁFA kulcs!');
          SZURES.Next;
          Continue;
        end
        else
          af:=LISTA.FieldByName('afa_id').AsString;
        //Tétel rögzítés
        try
          Beszuras('szamla_tetel',[
            'szamla_id='+SZAMLA_ID,
            'me_id='+me,
            'afa_id='+af,
            'szdt_id='+se,
            'szamlat_menny=1',
            'szamlat_ea='+ea,
            'szamlat_netto='+ADOQuery1.FieldByName('ALAP').AsString,
            'szamlat_afa='+ADOQuery1.FieldByName('AFA').AsString,
            'szamlat_brutto='+ADOQuery1.FieldByName('BRUTTO').AsString
          ]);
        except
          m.Lines.Add('- hibás számlatétel rögzítés ('+SZURES.FieldByName('SORSZAM').AsString+')');
        end;
        ADOQuery1.Next;
      end;
      //Visszérkezõ számlák kezelése
      ADOQuery1.SQL.Text:='Select * From JurtaTV_teszt.dbo.vszamlak Where szamlaszam='+SZURES.FieldByName('SORSZAM').AsString;
      ADOQuery1.Active:=True;
      while not ADOQuery1.Eof do
      begin
        Beszuras('szamla_megjegyzes',[
          'szmt_id=8',
          'berlo_id='+BERLO_ID,
          'szamla_id='+SZAMLA_ID,
          'szm_datum='+StrDate(ADOQuery1.FieldByName('VISSZAERKEZES').AsString),
          'szm_szoveg='+ADOQuery1.FieldByName('MEGJEGYZES').AsString
        ]);
        if StrDate(ADOQuery1.FieldByName('UJRAPOSTAZAS').AsString)<>''then
           Beszuras('szamla_megjegyzes',[
            'szmt_id=9',
            'berlo_id='+BERLO_ID,
            'szamla_id='+SZAMLA_ID,
            'szm_datum='+StrDate(ADOQuery1.FieldByName('UJRAPOSTAZAS').AsString)
          ]);
        ADOQuery1.Next;
      end;
      SZURES.Next;
    end;
  end;
  m.Lines.Add('Csarnok számlák átvétele ______________________________');
  //Számlafej - esetleg csak az aktív szerzõdéseknek megfelelõ számlák
  SZURES.Active:=False;
  SZURES.SQL.Text:=
    'Select a.* From JurtaTV_teszt.dbo.Csszamfej a Where Order By a.SORSZAM ';
  SZURES.Active:=True;
  SZURES.First;
  while not SZURES.Eof do
  begin
    //Bérlõ keresése a TIR-ben
    LISTA.SQL.Text:='Select szervezet_id From szervezet Where JURTA_KOD='+SZURES.FieldByName('BERLOKOD').AsString;
    LISTA.Active:=True;
    if LISTA.RecordCount=0 then
    begin
      m.Lines.Add('Nincs a TIR adatbázisban a "'+SZURES.FieldByName('BERLOKOD').AsString+'" szervezeti érték!');
      SZURES.Next;
      Continue;
    end;
    SZER_ID:=LISTA.FieldByName('szervezet_id').AsString;
    //Bérlemény nincs benne közvetlenül a csarnok számlákban, így a csarnok bérlemény bérlõ kódra keresve lehet megtalálni
    ADOQuery1.SQL.Text:='Select a.KOD From csberlemenyek a Where a.BERLOKOD='+SZURES.FieldByName('BERLOKOD').AsString;
    ADOQuery1.Active:=True;
    if ADOQuery1.RecordCount=0 then
    begin
      m.Lines.Add('- nincs a "'+SZURES.FieldByName('BERLOKOD').AsString+'" bérlõhöz csarnok bérlemény rendelve.');
      SZURES.Next;
      Continue;
    end;
    LISTA.SQL.Text:='Select berl_id From berlemeny a Where a.JURTA_KOD='+ADOQuery1.FieldByName('KOD').AsString;
    LISTA.Active:=True;
    if LISTA.RecordCount=0 then
    begin
      m.Lines.Add('- nincs a TIR adatbázisban a "'+SZURES.FieldByName('KOD').AsString+'" csarnok érték!');
      SZURES.Next;
      Continue;
    end;
    BERL_ID:=LISTA.FieldByName('berl_id').AsString;
    //Szerzõdés keresése a TIR-ben bérlemény (BERL_ID) és bérlõ (BERLO_ID) alapján - bérleti szerzõdés
    LISTA.SQL.Text:=
      'Select a.bszerz_id From szerzodes_kapocs a, berleti_szerzodes b Where a.berl_id='+BERL_ID+' '+
      'and a.bszerz_id=a.bszerz_id and b.berlo_id=(Select x.berlo_id From berlok x Where x.szervezet_id='+SZER_ID+')';
    LISTA.Active:=True;
    if LISTA.RecordCount=0 then
    begin
      m.Lines.Add('- nincs a TIR adatbázisban a "'+SZURES.FieldByName('KOD').AsString+'"-hoz tartozó szerzõdés érték!');
      SZURES.Next;
      Continue;
    end;
    SZE_ID:=LISTA.FieldByName('bszerz_id').AsString;
    //Fizetési mód
    if SZURES.FieldByName('FIZMOD').AsString='Átutalás' then fm:='1';
    if SZURES.FieldByName('FIZMOD').AsString='Csekk' then fm:='3';
    //Ha a számlaérték negatív, akkor sztornó számla
    if SZURES.FieldByName('SZAMLAERTEK').AsInteger<0 then szt:='3' else szt:='1';
    try
      SZAMLA_ID:=Beszuras('szamla',[
        'bszerz_id='+SZE_ID,
        'szt_id='+szt,
        'fm_id='+fm,
        'berlo_id='+BERLO_ID,
        'penz_id=2',             //magyar forint
        'felh_id='+FELHASZNALO_ID,
        'szamla_szama='+SZURES.FieldByName('SORSZAM').AsString,
        'szamla_kelte='+SZURES.FieldByName('KELT').AsString,
        'szamla_teljesites='+SZURES.FieldByName('TELJESITES').AsString,
        'szamla_hatarido='+SZURES.FieldByName('ESEDEKES').AsString,
        'szamla_osszdij='+SZURES.FieldByName('SZAMLAERTEK').AsString,
        'szamla_nyomtatva=1',
        'szamla_peldany='+SZURES.FieldByName('PELDANY').AsString,
        'szamla_ev='+SZURES.FieldByName('KONYVEV').AsString,
        'szamla_ho='+SZURES.FieldByName('KONYVHO').AsString
      ]);
    except
      m.Lines.Add('- hibás számla rögzítés ('+SZURES.FieldByName('SORSZAM').AsString+')');
    end;
    //Számlatörzs
    ADOQuery1.SQL.Text:='Select * From JurtaTV_teszt.dbo.Csszamtar Where sorszam='+SZURES.FieldByName('SORSZAM').AsString;
    ADOQuery1.Active:=True;
    while not ADOQuery1.eof do
    begin
      //Díjelem átkódolás
      if ADOQuery1.FieldByName('DIJKOD').AsString = '0' then de:=1;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '01' then de:=1;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '02' then de:=2;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '03' then de:=3;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '04' then de:=4;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '05' then de:=5;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '06' then de:=6;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '10' then de:=9;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '11' then de:=12;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '20' then de:=10;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '21' then de:=13;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '30' then de:=11;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '50' then de:=14;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '07' then de:=7;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '60' then de:=8;
      //Mennyiségi keresés
      LISTA.SQL.Text:='Select me_id From szerzodes_dijelem Where szde_id='+IntToStr(de);
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        m.Lines.Add('- nincs a TIR adatbázisban a "'+ADOQuery1.FieldByName('DIJKOD').AsString+'" díjelem nem található!');
        SZURES.Next;
        Continue;
      end
      else
      begin
        me:=LISTA.FieldByName('me_id').AsString;
        se:=LISTA.FieldByName('szdt_id').AsString;
        ea:=LISTA.FieldByName('szde_egysegar').AsString;
      end;
      //Áfakulcs keresés
      LISTA.SQL.Text:='Select afa_id From afa Where afa_szazalek='+ADOQuery1.FieldByName('afakulcs').AsString;
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        m.Lines.Add('- nincs a TIR adatbázisban a "'+ADOQuery1.FieldByName('afakulcs').AsString+'" értékû ÁFA kulcs!');
        SZURES.Next;
        Continue;
      end
      else
        af:=LISTA.FieldByName('afa_id').AsString;
      //Tétel rögzítés
      try
        Beszuras('szamla_tetel',[
          'szamla_id='+SZAMLA_ID,
          'me_id='+me,
          'afa_id='+af,
          'szdt_id='+se,
          'szamlat_menny=1',
          'szamlat_ea='+ea,
          'szamlat_netto='+ADOQuery1.FieldByName('ALAP').AsString,
          'szamlat_afa='+ADOQuery1.FieldByName('AFA').AsString,
          'szamlat_brutto='+ADOQuery1.FieldByName('BRUTTO').AsString
        ]);
      except
        m.Lines.Add('- hibás számlatétel rögzítés ('+SZURES.FieldByName('SORSZAM').AsString+')');
      end;
      ADOQuery1.Next;
    end;
    //Visszérkezõ számlák kezelése
    ADOQuery1.SQL.Text:='Select * From JurtaTV_teszt.dbo.vszamlak Where szamlaszam='+SZURES.FieldByName('SORSZAM').AsString;
    ADOQuery1.Active:=True;
    while not ADOQuery1.Eof do
    begin
      Beszuras('szamla_megjegyzes',[
        'szmt_id=8',
        'berlo_id='+BERLO_ID,
        'szamla_id='+SZAMLA_ID,
        'szm_datum='+StrDate(ADOQuery1.FieldByName('VISSZAERKEZES').AsString),
        'szm_szoveg='+ADOQuery1.FieldByName('MEGJEGYZES').AsString
      ]);
      if StrDate(ADOQuery1.FieldByName('UJRAPOSTAZAS').AsString)<>''then
         Beszuras('szamla_megjegyzes',[
          'szmt_id=9',
          'berlo_id='+BERLO_ID,
          'szamla_id='+SZAMLA_ID,
          'szm_datum='+StrDate(ADOQuery1.FieldByName('UJRAPOSTAZAS').AsString)
        ]);
      ADOQuery1.Next;
    end;
    SZURES.Next;
  end;
end;

procedure Tf_AdatMigracio.szervezetClick(Sender: TObject);
var s,t,u: String;
    l: TStringList;
begin
  inherited;
  l := TStringList.Create;
  m.Lines.Add('Szervezetek átvétele ______________________________');
  SZURES.Active:=False;
  SZURES.SQL.Text:=
    'Select a.* From JurtaTV_teszt.dbo.Nberlok a Where a.AKTIV=1 Order By a.NEV ';
  SZURES.Active:=True;
  SZURES.First;
  while not SZURES.Eof do
  begin
    //Keresés a TIR rendszerben
    LISTA.SQL.Text:=
      'Select szervezet_id From SZERVEZET Where '+
      'jurta_kod='+IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR;
    LISTA.Active:=True;
    if LISTA.RecordCount>0 then
    begin
      m.Lines.Add('A szervezet már szerepel a TIR rendszerben. (kód: '+SZURES.FieldByName('KOD').AsString+') - '+SZURES.FieldByName('NEV').AsString);
      SZURES.Next;
      Continue;
    end;
    s:=''; t:=''; u:='';
    //Fizetési mód, típus és tevékenység kiolvasása
    if SZURES.FieldByName('FIZETESMOD').AsString='Átutalás' then s:='1';
    if SZURES.FieldByName('FIZETESMOD').AsString='Csekk' then s:='3';
    if SZURES.FieldByName('TIPUS').AsString='Személy' then t:='42';
    if SZURES.FieldByName('TEVEKENYSEG').AsString<>'' then
    begin
      LISTA.SQL.Text:=
        'Select tev_id From tevekenyseg Where tev_nev='+
        IDCHAR+SZURES.FieldByName('TEVEKENYSEG').AsString+IDCHAR;
      LISTA.Active:=True;
      if LISTA.RecordCount>0 then u:=LISTA.FieldByName('tev_id').AsString
      else
        m.Lines.Add('Nincs a TIR adatbázisban a "'+SZURES.FieldByName('TEVEKENYSEG').AsString+'" tevékenység érték!');
    end;
    //Keresés a TIR rendszerben
    LISTA.SQL.Text:=
      'Select szervezet_id From SZERVEZET Where '+
      'upper(szervezet_nev)='+IDCHAR+UpperCase(SZURES.FieldByName('NEV').AsString)+IDCHAR;
    LISTA.Active:=True;
    if LISTA.RecordCount=0 then
    begin
      LISTA.SQL.Text:=
        'Select szervezet_id From SZERVEZET Where '+
        '(szervezet_nev='+IDCHAR+StringReplace(SZURES.FieldByName('NEV').AsString,IDCHAR,'`',[rfReplaceAll])+IDCHAR+') or '+
        '(adoszam='+IDCHAR+SZURES.FieldByName('ADOSZAM').AsString+IDCHAR+') or '+
        '(cegjegyzekszam='+IDCHAR+SZURES.FieldByName('CEGJEGYZEKSZAM').AsString+IDCHAR+') or '+
        '(jurta_kod='+IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR+')';
      LISTA.Active:=True;
      if LISTA.RecordCount>1 then
      begin
         m.Lines.Add('Több találat! (kód: '+SZURES.FieldByName('KOD').AsString+') - '+SZURES.FieldByName('NEV').AsString);
         while not LISTA.Eof do
         begin
           m.Lines.Add(LISTA.FieldByName('szervezet_id').AsString);
           LISTA.Next;
         end;
         SZURES.Next;
         Continue;
      end;
    end;
    if LISTA.RecordCount=0 then
    begin
      //Nincs a TIR-ben
      try
        SZER_ID:=Beszuras('SZERVEZET',[
          'szervezet_nev='+StringReplace(SZURES.FieldByName('NEV').AsString,IDCHAR,'`',[rfReplaceAll]),
          'adoszam='+SZURES.FieldByName('ADOSZAM').AsString,
          'cegjegyzekszam='+SZURES.FieldByName('CEGJEGYZEKSZAM').AsString,
          'bankszamlaszam='+SZURES.FieldByName('BANKSZAMLA').AsString,
          'szervezet_kezdete='+'20060101',
          'szervezet_vege='+StrDate(MAXDAT),
          'fm_id='+s,
          'tev_id='+u,
          'szervezet_tipus_id='+t,
          'megjegyzes='+SZURES.FieldByName('MEGJEGYZES').AsString+' ('+SZURES.FieldByName('TEVEKENYSEG').AsString+')',
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
    end
    else
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
    if TrimStr(StringReplace(SZURES.FieldByName('szekhely').AsString,IDCHAR,'`',[rfReplaceAll]))<>'' then
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
          'eleres_nev='+StringReplace(SZURES.FieldByName('szekhely').AsString,IDCHAR,'`',[rfReplaceAll])
        ],'eleres_id='+LISTA.FieldByName('eleres_id').AsString);
      end
      else
      begin
        //Most "csak" az elérés táblában rögzítjük és nem lesz CIM tábla kapcsolata
        ELE_ID:=Beszuras('eleres',[
          'eleres_nev='+StringReplace(SZURES.FieldByName('szekhely').AsString,IDCHAR,'`',[rfReplaceAll]),
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
      if TrimStr(StringReplace(SZURES.FieldByName('LAKCIM').AsString,IDCHAR,'`',[rfReplaceAll]))<>'' then
      begin
        ELE_ID:=Beszuras('eleres',[
          'eleres_nev='+StringReplace(SZURES.FieldByName('LAKCIM').AsString,IDCHAR,'`',[rfReplaceAll]),
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
    if TrimStr(StringReplace(SZURES.FieldByName('levelnev').AsString,IDCHAR,'`',[rfReplaceAll]))<>'' then
    begin
      //Rögzíteni személyként
      l.Clear;
      l:=ParseString(StringReplace(SZURES.FieldByName('levelnev').AsString,IDCHAR,'`',[rfReplaceAll]),' ',False,'',1);
      s:=LeftStr(l[0],20);
      t:=LeftStr(l[1],20);
      try
        SZEM_ID:=Beszuras('szemely',[
          'szerepkor_id=23', //kapcsolattartó
          'vezetekneve1='+s,
          'keresztneve1='+t,
          'szemely_teljes_neve='+StringReplace(SZURES.FieldByName('levelnev').AsString,IDCHAR,'`',[rfReplaceAll]),
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
    SZURES.Next;
  end;
end;

procedure Tf_AdatMigracio.csarnokberloClick(Sender: TObject);
var s,t,u: String;
    l: TStringList;
begin
  inherited;
  l := TStringList.Create;
  m.Lines.Add('Csarnok bérlõk átvétele ______________________________');
  SZURES.Active:=False;
  SZURES.SQL.Text:=
    'Select a.* From JurtaTV_teszt.dbo.Csberlok a Where a.AKTIV=1 Order By a.NEV ';
  SZURES.Active:=True;
  SZURES.First;
  while not SZURES.Eof do
  begin
    //Keresés a TIR rendszerben
    LISTA.SQL.Text:=
      'Select szervezet_id From SZERVEZET Where '+
      'jurta_kod='+IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR;
    LISTA.Active:=True;
    if LISTA.RecordCount>0 then
    begin
      m.Lines.Add('A szervezet már szerepel a TIR rendszerben. (kód: '+SZURES.FieldByName('KOD').AsString+') - '+SZURES.FieldByName('NEV').AsString);
      SZURES.Next;
      Continue;
    end;
    s:=''; t:=''; u:='';
    if SZURES.FieldByName('FIZETESMOD').AsString='Készpénz' then s:='4';
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
    //Keresés a TIR rendszerben
    LISTA.SQL.Text:=
      'Select szervezet_id From SZERVEZET Where '+
      '(szervezet_nev='+IDCHAR+StringReplace(SZURES.FieldByName('NEV').AsString,IDCHAR,'`',[rfReplaceAll])+IDCHAR+') or '+
      '(adoszam='+IDCHAR+SZURES.FieldByName('ADOSZAM').AsString+IDCHAR+') or '+
      '(cegjegyzekszam='+IDCHAR+SZURES.FieldByName('CEGJEGYZEKSZAM').AsString+IDCHAR+') or '+
      '(jurta_kod='+IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR+')';
    LISTA.Active:=True;
    if LISTA.RecordCount=0 then
    //Nincs a TIR-ben
    begin
      try
        SZER_ID:=Beszuras('SZERVEZET',[
          'szervezet_nev='+StringReplace(SZURES.FieldByName('NEV').AsString,IDCHAR,'`',[rfReplaceAll]),
          'adoszam='+SZURES.FieldByName('ADOSZAM').AsString,
          'cegjegyzekszam='+SZURES.FieldByName('CEGJEGYZEKSZAM').AsString,
          'bankszamlaszam='+SZURES.FieldByName('BANKSZAMLA').AsString,
          'szervezet_kezdete='+'20060101',
          'szervezet_vege='+StrDate(MAXDAT),
          'vall_ig='+SZURES.FieldByName('VALLALKOZOIG').AsString,
          'fm_id='+s,
          'tev_id='+u,
          'szervezet_tipus_id='+t,
          'megjegyzes='+SZURES.FieldByName('MEGJEGYZES').AsString+' ('+SZURES.FieldByName('TEVEKENYSEG').AsString+')',
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
    end
    else
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
          'eleres_nev='+StringReplace(SZURES.FieldByName('szekhely').AsString,IDCHAR,'`',[rfReplaceAll])
        ],'eleres_id='+LISTA.FieldByName('eleres_id').AsString);
      end
      else
      begin
        //Most "csak" az elérés táblában rögzítjük és nem lesz CIM tábla kapcsolata
        ELE_ID:=Beszuras('eleres',[
          'eleres_nev='+StringReplace(SZURES.FieldByName('szekhely').AsString,IDCHAR,'`',[rfReplaceAll]),
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
          'eleres_nev='+StringReplace(SZURES.FieldByName('KEPCIM').AsString,IDCHAR,'`',[rfReplaceAll]),
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
    if (TrimStr(SZURES.FieldByName('KEPVISELO2').AsString)<>'') and
      (TrimStr(SZURES.FieldByName('KEPVISELO').AsString)<>TrimStr(SZURES.FieldByName('KEPVISELO2').AsString)) then
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
          'szemely_teljes_neve='+SZURES.FieldByName('KEPVISELO2').AsString,
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
          'eleres_nev='+StringReplace(SZURES.FieldByName('UZCIM').AsString,IDCHAR,'`',[rfReplaceAll]),
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
    SZURES.Next;
  end;
end;

procedure Tf_AdatMigracio.bb_helyisegbefizetesClick(Sender: TObject);
var i, de: Integer;
    BEF_ID, fm: String;
begin
  inherited;
  //Végig járni a befizetés táblákat...
  m.Lines.Add('Helyiség befizetések átvétele ______________________________');
  for i := 1 to 24 do
  begin
    //Számlafej
    SZURES.Active:=False;
    SZURES.SQL.Text:=
      'Select a.* From JurtaTV_teszt.dbo.Befiz'+SzamlaEv[i]+'N a '+
      'Where a.KOD in (Select x.KOD From Nemlakas x Where x.AKTIV=1) '+
      'Order By a.SORSZAM ';
    SZURES.Active:=True;
    SZURES.First;
    while not SZURES.Eof do
    begin
      fm:=''; de:=0; BERLO_ID:='';
      //Bérlõ keresése a TIR-ben
      LISTA.SQL.Text:=
        'Select a.berlo_id From berlok a, szervezet b '+
        'Where b.JURTA_KOD='+IDCHAR+SZURES.FieldByName('BERLOKOD').AsString+IDCHAR+' '+
        'and a.szervezet_id=b.szervezet_id';
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        m.Lines.Add('- nincs a TIR adatbázisban a "'+SZURES.FieldByName('BERLOKOD').AsString+'" szervezeti érték!');
        SZURES.Next;
        Continue;
      end;
      BERLO_ID:=LISTA.FieldByName('berlo_id').AsString;
      //Díjelem átkódolás
      if ADOQuery1.FieldByName('DIJKOD').AsString = '0' then de:=1;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '1' then de:=1;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '2' then de:=1;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '3' then de:=1;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '4' then de:=1;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '5' then de:=2;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '6' then de:=2;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '10' then de:=3;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '11' then de:=3;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '20' then de:=4;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '21' then de:=4;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '30' then de:=5;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '50' then de:=6;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '7' then de:=2;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '60' then de:=2;
      //Számlatétel keresése - számlaszám és díjkód alapján
      LISTA.SQL.Text:='Select b.szamlat_id '+
      'From szamla a, szama_tetel b '+
      'Where a.szamla_id=b.szamla_id and x.szamla_szama='+IDCHAR+SZURES.FieldByName('SZAMLASZAM').AsString+IDCHAR+' '+
      'and b.szdt_id='+IntToStr(de);
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        m.Lines.Add('- nincs a TIR adatbázisban a "'+SZURES.FieldByName('SZAMLASZAM').AsString+'" számla érték!');
        SZURES.Next;
        Continue;
      end;
      //Fizetési mód átkódolása - kérdéses, de a
      if SZURES.FieldByName('FIZMOD').AsString='0' then fm:='4';
      if SZURES.FieldByName('FIZMOD').AsString='1' then fm:='4';
      if SZURES.FieldByName('FIZMOD').AsString='3' then fm:='4';
      if SZURES.FieldByName('FIZMOD').AsString='4' then fm:='5';
      if SZURES.FieldByName('FIZMOD').AsString='9' then fm:='4';
      if fm='' then
      begin
        m.Lines.Add('- nincs a TIR adatbázisban a "'+SZURES.FieldByName('FIZMOD').AsString+'" fizetési módnak megfelelõ kód. ('+SZURES.FieldByName('SZAMLASZAM').AsString+')');
        SZURES.Next;
        Continue;
      end;
      //Befizetés rögzítése
      BEF_ID:=Beszuras('befizetes',[
        'berlo_id='+BERLO_ID,
        'fm_id='+fm,
        'felh_id=0',
        'befiz_sorszam='+SZURES.FieldByName('SORSZAM').AsString,
        'befiz_ev='+SZURES.FieldByName('EV').AsString,
        'befiz_ho='+SZURES.FieldByName('HO').AsString,
        'befiz_datum='+SZURES.FieldByName('DATUM').AsString,
        'befiz_alap='+SZURES.FieldByName('ALAP').AsString,
        'befiz_afa='+SZURES.FieldByName('AFA').AsString,
        'befiz_brutto='+SZURES.FieldByName('BRUTTO').AsString,
        'befiz_hiv='+SZURES.FieldByName('SZAMLASZAM').AsString+' - '+SZURES.FieldByName('DIJNEV').AsString+' - '+SZURES.FieldByName('HIVATKOZAS').AsString
      ]);
      //Számlatétel kapcsolat rögzítése
      Beszuras('befizetes_kapocs',[
        'befiz_id='+BEF_ID,
        'szamlat_id='+LISTA.FieldByName('szamlat_id').AsString,
        'bk_osszeg='+SZURES.FieldByName('BRUTTO').AsString
      ]);
      SZURES.Next;
    end;
  end;
  m.Lines.Add('Csarnok befizetések átvétele ______________________________');
  //Számlafej
  SZURES.Active:=False;
  SZURES.SQL.Text:=
    'Select a.* From JurtaTV_teszt.dbo.Csbefizet a '+
    'Where a.BERLOKOD in (Select x.KOD From Csberlok x Where x.AKTIV=1) '+
    'Order By a.SORSZAM ';
  SZURES.Active:=True;
  SZURES.First;
  while not SZURES.Eof do
  begin
    fm:=''; BERLO_ID:='';
    //Bérlõ keresése a TIR-ben
    LISTA.SQL.Text:=
      'Select a.berlo_id From berlok a, szervezet b '+
      'Where b.JURTA_KOD='+IDCHAR+SZURES.FieldByName('BERLOKOD').AsString+IDCHAR+' '+
      'and a.szervezet_id=b.szervezet_id';
    LISTA.Active:=True;
    if LISTA.RecordCount=0 then
    begin
      m.Lines.Add('- nincs a TIR adatbázisban a '+SZURES.FieldByName('BERLOKOD').AsString+' szervezeti érték!');
      SZURES.Next;
      Continue;
    end;
    BERLO_ID:=LISTA.FieldByName('berlo_id').AsString;
    //Díjelem átkódolás
    if ADOQuery1.FieldByName('DIJKOD').AsString = '00' then de:=1;
    if ADOQuery1.FieldByName('DIJKOD').AsString = '58' then de:=1;
    if ADOQuery1.FieldByName('DIJKOD').AsString = '64' then de:=1;
    if ADOQuery1.FieldByName('DIJKOD').AsString = '65' then de:=1;
    if ADOQuery1.FieldByName('DIJKOD').AsString = '66' then de:=1;
    if ADOQuery1.FieldByName('DIJKOD').AsString = '67' then de:=2;
    if ADOQuery1.FieldByName('DIJKOD').AsString = '68' then de:=2;
    if ADOQuery1.FieldByName('DIJKOD').AsString = '70' then de:=3;
    if SZURES.FieldByName('SZAMLASZAM').AsString<>'' then
    begin
      //Számlatétel keresése - számlaszám és díjkód alapján
      LISTA.SQL.Text:='Select b.szamlat_id '+
      'From szamla a, szama_tetel b '+
      'Where a.szamla_id=b.szamla_id and x.szamla_szama='+IDCHAR+SZURES.FieldByName('SZAMLASZAM').AsString+IDCHAR+' '+
      'and b.szdt_id='+IntToStr(de);
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        m.Lines.Add('- nincs a TIR adatbázisban a '+SZURES.FieldByName('SZAMLASZAM').AsString+' számla érték!');
        SZURES.Next;
        Continue;
      end;
    end;
    //Fizetési mód átkódolása - kérdéses, de a
    if SZURES.FieldByName('FIZMOD').AsString='Bank' then fm:='1';
    if SZURES.FieldByName('FIZMOD').AsString='Csekk' then fm:='3';
    if SZURES.FieldByName('FIZMOD').AsString='Kerekítés' then fm:='4';
    if SZURES.FieldByName('FIZMOD').AsString='Leírás' then fm:='5';
    if SZURES.FieldByName('FIZMOD').AsString='Pénztár' then fm:='4';
    //Befizetés rögzítése
    BEF_ID:=Beszuras('befizetes',[
      'berlo_id='+BERLO_ID,
      'fm_id='+fm,
      'felh_id=0',
      'befiz_sorszam='+SZURES.FieldByName('SORSZAM').AsString,
      'befiz_ev='+SZURES.FieldByName('EV').AsString,
      'befiz_ho='+SZURES.FieldByName('HO').AsString,
      'befiz_datum='+SZURES.FieldByName('DATUM').AsString,
      'befiz_alap='+SZURES.FieldByName('ALAP').AsString,
      'befiz_afa='+SZURES.FieldByName('AFA').AsString,
      'befiz_brutto='+SZURES.FieldByName('BRUTTO').AsString,
      'befiz_hiv='+SZURES.FieldByName('SZAMLASZAM').AsString+' - '+SZURES.FieldByName('DIJNEV').AsString+' - '+SZURES.FieldByName('HIVATKOZAS').AsString
    ]);
    //Számlatétel kapcsolat rögzítése
    Beszuras('befizetes_kapocs',[
      'befiz_id='+BEF_ID,
      'szamlat_id='+LISTA.FieldByName('szamlat_id').AsString,
      'bk_osszeg='+SZURES.FieldByName('BRUTTO').AsString
    ]);
    SZURES.Next;
  end;
end;

procedure Tf_AdatMigracio.helyisegadatClick(Sender: TObject);
var bf, es, r, bj, bs: Integer;
begin
  inherited;
  //Feltételezzük, hogy minden helyiség kód szerepel a TIR-ben egyszer
  m.Lines.Add('Helyiségek átvétele ______________________________');
  SZURES.Active:=False;
  SZURES.SQL.Text:=
    'Select a.* From JurtaTV_teszt.dbo.Nemlakas a Where a.AKTIV=1 Order By a.CIM ';
  SZURES.Active:=True;
  SZURES.First;
  while not SZURES.Eof do
  begin
    LISTA.SQL.Text:=
      'Select nem_lakas_id From B_NEM_LAKAS Where JURTA_KOD='+
      IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR;
    LISTA.Active:=True;
    if LISTA.RecordCount>0 then
    begin
      m.Lines.Add('Helyiség bérlemény már létezik a TIR-ben ('+SZURES.FieldByName('KOD').AsString+')');
      //HRSZ
      LISTA.SQL.Text:='Select x.nem_lakas_id, x.osszes_terulet, '+
      '(Select y.helyrajziszam From helyrajzi_szamok y Where y.hrsz_id=x.hrsz_id) as hrsz '+
      'From B_NEM_LAKAS x Where x.JURTA_KOD='+IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR;
      LISTA.Active:=True;
      if LISTA.FieldByName('hrsz').AsString<>SZURES.FieldByName('hrsz').AsString+'/'+SZURES.FieldByName('albetet').AsString then
         m.Lines.Add('- hrsz hiba: '+SZURES.FieldByName('KOD').AsString+' ('+SZURES.FieldByName('hrsz').AsString+'/'+SZURES.FieldByName('albetet').AsString+') - '+
         LISTA.FieldByName('nem_lakas_id').AsString+' ('+LISTA.FieldByName('hrsz').AsString+')');
      //terület
      if LISTA.FieldByName('osszes_terulet').AsString<>SZURES.FieldByName('alapterulet').AsString then
         m.Lines.Add('- terület hiba: '+SZURES.FieldByName('KOD').AsString+' ('+SZURES.FieldByName('alapterulet').AsString+') - '+
         LISTA.FieldByName('nem_lakas_id').AsString+' ('+LISTA.FieldByName('osszes_terulet').AsString+')');
      if LISTA.RecordCount>1 then
      begin
         m.Lines.Add('- több JURTA kód: '+SZURES.FieldByName('KOD').AsString);
         SZURES.Next;
         Continue;
      end;
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
    end
    else
      m.Lines.Add('A helyiség nem szerepel a TIR rendszerben. ('+SZURES.FieldByName('KOD').AsString+')');
    SZURES.Next;
  end;
  //Csarnok rögzítése bérleményként
  m.Lines.Add('Csarnok átvétele ______________________________');
  SZURES.Active:=False;
  SZURES.SQL.Text:='Select * From JurtaTV_teszt.dbo.Csberlemenyek';
  SZURES.Active:=True;
  SZURES.First;
  while not SZURES.Eof do
  begin
    LISTA.SQL.Text:=
      'Select berl_id From berlemeny Where JURTA_KOD='+
      IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR;
    LISTA.Active:=True;
    if LISTA.RecordCount=0 then
    begin
      m.Lines.Add('A csarnok bérlemény nem szerepel a TIR rendszerben. ('+SZURES.FieldByName('KOD').AsString+')');
      SZER_ID:=''; bf:=0; es:=0;
      //Bérlemény fajta
      case SZURES.FieldByName('BERLEMENYFAJTA').AsInteger of
      0: begin bf:=25; r:=2; end;
      1: begin bf:=23; r:=2; end;
      2: begin bf:=27; r:=2; end;
      3: begin bf:=14; r:=4; end;
      4: begin bf:=26; r:=3; end;
      end;
      //Állapot kód - státusz
      case SZURES.FieldByName('ALLAPOTKOD').AsInteger of
      0: begin es:=3; bj:=0; end;
      1: begin es:=2; bj:=1; end;
      2: begin es:=9; bj:=9; end;
      4: begin es:=37; bj:=5 end;
      end;
      //Bérlõ feldolgozása
      if SZURES.FieldByName('BERLOKOD').AsString<>'' then
      begin
        LISTA.SQL.Text:=
          'Select szervezet_id From szervezet Where JURTA_KOD='+
          IDCHAR+SZURES.FieldByName('BERLOKOD').AsString+IDCHAR;
        LISTA.Active:=True;
        if LISTA.RecordCount>0 then SZER_ID:=LISTA.FieldByName('szervezet_id').AsString
        else
        begin
          m.Lines.Add(
          '- a '+SZURES.FieldByName('CIM').AsString+' csarnok esetében a "'+
          SZURES.FieldByName('BERLONEV').AsString+'" bérlõ nincs a TIR rendszerben!');
        end;
      end;
      BERL_ID:=Beszuras('berlemeny',[
        'bf_id='+IntToStr(bf),
        'rend_id='+IntToStr(r),
        'statusz_id='+IntToStr(es),
        'berl_terulet='+Valos(SZURES.FieldByName('ALAPTERULET').AsString),
        'berl_kiegter='+Valos(SZURES.FieldByName('KAPCSOLT').AsString),
        'berl_kiemelt='+SZURES.FieldByName('KIEMELT').AsString,
        'berl_aktiv='+SZURES.FieldByName('AKTIV').AsString,
        'berl_nev='+SZURES.FieldByName('CIM').AsString,
  //      'berl_megj='+SZURES.FieldByName('MEGJEGYZES').AsString,
        'jurta_kod='+SZURES.FieldByName('KOD').AsString
      ]);
      //Megjegyzés
      if SZURES.FieldByName('MEGJEGYZES').AsString<>'' then
         Beszuras('MEGJEGYZES',[
          'berl_id='+BERL_ID,
          'FELH_ID='+FELHASZNALO_ID,
          'MEGJEGYZES='+SZURES.FieldByName('MEGJEGYZES').AsString,
          'MEGJEGYZES_DATUM='+'20191231'
         ],False);
      //Közmûvek
      if SZURES.FieldByName('VIZMERO').AsString<>'1' then
         Beszuras('KOZMU',[
          'berl_id='+BERL_ID,
          'kt_id=4',
          'kozmu_szama='+SZURES.FieldByName('VIZGYARI').AsString,
          'kozmu_datumtol='+'20060101',
          'kozmu_datumig='+'21001231'
         ],False);
      if SZURES.FieldByName('ARAMMERO').AsString<>'1' then
         Beszuras('KOZMU',[
          'berl_id='+BERL_ID,
          'kt_id=3',
          'kozmu_szama='+SZURES.FieldByName('ARAMGYARI').AsString,
          'kozmu_datumtol='+'20060101',
          'kozmu_datumig='+'21001231'
         ],False);
      if SZURES.FieldByName('GAZMERO').AsString<>'1' then
         Beszuras('KOZMU',[
          'berl_id='+BERL_ID,
          'kt_id=2',
          'kozmu_szama='+SZURES.FieldByName('GAZGYARI').AsString,
          'kozmu_datumtol='+'20060101',
          'kozmu_datumig='+'21001231'
         ],False);
      if SZER_ID<>'' then
      begin
        BERLO_ID:=Beszuras('BERLOK',['szervezet_id='+SZER_ID]);
        try
          if SZURES.FieldByName('AKTIV').Asinteger=1 then bs:=3 else bs:=1;
          ADOQuery1.SQL.Text:=
            'Select MIN(JOGCIMKEZDET) as kezd, MAX(JOGCIMVEG) as veg '+
            'From Csszerzodes Where KOD='+IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR+
            ' and BERLOKOD='+IDCHAR+SZURES.FieldByName('BERLOKOD').AsString+IDCHAR;
          ADOQuery1.Active:=True;
        except
          m.Lines.Add('- a '+SZURES.FieldByName('KOD').AsString+' bérleménynek nem találom a szerõdés dátumait!');
        end;
        try
          Beszuras('BERLO_KAPCSOLAT',[
            'BERLESJOG_ID='+IntToStr(bj),
            'BSTATUSZ_ID='+IntToStr(bs),
            'BERLO_ID='+BERLO_ID,
            'berl_id='+BERL_ID,
            'BERLES_KEZDET_DATUMA='+StrDate(ADOQuery1.FieldByName('kezd').AsString),
            'BERLES_VEGE_DATUMA='+StrDate(ADOQuery1.FieldByName('veg').AsString),
            'HASZNALT_TERULET='+FloatToStr(SZURES.FieldByName('ALAPTERULET').AsFloat+SZURES.FieldByName('KAPCSOLT').AsFloat)
          ]);
        except
          m.Lines.Add('- a '+SZURES.FieldByName('KOD').AsString+' bérlemény bérlõ kapcsolata nem lett rögzítve!');
        end;
      end;
    end
    else
      m.Lines.Add('Csarnok bérlemény már létezik a TIR-ben ('+SZURES.FieldByName('KOD').AsString+')');
    SZURES.Next;
  end;
end;

procedure Tf_AdatMigracio.bb_szemelyClick(Sender: TObject);
var s,t,u: String;
    l: TStringList;
begin
  inherited;
  l := TStringList.Create;
  m.Lines.Add('Személyek átvétele ______________________________');
  SZURES.Active:=False;
  SZURES.SQL.Text:=
    'Select a.* From JurtaTV_teszt.dbo.Lberlok a Where a.AKTIV=1 Order By a.NEV ';
  SZURES.Active:=True;
  SZURES.First;
  while not SZURES.Eof do
  begin
    //Keresés a TIR rendszerben
    LISTA.SQL.Text:=
      'Select szemely_id From SZEMELY Where '+
      'jurta_kod='+IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR;
    LISTA.Active:=True;
    if LISTA.RecordCount>0 then
    begin
      m.Lines.Add('A személy már szerepel a TIR rendszerben. (kód: '+SZURES.FieldByName('KOD').AsString+') - '+SZURES.FieldByName('NEV').AsString);
      SZURES.Next;
      Continue;
    end;
    s:=''; t:=''; u:='';
    //Fizetési mód, típus és tevékenység kiolvasása
    if SZURES.FieldByName('FIZMOD').AsString='Átutalás' then s:='1';
    if SZURES.FieldByName('FIZMOD').AsString='Csekk' then s:='3';
    if SZURES.FieldByName('FIZMOD').AsString='Beszedés' then s:='5';
    //Keresés a TIR rendszerben
    LISTA.SQL.Text:=
      'Select szemely_id From SZEMELY Where '+
      'upper(szemely_teljes_neve)='+IDCHAR+UpperCase(StringReplace(SZURES.FieldByName('NEV').AsString,IDCHAR,'`',[rfReplaceAll]))+IDCHAR;
    LISTA.Active:=True;
    if LISTA.RecordCount=0 then
    begin
      LISTA.SQL.Text:=
        'Select szemely_id From SZEMELY Where '+
        '(upper(szemely_teljes_neve)='+IDCHAR+UpperCase(StringReplace(SZURES.FieldByName('NEV').AsString,IDCHAR,'`',[rfReplaceAll]))+IDCHAR+') or '+
        '(szig_szam='+IDCHAR+SZURES.FieldByName('SZIG').AsString+IDCHAR+') or '+
        '(jurta_kod='+IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR+')';
      LISTA.Active:=True;
      if LISTA.RecordCount>1 then
      begin
         m.Lines.Add('- több találat! (kód: '+SZURES.FieldByName('KOD').AsString+') - '+SZURES.FieldByName('NEV').AsString);
         while not LISTA.Eof do
         begin
           m.Lines.Add('- TIR szemely_id: '+LISTA.FieldByName('szemely_id').AsString);
           LISTA.Next;
         end;
         SZURES.Next;
         Continue;
      end;
    end;
    if LISTA.RecordCount=0 then
    begin
      //Nincs a TIR-ben
      l.Clear;
      l:=ParseString(SZURES.FieldByName('NEV').AsString,' ',False,'',1);
      s:=LeftStr(l[0],20);
      try
        t:=LeftStr(l[1],20);
      except
      end;
      try
        SZEM_ID:=Beszuras('SZEMELY',[
          'szemely_teljes_neve='+StringReplace(SZURES.FieldByName('NEV').AsString,IDCHAR,'`',[rfReplaceAll]),
          'vezetekneve1='+s,
          'keresztneve1='+t,
          'anyja_neve='+SZURES.FieldByName('ANYJANEVE').AsString,
          'szig_szam='+SZURES.FieldByName('SZIG').AsString,
          'szuletesi_hely='+StringReplace(SZURES.FieldByName('SZULHELY').AsString,',','',[rfReplaceAll]),
          'szuletesi_datum='+StrDate(SZURES.FieldByName('SZULIDO').AsString),
          'leanykori_nev='+SZURES.FieldByName('SZULNEV').AsString,
          'szamlaszam='+SZURES.FieldByName('szamlaszam').AsString,
          'szemely_kezdete='+'20060101',
          'szemely_vege='+StrDate(MAXDAT),
          'szemely_megjegyzes='+SZURES.FieldByName('MEGJEGYZES').AsString,
          'jurta_kod='+SZURES.FieldByName('KOD').AsString
          ]);
      except
        m.Lines.Add('- hibás személy rögzítés: '+SZURES.FieldByName('KOD').AsString+'-'+SZURES.FieldByName('NEV').AsString);
        SZURES.Next;
        Continue;
      end;
    end
    else
      SZEM_ID:=LISTA.FieldByName('szemely_id').AsString;
    if TrimStr(SZURES.FieldByName('TELEFON').AsString)<>'' then
    begin
      //Van már telefon (5) elérése?
      LISTA.SQL.Text:=
        'Select b.eleres_id From szemely_eleres a, eleres b Where '+
        'a.eleres_id=b.eleres_id and b.eleres_tipus_id=5 and '+
        'a.szemely_id='+SZEM_ID;
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
        Beszuras('szemely_eleres',[
          'szem_eleres_sorszam=0',
          'szemely_id='+SZEM_ID,
          'eleres_id='+ELE_ID,
          'szem_eleres_kezdete='+'20000101',
          'szem_eleres_vege='+StrDate(MAXDAT)
        ]);
      end;
    end;
    if TrimStr(SZURES.FieldByName('EMAIL').AsString)<>'' then
    begin
      //Van már e-mail (9) elérése?
      LISTA.SQL.Text:=
        'Select b.eleres_id From szemely_eleres a, eleres b Where '+
        'a.eleres_id=b.eleres_id and b.eleres_tipus_id=9 and '+
        'a.szemely_id='+SZEM_ID;
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
        Beszuras('szemely_eleres',[
          'szem_eleres_sorszam=0',
          'szemely_id='+SZEM_ID,
          'eleres_id='+ELE_ID,
          'szem_eleres_kezdete='+'20000101',
          'szem_eleres_vege='+StrDate(MAXDAT)
        ]);
      end;
    end;
    if TrimStr(SZURES.FieldByName('IRSZ').AsString)<>'' then
    begin
      //Van már levelezési (postai) cím (8) elérése?
      LISTA.SQL.Text:=
        'Select b.eleres_id From szemely_eleres a, eleres b Where '+
        'a.eleres_id=b.eleres_id and b.eleres_tipus_id=8 and '+
        'a.szemely_id='+SZEM_ID;
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        //CIM táblába rögzíteni?
        //Most "csak" az elérés táblában rögzítjük és nem lesz CIM tábla kapcsolata
        ELE_ID:=Beszuras('eleres',[
          'eleres_nev='+SZURES.FieldByName('IRSZ').AsString+' '+
          StringReplace(SZURES.FieldByName('helyseg').AsString,',','',[rfReplaceAll])
          +', '+SZURES.FieldByName('utca').AsString,
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
    SZURES.Next;
  end;
end;

procedure Tf_AdatMigracio.BitBtn10Click(Sender: TObject);
var
  i,de: Integer;
  fm, szt, af, me, se, ea: String;
begin
  inherited;
  //Végig járni a számlafej táblákat...
  m.Lines.Add('Lakás számlák átvétele ______________________________');
  for i := 1 to 24 do
  begin
    //Számlafej - esetleg csak az aktív szerzõdéseknek megfelelõ számlák
    SZURES.Active:=False;
    SZURES.SQL.Text:=
      'Select a.* From JurtaTV_teszt.dbo.Szlfej'+SzamlaEv[i]+'L a Order By a.SORSZAM ';
    SZURES.Active:=True;
    SZURES.First;
    while not SZURES.Eof do
    begin
      //Bérlõ keresése a TIR-ben
      LISTA.SQL.Text:='Select szemely_id From szemely Where JURTA_KOD='+SZURES.FieldByName('BERLOKOD').AsString;
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        m.Lines.Add('- nincs a TIR adatbázisban a "'+SZURES.FieldByName('BERLOKOD').AsString+'" személy érték!');
        SZURES.Next;
        Continue;
      end;
      SZEM_ID:=LISTA.FieldByName('szemely_id').AsString;
      //Bérlemény
      LISTA.SQL.Text:='Select lakas_id From l_lakas a Where a.JURTA_KOD='+SZURES.FieldByName('KOD').AsString;
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        m.Lines.Add('- nincs a TIR adatbázisban a '+SZURES.FieldByName('KOD').AsString+' lakás érték!');
        SZURES.Next;
        Continue;
      end;
      BERL_ID:=LISTA.FieldByName('lakas_id').AsString;
      //Szerzõdés keresése a TIR-ben bérlemény (BERL_ID) és bérlõ (BERLO_ID) alapján - bérleti szerzõdés
      LISTA.SQL.Text:=
        'Select a.bszerz_id From szerzodes_kapocs a, berleti_szerzodes b Where a.lakas_id='+BERL_ID+' '+
        'and a.bszerz_id=a.bszerz_id and b.berlo_id=(Select x.berlo_id From berlok x Where x.szemely_id='+SZEM_ID+')';
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        m.Lines.Add('- nincs a TIR adatbázisban a '+SZURES.FieldByName('KOD').AsString+'-hoz tartozó szerzõdés érték!');
        SZURES.Next;
        Continue;
      end;
      SZE_ID:=LISTA.FieldByName('bszerz_id').AsString;
      //Fizetési mód
      if SZURES.FieldByName('FIZMOD').AsString='Beszedés' then fm:='5';
      if SZURES.FieldByName('FIZMOD').AsString='Átutalás' then fm:='1';
      if SZURES.FieldByName('FIZMOD').AsString='Csekk' then fm:='3';
      if SZURES.FieldByName('FIZMOD').AsString='Helyesbítõ' then fm:='3';
      //Ha a számlaérték negatív, akkor sztornó számla
      if SZURES.FieldByName('SZAMLAERTEK').AsInteger<0 then szt:='3' else szt:='1';
      try
        SZAMLA_ID:=Beszuras('szamla',[
          'bszerz_id='+SZE_ID,
          'szt_id='+szt,
          'fm_id='+fm,
          'berlo_id='+BERLO_ID,
          'penz_id=2',             //magyar forint
          'felh_id='+FELHASZNALO_ID,
          'szamla_szama='+SZURES.FieldByName('SORSZAM').AsString,
          'szamla_kelte='+SZURES.FieldByName('KELT').AsString,
          'szamla_teljesites='+SZURES.FieldByName('TELJESITES').AsString,
          'szamla_hatarido='+SZURES.FieldByName('ESEDEKES').AsString,
          'szamla_osszdij='+SZURES.FieldByName('SZAMLAERTEK').AsString,
          'szamla_nyomtatva=1',
          'szamla_peldany='+SZURES.FieldByName('PELDANY').AsString,
          'szamla_ev='+SZURES.FieldByName('KONYVEV').AsString,
          'szamla_ho='+SZURES.FieldByName('KONYVHO').AsString
        ]);
      except
        m.Lines.Add('- hibás számla rögzítés ('+SZURES.FieldByName('SORSZAM').AsString+')');
      end;
      //Számlatörzs
      ADOQuery1.SQL.Text:='Select * From JurtaTV_teszt.dbo.szlsor'+SzamlaEv[i]+'L Where sorszam='+SZURES.FieldByName('SORSZAM').AsString;
      ADOQuery1.Active:=True;
      while not ADOQuery1.eof do
      begin
        //Díjelem átkódolás
        if ADOQuery1.FieldByName('DIJKOD').AsString = '0' then de:=15;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '01' then de:=1;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '2' then de:=2;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '3' then de:=3;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '4' then de:=4;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '5' then de:=5;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '6' then de:=6;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '10' then de:=9;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '11' then de:=12;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '20' then de:=10;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '21' then de:=13;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '30' then de:=11;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '50' then de:=14;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '7' then de:=7;
        if ADOQuery1.FieldByName('DIJKOD').AsString = '60' then de:=8;
        //Mennyiségi keresés
        LISTA.SQL.Text:='Select me_id From szerzodes_dijelem Where szde_id='+IntToStr(de);
        LISTA.Active:=True;
        if LISTA.RecordCount=0 then
        begin
          m.Lines.Add('- nincs a TIR adatbázisban a "'+ADOQuery1.FieldByName('DIJKOD').AsString+'" díjelem nem található!');
          SZURES.Next;
          Continue;
        end
        else
        begin
          me:=LISTA.FieldByName('me_id').AsString;
          se:=LISTA.FieldByName('szdt_id').AsString;
          ea:=LISTA.FieldByName('szde_egysegar').AsString;
        end;
        //Áfakulcs keresés
        LISTA.SQL.Text:='Select afa_id From afa Where afa_szazalek='+ADOQuery1.FieldByName('afakulcs').AsString;
        LISTA.Active:=True;
        if LISTA.RecordCount=0 then
        begin
          m.Lines.Add('- nincs a TIR adatbázisban a "'+ADOQuery1.FieldByName('afakulcs').AsString+'" értékû ÁFA kulcs!');
          SZURES.Next;
          Continue;
        end
        else
          af:=LISTA.FieldByName('afa_id').AsString;
        //Tétel rögzítés
        try
          Beszuras('szamla_tetel',[
            'szamla_id='+SZAMLA_ID,
            'me_id='+me,
            'afa_id='+af,
            'szdt_id='+se,
            'szamlat_menny=1',
            'szamlat_ea='+ea,
            'szamlat_netto='+ADOQuery1.FieldByName('ALAP').AsString,
            'szamlat_afa='+ADOQuery1.FieldByName('AFA').AsString,
            'szamlat_brutto='+ADOQuery1.FieldByName('BRUTTO').AsString
          ]);
        except
          m.Lines.Add('- hibás számlatétel rögzítés ('+SZURES.FieldByName('SORSZAM').AsString+')');
        end;
        ADOQuery1.Next;
      end;
      //Visszérkezõ számlák kezelése
      ADOQuery1.SQL.Text:='Select * From JurtaTV_teszt.dbo.vszamlak Where szamlaszam='+SZURES.FieldByName('SORSZAM').AsString;
      ADOQuery1.Active:=True;
      while not ADOQuery1.Eof do
      begin
        Beszuras('szamla_megjegyzes',[
          'szmt_id=8',
          'berlo_id='+BERLO_ID,
          'szamla_id='+SZAMLA_ID,
          'szm_datum='+StrDate(ADOQuery1.FieldByName('VISSZAERKEZES').AsString),
          'szm_szoveg='+ADOQuery1.FieldByName('MEGJEGYZES').AsString
        ]);
        if StrDate(ADOQuery1.FieldByName('UJRAPOSTAZAS').AsString)<>''then
           Beszuras('szamla_megjegyzes',[
            'szmt_id=9',
            'berlo_id='+BERLO_ID,
            'szamla_id='+SZAMLA_ID,
            'szm_datum='+StrDate(ADOQuery1.FieldByName('UJRAPOSTAZAS').AsString)
          ]);
        ADOQuery1.Next;
      end;
      SZURES.Next;
    end;
  end;
end;

procedure Tf_AdatMigracio.BitBtn12Click(Sender: TObject);
var i, de: Integer;
    BEF_ID, fm: String;
begin
  inherited;
  //Végig járni a befizetés táblákat...
  m.Lines.Add('Lakás befizetések átvétele ______________________________');
  for i := 1 to 24 do
  begin
    SZURES.Active:=False;
    SZURES.SQL.Text:=
      'Select a.* From JurtaTV_teszt.dbo.Befiz'+SzamlaEv[i]+'L a '+
      'Where a.KOD in (Select x.KOD From Lakasok x Where x.AKTIV=1) '+
      'Order By a.SORSZAM ';
    SZURES.Active:=True;
    SZURES.First;
    while not SZURES.Eof do
    begin
      fm:=''; de:=0; BERLO_ID:='';
      //Bérlõ keresése a TIR-ben
      LISTA.SQL.Text:=
        'Select a.berlo_id From berlok a, szemely b '+
        'Where b.JURTA_KOD='+IDCHAR+SZURES.FieldByName('BERLOKOD').AsString+IDCHAR+' '+
        'and a.szemely_id=b.szemely_id';
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        m.Lines.Add('- nincs a TIR adatbázisban a "'+SZURES.FieldByName('BERLOKOD').AsString+'" személy érték!');
        SZURES.Next;
        Continue;
      end;
      BERLO_ID:=LISTA.FieldByName('berlo_id').AsString;
      //Díjelem átkódolás
      if ADOQuery1.FieldByName('DIJKOD').AsString = '1' then de:=1;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '11' then de:=3;
      if ADOQuery1.FieldByName('DIJKOD').AsString = '21' then de:=4;
      //Számlatétel keresése - számlaszám és díjkód alapján
      LISTA.SQL.Text:='Select b.szamlat_id '+
      'From szamla a, szama_tetel b '+
      'Where a.szamla_id=b.szamla_id and x.szamla_szama='+IDCHAR+SZURES.FieldByName('SZAMLASZAM').AsString+IDCHAR+' '+
      'and b.szdt_id='+IntToStr(de);
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        m.Lines.Add('- nincs a TIR adatbázisban a "'+SZURES.FieldByName('SZAMLASZAM').AsString+'" számla érték!');
        SZURES.Next;
        Continue;
      end;
      //Fizetési mód átkódolása - kérdéses, de a
      if SZURES.FieldByName('FIZMOD').AsString='0' then fm:='4';
      if SZURES.FieldByName('FIZMOD').AsString='1' then fm:='4';
      if SZURES.FieldByName('FIZMOD').AsString='2' then fm:='4';
      if SZURES.FieldByName('FIZMOD').AsString='3' then fm:='5';
      if SZURES.FieldByName('FIZMOD').AsString='4' then fm:='4';
      if fm='' then
      begin
        m.Lines.Add('- nincs a TIR adatbázisban a "'+SZURES.FieldByName('FIZMOD').AsString+'" fizetési módnak megfelelõ kód. ('+SZURES.FieldByName('SZAMLASZAM').AsString+')');
        SZURES.Next;
        Continue;
      end;
      //Befizetés rögzítése
      BEF_ID:=Beszuras('befizetes',[
        'berlo_id='+BERLO_ID,
        'fm_id='+fm,
        'felh_id=0',
        'befiz_sorszam='+SZURES.FieldByName('SORSZAM').AsString,
        'befiz_ev='+SZURES.FieldByName('EV').AsString,
        'befiz_ho='+SZURES.FieldByName('HO').AsString,
        'befiz_datum='+SZURES.FieldByName('DATUM').AsString,
        'befiz_alap='+SZURES.FieldByName('ALAP').AsString,
        'befiz_afa='+SZURES.FieldByName('AFA').AsString,
        'befiz_brutto='+SZURES.FieldByName('BRUTTO').AsString,
        'befiz_hiv='+SZURES.FieldByName('SZAMLASZAM').AsString+' - '+SZURES.FieldByName('DIJNEV').AsString+' - '+SZURES.FieldByName('HIVATKOZAS').AsString
      ]);
      //Számlatétel kapcsolat rögzítése
      Beszuras('befizetes_kapocs',[
        'befiz_id='+BEF_ID,
        'szamlat_id='+LISTA.FieldByName('szamlat_id').AsString,
        'bk_osszeg='+SZURES.FieldByName('BRUTTO').AsString
      ]);
      SZURES.Next;
    end;
  end;

end;

procedure Tf_AdatMigracio.BitBtn6Click(Sender: TObject);
var sza,bj,df,bs,de: Integer;
    af,me,se,ea: String;
begin
  inherited;
  //Helyiség szerzõdések
  m.Lines.Add('Lakás szerzõdések átvétele ______________________________');
  SZURES.SQL.Text:='Select * From JurtaTV_teszt.dbo.Lszerzodes Where AKTIV=1';
  SZURES.Active:=True;
  while not SZURES.Eof do
  begin
    //Szerepel a TIR-ben a helyiség?
    LISTA.SQL.Text:=
      'Select lakas_id From L_LAKAS Where JURTA_KOD='+
      IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR;
    LISTA.Active:=True;
    if LISTA.RecordCount=0 then
    begin
      m.Lines.Add('Nincs a TIR lakás adatbázisban a '+IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR+' JURTA kód értéke!');
      SZURES.Next;
      Continue;
    end
    else
    begin
      LAK_ID:=LISTA.FieldByName('lakas_id').AsString;
      //Megvizsgálni, hogy feldolgoztuk-e már a szerzõdést
      LISTA.SQL.Text:=
        'Select count(bszerz_id) as db From berleti_szerzodes Where '+
        '(jurta_kod='+IDCHAR+SZURES.FieldByName('KAPCSOLT').AsString+IDCHAR+
        ') or (jurta_kod='+IDCHAR+SZURES.FieldByName('SORSZAM').AsString+IDCHAR+')';
      LISTA.Active:=True;
      if LISTA.FieldByName('db').AsInteger>0 then
      begin
        SZURES.Next;
        Continue;
      end;
      //Szerzõdés és hivatkozott szerzõdés, amibõl több is lehet
      ADOQuery1.SQL.Text:=
        'Select * From JurtaTV_teszt.dbo.Lszerzodes Where '+
        '(KAPCSOLT='+IDCHAR+SZURES.FieldByName('KAPCSOLT').AsString+IDCHAR+
        ') OR (SORSZAM='+IDCHAR+SZURES.FieldByName('KAPCSOLT').AsString+IDCHAR+') '+
        'Order By AKTIV desc, VALTOZAT';
      ADOQuery1.Active:=True;
      //Szerzõdés dátumai
      ADOQuery2.SQL.Text:=
        'Select MIN(jogcimkezdet) as kezd, MAX(jogcimveg) as veg '+
        'From JurtaTV_teszt.dbo.Lszerzodes Where '+
        '(KAPCSOLT='+IDCHAR+SZURES.FieldByName('KAPCSOLT').AsString+IDCHAR+
        ') OR (SORSZAM='+IDCHAR+SZURES.FieldByName('KAPCSOLT').AsString+IDCHAR+')';
      ADOQuery2.Active:=True;
      //Az elsõ aktív szerzõdés bérlõje
      if ADOQuery1.FieldByName('BERLOKOD').AsString<>'' then
      begin
        //Bérlõ keresése a TIR-ben
        LISTA.SQL.Text:='Select szemely_id From szemely Where JURTA_KOD='+IDCHAR+ADOQuery1.FieldByName('BERLOKOD').AsString+IDCHAR;
        LISTA.Active:=True;
        if LISTA.RecordCount=0 then
        begin
          m.Lines.Add('Nincs a TIR személy adatbázisban a "'+SZURES.FieldByName('BERLONEV').AsString+'" ('+SZURES.FieldByName('BERLOKOD').AsString+') JURTA bérlõkód érték!');
          SZURES.Next;
          Continue;
        end
        else
        begin
          SZEM_ID:=LISTA.FieldByName('szemely_id').AsString;
          BERLO_ID:=Beszuras('BERLOK',['szemely_id='+SZEM_ID]);
          //Jurta bérlõ napló sorok feldolgozása
          ADOQuery3.SQL.Text:=
            'Select * From JurtaTV_teszt.dbo.Naplo Where BERLOKOD='+IDCHAR+SZURES.FieldByName('BERLOKOD').AsString+IDCHAR;
          ADOQuery3.Active:=True;
          while not ADOQuery3.Eof do
          begin
            Beszuras('berlo_megjegyzes',[
              'berlo_id='+BERLO_ID,
              'bm_szoveg='+ADOQuery3.FieldByName('SZOVEG').AsString
            ]);
            ADOQuery3.Next;
          end;
        end;
      end;
      //Végig menni a szerzõdéseken, az elsõ lesz egy új szerzõdés a többi változás
      bj:=0;
      //Eredeti szerzõdés
      if ADOQuery1.FieldByName('VALTOZAT').AsInteger=0 then
      begin
        if ADOQuery2.FieldByName('veg').AsDateTime<date then sza:=6 else sza:=2;
        if ADOQuery2.FieldByName('veg').AsDateTime<date then bs:=3 else bs:=1;
        if ADOQuery1.FieldByName('JOGCIMKOD').AsString='10' then bj:=1;
        if ADOQuery1.FieldByName('JOGCIMKOD').AsString='61' then bj:=1;
        if ADOQuery1.FieldByName('JOGCIMKOD').AsString='11' then bj:=9;
        if ADOQuery1.FieldByName('JOGCIMKOD').AsString='41' then bj:=3;
        Beszuras('BERLO_KAPCSOLAT',[
          'berlo_id='+BERLO_ID,
          'berlesjog_id='+IntToStr(bj),
          'bstatusz_id='+IntToStr(bs),
          'lakas_id='+LAK_ID,
          'berles_kezdet_datuma='+ADOQuery2.FieldByName('kezd').AsString,
          'berles_vege_datuma='+ADOQuery2.FieldByName('veg').AsString
        ]);
        if ADOQuery1.FieldByName('GYAKORISAG').AsInteger=1 then df:=5 else df:=2;
        SZE_ID:=Beszuras('berleti_szerzodes',[
          'szi_id=2',
          'berlesjog_id='+IntToStr(bj),        //bérlésjog a jogcímbõl
          'sza_id='+IntToStr(sza),             //szerzõdés állapota
          'bt_id=2',                           //bérlemény típus = helyiség
          'dsz_id=2',                          //díjszámítás módja = piaci
          'df_id='+IntToStr(df),               //díjfizetés = havi
          'szerz_ev='+LeftStr(ADOQuery2.FieldByName('veg').AsString,4),
          'szerz_szam=0',
          'szerz_ter='+Valos(FloatToStr(SZURES.FieldByName('TERULET').AsFloat)),
          'bado_szama='+SZURES.FieldByName('HATAROZATSZAM').AsString,
          'bado_datuma='+StrDate(SZURES.FieldByName('HATAROZATKELT').AsString),
          'berles_celja='+SZURES.FieldByName('CEL').AsString,
          'kiut_szama='+SZURES.FieldByName('KIUTALOSZAM').AsString,
          'kiut_datuma='+StrDate(SZURES.FieldByName('KIUTALOKELT').AsString),
          'szerz_datum='+StrDate(ADOQuery2.FieldByName('kezd').AsString),
          'szerz_mettol='+StrDate(ADOQuery2.FieldByName('kezd').AsString),
          'szerz_meddig='+StrDate(ADOQuery2.FieldByName('veg').AsString),
          'szerz_ovadek='+SZURES.FieldByName('OVADEK').AsString,
          'szerz_emeles='+SZURES.FieldByName('EMELESTILTAS').AsString,
          'szerz_automata='+SZURES.FieldByName('AUTOEMELES').AsString,
          'szerz_emelesszaz='+SZURES.FieldByName('emeles').AsString,
          'szerz_leiras='+SZURES.FieldByName('MEGJEGYZES').AsString,
          'berlo_id='+BERLO_ID,
          'jurta_kod='+SZURES.FieldByName('SORSZAM').AsString
        ],false);
        Beszuras('szerzodes_kapocs',[
          'bszerz_id='+SZE_ID,
          'lakas_id='+LAK_ID
        ]);
        //Bérleti szerzõdés tételek
        ADOQuery3.SQL.Text:='Select * From JurtaTV_teszt.dbo.Lszerzdij Where sorszam='+IDCHAR+SZURES.FieldByName('SORSZAM').AsString+IDCHAR;
        ADOQuery3.Active:=True;
        while not ADOQuery3.Eof do
        begin
          //Díjelem átkódolás
          if ADOQuery3.FieldByName('KOD').AsString = '01' then de:=1;
          if ADOQuery3.FieldByName('KOD').AsString = '02' then de:=2;
          if ADOQuery3.FieldByName('KOD').AsString = '03' then de:=3;
          if ADOQuery3.FieldByName('KOD').AsString = '04' then de:=4;
          if ADOQuery3.FieldByName('KOD').AsString = '05' then de:=5;
          if ADOQuery3.FieldByName('KOD').AsString = '06' then de:=6;
          if ADOQuery3.FieldByName('KOD').AsString = '10' then de:=9;
          if ADOQuery3.FieldByName('KOD').AsString = '11' then de:=12;
          if ADOQuery3.FieldByName('KOD').AsString = '20' then de:=10;
          if ADOQuery3.FieldByName('KOD').AsString = '21' then de:=13;
          if ADOQuery3.FieldByName('KOD').AsString = '30' then de:=11;
          if ADOQuery3.FieldByName('KOD').AsString = '50' then de:=14;
          if ADOQuery3.FieldByName('KOD').AsString = '07' then de:=7;
          if ADOQuery3.FieldByName('KOD').AsString = '60' then de:=8;
          //Mennyiségi keresés
          LISTA.SQL.Text:='Select me_id, szdt_id, szde_egysegar From szerzodes_dijelem Where szde_id='+IntToStr(de);
          LISTA.Active:=True;
          if LISTA.RecordCount=0 then
          begin
            m.Lines.Add('Nincs a TIR adatbázisban a '+ADOQuery1.FieldByName('DIJKOD').AsString+' díjelem nem található!');
            SZURES.Next;
            Continue;
          end
          else
          begin
            me:=LISTA.FieldByName('me_id').AsString;
            se:=LISTA.FieldByName('szdt_id').AsString;
            ea:=LISTA.FieldByName('szde_egysegar').AsString;
          end;
          //Áfakulcs keresés
          LISTA.SQL.Text:='Select afa_id From afa Where afa_szazalek='+ADOQuery3.FieldByName('afakulcs').AsString;
          LISTA.Active:=True;
          if LISTA.RecordCount=0 then
          begin
            m.Lines.Add('Nincs a TIR adatbázisban a '+ADOQuery3.FieldByName('afakulcs').AsString+' értékû ÁFA kulcs!');
            SZURES.Next;
            Continue;
          end
          else
            af:=LISTA.FieldByName('afa_id').AsString;
          Beszuras('berleti_szerzodes_tetel',[
            'bszerz_id='+SZE_ID,
            'afa_id='+af,
            'me_id='+me,
            'szdt_id='+se,
//              'szt_havidij=',
            'szt_menny=1',
            'szt_egysegar='+ea,
            'szt_netto='+ADOQuery3.FieldByName('HAVIDIJ').AsString,
            'szt_afa='+ADOQuery3.FieldByName('AFA').AsString,
            'szt_brutto='+ADOQuery3.FieldByName('BRUTTO').AsString,
            'szt_mettol='+StrDate(ADOQuery2.FieldByName('kezd').AsString),
            'szt_meddig='+StrDate(ADOQuery2.FieldByName('veg').AsString)
          ]);
          ADOQuery3.Next;
        end;
        //Albérlõk kezelése
        if StrDate(SZURES.FieldByName('AVEGE').AsString)<>'' then
        begin
          if SZURES.FieldByName('AVEGE').AsDateTime>date then
          begin
            //Albérlõ keresése név alapján a TIR szervezetek között
            LISTA.SQL.Text:='Select szervezet_id From szervezet Where szervezet_nev='+IDCHAR+SZURES.FieldByName('ALBERLO').AsString+IDCHAR;
            LISTA.Active:=True;
            if LISTA.RecordCount=0 then
               SZER_ID:=Beszuras('szervezet',[
                'szervezet_nev='+SZURES.FieldByName('ALBERLO').AsString,
                'szervezet_kezdete='+StrDate(ADOQuery2.FieldByName('kezd').AsString),
                'szervezet_vege='+StrDate(MAXDAT)
               ])
            else
              SZER_ID:=LISTA.FieldByName('szervezet_id').AsString;
            BERLO_ID:=Beszuras('berlok',[
              'szemely_id='+SZEM_ID,
              'szervezet_id='+SZER_ID
            ]);
            BKAP_ID:=Beszuras('berlo_kapcsolat',[
              'lakas_id='+LAK_ID,
              'berlo_id='+BERLO_ID,
              'berlesjog_id=5',
              'bstatusz_id=1',
              'berles_kezdet_datuma='+StrDate(SZURES.FieldByName('JOGCIMKEZDET').AsString),
              'berles_vege_datuma='+StrDate(SZURES.FieldByName('AVEGE').AsString),
              'hasznalt_terulet='+SZURES.FieldByName('ATERULET').AsString
            ]);
          end
          else
            //Ha lejárt az albérlet, akkor mint eseményt rögzítjük
            Beszuras('szerzodes_esemeny',[
              'bszerz_id='+SZE_ID,
              'felh_id=0',
              'sze_datum='+StrDate(SZURES.FieldByName('AVEGE').AsString),
              'sze_leiras='+'Albérlõ: '+SZURES.FieldByName('ALBERLO').AsString+' - '+
                SZURES.FieldByName('ATELEPHELY').AsString+' - terület: '+
                SZURES.FieldByName('ATERULET').AsString
            ],false);
        end;
        //Szerzõdés események kezelée
        if SZURES.FieldByName('FELTETEL').AsString<>'' then
          Beszuras('szerzodes_esemeny',[
            'bszerz_id='+SZE_ID,
            'felh_id=0',
            'sze_datum='+StrDate(ADOQuery2.FieldByName('kezd').AsString),
            'sze_leiras='+SZURES.FieldByName('FELTETEL').AsString
          ],false);
        if SZURES.FieldByName('VALTOZASOKA').AsString<>'' then
          Beszuras('szerzodes_esemeny',[
            'bszerz_id='+SZE_ID,
            'felh_id=0',
            'sze_datum='+StrDate(SZURES.FieldByName('VALTOZASKELT').AsString),
            'sze_leiras='+SZURES.FieldByName('VALTOZASOKA').AsString
          ],false);
        if SZURES.FieldByName('RESZLETFIZETES').AsString='1' then
          Beszuras('szerzodes_esemeny',[
            'bszerz_id='+SZE_ID,
            'felh_id=0',
            'sze_datum='+StrDate(SZURES.FieldByName('RESZLETKEZDET').AsString),
            'sze_leiras='+'Részletfizetés!'
          ],false);
        if SZURES.FieldByName('PERTIPUS').AsString='1' then
          Beszuras('szerzodes_esemeny',[
            'bszerz_id='+SZE_ID,
            'felh_id=0',
            'sze_datum='+StrDate(SZURES.FieldByName('PERKEZDET').AsString),
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
          'valtozas_datuma='+StrDate(ADOQuery1.FieldByName('JOGCIMKEZDET').AsString),
          'valtozas_oka='+ADOQuery1.FieldByName('SORSZAM').AsString+' - '+
            'típus: '+ADOQuery1.FieldByName('TIPUS').AsString+' - '+
            'jogcím: '+ADOQuery1.FieldByName('JOGCIM').AsString+' - '+
            'ok: '+ADOQuery1.FieldByName('VALTOZASOKA').AsString+' - '+
            'megjegyzés: '+ADOQuery1.FieldByName('MEGJEGYZES').AsString
        ],false);
        ADOQuery1.Next;
      end;
    end;
    SZURES.Next;
  end;

  //A lakbér beírás szerzõdés tételként a dbo-Lakasok táblából
end;

procedure Tf_AdatMigracio.csarnokszerzodesClick(Sender: TObject);
var sza,bj,df,bs,de,szt: Integer;
    af,me,se,ea: String;
begin
  inherited;
  //Csarnok szerzõdések
  m.Lines.Add('Csarnok szerzõdések átvétele ______________________________');
  SZURES.SQL.Text:='Select * From JurtaTV_teszt.dbo.Csszerzodes Where AKTIV=1';
  SZURES.Active:=True;
  while not SZURES.Eof do
  begin
    //Szerepel a TIR-ben a helyiség?
    LISTA.SQL.Text:=
      'Select berl_id From berlemeny Where JURTA_KOD='+
      IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR;
    LISTA.Active:=True;
    if LISTA.RecordCount=0 then
    begin
      m.Lines.Add('Nincs a TIR bérlemény adatbázisban a '+IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR+' JURTA kód értéke!');
      SZURES.Next;
      Continue;
    end
    else
    begin
      BERL_ID:=LISTA.FieldByName('berl_id').AsString;
      //Megvizsgálni, hogy feldolgoztuk-e már a szerzõdést
      LISTA.SQL.Text:=
        'Select count(bszerz_id) as db From berleti_szerzodes Where '+
        '(jurta_kod='+IDCHAR+SZURES.FieldByName('KAPCSOLT').AsString+IDCHAR+
        ') or (jurta_kod='+IDCHAR+SZURES.FieldByName('SORSZAM').AsString+IDCHAR+')';
      LISTA.Active:=True;
      if LISTA.FieldByName('db').AsInteger>0 then
      begin
        SZURES.Next;
        Continue;
      end;
      //Szerzõdés és hivatkozott szerzõdés, amibõl több is lehet, elsõ az aktív
      ADOQuery1.SQL.Text:=
        'Select * From JurtaTV_teszt.dbo.Csszerzodes Where '+
        '(KAPCSOLT='+IDCHAR+SZURES.FieldByName('KAPCSOLT').AsString+IDCHAR+
        ') OR (SORSZAM='+IDCHAR+SZURES.FieldByName('KAPCSOLT').AsString+IDCHAR+') '+
        'Order By AKTIV desc, VALTOZAT';
      ADOQuery1.Active:=True;
      //Szerzõdés dátumai
      ADOQuery2.SQL.Text:=
        'Select MIN(jogcimkezdet) as kezd, MAX(jogcimveg) as veg '+
        'From JurtaTV_teszt.dbo.Csszerzodes Where '+
        '(KAPCSOLT='+IDCHAR+SZURES.FieldByName('KAPCSOLT').AsString+IDCHAR+
        ') OR (SORSZAM='+IDCHAR+SZURES.FieldByName('KAPCSOLT').AsString+IDCHAR+')';
      ADOQuery2.Active:=True;
      //Bérlõ keresése a TIR-ben
      LISTA.SQL.Text:='Select szervezet_id From szervezet Where JURTA_KOD='+IDCHAR+ADOQuery1.FieldByName('BERLOKOD').AsString+IDCHAR;
      LISTA.Active:=True;
      if LISTA.RecordCount=0 then
      begin
        m.Lines.Add('Nincs a TIR szervezet adatbázisban a '+SZURES.FieldByName('BERLOKOD').AsString+' JURTA bérlõkód érték!');
        SZURES.Next;
        Continue;
      end
      else
      begin
        SZER_ID:=LISTA.FieldByName('szervezet_id').AsString;
        BERLO_ID:=Beszuras('BERLOK',['szervezet_id='+SZER_ID]);
        //Jurta bérlõ napló sorok feldolgozása
        ADOQuery3.SQL.Text:=
          'Select * From JurtaTV_teszt.dbo.Naplo Where BERLOKOD='+IDCHAR+SZURES.FieldByName('BERLOKOD').AsString+IDCHAR;
        ADOQuery3.Active:=True;
        while not ADOQuery3.Eof do
        begin
          Beszuras('berlo_megjegyzes',[
            'berlo_id='+BERLO_ID,
            'bm_szoveg='+ADOQuery3.FieldByName('SZOVEG').AsString
          ]);
          ADOQuery3.Next;
        end;
        //Végig menni a szerzõdéseken, az elsõ lesz egy új szerzõdés a többi változás
        //Eredeti szerzõdés
        if ADOQuery1.FieldByName('VALTOZAT').AsInteger=0 then
        begin
          if ADOQuery2.FieldByName('veg').AsDateTime<date then sza:=6 else sza:=2;
          if ADOQuery2.FieldByName('veg').AsDateTime<date then bs:=3 else bs:=1;
          case ADOQuery1.FieldByName('JOGCIMKOD').AsInteger of
            0: bj:=0;
            1: bj:=1;
            2: bj:=9;
            3: bj:=14;
          end;
          case ADOQuery1.FieldByName('SZERZTIP').AsInteger of
            0: szt:=23;
            1: szt:=24;
            2: szt:=25;
            3: szt:=26;
          end;
          if ADOQuery1.FieldByName('GYAKORISAG').AsInteger=1 then df:=5 else df:=2;
          BKAP_ID:=Beszuras('BERLO_KAPCSOLAT',[
            'berlo_id='+BERLO_ID,
            'berlesjog_id='+IntToStr(bj),
            'bstatusz_id='+IntToStr(bs),
            'berl_id='+BERL_ID,
            'berles_kezdet_datuma='+ADOQuery2.FieldByName('kezd').AsString,
            'berles_vege_datuma='+ADOQuery2.FieldByName('veg').AsString
          ]);
          SZE_ID:=Beszuras('berleti_szerzodes',[
            'szi_id=2',
            'berlesjog_id='+IntToStr(bj),        //bérlésjog a jogcímbõl
            'sza_id='+IntToStr(sza),             //szerzõdés állapota
            'bt_id=3',                           //bérlemény típus = csarnok
            'dsz_id=2',                          //díjszámítás módja = piaci
            'df_id='+IntToStr(df),               //díjfizetés = havi
            'szt_id='+IntToStr(szt),             //szerzõdés típus
            'szerz_ev='+LeftStr(ADOQuery2.FieldByName('veg').AsString,4),
            'szerz_szam=0',
            'szerz_ter='+Valos(FloatToStr(SZURES.FieldByName('TERULET').AsFloat)),
            'bado_szama='+SZURES.FieldByName('HATAROZATSZAM').AsString,
            'bado_datuma='+StrDate(SZURES.FieldByName('HATAROZATKELT').AsString),
            'berles_celja='+SZURES.FieldByName('CEL').AsString,
            'kiut_szama='+SZURES.FieldByName('KIUTALOSZAM').AsString,
            'kiut_datuma='+StrDate(SZURES.FieldByName('KIUTALOKELT').AsString),
            'szerz_datum='+StrDate(ADOQuery2.FieldByName('kezd').AsString),
            'szerz_mettol='+StrDate(ADOQuery2.FieldByName('kezd').AsString),
            'szerz_meddig='+StrDate(ADOQuery2.FieldByName('veg').AsString),
            'szerz_ovadek='+SZURES.FieldByName('OVADEK').AsString,
            'szerz_emeles='+SZURES.FieldByName('EMELESTILTAS').AsString,
            'szerz_automata='+SZURES.FieldByName('AUTOEMELES').AsString,
            'szerz_emelesszaz='+SZURES.FieldByName('emeles').AsString,
            'szerz_leiras='+SZURES.FieldByName('MEGJEGYZES').AsString,
            'berlo_id='+BERLO_ID,
            'jurta_kod='+SZURES.FieldByName('SORSZAM').AsString
          ],false);
          Beszuras('szerzodes_kapocs',[
            'bszerz_id='+SZE_ID,
            'berl_id='+BERL_ID
          ]);
          //Bérleti szerzõdés tételek
          ADOQuery3.SQL.Text:='Select * From JurtaTV_teszt.dbo.Csszerzdij Where sorszam='+IDCHAR+SZURES.FieldByName('SORSZAM').AsString+IDCHAR;
          ADOQuery3.Active:=True;
          while not ADOQuery3.Eof do
          begin
            //Díjelem átkódolás - szerzõdés díjelem alapján a szerzõdés díjtípusa
            if ADOQuery3.FieldByName('KOD').AsString = '50' then de:=17;
            if ADOQuery3.FieldByName('KOD').AsString = '51' then de:=16;
            if ADOQuery3.FieldByName('KOD').AsString = '52' then de:=18;
            if ADOQuery3.FieldByName('KOD').AsString = '53' then de:=18;
            if ADOQuery3.FieldByName('KOD').AsString = '54' then de:=19;
            if ADOQuery3.FieldByName('KOD').AsString = '58' then de:=20;
            if ADOQuery3.FieldByName('KOD').AsString = '59' then de:=21;
            if ADOQuery3.FieldByName('KOD').AsString = '62' then de:=16;
            if ADOQuery3.FieldByName('KOD').AsString = '69' then de:=22;
            if ADOQuery3.FieldByName('KOD').AsString = '71' then de:=23;
            if ADOQuery3.FieldByName('KOD').AsString = '72' then de:=24;
            if ADOQuery3.FieldByName('KOD').AsString = '74' then de:=24;
            if ADOQuery3.FieldByName('KOD').AsString = '77' then de:=16;
            if ADOQuery3.FieldByName('KOD').AsString = '78' then de:=17;
            if ADOQuery3.FieldByName('KOD').AsString = '80' then de:=25;
            if ADOQuery3.FieldByName('KOD').AsString = '81' then de:=25;
            if ADOQuery3.FieldByName('KOD').AsString = '82' then de:=26;
            //Mennyiségi keresés
            LISTA.SQL.Text:='Select me_id, szdt_id, szde_egysegar From szerzodes_dijelem Where szde_id='+IntToStr(de);
            LISTA.Active:=True;
            if LISTA.RecordCount=0 then
            begin
              m.Lines.Add('Nincs a TIR adatbázisban a '+ADOQuery1.FieldByName('DIJKOD').AsString+' díjelem nem található!');
              SZURES.Next;
              Continue;
            end
            else
            begin
              me:=LISTA.FieldByName('me_id').AsString;
              se:=LISTA.FieldByName('szdt_id').AsString;
              ea:=LISTA.FieldByName('szde_egysegar').AsString;
            end;
            //Áfakulcs keresés
            LISTA.SQL.Text:='Select afa_id From afa Where afa_szazalek='+ADOQuery3.FieldByName('afakulcs').AsString;
            LISTA.Active:=True;
            if LISTA.RecordCount=0 then
            begin
              m.Lines.Add('Nincs a TIR adatbázisban a '+ADOQuery3.FieldByName('afakulcs').AsString+' értékû ÁFA kulcs!');
              SZURES.Next;
              Continue;
            end
            else
              af:=LISTA.FieldByName('afa_id').AsString;
            Beszuras('berleti_szerzodes_tetel',[
              'bszerz_id='+SZE_ID,
              'afa_id='+af,
              'me_id='+me,
              'szdt_id='+se,
              'szt_menny='+Valos(ADOQuery3.FieldByName('HAVIDIJ').AsString),
              'szt_egysegar='+ea,
              'szt_netto='+ADOQuery3.FieldByName('HAVIDIJ').AsString,
              'szt_afa='+ADOQuery3.FieldByName('AFA').AsString,
              'szt_brutto='+ADOQuery3.FieldByName('BRUTTO').AsString,
              'szt_mettol='+StrDate(ADOQuery2.FieldByName('kezd').AsString),
              'szt_meddig='+StrDate(ADOQuery2.FieldByName('veg').AsString)
            ]);
            ADOQuery3.Next;
          end;
          if SZURES.FieldByName('VALTOZASOKA').AsString<>'' then
            Beszuras('szerzodes_esemeny',[
              'bszerz_id='+SZE_ID,
              'felh_id=0',
              'sze_datum='+StrDate(SZURES.FieldByName('VALTOZASKELT').AsString),
              'sze_leiras='+SZURES.FieldByName('VALTOZASOKA').AsString
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
            'valtozas_datuma='+StrDate(ADOQuery1.FieldByName('JOGCIMKEZDET').AsString),
            'valtozas_oka='+ADOQuery1.FieldByName('SORSZAM').AsString+' - '+
              'típus: '+ADOQuery1.FieldByName('TIPUS').AsString+' - '+
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

procedure Tf_AdatMigracio.bb_hibaClick(Sender: TObject);
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

procedure Tf_AdatMigracio.bb_lakasokClick(Sender: TObject);
var bf, es, r, bj, bs: Integer;
begin
  inherited;
  m.Lines.Add('Lakások átvétele ______________________________');
  SZURES.Active:=False;
  SZURES.SQL.Text:=
    'Select a.* From JurtaTV_teszt.dbo.Lakasok a Where a.AKTIV=1 Order By a.CIM ';
  SZURES.Active:=True;
  SZURES.First;
  while not SZURES.Eof do
  begin
    LISTA.SQL.Text:=
      'Select lakas_id From L_LAKAS Where JURTA_KOD='+
      IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR;
    LISTA.Active:=True;
    if LISTA.RecordCount>0 then
       m.Lines.Add('Lakás bérlemény már létezik a TIR-ben ('+SZURES.FieldByName('KOD').AsString+')');
    //HRSZ
    LISTA.SQL.Text:='Select x.lakas_id, x.lakas_osszes_terulete, '+
    '(Select y.helyrajziszam From helyrajzi_szamok y Where y.hrsz_id=x.hrsz_id) as hrsz '+
    'From L_LAKAS x Where x.JURTA_KOD='+IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR;
    LISTA.Active:=True;
    if LISTA.RecordCount>0 then
    begin
      LAK_ID:=LISTA.FieldByName('lakas_id').AsString;
      if LISTA.FieldByName('hrsz').AsString<>SZURES.FieldByName('hrsz').AsString+'/'+SZURES.FieldByName('albetet').AsString then
         m.Lines.Add('- hrsz hiba: '+SZURES.FieldByName('KOD').AsString+' ('+SZURES.FieldByName('hrsz').AsString+'/'+SZURES.FieldByName('albetet').AsString+') - '+
         LISTA.FieldByName('lakas_id').AsString+' ('+LISTA.FieldByName('hrsz').AsString+')');
      //terület
      if LISTA.FieldByName('lakas_osszes_terulete').AsString<>SZURES.FieldByName('alapterulet').AsString then
         m.Lines.Add('- terület hiba: '+SZURES.FieldByName('KOD').AsString+' ('+SZURES.FieldByName('alapterulet').AsString+') - '+
         LISTA.FieldByName('lakas_id').AsString+' ('+LISTA.FieldByName('lakas_osszes_terulete').AsString+')');
      if LISTA.RecordCount>1 then
      begin
         m.Lines.Add('- több JURTA kód: '+SZURES.FieldByName('KOD').AsString);
         SZURES.Next;
         Continue;
      end;
       Modositas('L_LAKAS',[
        'SZOBA_SZAM='+SZURES.FieldByName('SZOBA').AsString,
        'FELSZOBA_SZAM='+SZURES.FieldByName('FELSZOBA').AsString,
        'LAKAS_HASZNOS_TERULETE='+Valos(SZURES.FieldByName('SZAMTERULET').AsString),
        'LAKOK_SZAMA='+SZURES.FieldByName('LAKOSZAM').AsString
       ],'LAKAS_ID='+LAK_ID);
      //megjegyzés
      if SZURES.FieldByName('MEGJEGYZES').AsString<>'' then
         Beszuras('MEGJEGYZES',[
          'LAKAS_ID='+LAK_ID,
          'FELH_ID='+FELHASZNALO_ID,
          'MEGJEGYZES='+SZURES.FieldByName('MEGJEGYZES').AsString,
          'MEGJEGYZES_DATUM='+'20191231'
         ],False);
      //Vízóra
      if SZURES.FieldByName('VIZORA').AsString='1' then
         Modositas('L_LAKAS',[
          'L_VIZMERO=1',
          'L_VIZMERO_DATUMA='+StrDate(SZURES.FieldByName('VIZORADATUM').AsString)
         ],'LAKAS_ID='+LAK_ID);
      //Csökkentõk
      if SZURES.FieldByName('MODOSITO').AsString<>'0' then
      begin
        if SZURES.FieldByName('NOVEZET').AsString='1' then
           Beszuras('l_lakas_csokkento',[
            'lakas_id='+LAK_ID,
            'cs_id=1',
            'lcs_mettol='+'20060101',
            'lcs_meddig='+'21001231'
           ]);
        if SZURES.FieldByName('CSPADLO').AsString='1' then
           Beszuras('l_lakas_csokkento',[
            'lakas_id='+LAK_ID,
            'cs_id=2',
            'lcs_mettol='+'20060101',
            'lcs_meddig='+'21001231'
           ]);
        if SZURES.FieldByName('CSZART').AsString='1' then
           Beszuras('l_lakas_csokkento',[
            'lakas_id='+LAK_ID,
            'cs_id=3',
            'lcs_mettol='+'20060101',
            'lcs_meddig='+'21001231'
           ]);
        if SZURES.FieldByName('CSFELVONO').AsString='1' then
           Beszuras('l_lakas_csokkento',[
            'lakas_id='+LAK_ID,
            'cs_id=4',
            'lcs_mettol='+'20060101',
            'lcs_meddig='+'21001231'
           ]);
        if SZURES.FieldByName('CSREGI').AsString='1' then
           Beszuras('l_lakas_csokkento',[
            'lakas_id='+LAK_ID,
            'cs_id=5',
            'lcs_mettol='+'20060101',
            'lcs_meddig='+'21001231'
           ]);
        if SZURES.FieldByName('CSDUCOLT').AsString='1' then
           Beszuras('l_lakas_csokkento',[
            'lakas_id='+LAK_ID,
            'cs_id=6',
            'lcs_mettol='+'20060101',
            'lcs_meddig='+'21001231'
           ]);
        if SZURES.FieldByName('CSNEDVES').AsString='1' then
           Beszuras('l_lakas_csokkento',[
            'lakas_id='+LAK_ID,
            'cs_id=7',
            'lcs_mettol='+'20060101',
            'lcs_meddig='+'21001231'
           ]);
        if SZURES.FieldByName('CSGOMBA').AsString='1' then
           Beszuras('l_lakas_csokkento',[
            'lakas_id='+LAK_ID,
            'cs_id=8',
            'lcs_mettol='+'20060101',
            'lcs_meddig='+'21001231'
           ]);
        if SZURES.FieldByName('CSVASUT').AsString='1' then
           Beszuras('l_lakas_csokkento',[
            'lakas_id='+LAK_ID,
            'cs_id=9',
            'lcs_mettol='+'20060101',
            'lcs_meddig='+'21001231'
           ]);
      end;
    end
    else
      m.Lines.Add('A lakás nem szerepel a TIR rendszerben. ('+SZURES.FieldByName('KOD').AsString+')');
    SZURES.Next;
  end;
end;

procedure Tf_AdatMigracio.helyisegszerzClick(Sender: TObject);
var sza,bj,df,bs,de: Integer;
    af,me,se,ea: String;
begin
  inherited;
  //Helyiség szerzõdések
  m.Lines.Add('Helyiség szerzõdések átvétele ______________________________');
  SZURES.SQL.Text:='Select * From JurtaTV_teszt.dbo.Nszerzodes Where AKTIV=1';
  SZURES.Active:=True;
  while not SZURES.Eof do
  begin
    //Szerepel a TIR-ben a helyiség?
    LISTA.SQL.Text:=
      'Select nem_lakas_id From B_NEM_LAKAS Where JURTA_KOD='+
      IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR;
    LISTA.Active:=True;
    if LISTA.RecordCount=0 then
    begin
      m.Lines.Add('Nincs a TIR helyiség adatbázisban a '+IDCHAR+SZURES.FieldByName('KOD').AsString+IDCHAR+' JURTA kód értéke!');
      SZURES.Next;
      Continue;
    end
    else
    begin
      NLAK_ID:=LISTA.FieldByName('nem_lakas_id').AsString;
      //Megvizsgálni, hogy feldolgoztuk-e már a szerzõdést
      LISTA.SQL.Text:=
        'Select count(bszerz_id) as db From berleti_szerzodes Where '+
        '(jurta_kod='+IDCHAR+SZURES.FieldByName('KAPCSOLT').AsString+IDCHAR+
        ') or (jurta_kod='+IDCHAR+SZURES.FieldByName('SORSZAM').AsString+IDCHAR+')';
      LISTA.Active:=True;
      if LISTA.FieldByName('db').AsInteger>0 then
      begin
        SZURES.Next;
        Continue;
      end;
      //Szerzõdés és hivatkozott szerzõdés, amibõl több is lehet
      ADOQuery1.SQL.Text:=
        'Select * From JurtaTV_teszt.dbo.Nszerzodes Where '+
        '(KAPCSOLT='+IDCHAR+SZURES.FieldByName('KAPCSOLT').AsString+IDCHAR+
        ') OR (SORSZAM='+IDCHAR+SZURES.FieldByName('KAPCSOLT').AsString+IDCHAR+') '+
        'Order By AKTIV desc, VALTOZAT';
      ADOQuery1.Active:=True;
      //Szerzõdés dátumai
      ADOQuery2.SQL.Text:=
        'Select MIN(jogcimkezdet) as kezd, MAX(jogcimveg) as veg '+
        'From JurtaTV_teszt.dbo.Nszerzodes Where '+
        '(KAPCSOLT='+IDCHAR+SZURES.FieldByName('KAPCSOLT').AsString+IDCHAR+
        ') OR (SORSZAM='+IDCHAR+SZURES.FieldByName('KAPCSOLT').AsString+IDCHAR+')';
      ADOQuery2.Active:=True;
      if ADOQuery1.FieldByName('BERLOKOD').AsString<>'' then
      begin
        //Bérlõ keresése a TIR-ben
        LISTA.SQL.Text:='Select szervezet_id From szervezet Where JURTA_KOD='+IDCHAR+ADOQuery1.FieldByName('BERLOKOD').AsString+IDCHAR;
        LISTA.Active:=True;
        if LISTA.RecordCount=0 then
        begin
          m.Lines.Add('Nincs a TIR szervezet adatbázisban a '+SZURES.FieldByName('BERLOKOD').AsString+' JURTA bérlõkód érték!');
          SZURES.Next;
          Continue;
        end
        else
        begin
          SZER_ID:=LISTA.FieldByName('szervezet_id').AsString;
          BERLO_ID:=Beszuras('BERLOK',['szervezet_id='+SZER_ID]);
          //Jurta bérlõ napló sorok feldolgozása
          ADOQuery3.SQL.Text:=
            'Select * From JurtaTV_teszt.dbo.Naplo Where BERLOKOD='+IDCHAR+SZURES.FieldByName('BERLOKOD').AsString+IDCHAR;
          ADOQuery3.Active:=True;
          while not ADOQuery3.Eof do
          begin
            Beszuras('berlo_megjegyzes',[
              'berlo_id='+BERLO_ID,
              'bm_szoveg='+ADOQuery3.FieldByName('SZOVEG').AsString
            ]);
            ADOQuery3.Next;
          end;
          BKAP_ID:=Beszuras('BERLO_KAPCSOLAT',[
            'berlo_id='+BERLO_ID,
            'berlesjog_id='+IntToStr(bj),
            'bstatusz_id='+IntToStr(bs),
            'nem_lakas_id='+NLAK_ID,
            'berles_kezdet_datuma='+ADOQuery2.FieldByName('kezd').AsString,
            'berles_vege_datuma='+ADOQuery2.FieldByName('veg').AsString
          ]);
        end;
      end;
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
        SZE_ID:=Beszuras('berleti_szerzodes',[
          'szi_id=2',
          'berlesjog_id='+IntToStr(bj),        //bérlésjog a jogcímbõl
          'sza_id='+IntToStr(sza),             //szerzõdés állapota
          'bt_id=2',                           //bérlemény típus = helyiség
          'dsz_id=2',                          //díjszámítás módja = piaci
          'df_id='+IntToStr(df),               //díjfizetés = havi
          'szerz_ev='+LeftStr(ADOQuery2.FieldByName('veg').AsString,4),
          'szerz_szam=0',
          'szerz_ter='+Valos(FloatToStr(SZURES.FieldByName('TERULET').AsFloat)),
          'bado_szama='+SZURES.FieldByName('HATAROZATSZAM').AsString,
          'bado_datuma='+StrDate(SZURES.FieldByName('HATAROZATKELT').AsString),
          'berles_celja='+SZURES.FieldByName('CEL').AsString,
          'kiut_szama='+SZURES.FieldByName('KIUTALOSZAM').AsString,
          'kiut_datuma='+StrDate(SZURES.FieldByName('KIUTALOKELT').AsString),
          'szerz_datum='+StrDate(ADOQuery2.FieldByName('kezd').AsString),
          'szerz_mettol='+StrDate(ADOQuery2.FieldByName('kezd').AsString),
          'szerz_meddig='+StrDate(ADOQuery2.FieldByName('veg').AsString),
          'szerz_ovadek='+SZURES.FieldByName('OVADEK').AsString,
          'szerz_emeles='+SZURES.FieldByName('EMELESTILTAS').AsString,
          'szerz_automata='+SZURES.FieldByName('AUTOEMELES').AsString,
          'szerz_emelesszaz='+SZURES.FieldByName('emeles').AsString,
          'szerz_leiras='+SZURES.FieldByName('MEGJEGYZES').AsString,
          'berlo_id='+BERLO_ID,
          'jurta_kod='+SZURES.FieldByName('SORSZAM').AsString
        ],false);
        Beszuras('szerzodes_kapocs',[
          'bszerz_id='+SZE_ID,
          'nem_lakas_id='+NLAK_ID
        ]);
        //Bérleti szerzõdés tételek
        ADOQuery3.SQL.Text:='Select * From JurtaTV_teszt.dbo.Nszerzdij Where sorszam='+IDCHAR+SZURES.FieldByName('SORSZAM').AsString+IDCHAR;
        ADOQuery3.Active:=True;
        while not ADOQuery3.Eof do
        begin
          //Díjelem átkódolás
          if ADOQuery3.FieldByName('KOD').AsString = '01' then de:=1;
          if ADOQuery3.FieldByName('KOD').AsString = '02' then de:=2;
          if ADOQuery3.FieldByName('KOD').AsString = '03' then de:=3;
          if ADOQuery3.FieldByName('KOD').AsString = '04' then de:=4;
          if ADOQuery3.FieldByName('KOD').AsString = '05' then de:=5;
          if ADOQuery3.FieldByName('KOD').AsString = '06' then de:=6;
          if ADOQuery3.FieldByName('KOD').AsString = '10' then de:=9;
          if ADOQuery3.FieldByName('KOD').AsString = '11' then de:=12;
          if ADOQuery3.FieldByName('KOD').AsString = '20' then de:=10;
          if ADOQuery3.FieldByName('KOD').AsString = '21' then de:=13;
          if ADOQuery3.FieldByName('KOD').AsString = '30' then de:=11;
          if ADOQuery3.FieldByName('KOD').AsString = '50' then de:=14;
          if ADOQuery3.FieldByName('KOD').AsString = '07' then de:=7;
          if ADOQuery3.FieldByName('KOD').AsString = '60' then de:=8;
          //Mennyiségi keresés
          LISTA.SQL.Text:='Select me_id, szdt_id, szde_egysegar From szerzodes_dijelem Where szde_id='+IntToStr(de);
          LISTA.Active:=True;
          if LISTA.RecordCount=0 then
          begin
            m.Lines.Add('Nincs a TIR adatbázisban a '+ADOQuery1.FieldByName('DIJKOD').AsString+' díjelem nem található!');
            SZURES.Next;
            Continue;
          end
          else
          begin
            me:=LISTA.FieldByName('me_id').AsString;
            se:=LISTA.FieldByName('szdt_id').AsString;
            ea:=LISTA.FieldByName('szde_egysegar').AsString;
          end;
          //Áfakulcs keresés
          LISTA.SQL.Text:='Select afa_id From afa Where afa_szazalek='+ADOQuery3.FieldByName('afakulcs').AsString;
          LISTA.Active:=True;
          if LISTA.RecordCount=0 then
          begin
            m.Lines.Add('Nincs a TIR adatbázisban a '+ADOQuery3.FieldByName('afakulcs').AsString+' értékû ÁFA kulcs!');
            SZURES.Next;
            Continue;
          end
          else
            af:=LISTA.FieldByName('afa_id').AsString;
          Beszuras('berleti_szerzodes_tetel',[
            'bszerz_id='+SZE_ID,
            'afa_id='+af,
            'me_id='+me,
            'szdt_id='+se,
//              'szt_havidij=',
            'szt_menny=1',
            'szt_egysegar='+ea,
            'szt_netto='+ADOQuery3.FieldByName('HAVIDIJ').AsString,
            'szt_afa='+ADOQuery3.FieldByName('AFA').AsString,
            'szt_brutto='+ADOQuery3.FieldByName('BRUTTO').AsString,
            'szt_mettol='+StrDate(ADOQuery2.FieldByName('kezd').AsString),
            'szt_meddig='+StrDate(ADOQuery2.FieldByName('veg').AsString)
          ]);
          ADOQuery3.Next;
        end;
        //Albérlõk kezelése
        if StrDate(SZURES.FieldByName('AVEGE').AsString)<>'' then
        begin
          if SZURES.FieldByName('AVEGE').AsDateTime>date then
          begin
            //Albérlõ keresése név alapján a TIR szervezetek között
            LISTA.SQL.Text:='Select szervezet_id From szervezet Where szervezet_nev='+IDCHAR+SZURES.FieldByName('ALBERLO').AsString+IDCHAR;
            LISTA.Active:=True;
            if LISTA.RecordCount=0 then
               SZER_ID:=Beszuras('szervezet',[
                'szervezet_nev='+SZURES.FieldByName('ALBERLO').AsString,
                'szervezet_kezdete='+StrDate(ADOQuery2.FieldByName('kezd').AsString),
                'szervezet_vege='+StrDate(MAXDAT)
               ])
            else
              SZER_ID:=LISTA.FieldByName('szervezet_id').AsString;
            BERLO_ID:=Beszuras('berlok',[
              'szemely_id='+SZEM_ID,
              'szervezet_id='+SZER_ID
            ]);
            BKAP_ID:=Beszuras('berlo_kapcsolat',[
              'nem_lakas_id='+NLAK_ID,
              'berlo_id='+BERLO_ID,
              'berlesjog_id=5',
              'bstatusz_id=1',
              'berles_kezdet_datuma='+StrDate(SZURES.FieldByName('JOGCIMKEZDET').AsString),
              'berles_vege_datuma='+StrDate(SZURES.FieldByName('AVEGE').AsString),
              'hasznalt_terulet='+SZURES.FieldByName('ATERULET').AsString
            ]);
          end
          else
            //Ha lejárt az albérlet, akkor mint eseményt rögzítjük
            Beszuras('szerzodes_esemeny',[
              'bszerz_id='+SZE_ID,
              'felh_id=0',
              'sze_datum='+StrDate(SZURES.FieldByName('AVEGE').AsString),
              'sze_leiras='+'Albérlõ: '+SZURES.FieldByName('ALBERLO').AsString+' - '+
                SZURES.FieldByName('ATELEPHELY').AsString+' - terület: '+
                SZURES.FieldByName('ATERULET').AsString
            ],false);
        end;
        //Szerzõdés események kezelée
        if SZURES.FieldByName('FELTETEL').AsString<>'' then
          Beszuras('szerzodes_esemeny',[
            'bszerz_id='+SZE_ID,
            'felh_id=0',
            'sze_datum='+StrDate(ADOQuery2.FieldByName('kezd').AsString),
            'sze_leiras='+SZURES.FieldByName('FELTETEL').AsString
          ],false);
        if SZURES.FieldByName('VALTOZASOKA').AsString<>'' then
          Beszuras('szerzodes_esemeny',[
            'bszerz_id='+SZE_ID,
            'felh_id=0',
            'sze_datum='+StrDate(SZURES.FieldByName('VALTOZASKELT').AsString),
            'sze_leiras='+SZURES.FieldByName('VALTOZASOKA').AsString
          ],false);
        if SZURES.FieldByName('RESZLETFIZETES').AsString='1' then
          Beszuras('szerzodes_esemeny',[
            'bszerz_id='+SZE_ID,
            'felh_id=0',
            'sze_datum='+StrDate(SZURES.FieldByName('RESZLETKEZDET').AsString),
            'sze_leiras='+'Részletfizetés!'
          ],false);
        if SZURES.FieldByName('PERTIPUS').AsString='1' then
          Beszuras('szerzodes_esemeny',[
            'bszerz_id='+SZE_ID,
            'felh_id=0',
            'sze_datum='+StrDate(SZURES.FieldByName('PERKEZDET').AsString),
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
          'valtozas_datuma='+StrDate(ADOQuery1.FieldByName('JOGCIMKEZDET').AsString),
          'valtozas_oka='+ADOQuery1.FieldByName('SORSZAM').AsString+' - '+
            'típus: '+ADOQuery1.FieldByName('TIPUS').AsString+' - '+
            'jogcím: '+ADOQuery1.FieldByName('JOGCIM').AsString+' - '+
            'ok: '+ADOQuery1.FieldByName('VALTOZASOKA').AsString+' - '+
            'megjegyzés: '+ADOQuery1.FieldByName('MEGJEGYZES').AsString
        ],false);
        ADOQuery1.Next;
      end;
    end;
    SZURES.Next;
  end;
end;

end.
