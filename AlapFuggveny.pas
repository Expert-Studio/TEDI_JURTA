unit AlapFuggveny;

interface

uses SysUtils, Classes, DB, Windows, Vcl.Graphics, Vcl.Controls,
  DateUtils, StrUtils, Math, Winsock, Vcl.ComCtrls, Vcl.CheckLst,
  Vcl.DBGrids, IdCoder, IdCoder3to4, IdCoderMIME, Vcl.Dialogs,
  ComObj, Variants, Registry, AdoDB, Vcl.Forms, Vcl.Buttons,
  Vcl.ExtCtrls, Vcl.StdCtrls, System.Types, System.UITypes;

const
  NOCHAR = #0; // �res karakter
  TABCHAR = #9; // TAB karakter
  CRCHAR = #13; // ENTER karakter
  APOCHAR = #24; // az aposztr�f karaktere
  IDCHAR = #39; // SQL aposzt�f karaktere
  ESC = #27; // Escape karaktere
  SPACECHAR = ' '; // sz�k�z
  FEL = #8593;
  LE = #9660;
  NOSTRING = ''; // �res string
  UJSOR = #13#10; // �j sor
  MAXDAT = '2100.12.31.';
  VERZIO = '1.0.0.1';
  JELSZO_MD5='szf0t1t0k';
  HONAPOK: array [1 .. 12] of String[10] = ('janu�r', 'febru�r', 'm�rcius',
    '�prilis', 'm�jus', 'j�nius', 'j�lius', 'augusztus', 'szeptember',
    'okt�ber', 'november', 'december');
  NAPOK: array [1 .. 7] of String[10] = ('vas�rnap', 'h�tf�', 'kedd', 'szerda',
    'cs�t�rt�k', 'p�ntek', 'szombat');
  AT3: array [1 .. 9] of String = ('t�z', 'h�sz', 'harminc', 'negyven', '�tven',
    'hatvan', 'hetven', 'nyolcvan', 'kilencven');
  AT2: array [1 .. 9] of String = ('tizen', 'huszon', 'harminc', 'negyven',
    '�tven', 'hatvan', 'hetven', 'nyolcvan', 'kilencven');
  AT1: array [1 .. 9] of String = ('egy', 'kett�', 'h�rom', 'n�gy', '�t', 'hat',
    'h�t', 'nyolc', 'kilenc');
  SZINERTEK: Array [0 .. 26] of TColor = ($00D0FFFF, // info          0
    $0080FFFF, // pasztel s�rga 1
    $00FFFFC0, // �gsz�n k�k    2
    $00D0D3D5, // pasztel z�ld  3
    clBlack, // fekete        4
    clMaroon, // gesztenye     5
    clGreen, // z�ld          6
    clOlive, // ol�v          7
    clNavy, // tengerk�k     8
    clPurple, // b�bor         9
    clTeal, // pasztelz�ld  10
    clGray, // sz�rke       11
    clSilver, // ez�st        12
    clRed, // piros        13
    clLime, // s�rg�sz�ld   14
    clYellow, // s�rga        15
    clBlue, // k�k          16
    clFuchsia, // lila         17
    clAqua, // z�ldesk�k    18
    clWhite, // feh�r        19
    clInfoBk, // h�tt�r       20
    clBtnFace, // gomb         21
    clMoneyGreen, // p�nz z�ld    22
    clSkyBlue, // �gk�k        23
    $0000D7FF, // arany       24
    $0000A5FF, // narancs     25
    $00CBC0FF // r�zsasz�n   26
    );
  MezoKotelezo = 'A(z) %s megad�sa k�telez�!';
  SZINNEV: Array [0 .. 26] of String[11] = ('1', '2', '3', '4', 'fekete',
    'gesztenye', 'z�ld', 'ol�v', 'tengerk�k', 'b�bor', 'pasztelz�ld', 'sz�rke',
    'ez�st', 'piros', 's�rg�sz�ld', 's�rga', 'k�k', 'lila', 'z�ldesk�k',
    'feh�r', 'h�tt�r', 'gomb', 'p�nz z�ld', '�gk�k', 'arany', 'narancs',
    'r�zsasz�n');
  SHELL_HIBA: Array [0 .. 32] of String =
    ('0 = Az oper�ci�s rendszernek nincs el�g mem�ri�ja vagy er�forr�ssa.',
    '1 = ?', '2 = A megadott f�jl nem tal�lhat�.',
    '3 = A megadott el�r�si �t nem tal�lhat�.', '4 = ?',
    '5 = Windows 95 csak: Az oper�ci�s rendszer megtagadta a hozz�f�r�st a megadott f�jlt.',
    '6 = ?', '7 = ?',
    '8 = Windows 95 csak: Nem volt el�g mem�ria a m�velet befejez�s�hez.',
    '9 = ?', '10 = Rossz Windows-verzi�',
    '11 = az .exe f�jl �rv�nytelen (nem Win32 EXE vagy hiba .EXE k�p)',
    '12 = alkalmaz�s�nak c�lja az volt egy m�sik oper�ci�s rendszer',
    '13 = Alkalmaz�s c�lja az volt, MS-DOS 4.0', '14 = ?',
    '15 = megpr�b�lja bet�lteni a val�s m�d� programot',
    '16 = megpr�b�lja bet�lteni a m�sodfok� k�relem, valamint a nem olvashat� adatok szegmensek.',
    '17 = ?', '18 = ?',
    '19 = megpr�b�lja bet�lteni egy t�m�r�tett f�jl alkalmaz�sa.',
    '20 = dynamic-link library (DLL f�jl) hiba.', '21 = ?', '22 = ?', '23 = ?',
    '24 = ?', '25 = ?', '26 = A megoszt�si hiba fordult el�.',
    '27 = A f�jln�v egyes�let hi�nyos vagy �rv�nytelen.',
    '28 = A DDE tranzakci� nem hajthat� v�gre, mert a k�relem id�t�ll�p�s.',
    '29 = A DDE tranzakci� nem siker�lt.',
    '30 = A DDE tranzakci� nem hajthat� v�gre, mert a t�bbi DDE tranzakci�k feldolgoz�sa folyt.',
    '31 = nincs t�rs�tott alkalmaz�s az adott f�jl kiterjeszt�se.',
    '32 = Windows 95 eset�ben: A megadott DLL nem tal�lhat�.');
  RegistryKulcs = '\Software\Expert St�di�\TEDI_JURTA\';

  KettoHatvany: Array [0 .. 15] Of Integer = (1, 2, 4, 8, 16, 32, 64, 128, 256,
    512, 1024, 2048, 4096, 8192, 16384, 32768);
  c_ObjTip_Menu = 0;
  c_ObjTip_Ablak = 1;

Function Uzenet(Szoveg: String): Boolean;
Function Rakerdez(Szoveg: String): Boolean;

Function ParseString(const s: string; const pcs: string; inclpc: Boolean;
  const exclcs: string; numpstrs: Integer): TStringList;
