unit Alap;

interface

uses SysUtils, Classes, DB, Windows, Vcl.Graphics, Vcl.Controls,
  DateUtils, StrUtils, Math, Winsock, Vcl.ComCtrls, Vcl.CheckLst,
  Vcl.DBGrids, Vcl.StdCtrls, Vcl.OleCtnrs, Vcl.ExtCtrls, Vcl.Forms,
  Vcl.Buttons, Vcl.Menus, Vcl.Mask, Vcl.DBCtrls, Vcl.Grids, Vcl.Samples.Spin,
  IdCoder, IdCoder3to4, IdCoderMIME, Vcl.Dialogs,
  ComObj, Variants, AdoDB, Registry, IdSMTP, IdIMAP4, IdMessage, wininet,
  Messages, Vcl.ActnList, System.Actions, Vcl.ExtActns,
  System.Types, System.UITypes, IdAttachmentFile,
  AlapFuggveny, VDComboBox, NumberEdit,
  IdExplicitTLSClientServerBase, IdMessageClient, IdSMTPBase,
  IdAttachment;

procedure SwitchToThisWindow(h1: hWnd; x: bool); stdcall;
  external user32 Name 'SwitchToThisWindow';

Procedure UresreTorles(Ablak: TWinControl);
Procedure Vedette(WC: TWinControl);
Procedure SzinValtas(Ablak: TWinControl; MuveletKod: Integer);
Procedure LapEngedes(Lap: TPageControl);
Procedure LapTiltas(Lap: TPageControl; Sorszam: Integer);

Function szervezet_eleres(Ceg, Tip: String): String;
Function szemely_eleres(Szem, Tip: String): String;
procedure dbg_TitleClick(Grid: TDBGrid; Column: TColumn);

Function AblakNyit(TF: TFormClass; Var F: TForm; Preview: Boolean = True;
  Sender: TObject = Nil): Integer;

Function DoksiMasol_Szerverre(Fajlneve: String): Boolean;
Function DoksiSzerverre(Fajlneve1, Fajlneve2: String; Feluliras: Boolean = False): String;
Function DoksiSzerverrol(Fajlnev: String): String;
Function DoksiTorles(Fajlnev: String): Boolean;
Procedure DokuVerzio(id, nev, ev: String);

function CHR_Replace(const str: String; kar: Char = '_'): String;
Function Atvalt(Szem: Real): String;
Function SpaceDel(szov: String): String;

Function Beszuras(Tabla: String; Ertekek: Array of String; Kereshet: Boolean = True): String;
Procedure Modositas(Tabla: String; Ertekek: Array of String; Hol: String);
Procedure Torles(Tabla: String; Hol: String);

Function IDKeres(IDk: TStringList; id: String): Integer;

Function SzerverEv: String;
Function SzerverHo: String;
Function SzervDatum: TDateTime;
Function SzerverDat(Tip: Integer): String;
Function DatumIdo(datum, ido: String): String;
Function HibaKuldes(Ablak, Hiba, Torzs: String): Boolean;
Function EmailKuldes(Valasz, Felado, Cimzett, Masolat, TitkosMasolat, Targy, Torzs: String; Csatolasok: Array Of String): Boolean;

Procedure Agak(Ablak: TForm; FaLista: TTreeView; Mibol: TTreeNode;
  Azon, TablaNev, SzuloMezo, IdMezo, NevMezo: String);

function BoolToInt(b: Boolean): Integer;
function BoolToStr(b: Boolean): String;
function IntToBool(x: Integer): Boolean;
function StrToBool(x: String): Boolean;
Function FelhObjJog(Objektum: String; ObjektumTipus: Integer): Integer;
Function GLS_CheckDigit(szam: String): String;
function Frissites(Tabla: TADOQuery; id, Mezo: String): String;
function FrissitesTeljes(Tabla: TADOQuery; id, Mezo: String): String;
function FrissitesParam(Tabla: TADOQuery; PList: String): Boolean;
function GetInetFile(const fileURL, FileName: String): Boolean;
function NCharToWeb(szov: String): String;
function EredetiAdat(Tabla: TADOQuery; Sor: TDBGrid): String;

Function Html2Text(S: String): String;
Function iktatoszam(ev, konyv: String): String;
Function iktato_alszam(foszam, ev, konyv: String): String;
Function iktato_ki(jel, foszam, alszam, ev: String): String;
Procedure ertektorles;
Procedure CloseDoc(OleContainer: TOleContainer);
Procedure SaveAsPDFContainer(OleContainer: TOleContainer; PDFFileNev: String);
Procedure DocumentToContainer(FileNev: String; OleContainer: TOleContainer;
  CsakOlvashato: Boolean = True; Nyomtathato: Boolean = False);
Function IngatlanKeres(hrsz: String): String;
Function IngatlanKeres_cim(cim: String): String;
Function Vezeto(csoport: String): String;
Function Iktatoszam_nev(id: String): String;
Function Iratgyujto: String;
Function IktatoKonyv(iktato_id: String): String;
Function Erkezteto(ikt_konyv: String): String;
Function Erkezteto_azon(erk_id: String): String;
Function Elozmeny_ID(iszam: String): String;
function base64Decode(const Text: WideString): WideString;
function base64Encode(const Text: WideString): WideString;
function GetIPFromHost(HostName: string): string;

Function HonapKezdet(const AValue: TDateTime): TDateTime;
Function HonapVeg(const AValue: TDateTime): TDateTime;

Procedure Doc2Pdf(DocFileName: String; PdfFileName: String = '');
Procedure GridAllapotToltes(Grid: TDBGrid);
Procedure GridAllapotMentes(Grid: TDBGrid);
Function Valos(szov:String):String;

implementation

uses AlapAdat;

{$R alap_unit.res}

// Az ablak beviteli mezõit üresre állítja
Procedure UresreTorles(Ablak: TWinControl);
var
  i, j: Integer;
begin
  for i := 0 to Ablak.ComponentCount - 1 do
  begin
    if Ablak.Components[i] is TFrame then
      UresreTorles((Ablak.Components[i] as TFrame));
    if Ablak.Components[i] is TEdit then
      (Ablak.Components[i] as TEdit).Text := '';
    if Ablak.Components[i] is TLabeledEdit then
      (Ablak.Components[i] as TLabeledEdit).Text := '';
    if Ablak.Components[i] is TCheckBox then
      (Ablak.Components[i] as TCheckBox).Checked := False;
    if Ablak.Components[i] is TComboBox then
      (Ablak.Components[i] as TComboBox).Text := '';
    if Ablak.Components[i] is TComboBox then
      (Ablak.Components[i] as TComboBox).ItemIndex := -1;
    if Ablak.Components[i] is TMaskEdit then
      (Ablak.Components[i] as TMaskEdit).Text := '';
    if Ablak.Components[i] is TDateTimePicker then
    begin
      if (Ablak.Components[i] as TDateTimePicker).Tag = 0 Then
        (Ablak.Components[i] as TDateTimePicker).Date := Now
      Else
        (Ablak.Components[i] as TDateTimePicker).Date :=
          (Ablak.Components[i] as TDateTimePicker).Tag;
      (Ablak.Components[i] as TDateTimePicker).Checked := False;
    end;
    if Ablak.Components[i] is TDBEdit then
      (Ablak.Components[i] as TDBEdit).Text := '';
    if Ablak.Components[i] is TRadioGroup then
      (Ablak.Components[i] as TRadioGroup).ItemIndex := -1;
    if Ablak.Components[i] is TDBLookUpComboBox then
      (Ablak.Components[i] as TDBLookUpComboBox).KeyValue := -1;
    if Ablak.Components[i] is TVDComboBox then
      begin
      (Ablak.Components[i] as TVDComboBox).ItemIndex:=-1;
      (Ablak.Components[i] as TVDComboBox).Ertek('');
      (Ablak.Components[i] as TVDComboBox).Text:='';
      end;

    if Ablak.Components[i] is TMemo then
    begin
      j := 0;
      while (Ablak.Components[i] as TMemo).Lines[j] <> '' do
      begin
        (Ablak.Components[i] as TMemo).Lines[j] := '';
        Inc(j);
      end;
    end;
    if Ablak.Components[i] is TCheckListBox then
    begin
      For j := 0 to (Ablak.Components[i] as TCheckListBox).Count - 1 do
        (Ablak.Components[i] as TCheckListBox).Checked[j] := False;
    end;
    if Ablak.Components[i] is TDBGrid then
    begin
      REND_OSZLOP := '';
      REND_IRANY := '';
      For j := 0 To (Ablak.Components[i] as TDBGrid).Columns.Count - 1 Do
      Begin
        (Ablak.Components[i] as TDBGrid).Columns[j].Title.Color := AlapSzin;
        If (RightStr((Ablak.Components[i] as TDBGrid).Columns[j].Title.Caption,
          1) = ' >') or
          (RightStr((Ablak.Components[i] as TDBGrid).Columns[j].Title.Caption,
          1) = ' <') Then
          (Ablak.Components[i] as TDBGrid).Columns[j].Title.Caption :=
            Copy((Ablak.Components[i] as TDBGrid).Columns[j].Title.Caption, 1,
            Length((Ablak.Components[i] as TDBGrid).Columns[j]
            .Title.Caption) - 2);
      End;
    end;
  end;