Function FindChar(const s: string; c, exclc: char; from: Integer): Integer;
Function RTrimStr(const s: string): string;
Function LTrimStr(const s: string): string;
Function TrimStr(const s: string): string;
Function FindMatchBracket(const s: string; exclc: char; pos: Integer): Integer;
Function RFindChar(const s: string; c, exclc: char; from: Integer): Integer;
Function DateToSzoveg(akt_datum: TDateTime): String;
Function DateToData(akt_datum: TDateTime): String;
Function StrDate(mask: String): String;
Function DateStr(datum: String): String;
Function TimeStr(ido: String): String;
function CheckBankszamlaszam(a: string): Boolean;
Function CheckToDec(clb: TCheckListBox): Integer;
Function DecToCheck(clb: TCheckListBox; dec: Integer): Boolean;
Function CheckToStr(clb: TCheckListBox): String;
Function StrToCheck(clb: TCheckListBox; str: String): Boolean;
function LTrimStrSpec(const s: string; kar, be: char): string;
function RTrimStrSpec(const s: string; kar, be: char): string;
function TrimStrSpec(const s: string; kar, be: char): string;

function SzamTobbKarakteren(I, Hossz: Integer): String;
function GoodDate(const d: String): Boolean;
function SubString(s: String): String;

Function StrToData(s: String; AposztrofKore: Boolean = false): String;

Function DoksiSzerverre(Fajlneve1, Fajlneve2: String;
  Feluliras: Boolean = false): String;
Function DoksiSzerverrol(Fajlnev: String): String;
Function DoksiTorles(Fajlnev: String): Boolean;

function CHR_Replace(const str: String; kar: char = '_'): String;
Function Atvalt(szem: Real): String;
Function Helyiertek(szem: Real): String;
Function SpaceDel(szov: String): String;

Function Kodolas(s: String): String;
Function DeKodolas(s: String): String;

Function DatumIdo(datum, ido: String): String;
function BoolToInt(b: Boolean): Integer;
function BoolToStr(b: Boolean): String;
function IntToBool(x: Integer): Boolean;
function StrToBool(x: String): Boolean;

Function GLS_CheckDigit(szam: String): String;

function NCharToWeb(szov: String): String;
Function Html2Text(s: String): String;

function base64Decode(const Text: WideString): WideString;
function base64Encode(const Text: WideString): WideString;

Function ExcelKimenet(Forras: TADOQuery; Tabla: TDBGrid; Szoveg: String): Boolean;
Procedure CSVkimenet(Forras: TADOQuery; Tabla: TDBGrid; Szoveg: String);

Var
  // Word
  BB_BILL, // Funkci� gomb azonos�t�
  Funkcio, // Ablak megh�v�sakor funkci�m�dos�t� param�ter
  SZEK_ID, akt_ev, akt_ho, akt_nap: Word; // Szerepk�r azonos�t�
  // Integer
  UJ, ALLAPOT_ID, HIVO, MENUJOG_ID, // Megnyitott men�pont jogosults�ga
  SZERK, DOK_ALL, FIGYEL,
  // F�men� lapj�n a figyel�s enged�lyez�se = 1 vagy til�t�sa = 0
  JOG_FIGYEL, // Jog lapj�n a figyel�s enged�lyez�se = 1 vagy til�t�sa = 0
  JOG_NAP, FELADAT, // Feladatkezel�sn�l a feladatok saj�t = 0 vagy minden = 1
  BETUMERET
    : Integer;
  // String
  BETUTIPUS,
  FELHASZNALO, // Bel�pett felhaszn�l� neve
  FELHCSOP_ID, // Bel�pett felhaszn�l� csoport ID
  FELH_JELSZO, // Bel�pett felhaszn�l� jelszava
  FELHASZNALO_ID, // Bel�pett felhaszn�l� ID
  FELH_ID, FELH_CSOP, FELH_NEV, BELEP_NEV, // Bel�p�si n�v
  FELH_EMAIL,
  AB_NEV, REND_OSZLOP, REND_IRANY, KK_ID, KKUT_ID, // K�z�s k�lts�g utal�s ID
  EP_ID, // �p�let ID
  LAK_ID, // Lak�sa ID
  NLAK_ID, // Nem lak�s ID
  BERL_ID,  //B�rlem�ny ID
  KEPV_ID, // K�pvielet ID
  SZEM_ID, // Szem�ly ID
  SZEM_ANYJA,
  SZEM_SZH,
  SZEM_SZD,
  SZER_ID, // Szervezet ID
  SZER_ADO,
  SZER_BSZ,
  KAT_ID, // Kataszter ID
  KEP_ID,
  BKAP_ID, // B�rl� kapcsolat
  LTUL_ID, // Lak�s tulajdonos
  NTUL_ID, // Nem lak�s tulajdonos
  ETUL_ID, // �p�let tulajdonos
  ERTE_ID, // �rt�k adat
  KGY_ID, // K�zgy�l�s ID
  KOT_ID, // K�telezetts�g ID
  KP_ID, // P�ly�zat ID
  FE_ID, // Feladat ID
  SZE_ID, // Szerz�d�s ID
  SZET_ID, // Szerz�d�s m�dos�t� ID
  USZ_ID, // �gyf�lszolg�lati ID
  AFE_ID, ILE_ID, KOZMU_ID, Etabla, Erekord, ELE_ID, BER_ID, VIZ_ID,
  // Vizfogyaszt�s ID
  MEG_ID, // Megjegyz�s ID
  HRSZ_ID, // Helyrajzi sz�m ID
  HRSZ_SOR, // Helyrajzi sz�m teljes
  IKT_ID, // Iktat� ID
  EIKT_ID, // El�zm�ny ID
  IKT_SZAM, // Iktat� sz�m
  IRT_ID, // Iratt�r ID
  IRK_ID, // Iratk�lcs�nz�s ID
  DOK_ALAIRO, // Lev�l al��r�ja
  UO_VEZ, // �gyoszt�ly vezet�je
  IKTT_ID, // Iktat�t�rt�net ID
  ikt_konyv, // Iktat� k�nyv
  TARGY_ID, // Iktat� t�rgy ID
  HAT_ID, // Hat�rozat ID
  CIM_ID, // C�m ID
  CIM_SOR, // C�m sora
  PCIM_SOR, // C�m teljes sora
  T_ID, // Iktat�s t�rgy ID
  LE_ID, // Informatikai lelt�r ID
  JOG_ID, // Jogi iktatas ID
  JU_ID, // Jogi �gymenet ID
  IE_ID, // Iktat� �rintett ID
  EK_ID, // �rkeztet� k�nyv ID
  IP_ID, // Iratp�d�ny azonos�t�
  BERLO_ID, // B�rl� azonos�t�
  BERLO,
  BERLO_TARS,
  PA_ID, // P�ly�zat azonos�t�
  SZOBA, // Felhaszn�l� szoba sz�ma
  SZEREP, UTAL_TIP, AB_SZERVER, AB_KONV, NYOMT_ID, USER_NEV, // E-mailhez
  PASS_NEV, // E-mailhez
  SMTP_NEV, // E-mailhez
  POP3_NEV, // E-mailhez
  IMAP_NEV,
  SZEM_NEV, // Szem�ly neve
  SZER_NEV, // Szervezet neve
  SZEM_EMIL, // Szem�ly e-mail c�me
  SZER_EMIL, // Szervezet e-mail c�me
  SZER_CIM,
  SZEM_CIM,
  SZERVER, // f�jlszerver
  SZERZT_ID,
  SZAMLA_ID,
  SZAMLAT_ID: String;

  SZERKESZT,
  EMELO
  : Boolean;

  EL_ID, EA_ID, ELTE_ID, USZ, CSTENY_ID, NYB_ID, Felado, Cimzett,
    U_FELADO, U_CIMZETT, MEGOSZTAS, ALL_ID, ALL_NEV, DOK_ID, DOK_NEV, DOK_EV,
    DOK_FELH, OLD_SZAM, LAP_OLV, UTALAS_CIMZETT, INTEZ, S_SQL, S_SQL1, S_SQL2,
    S_SQL3, S_SQL4, S_SQL5, S_SQL6, S_SQL7, S_SQL8, S_SQL9, S_FEJ, S_FEJ1,
    S_FEJ2, S_FEJ3, S_FEJ4, S_FEJ5, S_FEJ6, S_FEJ7, S_FEJ8, S_FEJ9, HB_ID, M_ID,
    MSZ_ID, MEGR_ID, IT_ID, INT_ID, ISE_ID, UT_ID, MA_ID, MK_ID, MUSZAK_ID,
    J_UGYSZAM, MIKT, HIKT, MKB_ID, MKOZ_ID, Host, IP, G_ELERES, D_ELERES,
    K_ELERES, S_ELERES, TSZE_ID, STILUS: String;

  SZAMOK: set of '0' .. '9' = ['-', '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9'];
  Ertekek: Array [0 .. 50] of String[50];
  CIM_ERTEKEK: Array [0 .. 50] of String[50];
  HRSZ_ERTEKEK: Array [0 .. 50] of String[50];

  NemEngedelyezettSzin: Integer = $00D1C9E7; // clSilver;
  KotelezoMezoSzin: Integer = $009BB1FF;
  KiemeltSzin: Integer = clYellow;
  KIJELOLES_SZIN: Integer = clRed;
  TiltottSzin: Integer = clInactiveCaption;
  AlapSzin: Integer = clMoneyGreen;
  ADOConnection: TADOConnection;

  id: ^Integer;
  TN: TTreeNode;
  Mo: Boolean;