end;

// A paraméterként átadott kontrollt írásvédetté teszi és nem engedélyezetté teszi a színét
Procedure Vedette(WC: TWinControl);
Begin
  WC.TabStop := False;
  WC.Enabled := False;
End;

{ Adatmódosításkor végrehajtott színváltások }
Procedure SzinValtas(Ablak: TWinControl; MuveletKod: Integer);
var
  i, Szin: Integer;
begin
  for i := 0 to Ablak.ComponentCount - 1 do
  begin
    if (Ablak.Components[i] is TEdit) then
       (Ablak.Components[i] as TEdit).Enabled := MuveletKod <> 0;
    if (Ablak.Components[i] is TLabeledEdit) then
       (Ablak.Components[i] as TLabeledEdit).Enabled := MuveletKod <> 0;
    if (Ablak.Components[i] is TNumberEdit) then
       (Ablak.Components[i] as TNumberEdit).Enabled := MuveletKod <> 0;
    if (Ablak.Components[i] is TGroupBox) then
       (Ablak.Components[i] as TGroupBox).Enabled := MuveletKod <> 0;
    if (Ablak.Components[i] is TComboBox) then
       (Ablak.Components[i] as TComboBox).Enabled := MuveletKod <> 0;
    if (Ablak.Components[i] is TCheckListBox) then
       (Ablak.Components[i] as TCheckListBox).Enabled := MuveletKod <> 0;
    if (Ablak.Components[i] is TListBox) then
       (Ablak.Components[i] as TListBox).Enabled := MuveletKod <> 0;
    if (Ablak.Components[i] is TRichEdit) then
       (Ablak.Components[i] as TRichEdit).Enabled := MuveletKod <> 0;
    if (Ablak.Components[i] is TMemo) then
       (Ablak.Components[i] as TMemo).Enabled := MuveletKod <> 0;
    if (Ablak.Components[i] is TDateTimePicker) then
       (Ablak.Components[i] as TDateTimePicker).Enabled := MuveletKod <> 0;
  end;
end;

{ Aktuális PageControl fül látszik a többit letiltjuk }
Procedure LapTiltas(Lap: TPageControl; Sorszam: Integer);
var
  i: Integer;
begin
  For i := 0 to Lap.PageCount - 1 do
    Lap.Pages[i].TabVisible := False;
  Lap.Pages[Sorszam].TabVisible := True;
end;

{ Az összes PageControl fül engedélyezése }
Procedure LapEngedes(Lap: TPageControl);
var
  i: Integer;
begin
  For i := 0 to Lap.PageCount - 1 do
    Lap.Pages[i].TabVisible := True;
end;

{ Visszaadja a <Ceg> szervezet <Tip>-ben megadot elérését }
Function szervezet_eleres(Ceg, Tip: String): String;
begin
  With AlapAdat.AdatModul.ADOQuery2 do
  begin
    If (Ceg <> '') and (Tip <> '') Then
    begin
      Active := False;
      SQL.Text := 'Select a.eleres_id, a.eleres_nev ' +
        'From eleres a, szervezet_eleres b ' +
        'Where a.eleres_id=b.eleres_id and b.szervezet_id=' + Ceg +
        ' and a.eleres_tipus_id=' + Tip + ' and a.eleres_vege>getdate()';
      Active := True;
      If RecordCount > 0 Then
        Result := FieldByName('eleres_nev').AsString
      else
        Result := '';
    end;
  end;
end;

{ Visszaadja a <Szem> személy <Tip>-ben megadot elérését }
Function szemely_eleres(Szem, Tip: String): String;
begin
  With AlapAdat.AdatModul.ADOQuery2 do
  begin
    If (Szem <> '') and (Tip <> '') Then
    begin
      Active := False;
      SQL.Text := 'Select a.eleres_id, a.eleres_nev ' +
        'From eleres a, szemely_eleres b ' +
        'Where a.eleres_id=b.eleres_id and b.szemely_id=' + Szem +
        'and a.eleres_tipus_id=' + Tip + ' and a.eleres_vege>getdate()';
      Active := True;
      If RecordCount > 0 Then
        Result := FieldByName('eleres_nev').AsString
      else
        Result := '';
    end;
  end;
end;

procedure dbg_TitleClick(Grid: TDBGrid; Column: TColumn);
Var
  S: String;
  i: Integer;
  Elozo, Irany: String;
begin
  if not(Grid.dataSource.DataSet is TADOQuery) Then
    Exit;
  try
    Grid := Column.Grid as TDBGrid;
    If Not TADOQuery(Grid.dataSource.DataSet).Active Then
      Exit;
    If TADOQuery(Grid.dataSource.DataSet).RecordCount = 0 Then
      Exit;
    Irany := ' asc';
    If (RightStr(Column.Title.Caption, 2) = ' >') Then
      Elozo := ' >'
    Else If (RightStr(Column.Title.Caption, 2) = ' <') Then
      Elozo := ' <'
    Else
      Elozo := ' >';
    REND_OSZLOP := Column.FieldName;
    REND_IRANY := Irany;
    For i := 0 To Grid.Columns.Count - 1 Do
    begin
      Grid.Columns[i].Title.Color := AlapSzin;
      Grid.Columns[i].Title.Caption :=
        RTrimStrSpec(Grid.Columns[i].Title.Caption, '>', NOCHAR);
      Grid.Columns[i].Title.Caption :=
        RTrimStrSpec(Grid.Columns[i].Title.Caption, '<', NOCHAR);
    end;
    If Elozo = ' <' Then
    Begin
      Elozo := ' >';
      Irany := ' asc';
    End
    Else If Elozo = ' >' Then
    Begin
      Elozo := ' <';
      Irany := ' desc';
    End;
    Column.Title.Caption := Column.Title.Caption + Elozo;
    Column.Title.Color := KiemeltSzin;
    If Pos('order by', LowerCase(TADOQuery(Grid.dataSource.DataSet)
      .SQL.Text)) = 0 Then
    Begin
      If TADOQuery(Grid.dataSource.DataSet).SQL.Strings
        [TADOQuery(Grid.dataSource.DataSet).SQL.Count - 1] <> '' Then
        TADOQuery(Grid.dataSource.DataSet).SQL.Add('');
      TADOQuery(Grid.dataSource.DataSet).SQL.Strings
        [TADOQuery(Grid.dataSource.DataSet).SQL.Count - 1] := 'order by ';
    End;
    S := ReverseString(TADOQuery(Grid.dataSource.DataSet).SQL.Text);
    delete(S, 1, Pos('yb redro', LowerCase(S)) + 8);
    S := ReverseString(S) + '  order by ' + Column.FieldName + Irany;
    TADOQuery(Grid.dataSource.DataSet).Active := False;
    TADOQuery(Grid.dataSource.DataSet).SQL.Text := S;
    TADOQuery(Grid.dataSource.DataSet).Active := True;
  except
  end;

end;

{ Ablak nyitás függvénye }
Function AblakNyit(TF: TFormClass; Var F: TForm; Preview: Boolean = True;
  Sender: TObject = Nil): Integer;
  Procedure GombJog(GombNev: String; Jog: Boolean = True);
  Var
    Gomb: TButton;
  Begin
    Gomb := TButton(F.FindComponent(GombNev));
    If Gomb <> nil Then
    Begin
      Gomb.Enabled := Jog;
      Gomb.Visible := Jog and Gomb.Visible;
      If Not Jog Then
        Gomb.OnClick := Nil;
    End;
  End;

Var
  i: Integer;
  Reg: TRegistry;
Begin
  // If BB_BILL=0 Then
  // begin
  F := TF.Create(Application);
    Begin
//      F.Font.Size := BETUMERET;
      // I:=FelhObjJog(F.Name, c_ObjTip_Ablak);
      // I:=FelhObjJog(F.Name, 0);
      i := 62;
      If Sender <> nil then
      Begin
        If (Sender as TComponent).Tag = 1 Then
          i := 1
        Else
          i := i Or (Sender as TComponent).Tag;
        If Sender is TMenuItem Then
          MENUJOG_ID := (Sender as TMenuItem).Tag;
      End
      Else
      Begin
        If MENUJOG_ID <> -1 Then
          i := i Or MENUJOG_ID;
        If MENUJOG_ID = 1 Then
          i := 1;
      End;
      If i <= 1 Then
         Uzenet('Nincs jogosultságod az ablak megnyitásához');
      GombJog('bb_uj', (I and KettoHatvany[3]) > 0);
      GombJog('bb_modosit', (I and KettoHatvany[4]) > 0);
      GombJog('bb_torol', (I and KettoHatvany[5]) > 0);
      I:= (I and KettoHatvany[3]) + (I and KettoHatvany[4]) + (I and KettoHatvany[5]);
      GombJog('bb_felvesz', I > 0);
      GombJog('bb_megsem', I > 0);
        {
        GombJog('bb_feladas', I > 0);
        GombJog('bb_vissza', I > 0);
        GombJog('bb_frissit', I > 0);
        GombJog('sb_email', I > 0);
        GombJog('sb_fax', I > 0);
        //       GombJog('sb_nyomtat', I > 0);

        GombJog('bb_email', I > 0);
        GombJog('bb_ok', I > 0);
        GombJog('bb_xml', I > 0);
        GombJog('bb_Ment', I > 0);
        GombJog('bb_excel', I > 0);
        GombJog('bb_nyomtat', I > 0);
        { }
      F.Show;
      F.Visible := True;
      Result := F.ModalResult;
      // result:=F.ShowModal;
    End;

End;

{ <s> bal oldalarol eltunteti a <kar>-eket és ha <be> nem üres, akkor beilleszti azt. }
function LTrimStrSpec(const S: string; kar, be: Char): string;
var
  i, slen: Integer;
begin
  slen := Length(S);
  i := 1;
  while i <= slen do
  begin
    if S[i] <> kar then
      Break;
    Inc(i);
  end;
  if i > slen then
    LTrimStrSpec := be
  else
    LTrimStrSpec := RightStr(S, slen - i + 1);
end; { LTrimStr }

{ <s> jobb oldalarol eltunteti a <kar>-eket és ha <be> nem üres, akkor beilleszti azt. }
function RTrimStrSpec(const S: string; kar, be: Char): string;
var
  i: Integer;
begin
  i := Length(S);
  while i > 0 do
  begin
    if S[i] <> kar then
      Break;
    Dec(i);
  end;
  if i < 1 then
    RTrimStrSpec := be
  else
    RTrimStrSpec := LeftStr(S, i);
end; { RTrimStr }

function TrimStrSpec(const S: string; kar, be: Char): string;
var
  res: string;
begin
  res := LTrimStrSpec(S, kar, be);
  TrimStrSpec := RTrimStrSpec(res, kar, be);
end; { TrimStr }

function SzamTobbKarakteren(i, Hossz: Integer): String;
Var
  S: String;
Begin
  S := IntToStr(i);
  While Length(S) < Hossz Do
    S := '0' + S;
  Result := S;
End;

{ Dátum ellenõrzése }
function GoodDate(const d: String): Boolean;
var
  dat: TDateTime;
  S: String;
begin
  try
    // Ha d is date type
    If FindChar(d, '.', NOCHAR, 1) <> 0 Then
    begin
      If FindChar(d, ' ', NOCHAR, 1) <> 0 Then
        S := TrimStrSpec(d, ' ', '0')
      else
        S := d;
      dat := StrToDate(S);
    end;
    // Ha d is time type
    If FindChar(d, ':', NOCHAR, 1) <> 0 Then
    begin
      If FindChar(d, ' ', NOCHAR, 1) <> 0 Then
        S := TrimStrSpec(d, ' ', '0')
      else
        S := d;
      dat := StrToTime(S);
    end;
    dat := dat + 1;
    Result := True;
  except
    Result := False;
  end;
end;

{ }
function SubString(S: String): String;
var
  i: Integer;
begin
  i := Length(S);
  while i > 0 do
  begin
    if S[i] in [' ', '_'] then
      S[i] := '%';
    Dec(i);
  end;
  Result := S;
end;

Function StrToData(S: String; AposztrofKore: Boolean = False): String;
Begin
  If AposztrofKore Then
    Result := '''' + TrimRight(StringReplace(S, #39, #39#39,
      [rfReplaceAll])) + ''''
  Else
    Result := TrimRight(StringReplace(S, #39, #39#39, [rfReplaceAll]));
End;

Function DoksiMasol_Szerverre(Fajlneve: String): Boolean;
Var
  UjFajlNeve, HoKonyvtar: String;
Begin
  DoksiMasol_Szerverre := False;
  if Not FileExists(Fajlneve) Then
    Exit;
  UjFajlNeve := ExtractFileName(Fajlneve);
  HoKonyvtar := FormatDateTime('yyyymm', Now);
  CreateDir(MEGOSZTAS + 'DOKUMENTUM\' + HoKonyvtar);
  If CopyFile(PChar(Fajlneve), PChar(MEGOSZTAS + 'DOKUMENTUM\' + HoKonyvtar +
    '\' + UjFajlNeve), False) Then
    DoksiMasol_Szerverre := True
End;

Function DoksiSzerverre(Fajlneve1, Fajlneve2: String;
  Feluliras: Boolean = False): String;
Var
  UjFajlNeve, Eleres: String;
Begin
  DoksiSzerverre := '';
  If Fajlneve2 = '' Then
    Fajlneve2 := Fajlneve1;
  if Not FileExists(Fajlneve1) Then
    Exit;
  // UjFajlNeve:=ExtractFileName(FajlNeve2);
  // Eleres:=D_ELERES+UjFajlNeve;
  Eleres := D_ELERES + Fajlneve2;
  If CopyFile(PChar(Fajlneve1), PChar(Eleres), False) Then
    DoksiSzerverre := Eleres;
End;

Function DoksiSzerverrol(Fajlnev: String): String;
Var
  UjFajlNeve: String;
Begin
  DoksiSzerverrol := '';
  UjFajlNeve := ExtractFileName(Fajlnev);
  delete(UjFajlNeve, 1, Pos('_', UjFajlNeve));
  UjFajlNeve := GetCurrentDir + '\' + UjFajlNeve;
  If FileExists(Fajlnev) Then
    If CopyFile(PChar(Fajlnev), PChar(UjFajlNeve), False) Then
      // Sikerult atmasolni
      DoksiSzerverrol := UjFajlNeve;
End;

Function DoksiTorles(Fajlnev: String): Boolean;
Begin
  DoksiTorles := False;
  If FileExists(D_ELERES + Fajlnev) Then
    If DeleteFile(PChar(D_ELERES + Fajlnev)) Then
      DoksiTorles := True;
End;

Procedure DokuVerzio(id, nev, ev: String);
var
  S, ujnev, Fajlnev, UjFajlnev: String;
  x: Integer;
begin
  With AlapAdat.AdatModul.ADOQuery3 do
  begin
    SQL.Text := 'Select doku_verzio From dokumentum Where dokumentum_id=' + id;
    Active := True;
    If RecordCount > 0 Then
      S := FieldByName('doku_verzio').AsString
    else
      S := '1';
  end;
  x := StrToInt(S);
  x := x + 1;
  Fajlnev := D_ELERES + ev + '\' + nev;
  ujnev := Copy(nev, 1, Pos('.', nev) - 1) + '_v' + S + ExtractFileExt(nev);
  UjFajlnev := D_ELERES + ev + '\' + ChangeFileExt(ujnev, ExtractFileExt(nev));
  If FileExists(Fajlnev) Then
    If CopyFile(PChar(Fajlnev), PChar(UjFajlnev), False) Then
      Modositas('dokumentum', ['doku_verzio=' + IntToStr(x)],
        'dokumentum_id=' + id);
end;

function CHR_Replace(const str: String; kar: Char = '_'): String;
var
  i: Integer;
  S: String;
begin
  SetLength(S, Length(str));
  For i := 1 to Length(str) do
  begin
    Case str[i] of
      'á':
        S[i] := 'a';
      'Á':
        S[i] := 'A';
      'é':
        S[i] := 'e';
      'É':
        S[i] := 'E';
      'ö', 'õ', 'ó':
        S[i] := 'o';
      'Ö', 'Õ', 'Ó':
        S[i] := 'O';
      'í':
        S[i] := 'i';
      'Í':
        S[i] := 'I';
      'ü', 'û', 'ú':
        S[i] := 'u';
      'Ü', 'Û', 'Ú':
        S[i] := 'U';
      '.', APOCHAR, IDCHAR, '+', ' ', '/', '\':
        S[i] := kar;
    else
      S[i] := str[i];
    End;
  end;
  Result := S;
end;

Function Atvalt(Szem: Real): String;
Var
  sz, bet, szov: String;
  Hossz, nrend, hely, i, betszam, kod: Integer;
Begin
  szov := '';
  If Szem <> 0 Then
  begin
    Szem := Round(Szem);
    If Szem < 0 Then
    begin
      szov := 'minusz ';
      Szem := Abs(Szem);
    end;
    sz := TrimStr(FloatToStr(Szem));
    Hossz := Length(sz);
    nrend := (Hossz div 3) + 1;
    hely := Hossz;
    i := 1;
    While i <= Hossz Do
    Begin
      bet := Copy(sz, i, 1);
      Val(bet, betszam, kod);
      If ((hely mod 3) = 2) and (Copy(sz, i, 1) <> '0') Then
      Begin
        If Copy(sz, i + 1, 1) = '0' Then
        Begin
          szov := szov + AT3[betszam];
          i := i + 1;
          hely := hely - 1;
        End
        Else
          szov := szov + AT2[betszam];
      End;
      If ((hely mod 3) = 1) And (Copy(sz, i, 1) <> '0') Then
        szov := szov + AT1[betszam];
      If (hely mod 3) = 1 Then
        Case hely of
          10 .. 12:
            szov := szov + 'milliárd ';
          7 .. 9:
            szov := szov + 'millió ';
          3 .. 6:
            If (nrend >= 2) And (Copy(sz, i - 2, 3) <> '000') Then
              szov := szov + 'ezer ';
        End;
      If ((hely mod 3) = 0) and (Copy(sz, i, 1) <> '0') Then
        szov := szov + AT1[betszam] + 'száz';
      hely := hely - 1;
      i := i + 1;
    End;
  end
  else
    szov := 'nulla';
  Atvalt := szov;
End;

Function SpaceDel(szov: String): String;
begin
  Result := StringReplace(StringReplace(szov, ' ', '', [rfReplaceAll]), '.', '',
    [rfReplaceAll]);
end;

// TABLA táblába beszúrja az ERTEKEK értékeket. Az értékek stringtömbben vannak
// 'mezõnév=érték' formátumban. (az érték lehet több szavas/soros is)
// Ha a KERESHET mezõ igaz, mielõtt beszúrna, alõtte megnézi, hogy van-e már ezekkel az értékekkel rekord
// így elkerülhetõk a duplikált sorok. Visszatérési értéke a beszúrt sor ID-je
Function Beszuras(Tabla: String; Ertekek: Array of String;
  Kereshet: Boolean = True): String;
Var
  Mezok, Ertek, S, S2, S3, Kereses, Rekord, Uj_ertek: String;
  i: Integer;
  l: TStringList;
begin
  With AdatModul do
  begin
    ADOQuery1.SQL.Clear;
    Mezok := '';
    Ertek := '';
    Kereses := '';
    Uj_ertek := '';
    For i := 0 To Length(Ertekek) - 1 Do
    Begin
      S := Ertekek[i];
      Uj_ertek := Uj_ertek + S + ',';
      If S <> '' Then
        // Ha van érték
        If Mezok = '' Then
        Begin
          // elsõ lépés
          Mezok := Copy(Ertekek[i], 1, Pos('=', Ertekek[i]) - 1);
          delete(S, 1, Pos('=', Ertekek[i]));
          If (LowerCase(S) = 'null') or (LowerCase(S) = '') or (TrimStr(S) = '')
          then
          Begin
            Ertek := 'null';
            Kereses := Mezok + ' is null ';
          End
          Else
          Begin
            If RightStr(Mezok, 1) = ':' then
            Begin
              SetLength(Mezok, Length(Mezok) - 1);
              Ertek := S;
            End
            Else
              Ertek := '''' + Trim(StringReplace(S, #39, #39#39,
                [rfReplaceAll])) + '''';
            Kereses := Mezok + ' = ' + Ertek;
          End;
        End
        Else
        Begin
          S2 := Copy(Ertekek[i], 1, Pos('=', Ertekek[i]) - 1);
          Mezok := Mezok + ', ' + S2;
          delete(S, 1, Pos('=', Ertekek[i]));
          If RightStr(Mezok, 1) = ':' then
          Begin
            SetLength(Mezok, Length(Mezok) - 1);
            S3 := S;
          End
          Else If (LowerCase(S) = 'null') or (LowerCase(S) = '') or
            (TrimStr(S) = '') Then
            S3 := 'null'
          Else
            S3 := '''' + Trim(StringReplace(S, #39, #39#39,
              [rfReplaceAll])) + '''';
          Ertek := Ertek + ', ' + S3;
          If (Pos('DATUMTOL', S2) = 0) AND (Pos('DATUMIG', S2) = 0) Then
            If (S3 = 'null') Then
              Kereses := Kereses + ' AND ' + S2 + ' is null'
            Else
              Kereses := Kereses + ' AND ' + S2 + '=' + S3;
        End;
    End;
    If Kereshet Then
    Begin
      ADOQuery1.Active := False;
      ADOQuery1.SQL.Text := 'Select Count(*) DB From ' + Tabla + ' Where '
        + Kereses;
      ADOQuery1.Active := True;
      i := ADOQuery1.FieldByName('DB').AsInteger;
    End
    Else
      i := 0;
    If i = 0 Then
    Begin
      ADOQuery1.Active := False;
      ADOQuery1.SQL.Text := 'Insert Into ' + Tabla + ' (' + Mezok + ') Values ('
        + Ertek + ')';
      ADOQuery1.ExecSQL;
      ADOQuery1.SQL.Text := 'select IDENT_CURRENT ('+IDCHAR+Tabla+IDCHAR+') as ID';
      ADOQuery1.Active := True;
      Rekord := ADOQuery1.Fields[0].AsString;
      If Rekord = '' Then
      begin
        Ertek := StringReplace(Ertek, IDCHAR, '', [rfReplaceAll]);
        l := TStringList.Create;
        l := ParseString(Ertek, ',', False, '', -1);
        Rekord := l[0];
        l.Destroy;
      end;
    End
    Else
    Begin // Ha már benne van az adatbáziban, az eredetinek az azonosítóját kell visszaadni
      ADOQuery1.Active := False;
      // az ID mezõ megkeresése
      ADOQuery1.SQL.Text := 'Select * from ' + Tabla + ' where ' + Kereses;
      ADOQuery1.Active := True;
      If Pos('_ID', UpperCase(ADOQuery1.Fields[0].FieldName)) <> 0 Then
        Rekord := ADOQuery1.Fields[0].AsString;
      ADOQuery1.Active := False;
    End;
    // Eseménynaplóba rögzíteni
    Beszuras := Rekord;
    ADOQuery1.Active := False;
    ADOQuery1.SQL.Text :=
      'Insert Into esemenynaplo (esemenytipus_id, esemeny_datum, felh_id, erintett_tabla, erintett_rekord, uj_ertek, felh_csoport_id) '
      + 'Values (' + IDCHAR + '1' + IDCHAR + ', getdate(),' + IDCHAR +
      FELHASZNALO_ID + IDCHAR + ',' + IDCHAR + UpperCase(Tabla) + IDCHAR + ',' +
      IDCHAR + Rekord + IDCHAR + ',' + IDCHAR + StringReplace(Uj_ertek, IDCHAR,
      '', [rfReplaceAll]) + IDCHAR + ',' + IDCHAR + FELHCSOP_ID + IDCHAR + ')';
    ADOQuery1.ExecSQL;
    ADOQuery1.Active := False;
  End;
End;

// Használata megegyezik a BESZURAS funcióval. Annyi különbséggel, hogy a HOL paraméter
// adja meg, melyik rekord(ok)at módosítsa
Procedure Modositas(Tabla: String; Ertekek: Array of String; Hol: String);
Var
  Ertek, S, Vesszo, Regi, Rekord: String;
  i: Integer;
  l: TStringList;
begin
  With AdatModul do
  begin
    Regi := '';
    ADOQuery1.Active := False;
    ADOQuery1.SQL.Clear;
    ADOQuery1.SQL.Text := 'Select * From ' + Tabla + ' Where ' + Hol;
    ADOQuery1.Active := True;
    If ADOQuery1.RecordCount > 0 Then
    begin
      Rekord := ADOQuery1.Fields.Fields[0].AsString;
      For i := 0 to ADOQuery1.FieldCount - 1 do
        Regi := Regi + ADOQuery1.Fields[i].FieldName + '=' + ADOQuery1.Fields[i]
          .AsString + '; ';
      Ertek := '';
      Vesszo := '';
      For i := 0 To High(Ertekek) Do
      Begin
        S := Ertekek[i];
        If S <> '' Then
        Begin
          delete(S, 1, Pos('=', Ertekek[i]));
          If (LowerCase(S) = 'null') or (LowerCase(S) = '') or
            (TrimStr(S) = '') Then
            Ertek := Ertek + Vesszo + Copy(Ertekek[i], 1,
              Pos('=', Ertekek[i]) - 1) + ' = Null'
          else
            Ertek := Ertek + Vesszo + Copy(Ertekek[i], 1,
              Pos('=', Ertekek[i]) - 1) + ' = ''' + StringReplace(S, #39,
              #39#39, [rfReplaceAll]) + '''';
          Vesszo := ', ';
        End;
      End;
      ADOQuery1.SQL.Text := 'Update ' + Tabla + ' Set ' + Ertek +
        ' Where ' + Hol;
      ADOQuery1.ExecSQL;
      If Rekord = '' Then
      begin
        Ertek := StringReplace(Ertek, IDCHAR, '', [rfReplaceAll]);
        l := TStringList.Create;
        l := ParseString(Ertek, ',', False, '', -1);
        Rekord := l[0];
        l.Destroy;
      end;
//      ADOQuery1.Active := False;
//      ADOQuery1.SQL.Text :=
//        'Insert Into esemenynaplo (esemenytipus_id, esemeny_datum, felh_id, erintett_tabla, erintett_rekord, regi_ertek, uj_ertek, felh_csoport_id) '
//        + 'Values (' + IDCHAR + '2' + IDCHAR + ', getdate(),' + IDCHAR +
//        FELHASZNALO_ID + IDCHAR + ',' + IDCHAR + UpperCase(Tabla) + IDCHAR + ','
//        + IDCHAR + Rekord + IDCHAR + ',' + IDCHAR + Regi + IDCHAR + ',' + IDCHAR
//        + StringReplace(Ertek, IDCHAR, '', [rfReplaceAll]) + IDCHAR + ',' +
//        IDCHAR + FELHCSOP_ID + IDCHAR + ')';
//      ADOQuery1.ExecSQL;
//      ADOQuery1.Active := False;
    end;
  End;
End;

Procedure Torles(Tabla: String; Hol: String);
Var
  Regi, id: String;
  i: Integer;
begin
  With AdatModul.ADOQuery1 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Text := 'Select * From ' + Tabla + ' Where ' + Hol;
    Active := True;
    id := Fields.Fields[0].AsString;
    For i := 0 to FieldCount - 1 do
      Regi := Regi + Fields[i].FieldName + '=' + Fields[i].AsString + '; ';
    Active := False;
    SQL.Text := 'delete from ' + Tabla + ' Where ' + Hol;
    ExecSQL;
    Active := False;
    If id = '' Then
      SQL.Text :=
        'Insert Into esemenynaplo (esemenytipus_id, esemeny_datum, felh_id, erintett_tabla, regi_ertek, uj_ertek, felh_csoport_id) '
        + 'Values (' + IDCHAR + '3' + IDCHAR + ', getdate(),' + IDCHAR +
        FELHASZNALO_ID + IDCHAR + ',' + IDCHAR + Tabla + IDCHAR + ',' + IDCHAR +
        Regi + IDCHAR + ',' + IDCHAR + 'adat törölve' + IDCHAR + ',' + IDCHAR +
        FELHCSOP_ID + ')'
    else
      SQL.Text :=
        'Insert Into esemenynaplo (esemenytipus_id, esemeny_datum, felh_id, erintett_tabla, erintett_rekord, regi_ertek, uj_ertek, felh_csoport_id) '
        + 'Values (' + IDCHAR + '3' + IDCHAR + ', getdate(),' + IDCHAR +
        FELHASZNALO_ID + IDCHAR + ',' + IDCHAR + UpperCase(Tabla) + IDCHAR + ','
        + IDCHAR + id + IDCHAR + ',' + IDCHAR + Regi + IDCHAR + ',' + IDCHAR +
        'adat törölve' + IDCHAR + ',' + IDCHAR + FELHCSOP_ID + ')';
    ExecSQL;
    Active := False;
  end;
End;

Function IDKeres(IDk: TStringList; id: String): Integer;
Var
  i: Integer;
Begin
  Result := -1;
  If (id = '') or (id = Null) Then
    Exit;
  For i := 0 To IDk.Count Do
    If IDk.Strings[i] = id Then
      Break;
  If IDk.Strings[i] = id Then
    Result := i;
End;


Function Hanyadik(C: String): Byte;
Const
  Karakterek: String[64]
    = '0QW2ERT4Y5UI6OPA1SDF3GHJ8KLZX7CVB9NM!.?+-[]{}\/><:,;~%()@#$&=* _';
Var
  i: Byte;
Begin
  i := 1;
  While (Karakterek[i] <> C) And (i < 65) Do
    Inc(i);
  Hanyadik := i;
End;

Function ComponentKeres(Ablak: TForm; nev: String): TComponent;
Var
  Comp: TComponent;
Begin
  If Pos('.', nev) = 0 Then
    Result := Ablak.FindComponent(nev)
  Else
  Begin
    Comp := Ablak;
    While Pos('.', nev) > 0 Do
    Begin
      Comp := Comp.FindComponent(Copy(nev, 1, Pos('.', nev) - 1));
      delete(nev, 1, Pos('.', nev));
    End;
    Result := Comp.FindComponent(nev);
  End;
End;

Function SzerverDat(Tip: Integer): String;
begin
  With AdatModul.ADOQuery1 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Text := 'Select ' + 'convert(varchar(50), getdate(), 20) as DATUM_IDO, '
      + 'convert(varchar(50), getdate(), 102) as DATUM, ' +
      'convert(varchar(50), getdate(), 108) as IDO ';
    Active := True;
    If Tip = 0 Then
      Result := LeftStr(FieldByName('DATUM').AsString,4);
    If Tip = 1 Then
      Result := FieldByName('DATUM').AsString;
    If Tip = 2 Then
      Result := FieldByName('DATUM_IDO').AsString;
    If Tip = 3 Then
      Result := FieldByName('IDO').AsString;
  end;
end;

Function SzerverEv: String;
begin
  Result:=LeftStr(SzerverDat(1),4);
end;

Function SzerverHo: String;
begin
  Result:=IntToStr(MonthOf(SzervDatum));
end;

Function SzervDatum: TDateTime;
begin
  With AdatModul.ADOQuery1 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Text := 'Select getdate() ';
    Active := True;
    Result := Fields[0].AsDateTime;
  end;
end;

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

Function HibaKuldes(Ablak, Hiba, Torzs: String): Boolean;
begin
  HibaKuldes:=False;
  if FELH_EMAIL='' then FELH_EMAIL:='semaphor@semmelweis-univ.hu';
  if EmailKuldes('', FELH_EMAIL, 'altmann.attila@semmelweis-univ.hu', '', '', 'Semaphor hiba',
    'Verzió: '+VERZIO+UJSOR+
    'Flehasználó: '+FELHASZNALO+UJSOR+
    'Ablak: '+Ablak+UJSOR+UJSOR+
    'Hiba: '+Hiba+UJSOR+UJSOR+
    Torzs, []) then
     HibaKuldes:=True;
end;

Function EmailKuldes(Valasz, Felado, Cimzett, Masolat, TitkosMasolat, Targy, Torzs: String; Csatolasok: Array Of String): Boolean;
Var Level1: TidSMTP;
    Level2: TidIMAP4;
    Uzenet: TidMessage;
    I: Integer;
Begin
  EmailKuldes:=False;  // alapból nem ment el...
  Try
    If SMTP_NEV<>'' Then
    Begin
      Level1:=TidSMTP.Create(Nil);
      If USER_NEV<>'' Then
      begin
        Level1.Username:=USER_NEV;
        Level1.Password:=PASS_NEV;
      end
      else
      begin
        Level1.Username:='altmann';
        Level1.Password:='monpti';
      end;
      Level1.Host:=SMTP_NEV;
      Level1.Connect;
      If Level1.Connected Then
      Begin
        Uzenet:=TIdMessage.Create(Nil);
        Uzenet.MessageParts.Clear;
        Uzenet.CharSet:='ISO-8859-2';
        Uzenet.From.Name:=AB_NEV;
        Uzenet.From.Address:=Felado;
        Uzenet.Subject:=Targy;
        Uzenet.Body.Add(Torzs);
        For I:=1 To Length(Csatolasok) Do
        Begin
          If Csatolasok[I-1]<>'' Then
            TidAttachmentFile.Create(Uzenet.MessageParts, Csatolasok[I-1]);
        End;
        Uzenet.ReplyTo.EMailAddresses:=Valasz;
        Uzenet.Recipients.EMailAddresses:=Cimzett;
        Uzenet.CCList.EMailAddresses:=Masolat;
        Uzenet.BccList.EMailAddresses:=TitkosMasolat;
        Uzenet.Encoding:=meMIME;
      End;
      Level1.Send(Uzenet);
      EmailKuldes:=True;
      FreeAndNil(Uzenet);
      FreeAndNil(Level1);
      Exit;
    End;
  Except
  End;
  Try
    If IMAP_NEV<>'' Then
    Begin
      Level2:=TidIMAP4.Create(Nil);
      Level2.Username:='altmann';
      Level2.Password:='monpti';
      Level2.Host:=IMAP_NEV;
      Level2.Connect;
      If Level2.Connected Then
      Begin
        Uzenet:=TIdMessage.Create(Nil);
        Uzenet.MessageParts.Clear;
        Uzenet.CharSet:='ISO-8859-2';
        Uzenet.ContentType:='text/plain; charset=Windows-1250';
        Uzenet.ContentTransferEncoding := 'quoted-printable';
        Uzenet.ContentDisposition := 'inline';
        Uzenet.From.Name:=AB_NEV;
        Uzenet.From.Address:=Felado;
        Uzenet.Subject:=Targy;
        Uzenet.Body.Add('Tisztelt Érintett!'+UJSOR);
        Uzenet.Body.Add(Torzs + UJSOR);
        Uzenet.Body.Add('Üdvözlettel: TEDI rendszer');
        Uzenet.AddHeader('Content-Type: text/plain; charset=iso-8859-1');
        Uzenet.AddHeader('Content-Transfer-Encoding: quoted-printable');
        For I:=1 To Length(Csatolasok) Do
        Begin
          If Csatolasok[I-1]<>'' Then
             TIdAttachmentFile.Create(Uzenet.MessageParts, csatolasok[I-1]);
        End;
        Uzenet.Recipients.EMailAddresses:=Cimzett;
        Uzenet.CCList.EMailAddresses:=Masolat;
        Uzenet.BccList.EMailAddresses:=TitkosMasolat;
        Uzenet.ReplyTo.EMailAddresses:=Valasz;
        Uzenet.Encoding:=meMIME;
      End;
      Level2.SendMsg(Uzenet);
      EmailKuldes:=True;
      FreeAndNil(Uzenet);
      FreeAndNil(Level2);
    End;
  Except
  End;
End;

Procedure Agak(Ablak: TForm; FaLista: TTreeView; Mibol: TTreeNode;
  Azon, TablaNev, SzuloMezo, IdMezo, NevMezo: String);
var
  T: TTreeNode;
  Q: TADOQuery;
Begin
  try
    Q := TADOQuery.Create(Ablak);
    Q.Connection := AdatModul.ADOConn;
    Q.SQL.Text := 'Select * From ' + TablaNev + ' Where ' + SzuloMezo + '=' +
      Azon + ' and ' + IdMezo + '<>' + SzuloMezo + ' ';
    Q.Active := True;
    Q.First;
    While Not Q.Eof Do
    Begin
      T := FaLista.Items.AddChild(Mibol, Q.FieldByName(NevMezo).AsString);
      New(id);
      id^ := Q.FieldByName(IdMezo).AsInteger;
      T.Data := id;
      Agak(Ablak, FaLista, T, Q.FieldByName(IdMezo).AsString, TablaNev,
        SzuloMezo, IdMezo, NevMezo); // Rekurzió
      Q.Next;
    End;
    Q.Destroy;
  except
  end;
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
    Result := False;
end;

function StrToBool(x: String): Boolean;
begin
  If (x = '1') or (x = 'True') Then
    Result := True
  Else
    Result := False;
end;

Function GLS_CheckDigit(szam: String): String;
var
  i, a: Integer;
begin
  a := 0;
  For i := 0 to Length(szam) do
    a := a + StrToInt(szam[i]);
  a := a * 3;
  For i := 1 to Length(szam) do
    a := a + StrToInt(szam[i]);
  a := a + 1;
  Result := IntToStr(a mod 10);
end;

Function FelhObjJog(Objektum: String; ObjektumTipus: Integer): Integer;
Begin
  With AdatModul.ADOQuery2 do
  begin
    Active := False;
    SQL.Clear;
    SQL.Text :=
      'Select (case when ((Select x.csoport_felh_jog from csoport_funkciok x where '
      + ' x.funkcio_id = a.funkcio_id and x.felh_csoport_id = ' + FELHCSOP_ID +
      ') = 1) or ' +
      ' ((Select x.rendszer_felh_jog from rendszer_kapocs x where x.funkcio_id = a.funkcio_id '
      + ' and x.felh_id = ' + FELHASZNALO_ID +
      ') = 1) then 1 else isnull((Select x.rendszer_felh_jog from rendszer_kapocs x where '
      + ' x.funkcio_id = a.funkcio_id and x.felh_id = ' + FELHASZNALO_ID +
      '), (isnull((Select x.csoport_felh_jog ' +
      ' from csoport_funkciok x where x.funkcio_id = a.funkcio_id and x.felh_csoport_id = '
      + FELHCSOP_ID + '), 0)))' +
      ' end) as FELHJOG from rendszer_funkciok a where a.funkcio_menu = ' +
      IDCHAR + Objektum + IDCHAR;
    Active := True;
    If Eof and Bof Then
      Result := 0
    Else
      Result := FieldByName('FELHJOG').AsInteger;
    Active := False;
  end;
End;

function Frissites(Tabla: TADOQuery; id, Mezo: String): String;
var
  i: Integer;
begin
  If id <> '' Then
  begin
    i := StrToInt(id);
    // Tabla.Active:=False;
    // Tabla.Active:=True;
    If Not Tabla.Locate(Mezo, i, [loPartialKey]) Then
      If Not Tabla.Locate(Mezo, i + 1, [loPartialKey]) Then
        Tabla.Locate(Mezo, i - 1, [loPartialKey]);
    Result := IntToStr(i);
  end
  else
    Result := '';
end;

function FrissitesTeljes(Tabla: TADOQuery; id, Mezo: String): String;
var
  i: Integer;
begin
  If id <> '' Then
  begin
    i := StrToInt(id);
    Tabla.Active := False;
    Tabla.Active := True;
    If Not Tabla.Locate(Mezo, i, [loPartialKey]) Then
      If Not Tabla.Locate(Mezo, i + 1, [loPartialKey]) Then
        Tabla.Locate(Mezo, i - 1, [loPartialKey]);
    Result := IntToStr(i);
  end
  else
    Result := '';
end;

function FrissitesParam(Tabla: TADOQuery; PList: String): Boolean;
var
  i: Integer;
  l: TStringList;
begin
  i := 0;
  l := TStringList.Create;
  l := ParseString(PList, ';', False, '', -1);
  Tabla.Active := False;
  While l.Count > i do
  begin
    Tabla.Parameters.Items[i].Value := l.Strings[i];
    Inc(i);
  end;
  Try
    Tabla.Active := True;
    Result := True;
  Except
    Result := False;
  End;
  l.Destroy;
end;

// használata:
// GetInetFile('http://www.phone21.hu/ph21_files/S7153248/dijbekero.htm', 'c:\dij.htm');
function GetInetFile(const fileURL, FileName: String): Boolean;
const
  BufferSize = 1024;
var
  hSession, hURL: HInternet;
  Buffer: array [1 .. BufferSize] of Byte;
  BufferLen: DWORD;
  F: File;
  sAppName: string;
begin
  Result := False;
  sAppName := ExtractFileName(Application.ExeName);
  hSession := InternetOpen(PChar(sAppName), INTERNET_OPEN_TYPE_PRECONFIG,
    nil, nil, 0);
  try
    hURL := InternetOpenURL(hSession, PChar(fileURL), nil, 0,
      INTERNET_FLAG_PRAGMA_NOCACHE + INTERNET_FLAG_RELOAD +
      INTERNET_FLAG_RESYNCHRONIZE + INTERNET_FLAG_HYPERLINK, 0);
    If hURL <> nil Then
      try
        AssignFile(F, FileName);
        ReWrite(F, 1);
        repeat
          InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen);
          BlockWrite(F, Buffer, BufferLen);
          Application.ProcessMessages;
        until BufferLen = 0;
        CloseFile(F);
        Result := True;
      finally
        InternetCloseHandle(hURL)
      end
  finally
    InternetCloseHandle(hSession)
  end;
  sleep(500);
  Application.ProcessMessages;
end;

function NCharToWeb(szov: String): String;
begin
  szov := StringReplace(szov, 'í', '&iacute;', [rfReplaceAll]);
  szov := StringReplace(szov, 'Í', '&Iacute;', [rfReplaceAll]);
  szov := StringReplace(szov, 'é', '&eacute;', [rfReplaceAll]);
  szov := StringReplace(szov, 'É', '&Eacute;', [rfReplaceAll]);
  szov := StringReplace(szov, 'á', '&aacute;', [rfReplaceAll]);
  szov := StringReplace(szov, 'Á', '&Aacute;', [rfReplaceAll]);
  szov := StringReplace(szov, 'ó', '&oacute;', [rfReplaceAll]);
  szov := StringReplace(szov, 'Ó', '&Oacute;', [rfReplaceAll]);
  szov := StringReplace(szov, 'ú', '&uacute;', [rfReplaceAll]);
  szov := StringReplace(szov, 'Ú', '&Uacute;', [rfReplaceAll]);
  szov := StringReplace(szov, 'ö', '&ouml;', [rfReplaceAll]);
  szov := StringReplace(szov, 'Ö', '&Ouml;', [rfReplaceAll]);
  szov := StringReplace(szov, 'ü', '&uuml;', [rfReplaceAll]);
  szov := StringReplace(szov, 'Ü', '&Uuml;', [rfReplaceAll]);
  szov := StringReplace(szov, 'õ', '&otilde;', [rfReplaceAll]);
  szov := StringReplace(szov, 'Õ', '&Otilde;', [rfReplaceAll]);
  szov := StringReplace(szov, 'û', '&utilde;', [rfReplaceAll]);
  szov := StringReplace(szov, 'Û', '&Utilde;', [rfReplaceAll]);
  Result := szov;
end;

function EredetiAdat(Tabla: TADOQuery; Sor: TDBGrid): String;
var
  i: Integer;
  S: String;
begin
  S := '';
  For i := 0 to Sor.Columns.Count - 1 do
    S := S + Sor.Columns[i].Title.Caption + ': ' +
      Tabla.FieldByName(Sor.Columns[i].FieldName).AsString + ';' + UJSOR;
  Result := S;
end;

Function Html2Text(S: String): String;
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
  i: Integer;
  Tag, txt: Boolean;
  htm, tx: string;
Begin
  htm := StringReplace(S, #13#10, #32, [rfReplaceAll]);
  htm := StringReplace(htm, #160, #32, [rfReplaceAll]);
  While Pos('  ', htm) > 0 Do
    htm := StringReplace(htm, #32#32, #32, [rfReplaceAll]);
  htm := StringReplace(htm, '</P>', '<BR>', [rfReplaceAll, rfIgnoreCase]);
  htm := StringReplace(htm, '<BR />', '<BR>', [rfReplaceAll, rfIgnoreCase]);
  htm := StringReplace(htm, '<BR>', #13#10, [rfReplaceAll, rfIgnoreCase]);
  htm := StringReplace(htm, #13#10#32, #13#10, [rfReplaceAll]);
  htm := StringReplace(htm, #32#13#10, #13#10, [rfReplaceAll]);
  delete(htm, 1, Pos('<BODY', UpperCase(htm)) - 1);
  i := 1;
  Tag := False;
  txt := False;
  tx := '';
  while i <= Length(htm) do
  begin
    case htm[i] of
      '<':
        begin
          Tag := True;
          txt := False;
        end;
      '>':
        begin
          if (Length(tx) > 1) then
            if not(tx[Length(tx)] in [#32, #10]) then
              tx := tx + #32;
          Tag := False;
          txt := False;
        end;
    else
      if (i > 1) and (htm[i - 1] = #32) then
        txt := False;
      txt := txt or ((not Tag) and (htm[i] <> #32));
      if not Tag and txt then
      begin
        tx := tx + htm[i];
      end;
    end;
    Inc(i);
  end;
  for i := 1 to NISOCS do
  begin
    tx := StringReplace(tx, ISOCS[i, 2], ISOCS[i, 1], [rfReplaceAll]);
  end;
  tx := StringReplace(tx, #160, #32, [rfReplaceAll]);
  Result := tx;
End;

Function iktatoszam(ev, konyv: String): String;
begin
  With AdatModul.ADOQuery1 do
  begin
    If konyv <> '' Then
    begin
      Active := False;
      SQL.Text := 'select max(k.IRAT_FOSZAM) m from IKTATOKONYV k ' +
        'Where k.IRAT_EV=' + ev + ' and k.IKTATO_KONYV_SZAMA=' + konyv;
      Active := True;
      Result := IntToStr(FieldByName('m').AsInteger + 1);
    end
    else
      Uzenet('A könyvszám megadása kötelezõ!');
  end;
end;

Function iktato_alszam(foszam, ev, konyv: String): String;
begin
  // Alszámok maximuma
  If (foszam <> '') and (ev <> '') and (konyv <> '') Then
  begin
    With AdatModul.ADOQuery1 do
    begin
      Active := False;
      SQL.Text :=
        'Select max(k.IRAT_ALSZAM) m, count(k.irat_foszam) as db From IKTATOKONYV k '
        + 'Where k.IRAT_FOSZAM=' + foszam + ' and k.IRAT_EV=' + ev +
        ' and k.IKTATO_KONYV_SZAMA=' + konyv;
      Active := True;
      If FieldByName('db').AsInteger > 0 Then
        Result := IntToStr(FieldByName('m').AsInteger + 1)
      else
        Result := '';
    end;
  end
  else
    Uzenet('A fõszám, könyvszám vagy év valamelyike nincs megadva!');
end;

Function iktato_ki(jel, foszam, alszam, ev: String): String;
var
  atm: String;
begin
  atm := '';
  If ev <> '' Then
  begin
    If jel <> '' Then
      atm := jel + '/';
    atm := atm + foszam + '/';
    If (alszam <> '') and (StrToInt(alszam) > 0) Then
      atm := atm + alszam + '/';
    atm := atm + ev;
  end;
  Result := atm;
end;

Procedure ertektorles;
var
  i: Integer;
begin
  For i := 0 to 50 do
  begin
    Ertekek[i] := '';
    CIM_ERTEKEK[i] := '';
    HRSZ_ERTEKEK[i] := '';
  end;
end;

Procedure DocumentToContainer(FileNev: String; OleContainer: TOleContainer;
  CsakOlvashato: Boolean = True; Nyomtathato: Boolean = False);
Begin
  if OleContainer.State <> osEmpty then
    CloseDoc(OleContainer);
  OleContainer.DoVerb(ovInPlaceActivate);
End;

Procedure SaveAsPDFContainer(OleContainer: TOleContainer; PDFFileNev: String);
Begin
  If OleContainer.State = osEmpty Then
    Exit;
  If PDFFileNev <> '' Then
    OleContainer.OleObject.SaveAs(PDFFileNev, 17, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, True, True); // wdFormatPDF
End;

Procedure CloseDoc(OleContainer: TOleContainer);
begin
  if OleContainer.State = osEmpty then
    Exit;
  OleContainer.Close;
end;

Function IngatlanKeres(hrsz: String): String;
begin
  Result := '';
  With AdatModul.ADOQuery1 do
  begin
    Active := False;
    SQL.Text := 'Select lakas_id From l_lakas Where hrsz_id=' + hrsz;
    Active := True;
    If RecordCount > 0 Then
    begin
      LAK_ID := FieldByName('lakas_id').AsString;
      Result := '2'
    end
    Else
    begin
      LAK_ID := '';
      Active := False;
      SQL.Text := 'Select nem_lakas_id From b_nem_lakas Where hrsz_id=' + hrsz;
      Active := True;
      If RecordCount > 0 Then
      begin
        NLAK_ID := FieldByName('nem_lakas_id').AsString;
        Result := '3';
      end
      Else
      begin
        NLAK_ID := '';
        Active := False;
        SQL.Text :=
          'Select lakoepulet_id From e_lakoepulet Where hrsz_id=' + hrsz;
        Active := True;
        If RecordCount > 0 Then
        begin
          EP_ID := FieldByName('lakoepulet_id').AsString;
          Result := '4';
          If EP_ID = '1185' Then // Saját
            Result := '7';
          If EP_ID = '386' Then // Piac
            Result := '6';
          // Ha intézmény
          Active := False;
          SQL.Text :=
            'Select int_id From intezmeny Where lakoepulet_id=' + EP_ID;
          Active := True;
          If RecordCount > 0 Then
          begin
            INT_ID := FieldByName('int_id').AsString;
            Result := '5';
          end;
        end
        Else
        begin
          EP_ID := '';
          Active := False;
          SQL.Text := 'Select TOP 1 ut_id From utak_hrsz Where hrsz_id=' + hrsz;
          Active := True;
          If RecordCount > 0 Then
          begin
            UT_ID := FieldByName('ut_id').AsString;
            Result := '8';
          end
          Else
            UT_ID := '';
        end;
      end;
    end;
  end;
end;

Function IngatlanKeres_cim(cim: String): String;
var
  hrsz: String;
begin
  Result := '';
  With AdatModul.ADOQuery1 do
  begin
    Active := False;
    SQL.Text := 'Select lakas_id From l_lakas Where hrsz_id=' + hrsz;
    Active := True;
    If RecordCount > 0 Then
    begin
      LAK_ID := FieldByName('lakas_id').AsString;
      Result := '2'
    end
    Else
    begin
      LAK_ID := '';
      Active := False;
      SQL.Text := 'Select nem_lakas_id From b_nem_lakas Where hrsz_id=' + hrsz;
      Active := True;
      If RecordCount > 0 Then
      begin
        NLAK_ID := FieldByName('nem_lakas_id').AsString;
        Result := '3';
      end
      Else
      begin
        NLAK_ID := '';
        Active := False;
        SQL.Text :=
          'Select lakoepulet_id From e_lakoepulet Where hrsz_id=' + hrsz;
        Active := True;
        If RecordCount > 0 Then
        begin
          EP_ID := FieldByName('lakoepulet_id').AsString;
          Result := '4';
          If EP_ID = '1185' Then // Saját
            Result := '7';
          If EP_ID = '386' Then // Piac
            Result := '6';
          // Ha intézmény
          Active := False;
          SQL.Text :=
            'Select int_id From intezmeny Where lakoepulet_id=' + EP_ID;
          Active := True;
          If RecordCount > 0 Then
          begin
            INT_ID := FieldByName('int_id').AsString;
            Result := '5';
          end;
        end
        Else
        begin
          EP_ID := '';
          Active := False;
          SQL.Text := 'Select TOP 1 ut_id From utak_hrsz Where hrsz_id=' + hrsz;
          Active := True;
          If RecordCount > 0 Then
          begin
            UT_ID := FieldByName('ut_id').AsString;
            Result := '8';
          end
          Else
            UT_ID := '';
        end;
      end;
    end;
  end;
end;

Function Vezeto(csoport: String): String;
begin
  // vezetõ kiolvasása
  Result := '0';
  With AdatModul.ADOQuery3 do
  begin
    Active := False;
    SQL.Text :=
      'Select TOP 1 x.felh_id From FELHASZNALO x, FELHASZNALO_KAPOCS y Where x.felh_id=y.felh_id '
      + 'and y.felh_csoport_id=' + csoport +
      ' and x.beosztas_id in (1,4,5,6,12,17,18,19,20) and x.belephet=1 Order By x.beosztas_id';
    Active := True;
    If RecordCount > 0 Then
      Result := FieldByName('felh_id').AsString;
    If (Result = '0') or (Result = '') Then
      Uzenet('A csoporthoz nincs vezetõ rendelve!');
  end;
end;

Function Iktatoszam_nev(id: String): String;
begin
  Result := '0';
  With AdatModul.ADOQuery3 do
  begin
    Active := False;
    SQL.Text :=
      'Select irat_teljes_szama From iktatokonyv Where iktato_id=' + id;
    Active := True;
    If RecordCount > 0 Then
      Result := FieldByName('irat_teljes_szama').AsString;
    If (Result = '0') or (Result = '') Then
      Uzenet('Nincs iktatószám!');
  end;
end;

function GetIPFromHost(HostName: string): string;
type
  TaPInAddr = array [0 .. 10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  i: Integer;
  GInitData: TWSAData;
begin
  WSAStartup($101, GInitData);
  try
    Result := '';
    phe := GetHostByName(PAnsiChar(AnsiString((HostName))));
    if phe = nil then
      Exit;
    pptr := PaPInAddr(phe^.h_addr_list);
    i := 0;
    while pptr^[i] <> nil do
    begin
      Result := string(inet_ntoa(pptr^[i]^));
      Inc(i);
    end;
  finally
    WSACleanup;
  end;
end;

Function Iratgyujto: String;
begin
  With AdatModul.ADOQuery3 do
  begin
    Active := False;
    SQL.Text :=
      'Select iratgyujto_id From irat_gyujto Where iratgyujto_ev = cast((convert(varchar(4),getdate(),102)) as integer)';
    Active := True;
  end;
  Result := AdatModul.ADOQuery3.FieldByName('iratgyujto_id').AsString;
end;

Function IktatoKonyv(iktato_id: String): String;
begin
  With AdatModul.ADOQuery3 do
  begin
    Active := False;
    SQL.Text := 'Select ikonyv_id From iktatokonyv Where iktato_id = ' +
      iktato_id;
    Active := True;
  end;
  Result := AdatModul.ADOQuery3.FieldByName('ikonyv_id').AsString;
end;

Function Erkezteto(ikt_konyv: String): String;
begin
  With AdatModul.ADOQuery3 do
  begin
    Active := False;
    SQL.Text :=
      'Select ek_id From iktatas_erkezteto_konyv Where ek_ev = cast((convert(varchar(4),getdate(),102)) as integer) '
      + ' and ek_azon like ' + IDCHAR + ikt_konyv + '%' + IDCHAR +
      ' and ek_statusz=1';
    Active := True;
  end;
  Result := AdatModul.ADOQuery3.FieldByName('ek_id').AsString;
end;

Function Erkezteto_azon(erk_id: String): String;
begin
  With AdatModul.ADOQuery3 do
  begin
    Active := False;
    SQL.Text := 'Select ek_azon From iktatas_erkezteto_konyv Where ek_id = ' +
      erk_id + ' ';
    Active := True;
  end;
  Result := AdatModul.ADOQuery3.FieldByName('ek_azon').AsString;
end;

Function Elozmeny_ID(iszam: String): String;
var
  l: TStringList;
  S: String;
begin
  Result := '';
  l := TStringList.Create;
  l := ParseString(iszam, '/', False, '', -1);
  try
    S := l[2];
  except
    S := l[1];
  end;
  With AdatModul.ADOQuery3 do
  begin
    Active := False;
    SQL.Text := 'Select iktato_id From iktatokonyv Where irat_foszam=' + l[0] +
      ' and irat_ev=' + S;
    Active := True;
    If RecordCount > 0 Then
      Result := FieldByName('iktato_id').AsString;
  end;
  l.Destroy;
end;

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

Procedure Doc2Pdf(DocFileName: String; PdfFileName: String = '');
 Var OleWord: OleVariant;
     OleDoc : OleVariant;
 Begin
   OleWord:=CreateOleObject('Word.Application');
   OleWord.Visible:=False;
   OleWord.Documents.Open(DocFileName);
   OleDoc  := OleWord.ActiveDocument;
   If PdfFileName='' Then PdfFileName := ChangeFileExt(DocFileName, '.pdf');
   OleDoc.SaveAs(Filename:=PdfFileName, FileFormat:=17);
   OleWord.ActiveDocument.Close;
   OleWord.Quit(0, EmptyParam, EmptyParam);
   Try OleWord.Quit Except End;
   OleDoc := VarNull;
   OleWord:= VarNull;
 End;

 Procedure GridAllapotToltes(Grid: TDBGrid);
Var
  Reg: TRegistry;
  I: Integer;
  GridReg: String;
  F: TWinControl;
  Sorrend: Array [0 .. 50] Of TColumn;
Begin
  FillChar(Sorrend, SizeOf(Sorrend), 0);
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  F := Grid;
  While Not(F is TForm) Do
    F := F.Parent;
  GridReg := RegistryKulcs + 'Ablakok\' + F.Name + '\' + Grid.Name;
  if Reg.OpenKey(GridReg, True) then
  Begin
    For I := 0 To Grid.Columns.Count - 1 Do
    Begin
      if Reg.OpenKey(GridReg + '\' + Grid.Columns[I].FieldName, True) then
      Begin
        Try
          Grid.Columns[I].Visible := Reg.ReadBool('Visible');
          Sorrend[Reg.ReadInteger('Index')] := Grid.Columns[I];
          Grid.Columns[I].Width := Reg.ReadInteger('Width');
        Except
        End;
      End;
    End;
    I := 0;
    While Sorrend[I] <> nil Do
    Begin
      Sorrend[I].Index := Grid.Columns.Count - 1;
      Inc(I);
    End;
  End;
  Reg.CloseKey;
  FreeAndNil(Reg);
End;

Procedure GridAllapotMentes(Grid: TDBGrid);
Var
  Reg: TRegistry;
  I: Integer;
  GridReg: String;
  F: TWinControl;
  Sorrend: Array [0 .. 50] Of TColumn;
Begin
  FillChar(Sorrend, SizeOf(Sorrend), 0);
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  F := Grid;
  While Not(F is TForm) Do
    F := F.Parent;
  GridReg := RegistryKulcs + 'Ablakok\' + F.Name + '\' + Grid.Name;
  For I := 0 To Grid.Columns.Count - 1 Do
  Begin
    if Reg.OpenKey(GridReg + '\' + Grid.Columns[I].FieldName, True) then
    Begin
      Reg.WriteBool('Visible', Grid.Columns[I].Visible);
      Reg.WriteInteger('Index', Grid.Columns[I].Index);
      Reg.WriteInteger('Width', Grid.Columns[I].Width);
    End;
  End;
  try
  Finally
    Reg.CloseKey;
    Reg.Free;
  End;
End;

function HonapKezdet(const AValue: TDateTime): TDateTime;
var
  ev, ho, nap: Word;
begin
  DecodeDate(AValue, ev, ho, nap);
  Result := EncodeDate(ev, ho, 1);
end;

function HonapVeg(const AValue: TDateTime): TDateTime;
var
  ev, ho, nap: Word;
begin
  DecodeDate(AValue, ev, ho, nap);
  If ho=12 Then
  begin
    ev:=ev+1;
    ho:=1;
    Result := EncodeDate(ev, ho, 1) - 1;
  end
  else
    Result := EncodeDate(ev, ho+1, 1) - 1;
end;

Function Valos(szov:String):String;
begin
  Result:=StringReplace(szov, ',', '.', [rfReplaceAll]);
end;

Initialization

// Program_Verzio:=VERZIO;
end.