implementation

{ �zenet a felhaszn�l�nak }
Function Uzenet(Szoveg: String): Boolean;
Var
  F: TForm;
  bb_OK: TBitBtn;
  L1: TLabel;
  Panel: TPanel;
begin
  F := TForm.CreateNew(Application);
  With F Do
  Begin
    ClientWidth := 252;
    ClientHeight := 96;
    Position := poScreenCenter;
    Font.Size := BETUMERET;
    BorderStyle := bsNone;
    OldCreateOrder := True;
  End;

  Panel := TPanel.Create(F);
  With Panel Do
  Begin
    Parent := F;
    Align := alClient;
    Color := clMoneyGreen;
  End;

  bb_OK := TBitBtn.Create(F);
  With bb_OK Do
  Begin
    Parent := Panel;
    Left := 90;
    Top := 82;
    Width := 84;
    Height := 36;
    Caption := 'Rendben';
    ModalResult := mrOk;
    Cursor := crHandPoint;
    Default := True;
  End;

  L1 := TLabel.Create(F);
  With L1 Do
  Begin
    Parent := Panel;
    Caption := Szoveg;
    Left := 18;
    Top := 18;
    Width := 216;
    Height := 60;
    Alignment := taCenter;
    AutoSize := false;
    Font.Size := BETUMERET;
    WordWrap := True;
  End;

  F.ActiveControl := bb_OK;
  Try
    F.ShowModal;
  Except
  End;
  If F.ModalResult = mrOk Then
    Result := True
  Else
    Result := false;
  F.Destroy;
End;

{ R�k�rdez�s a m�velet v�grehajt�s�ra }
Function Rakerdez(Szoveg: String): Boolean;
Var
  F: TForm;
  bb_OK, bb_Megsem: TButton;
  L1: TLabel;
  Panel: TPanel;
begin

  F := TForm.CreateNew(Application);
  With F Do
  Begin
    ClientWidth := 240;
    ClientHeight := 100;
    Position := poScreenCenter;
    Font.Size := BETUMERET;
    Font.Name := 'Calibri';
    Font.Style := [fsBold];
    BorderIcons := [];
    BorderStyle := bsNone;
    OldCreateOrder := True;
  End;

  Panel := TPanel.Create(F);
  With Panel Do
  Begin
    Parent := F;
    Align := alClient;
    BevelInner := bvRaised;
    BevelOuter := bvLowered;
  End;

  bb_OK := TButton.Create(F);
  With bb_OK Do
  Begin
    Parent := Panel;
    Left := 32;
    Top := 80;
    Width := 76;
    Height := 36;
    Caption := 'Igen';
    ParentShowHint := false;
    Cursor := crHandPoint;
    ShowHint := false;
    ModalResult := mrOk;
    Cursor := crHandPoint;
  End;

  bb_Megsem := TButton.Create(F);
  With bb_Megsem Do
  Begin
    Parent := Panel;
    Left := 140;
    Top := 80;
    Width := 76;
    Height := 36;
    Caption := 'Nem';
    ParentShowHint := false;
    ShowHint := false;
    ModalResult := mrCancel;
    Cursor := crHandPoint;
    Cancel := True;
    Default := True;
  End;

  L1 := TLabel.Create(F);
  With L1 Do
  Begin
    Parent := Panel;
    Caption := Szoveg;
    Left := 18;
    Top := 12;
    Width := 205;
    Height := 64;
    Alignment := taCenter;
    AutoSize := false;
    WordWrap := True;
  End;

  F.ActiveControl := bb_Megsem;
  Try
    F.ShowModal;
  Except
  End;
  If F.ModalResult = mrOk Then
    Result := True
  Else
    Result := false;
  F.Destroy;
End;


// String darabol�s...

{ <s>: a feldaraboland� string,
  <pcs>: az elv�laszt� karakterek t�mbje, ugyanis t�bb elv�laszt� karaktert is meg lehet adni,
  �s b�rmelyik el�fordul, darabol. <pc> a tal�lt elv�laszt� karakter, vagy 255,
  ha nincs az adott pozici�ban ilyen.
  <inclpc>: true, ha a darabolt stringek koze be	kell tenni <pc>-t is (pl. s='8*7', pc='*',
  <inclpc>:true -> '8','*','7' lesz az eredmeny),
  <exclcs>: a kiv�tel karakterek: ha ket ilyen k�z�tt van egy <pc>, akkor ott nem darabolunk!
  <numpstrs>: h�ny darabol�st hajtson v�gre. Ha 1, akkor k�t darabra v�gja a stringet
  (ha <inclpc>=true, akkor h�romra! ). Ha -1, akkor az eg�sz	stringet darabolja. }
function ParseString(const s: string; const pcs: string; inclpc: Boolean;
  const exclcs: string; numpstrs: Integer): TStringList;
var
  I, j, slen, nump: Integer;
  tordelendo: Boolean;
  tsl: TStringList;
begin
  slen := Length(s);
  if slen < 1 then
  begin
    ParseString := nil;
    exit;
  end;
  tsl := TStringList.Create;
  j := 1;
  I := 1;
  nump := 0;
  while True do
  begin
    tordelendo := false;
    if FindChar(pcs, s[j], NOCHAR, 1) <> 0 then
      tordelendo := True;
    if tordelendo then
    begin
      { if j <> i then tsl.Add(MidStr(s, i, j - i)); }
      tsl.Add(Copy(s, I, j - I));
      if inclpc then
        tsl.Add(s[j]);
      Inc(nump);
      I := j + 1;
    end;
    if nump = numpstrs then
    { Ha annyi darabolas tortent, ahanyat kertunk, akkor a maradek stringet is hozzaadjuk a
      listahoz, es kilepunk. }
    begin
      if I <= slen then
        tsl.Add(Copy(s, I, slen - I + 1));
      break;
    end;
    if FindChar(exclcs, s[j], NOCHAR, 1) <> 0 then
    { Most egy olyan karaktert talaltunk, ami kizaro, tehat a kezdete es a vege kozott nem szabad
      darabolni. Ha ez a karakter nyito zarojel, akkor a zaro zarojel utan szabad folytatni a
      darabolast! }
    begin
      j := FindMatchBracket(s, NOCHAR, j);
      if j = 0 then
        { ha nincs parja, akkor ezutan nem tordelunk }
        j := slen;
    end;
    Inc(j);
    if j > slen then
    begin
      { Ha a string vegere ertunk, meg lehet, hogy az utolso darab nincs <tsl>-hez adva! }
      { if j <> i then tsl.Add(MidStr(s, i, j - i)); }
      tsl.Add(Copy(s, I, j - I));
      break;
    end;
  end;
  ParseString := tsl;
end; { ParseString }

function FindChar(const s: string; c, exclc: char; from: Integer): Integer;
{ Megkeresi <s>-ben <from> poziciotol <c>-t, es	ha megtalalja, akkor a poziciojaval ter vissza.
  Ha nincs meg, akkor 0 a visszateresi ertek.
  Ket <exclc> kozott nem vizsgal!
  Ez akkor fontos, amikor forditott lengyel alakra hozunk stringkifejezest, akkor ne
  keressunk zarojelezest ket STRINGCHAR kozott, tehat pl. mid$("subi(dubi)",2,3) -ra ne
  keressen ra (dubi) zarojeleire. }
var
  voltexclc: Boolean;
  slen: Integer;
begin
  if from < 1 then
    from := 1;
  slen := Length(s);
  voltexclc := false;
  while from <= slen do
  begin
    if (s[from] = c) and not voltexclc then
      break
    else if s[from] = exclc then
      voltexclc := not voltexclc;
    Inc(from);
  end;
  if from > slen then
    from := 0;
  FindChar := from;
end; { FindChar }

function LTrimStr(const s: string): string;
{ <s> bal oldalarol eltunteti a SPACE-eket es a TAB-okat. }
var
  I, slen: Integer;
begin
  slen := Length(s);
  I := 1;
  while I <= slen do
  begin
    if (s[I] <> SPACECHAR) and (s[I] <> TABCHAR) then
      break;
    Inc(I);
  end;
  if I > slen then
    LTrimStr := NOSTRING
  else
    LTrimStr := RightStr(s, slen - I + 1);
end; { LTrimStr }

function RTrimStr(const s: string): string;
{ <s> jobb oldalarol eltunteti a SPACE-eket es a TAB-okat. }
var
  I: Integer;
begin
  I := Length(s);
  while I > 0 do
  begin
    if (s[I] <> SPACECHAR) and (s[I] <> TABCHAR) then
      break;
    dec(I);
  end;
  if I < 1 then
    RTrimStr := NOSTRING
  else
  begin
    RTrimStr := LeftStr(s, I);
  end;
end; { RTrimStr }

function TrimStr(const s: string): string;
var
  res: string;
begin
  res := LTrimStr(s);
  TrimStr := RTrimStr(res);
end; { TrimStr }

function FindMatchBracket(const s: string; exclc: char; pos: Integer): Integer;
{ Megkeresi <s>-ben a <pos> helyen l�v� <bracket> z�r�jelnek a p�rj�t, �s annak
  pozici�j�val t�r vissza. Ha nincs meg, 0-val.
  <bracket> lehet : (),[],{?,<>
  Ha <bracket> m�s, akkor ugyanolyan karaktert keres p�rnak.
  Ha <exclc>-be �tk�zik a keres�s sor�n, akkor r�keres a k�vetkez�re, majd csak onnan
  folytatja a z�rojelp�r keres�s�t. }
var
  slen, dir, numopen, numclosed: Integer;
  bracket, brpair: char;
begin
  slen := Length(s);
  numopen := 0;
  numclosed := 0;
  bracket := s[pos];
  case bracket of
    '(':
      begin
        brpair := ')';
        dir := 1;
      end;
    ')':
      begin
        brpair := '(';
        dir := -1;
      end;
    '[':
      begin
        brpair := ']';
        dir := 1;
      end;
    ']':
      begin
        brpair := '[';
        dir := -1;
      end;
    '{':
      begin
        brpair := '}';
        dir := 1;
      end;
    '}':
      begin
        brpair := '{';
        dir := -1;
      end;
    '<':
      begin
        brpair := '>';
        dir := 1;
      end;
    '>':
      begin
        brpair := '<';
        dir := -1;
      end;
  else
    begin
      brpair := bracket;
      dir := 1;
    end;
  end;
  pos := pos + dir;
  while (pos > 0) and (pos <= slen) do
  begin
    if s[pos] = exclc then
    begin
      if dir = 1 then
        { zarozarojelet keresunk, az esetleges dupla <exclc>-t atugorjuk. }
        pos := FindChar(s, exclc, NOCHAR, pos + 1)
      else
        { nyitozarojelet keresunk, az esetleges dupla <exclc>-t atugorjuk. }
        pos := RFindChar(s, exclc, NOCHAR, pos - 1);
      if pos = 0 then
        break;
    end
    else if (s[pos] = brpair) and (numopen = numclosed) then
    begin
      FindMatchBracket := pos;
      exit;
    end
    else if s[pos] = bracket then
      Inc(numopen)
    else if s[pos] = brpair then
      Inc(numclosed);
    pos := pos + dir;
  end;
  FindMatchBracket := 0;
end; { FindMatchBracket }

function RFindChar(const s: string; c, exclc: char; from: Integer): Integer;
{ Megkeresi <s>-ben <from> poziciotol visszafele <c>-t, es ha megtalalja,
  akkor a poziciojaval ter vissza.
  Ha nincs meg, akkor 0 a visszateresi ertek. <exclc> magyarazatat lasd FindChar()-nal; }
var
  slen: Integer;
  voltexclc: Boolean;
begin
  slen := Length(s);
  voltexclc := false;
  if from > slen then
    from := slen;
  while from > 0 do
  begin
    if (s[from] = c) and not voltexclc then
      break
    else if s[from] = exclc then
      voltexclc := not voltexclc;
    dec(from);
  end;
  if from < 1 then
    from := 0;
  RFindChar := from;
end; { RFindChar }

{ D�tumot sz�vegg� alak�t }
Function DateToSzoveg(akt_datum: TDateTime): String;
Begin
  Result := IntToStr(YearOf(akt_datum)) + '. ' + HONAPOK[MonthOf(akt_datum)] +
    ' ' + IntToStr(DayOf(akt_datum)) + ' (' + NAPOK[DayOfWeek(akt_datum)] + ')';
end;

Function DateToData(akt_datum: TDateTime): String;
Var
  s, S1: String;
Begin
  S1 := IntToStr(MonthOf(akt_datum));
  If Length(S1) = 1 Then
    S1 := '0' + S1;
  s := IntToStr(YearOf(akt_datum)) + S1;
  S1 := IntToStr(DayOf(akt_datum));
  If Length(S1) = 1 Then
    S1 := '0' + S1;
  s := s + S1;
  Result := s;
end;

Function StrDate(mask: String): String;
var
  s: String;
begin
  s := LTrimStr(StringReplace(mask, '.', '', [rfReplaceAll]));
  Result := LTrimStr(StringReplace(s, ':', '', [rfReplaceAll]));
end;

Function DateStr(datum: String): String;
begin
  Result := LeftStr(datum, 10);
end;

Function TimeStr(ido: String): String;
var
  s: String;
begin
  s := '';
  // Result:='  :  ';
  Result := '';
  If MidStr(ido, 14, 1) = ':' Then
    s := '0' + MidStr(ido, 13, Length(ido) - 1)
  else
    s := MidStr(ido, 13, Length(ido) - 1);
  Result := s;
end;

{ D�tumb�l megadja annek �v�t }

{ Banksz�mlasz�m ellen�rz�se }
function CheckBankszamlaszam(a: string): Boolean;
var
  Hossz, crc: Integer;
begin
  CheckBankszamlaszam := false; { alapbol rossz }
  Hossz := Length(a);

  if (Copy(a, 1, 8) = '00000000') then
    exit;
  if (Copy(a, 1, 8) = '11111111') then
    exit;
  if (Copy(a, 1, 8) = '22222222') then
    exit;
  if (Copy(a, 1, 8) = '33333333') then
    exit;
  if (Copy(a, 1, 8) = '44444444') then
    exit;
  if (Copy(a, 1, 8) = '55555555') then
    exit;
  if (Copy(a, 1, 8) = '66666666') then
    exit;
  if (Copy(a, 1, 8) = '77777777') then
    exit;
  if (Copy(a, 1, 8) = '99999999') then
    exit;

  if (Copy(a, 8, 8) = '00000000') then
    exit;
  if (Copy(a, 8, 8) = '11111111') then
    exit;
  if (Copy(a, 8, 8) = '22222222') then
    exit;
  if (Copy(a, 8, 8) = '33333333') then
    exit;
  if (Copy(a, 8, 8) = '44444444') then
    exit;
  if (Copy(a, 8, 8) = '55555555') then
    exit;
  if (Copy(a, 8, 8) = '66666666') then
    exit;
  if (Copy(a, 8, 8) = '77777777') then
    exit;
  if (Copy(a, 8, 8) = '99999999') then
    exit;
  try
    case Hossz of
      16:
        begin
          crc := (9 * StrToInt(a[1]) + 7 * StrToInt(a[2]) + 3 * StrToInt(a[3]) +
            1 * StrToInt(a[4]) + 9 * StrToInt(a[5]) + 7 * StrToInt(a[6]) + 3 *
            StrToInt(a[7]) + 1 * StrToInt(a[8])) mod 10;
          if crc <> 0 then
            exit;
          crc := (9 * StrToInt(a[9]) + 7 * StrToInt(a[10]) + 3 * StrToInt(a[11])
            + 1 * StrToInt(a[12]) + 9 * StrToInt(a[13]) + 7 * StrToInt(a[14]) +
            3 * StrToInt(a[15]) + 1 * StrToInt(a[16])) mod 10;
          if crc <> 0 then
            exit;
          CheckBankszamlaszam := True;
        end;
      24:
        begin
          crc := (9 * StrToInt(a[1]) + 7 * StrToInt(a[2]) + 3 * StrToInt(a[3]) +
            1 * StrToInt(a[4]) + 9 * StrToInt(a[5]) + 7 * StrToInt(a[6]) + 3 *
            StrToInt(a[7]) + 1 * StrToInt(a[8])) mod 10;
          if crc <> 0 then
            exit;
          crc := (9 * StrToInt(a[9]) + 7 * StrToInt(a[10]) + 3 * StrToInt(a[11])
            + 1 * StrToInt(a[12]) + 9 * StrToInt(a[13]) + 7 * StrToInt(a[14]) +
            3 * StrToInt(a[15]) + 1 * StrToInt(a[16]) + 9 * StrToInt(a[17]) + 7
            * StrToInt(a[18]) + 3 * StrToInt(a[19]) + 1 * StrToInt(a[20]) + 9 *
            StrToInt(a[21]) + 7 * StrToInt(a[22]) + 3 * StrToInt(a[23]) + 1 *
            StrToInt(a[24])) mod 10;
          if crc <> 0 then
            exit;
          CheckBankszamlaszam := True;
        end;
    end;
  except
  end;
end;

{ Egy CheckListBox bejel�lt �rt�keit decim�lisan k�dol }
Function CheckToDec(clb: TCheckListBox): Integer;
Var
  I, x: Integer;
begin
  x := 0;
  For I := 0 to clb.Items.Count - 1 do
  begin
    If clb.Checked[I] Then
      x := x + Round(IntPower(2, I));
  end;
  Result := x;
end;

{ Egy decim�lis k�dot CheckListBox jel�l�sekk� alak�t }
Function DecToCheck(clb: TCheckListBox; dec: Integer): Boolean;
var
  I, x: Integer;
begin
  x := dec;
  For I := 0 to clb.Items.Count - 1 do
  begin
    If ((x mod 2) = 1) or (x = 1) Then
      clb.Checked[I] := True;
    x := x div 2;
  end;
  Result := True;
end;

{ Egy CheckListBox bejel�lt �rt�keit String-ben t�rolja }
Function CheckToStr(clb: TCheckListBox): String;
Var
  I: Integer;
  s: String;
begin
  s := '';
  For I := 0 to clb.Items.Count - 1 do
    If clb.Checked[I] Then
      s := s + '1'
    Else
      s := s + '0';
  Result := s;
end;

{ Egy String k�dot CheckListBox jel�l�sekk� alak�t }
Function StrToCheck(clb: TCheckListBox; str: String): Boolean;
var
  I: Integer;
begin
  For I := 1 to Length(str) do
    If str[I] = '1' Then
      clb.Checked[I - 1] := True
    Else
      clb.Checked[I - 1] := false;
  Result := True;
end;

{ <s> bal oldalarol eltunteti a <kar>-eket �s ha <be> nem �res, akkor beilleszti azt. }
function LTrimStrSpec(const s: string; kar, be: char): string;
var
  I, slen: Integer;
begin
  slen := Length(s);
  I := 1;
  while I <= slen do
  begin
    if s[I] <> kar then
      break;
    Inc(I);
  end;
  if I > slen then
    LTrimStrSpec := be
  else
    LTrimStrSpec := RightStr(s, slen - I + 1);
end; { LTrimStr }

{ <s> jobb oldalarol eltunteti a <kar>-eket �s ha <be> nem �res, akkor beilleszti azt. }
function RTrimStrSpec(const s: string; kar, be: char): string;
var
  I: Integer;
begin
  I := Length(s);
  while I > 0 do
  begin
    if s[I] <> kar then
      break;
    dec(I);
  end;
  if I < 1 then
    RTrimStrSpec := be
  else
    RTrimStrSpec := LeftStr(s, I);
end; { RTrimStr }

//
function TrimStrSpec(const s: string; kar, be: char): string;
var
  res: string;
begin
  res := LTrimStrSpec(s, kar, be);
  TrimStrSpec := RTrimStrSpec(res, kar, be);
end; { TrimStr }

// Nulla el�tagokkal t�lti fel az 'I' �rt�k�t 'Hossz' m�rt�kben
function SzamTobbKarakteren(I, Hossz: Integer): String;
Var
  s: String;
Begin
  s := IntToStr(I);
  While Length(s) < Hossz Do
    s := '0' + s;
  Result := s;
End;

{ D�tum ellen�rz�se }
function GoodDate(const d: String): Boolean;
var
  dat: TDateTime;
  s: String;
begin
  try
    // Ha d d�tum t�pus�
    If FindChar(d, '.', NOCHAR, 1) <> 0 Then
    begin
      If FindChar(d, ' ', NOCHAR, 1) <> 0 Then
        s := TrimStrSpec(d, ' ', '0')
      else
        s := d;
      dat := StrToDate(s);
    end;
    // Ha d id� t�pus�
    If FindChar(d, ':', NOCHAR, 1) <> 0 Then
    begin
      If FindChar(d, ' ', NOCHAR, 1) <> 0 Then
        s := TrimStrSpec(d, ' ', '0')
      else
        s := d;
      dat := StrToTime(s);
    end;
    dat := dat + 1;
    Result := True;
  except
    Result := false;
  end;
end;

{ }
function SubString(s: String): String;
var
  I: Integer;
begin
  I := Length(s);
  while I > 0 do
  begin
    if s[I] in [' ', '_'] then
      s[I] := '%';
    dec(I);
  end;
  Result := s;
end;

Function StrToData(s: String; AposztrofKore: Boolean = false): String;
Begin
  If AposztrofKore Then
    Result := '''' + TrimRight(StringReplace(s, #39, #39#39,
      [rfReplaceAll])) + ''''
  Else
    Result := TrimRight(StringReplace(s, #39, #39#39, [rfReplaceAll]));
End;

Function DoksiSzerverre(Fajlneve1, Fajlneve2: String;
  Feluliras: Boolean = false): String;
Var
  UjFajlNeve, Eleres: String;
Begin
  DoksiSzerverre := '';
  If Fajlneve2 = '' Then
    Fajlneve2 := Fajlneve1;
  if Not FileExists(Fajlneve1) Then
    exit;
  Eleres := Fajlneve2;
  If CopyFile(PChar(Fajlneve1), PChar(Eleres), false) Then
    DoksiSzerverre := Eleres;
End;

Function DoksiSzerverrol(Fajlnev: String): String;
Var
  UjFajlNeve: String;
Begin
  DoksiSzerverrol := '';
  UjFajlNeve := ExtractFileName(Fajlnev);
  Delete(UjFajlNeve, 1, pos('_', UjFajlNeve));
  UjFajlNeve := GetCurrentDir + '\' + UjFajlNeve;
  If FileExists(Fajlnev) Then
    If CopyFile(PChar(Fajlnev), PChar(UjFajlNeve), false) Then
      // Sikerult atmasolni
      DoksiSzerverrol := UjFajlNeve;
End;

Function DoksiTorles(Fajlnev: String): Boolean;
Begin
  DoksiTorles := false;
  If FileExists(Fajlnev) Then
    If DeleteFile(PChar(Fajlnev)) Then
      DoksiTorles := True;
End;

function CHR_Replace(const str: String; kar: char = '_'): String;
var
  I: Integer;
  s: String;
begin
  SetLength(s, Length(str));
  For I := 1 to Length(str) do
  begin
    Case str[I] of
      '�':
        s[I] := 'a';
      '�':
        s[I] := 'A';
      '�':
        s[I] := 'e';
      '�':
        s[I] := 'E';
      '�', '�', '�':
        s[I] := 'o';
      '�', '�', '�':
        s[I] := 'O';
      '�':
        s[I] := 'i';
      '�':
        s[I] := 'I';
      '�', '�', '�':
        s[I] := 'u';
      '�', '�', '�':
        s[I] := 'U';
      '.', APOCHAR, IDCHAR, '+', ' ', '/', '\':
        s[I] := kar;
    else
      s[I] := str[I];
    End;
  end;
  Result := s;
end;

//
Function Atvalt(szem: Real): String;
Var
  sz, bet, szov: String;
  Hossz, nrend, hely, I, betszam, kod: Integer;
Begin
  szov := '';
  If szem <> 0 Then
  begin
    szem := Round(szem);
    If szem < 0 Then
    begin
      szov := 'minusz ';
      szem := Abs(szem);
    end;
    sz := TrimStr(FloatToStr(szem));
    Hossz := Length(sz);
    nrend := (Hossz div 3) + 1;
    hely := Hossz;
    I := 1;
    While I <= Hossz Do
    Begin
      bet := Copy(sz, I, 1);
      Val(bet, betszam, kod);
      If ((hely mod 3) = 2) and (Copy(sz, I, 1) <> '0') Then
      Begin
        If Copy(sz, I + 1, 1) = '0' Then
        Begin
          szov := szov + AT3[betszam];
          I := I + 1;
          hely := hely - 1;
        End
        Else
          szov := szov + AT2[betszam];
      End;
      If ((hely mod 3) = 1) And (Copy(sz, I, 1) <> '0') Then
        szov := szov + AT1[betszam];
      If (hely mod 3) = 1 Then
        Case hely of
          10 .. 12:
            szov := szov + 'milli�rd ';
          7 .. 9:
            szov := szov + 'milli� ';
          3 .. 6:
            If (nrend >= 2) And (Copy(sz, I - 2, 3) <> '000') Then
              szov := szov + 'ezer ';
        End;
      If ((hely mod 3) = 0) and (Copy(sz, I, 1) <> '0') Then
        szov := szov + AT1[betszam] + 'sz�z';
      hely := hely - 1;
      I := I + 1;
    End;
  end
  else
    szov := 'nulla';
  Atvalt := szov;
End;

Function Helyiertek(szem: Real): String;
Var
  sz, bet, szov, elo: String;
  Hossz, I: Integer;
Begin
  Helyiertek := '';
  szov := '';
  If szem <> 0 Then
  begin
    szem := Round(szem);
    If szem < 0 Then
    begin
      elo := '- ';
      szem := Abs(szem);
    end
    else
      elo := '';
    sz := TrimStr(FloatToStr(szem));
    Hossz := Length(sz);
    I := 1;
    While Hossz >= 1 Do
    Begin
      bet := Copy(sz, I, 1);
      szov := szov + bet;
      If ((Hossz mod 3) = 1) Then
        szov := szov + ' ';
      Hossz := Hossz - 1;
      I := I + 1;
    End;
  end
  else
    szov := '0';
  Helyiertek := elo + szov;
End;

Function SpaceDel(szov: String): String;
begin
  Result := StringReplace(StringReplace(szov, ' ', '', [rfReplaceAll]), '.', '',
    [rfReplaceAll]);
end;

Function Kodolas(s: String): String;
Const
  Karakterek: String[64]
    = '0QW2ERT4Y5UI6OPA1SDF3GHJ8KLZX7CVB9NM!.?+-[]{}\/><:,;~%()@#$&=* _';
Var
  Ki: String;
  I: Integer;
Begin
  Ki := '';
  For I := 1 To Length(s) Do
    Ki := Ki + Karakterek[Ord(s[I]) MOD 16 + 1] + Karakterek
      [(Ord(s[I]) DIV 16 + 1) + (Ord(s[I]) AND 128) DIV 4];
  Kodolas := Ki;
End;

Function Hanyadik(c: char): Byte;
Const
  Karakterek: String[64]
    = '0QW2ERT4Y5UI6OPA1SDF3GHJ8KLZX7CVB9NM!.?+-[]{}\/><:,;~%()@#$&=* _';
Var
  I: Byte;
  s: String[1];
Begin
  I := 1;
  s := c;
  While ((Karakterek[I] <> s) And (I < 65)) Do
    Inc(I);
  Hanyadik := I;
End;

Function DeKodolas(s: String): String;
Var
  Ki: String;
  I: Integer;
Begin
  Ki := '';
  I := 1;
  s := Trim(s);
  If s <> '' Then
    Repeat
      Ki := Ki + Chr(Hanyadik(s[I]) - 1 + (Hanyadik(s[I + 1]) AND
        31 { } - 1) * 16);
      Inc(I, 2);
    Until Length(s) < I
  Else
    Ki := '';
  DeKodolas := Ki;
End;


Function DatumIdo(datum, ido: String): String;
begin
  if (datum <> '    .  .  .') and (datum <> '') and (datum <> 'null') Then
  begin
    if (ido = '  :  ') or (ido = '  :  :  ') Then
      Result := StrDate(datum)
    Else
      Result := StrDate(datum) + ' ' + ido;
  end
  else
    Result := 'null';
End;

function BoolToInt(b: Boolean): Integer;
begin
  If b Then
    Result := 1
  Else
    Result := 0;
end;

function BoolToStr(b: Boolean): String;
begin
  If b Then
    Result := '1'
  Else
    Result := '0';
end;

function IntToBool(x: Integer): Boolean;
begin
  If x = 1 Then
    Result := True
  Else
    Result := false;
end;

function StrToBool(x: String): Boolean;
begin
  If (x = '1') or (x = 'True') Then
    Result := True
  Else
    Result := false;
end;

Function GLS_CheckDigit(szam: String): String;
var
  I, a: Integer;
begin
  a := 0;
  For I := 0 to Length(szam) do
    a := a + StrToInt(szam[I]);
  a := a * 3;
  For I := 1 to Length(szam) do
    a := a + StrToInt(szam[I]);
  a := a + 1;
  Result := IntToStr(a mod 10);
end;

function NCharToWeb(szov: String): String;
begin
  szov := StringReplace(szov, '�', '&iacute;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&Iacute;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&eacute;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&Eacute;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&aacute;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&Aacute;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&oacute;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&Oacute;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&uacute;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&Uacute;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&ouml;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&Ouml;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&uuml;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&Uuml;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&otilde;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&Otilde;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&utilde;', [rfReplaceAll]);
  szov := StringReplace(szov, '�', '&Utilde;', [rfReplaceAll]);
  Result := szov;
end;

Function Html2Text(s: String): String;
const
  NISOCS = 103;
  ISOCS: array [1 .. NISOCS, 1 .. 2] of string = ((#034, '&quot;'),
    (#038, '&amp;'), (#060, '&lt;'), (#062, '&gt;'), (#160, '&nbsp;'),
    (#161, '&iexcl;'), (#162, '&cent;'), (#163, '&pound;'), (#164, '&curren;'),
    (#165, '&yen;'), (#166, '&brvbar;'), (#166, '&brkbar;'), (#167, '&sect;'),
    (#168, '&uml;'), (#168, '&die;'), (#169, '&copy;'), (#170, '&ordf;'),
    (#171, '&laquo;'), (#172, '&not'), (#173, '&shy;'), (#174, '&reg;'),
    (#175, '&macr;'), (#175, '&hibar;'), (#176, '&deg;'), (#177, '&plusmn;'),
    (#178, '&sup2;'), (#179, '&sup3;'), (#180, '&acute;'), (#181, '&micro;'),
    (#182, '&para;'), (#183, '&middot;'), (#184, '&cedil;'), (#185, '&sup1;'),
    (#186, '&ordm;'), (#187, '&raquo;'), (#188, '&frac14;'), (#189, '&frac12;'),
    (#190, '&frac34;'), (#191, '&iquest;'), (#192, '&Agrave;'),
    (#193, '&Aacute;'), (#194, '&Acirc;'), (#195, '&Atilde;'), (#196, '&Auml;'),
    (#197, '&Aring;'), (#198, '&AElig;'), (#199, '&Ccedil;'),
    (#200, '&Egrave;'), (#201, '&Eacute;'), (#202, '&Ecirc;'), (#203, '&Euml;'),
    (#204, '&Igrave;'), (#205, '&Iacute;'), (#206, '&Icirc;'), (#207, '&Iuml;'),
    (#208, '&ETH;'), (#209, '&Ntilde;'), (#210, '&Ograve;'), (#211, '&Oacute;'),
    (#212, '&Ocirc;'), (#213, '&Otilde;'), (#214, '&Ouml;'), (#215, '&times;'),
    (#216, '&Oslash;'), (#217, '&Ugrave;'), (#218, '&Uacute;'),
    (#219, '&Ucirc;'), (#220, '&Uuml;'), (#221, '&Yacute;'), (#222, '&THORN;'),
    (#223, '&szlig;'), (#224, '&agrave;'), (#225, '&aacute;'),
    (#226, '&acirc;'), (#227, '&atilde;'), (#228, '&auml;'), (#229, '&aring;'),
    (#230, '&aelig;'), (#231, '&ccedil;'), (#232, '&egrave;'),
    (#233, '&eacute;'), (#234, '&ecirc;'), (#235, '&euml;'), (#236, '&igrave;'),
    (#237, '&iacute;'), (#238, '&icirc;'), (#239, '&iuml;'), (#240, '&eth;'),
    (#241, '&ntilde;'), (#242, '&ograve;'), (#243, '&oacute;'),
    (#244, '&ocirc;'), (#245, '&otilde;'), (#246, '&ouml;'), (#247, '&divide;'),
    (#248, '&oslash;'), (#249, '&ugrave;'), (#250, '&uacute;'),
    (#251, '&ucirc;'), (#252, '&uuml;'), (#253, '&yacute;'), (#254, '&thorn;'),
    (#255, '&yuml;'));
var
  I: Integer;
  tag, txt: Boolean;
  htm, tx: string;
Begin
  htm := StringReplace(s, #13#10, #32, [rfReplaceAll]);
  htm := StringReplace(htm, #160, #32, [rfReplaceAll]);
  While pos('  ', htm) > 0 Do
    htm := StringReplace(htm, #32#32, #32, [rfReplaceAll]);
  htm := StringReplace(htm, '</P>', '<BR>', [rfReplaceAll, rfIgnoreCase]);
  htm := StringReplace(htm, '<BR />', '<BR>', [rfReplaceAll, rfIgnoreCase]);
  htm := StringReplace(htm, '<BR>', #13#10, [rfReplaceAll, rfIgnoreCase]);
  htm := StringReplace(htm, #13#10#32, #13#10, [rfReplaceAll]);
  htm := StringReplace(htm, #32#13#10, #13#10, [rfReplaceAll]);
  Delete(htm, 1, pos('<BODY', UpperCase(htm)) - 1);
  I := 1;
  tag := false;
  txt := false;
  tx := '';
  while I <= Length(htm) do
  begin
    case htm[I] of
      '<':
        begin
          tag := True;
          txt := false;
        end;
      '>':
        begin
          if (Length(tx) > 1) then
            if not(tx[Length(tx)] in [#32, #10]) then
              tx := tx + #32;
          tag := false;
          txt := false;
        end;
    else
      if (I > 1) and (htm[I - 1] = #32) then
        txt := false;
      txt := txt or ((not tag) and (htm[I] <> #32));
      if not tag and txt then
      begin
        tx := tx + htm[I];
      end;
    end;
    Inc(I);
  end;
  for I := 1 to NISOCS do
  begin
    tx := StringReplace(tx, ISOCS[I, 2], ISOCS[I, 1], [rfReplaceAll]);
  end;
  tx := StringReplace(tx, #160, #32, [rfReplaceAll]);
  Result := tx;
End;

function base64Decode(const Text: WideString): WideString;
var
  Decoder: TIdDecoderMime;
begin
  Decoder := TIdDecoderMime.Create(nil);
  try
    Result := Decoder.DecodeString(Text);
  finally
    FreeAndNil(Decoder)
  end
end;

function base64Encode(const Text: WideString): WideString;
var
  Encoder: TIdEncoderMime;
begin
  Encoder := TIdEncoderMime.Create(nil);
  try
    Result := Encoder.EncodeString(Text);
  finally
    FreeAndNil(Encoder);
  end
end;

Function ExcelKimenet(Forras: TADOQuery; Tabla: TDBGrid; Szoveg: String):Boolean;
Var
  FExcel: Variant;
  FWorkBook: Variant;
  FWorkSheet: Variant;
  J, Sor, Oszlop: Integer;

 Procedure SetCell(ACol, ARow: Integer; const Value: string);
 var
   Cell: Variant;
 begin
   Cell := FWorkSheet.Cells[ ARow, ACol ];
   Cell.Value := Value;
 end;

begin
  try
    Screen.Cursor := crHourGlass ;
    FExcel := CreateOLEObject( 'Excel.Application' );
    FWorkBook := FExcel.WorkBooks.Add;
    FWorkSheet := FExcel.WorkSheets[1];
    FExcel.Visible := False;

    Forras.First ;
    Sor:=1;
    Oszlop:=1;
    For J := 0 To Tabla.Columns.Count-1 Do
      If Tabla.Columns[J].Visible Then
      begin
         SetCell(Oszlop, Sor, Tabla.Columns[J].Title.Caption);
         Inc(Oszlop);
      end;
    Inc(Sor) ;
    While Not Forras.Eof Do
    Begin
      Oszlop:=1;
      For J := 0 To Tabla.Columns.Count-1 Do
         If Tabla.Columns[J].Visible Then
         begin
           If Forras.FieldByName(Tabla.Columns[J].FieldName).Value=Null Then
              SetCell(Oszlop, Sor, '')
           Else
              SetCell(Oszlop, Sor, StringReplace(Forras.FieldByName(Tabla.Columns[J].FieldName).AsString,'.',',',[rfReplaceAll]));
           Inc(Oszlop);
         end;
       Inc(Sor) ;
       Forras.Next;
       Application.ProcessMessages;
    End;
  Finally
    Screen.Cursor := crDefault ;
    FExcel.Visible := True;
  end;
  Application.ProcessMessages;
  Uzenet(Szoveg);
end;


Procedure CSVkimenet(Forras: TADOQuery; Tabla: TDBGrid; Szoveg: String);
Var SD: TSaveDialog;
    F: TextFile;
    I: Integer;
begin
  SD:=TSaveDialog.Create(Nil);
  SD.Filter:='Sz�veges f�jlok|*.csv';
  SD.DefaultExt:='*.csv';
  If SD.Execute Then
  Begin
    Forras.First;
    AssignFile(F, SD.FileName);
    ReWrite(F);
    For I:=0 To Tabla.Columns.Count-1 Do
        Write(F, Tabla.Columns[I].Title.Caption, ';');
    WriteLn(F);
    While Not Forras.Eof Do
    Begin
      For I:=0 To Tabla.Columns.Count-1 Do
          Try Write(F, Forras.FieldByName(Tabla.Columns[I].FieldName).AsString, ';'); Except End;
      WriteLn(F);
      Forras.Next;
    End;
    CloseFile(F);
  End;
  FreeAndNil(SD);
  Application.ProcessMessages;
  Uzenet(Szoveg);
end;


end.
