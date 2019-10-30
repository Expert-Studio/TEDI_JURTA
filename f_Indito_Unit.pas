unit f_Indito_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, IniFiles, DBCtrls, Alap, Spin,
  DB, ADODB, ShellAPI, Alapfuggveny, IdGlobal, IdHash, IdHashMessageDigest,
  Vcl.WinXCtrls;

type
  Tf_Indito = class(TForm)
    Belepes: TBitBtn;
    FNev: TEdit;
    FJelszo: TEdit;
    l_nev: TLabel;
    l_jelszo: TLabel;
    Timer1: TTimer;
    bb_kilep: TBitBtn;
    Image1: TImage;
    l_verzio: TLabel;
    Label2: TLabel;
    cb_adat: TComboBox;
    ai_var: TActivityIndicator;
    felh: TADOQuery;
    procedure FormCreate(Sender: TObject);
    procedure BelepesClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure bb_kilepClick(Sender: TObject);
    procedure FNevKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FNevKeyPress(Sender: TObject; var Key: Char);
    procedure cb_adatExit(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FNevEnter(Sender: TObject);
    procedure FJelszoEnter(Sender: TObject);
    procedure cb_adatEnter(Sender: TObject);
  private
    ini_allomany: TIniFile;
    Procedure DoNCHitTest(var mes: TWMNCHitTest); message WM_NCHITTEST;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  f_Indito: Tf_Indito;
  ProbaSzam: Integer;

implementation

uses AlapAdat;

{$R *.DFM}

procedure Tf_Indito.DoNCHitTest(var mes: TWMNCHitTest);
begin
  inherited;
  if mes.Result = HTCLIENT then
  begin
    mes.Result := HTCAPTION;
  end;
end;

procedure Tf_Indito.FormCreate(Sender: TObject);
Const
  PontokSzama = 20;
  Poligon: Array [1 .. PontokSzama * 2] Of Integer = (117, 0, 119, 1, 124, 5,
    133, 14, 141, 22, 142, 23, 306, 23, 308, 24, 310, 26, 312, 27, 312, 138,
    310, 140, 308, 142, 4, 142, 2, 140, 0, 138, 0, 4, 1, 2, 3, 1, 5, 0);
var
  R: HRgn;
  P: array [0 .. PontokSzama - 1] of TPoint;
  I: Integer;
begin
  For I := 0 To PontokSzama - 1 Do
    P[I] := Point(Poligon[I * 2 + 1], Poligon[I * 2 + 2]);
  R := CreatePolygonRgn(P, PontokSzama, ALTERNATE);
  SetWindowRgn(Handle, R, true);
  bb_kilep.Enabled := true;
end;

function MD5String(str: String): String;
begin
  with TIdHashMessageDigest5.Create do
    try
      Result := HashStringAsHex(str);
    finally
      Free;
    end;
end;

procedure Tf_Indito.BelepesClick(Sender: TObject);
Var
  ut, S, JSZ: String;
  Ini: TIniFile;
  I: Cardinal;
  Adat: Array [0 .. 50] Of Char;
  st: Array [1 .. 255] of Char;
  MD5: TIdHashMessageDigest5;
begin
  ai_var.Animate := true;
  StrPCopy(@st, FJelszo.Text);
  // JSZ:=MD5String(FJelszo.Text);
  JSZ := FJelszo.Text;

  MD5 := TIdHashMessageDigest5.Create();
  S := AnsiUpperCase(MD5.HashStringAsHex(FJelszo.Text+JELSZO_MD5));
  MD5.Free;

  s:='';
  AlapAdat.AdatModul.ADOConn.Connected := False;
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'tedi.ini');
  // AB_CEL:=Ini.ReadString('Futtatas', 'A_ELERES', '');
  AB_NEV := cb_adat.Text;
  SMTP_NEV:='mail.tvvrt.hu';
  // SMTP_NEV:=Ini.ReadString('Hibakezeles', 'SMTP szerver', '');
  // IMAP_NEV:=Ini.ReadString('Hibakezeles', 'IMAP szerver', '');
  AlapAdat.AdatModul.ADOConn.Connected := False;
  //AlapAdat.AdatModul.ADOConn.ConnectionString := 'Provider=SQLNCLI11.1;' +         //SQL kapcsolat?
  AlapAdat.AdatModul.ADOConn.ConnectionString := 'Provider=SQLOLEDB.1;' +
    'Password=Rozsa8183;' + 'Persist Security Info=False;' + 'User ID=sa;' +
    'Initial Catalog='+AB_NEV+';' + 'Data Source=192.168.99.220';
  Try
    AlapAdat.AdatModul.ADOConn.Connected := true;
  Except
    Uzenet('Nincs kapcsolat az SQL adatbázissal!');
    ModalResult := MrCancel;
    Exit;
  End;
  AlapAdat.AdatModul.JURTA.Connected := False;
  //AlapAdat.AdatModul.ADOConn.ConnectionString := 'Provider=SQLNCLI11.1;' +         //SQL kapcsolat?
  AlapAdat.AdatModul.JURTA.ConnectionString := 'Provider=SQLOLEDB.1;' +
    'Password=Rozsa8183;' + 'Persist Security Info=False;' + 'User ID=sa;' +
    'Initial Catalog=JurtaTV_teszt;' + 'Data Source=192.168.99.220';
  Try
    AlapAdat.AdatModul.JURTA.Connected := true;
  Except
    Uzenet('Nincs kapcsolat az SQL adatbázissal!');
    ModalResult := MrCancel;
    Exit;
  End;
  With felh do
  begin
    Active:=False;
    SQL.Clear;
    SQL.Text:='Select * From felhasznalo Where belepesi_nev='+IDCHAR+UpperCase(Fnev.Text)+IDCHAR;//+' and jelszo_md5 = '+IDCHAR+S+IDCHAR+' ';
    Active:=True;
    If RecordCount=0 Then
    begin
      Uzenet('A megadott névvel és jelszóval nem tudja beléptetni a '+
          'rendszer!'+#13#10+#13#10+'Próbálja meg újra!');
      ModalResult:=MrCancel;
      //bb_kilepClick(Self);
      Exit;
    end;
    FELHASZNALO:=FieldByName('teljes_nev').AsString;
    BELEP_NEV:=felh.FieldByName('belepesi_nev').AsString;
    FELHASZNALO_ID:=FieldByName('felh_id').AsString;
    FELH_EMAIL:=FieldByName('felhasznalo_level').AsString;
    Active:=False;
    SQL.Clear;
    SQL.Text:='Select felh_csoport_id From felhasznalo_kapocs Where felh_id='+FELHASZNALO_ID;//+' and tedi = 1';
    Active:=True;
    If RecordCount>0 Then
       FELHCSOP_ID:=FieldByName('felh_csoport_id').AsString
    else
       FELHCSOP_ID:='2';
  end;
  MEGOSZTAS := Ini.ReadString('Futtatas', 'D_ELERES', '');
  BETUMERET := Ini.ReadInteger('Hibakezeles', 'Betumeret', 10);
  STILUS := Ini.ReadString('Hibakezeles', 'Stilus', 'Luna');
  D_ELERES := MEGOSZTAS;
  Ini.Free;
  FillChar(Adat, SizeOf(Adat), 0);
  I := 50;
  GetComputerName(@Adat, I);
  ModalResult := 19780712;
end;

procedure Tf_Indito.Timer1Timer(Sender: TObject);
begin
  If AlphaBlendValue < 220 Then
    AlphaBlendValue := AlphaBlendValue + 1;
end;

procedure Tf_Indito.bb_kilepClick(Sender: TObject);
begin
  ModalResult := MrCancel;
end;

procedure Tf_Indito.FNevKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = VK_CAPITAL Then
    Uzenet('Figyelem, a CapsLock billentyût nyomta meg!');
end;

procedure Tf_Indito.FNevKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = Chr(VK_CAPITAL) Then
    Uzenet('Figyelem, a CapsLock billentyû bekapcsolt állapotban van!');
end;

procedure Tf_Indito.cb_adatExit(Sender: TObject);
begin
  If cb_adat.Text = '' Then
  begin
    Uzenet('Válasszon adatbázist!');
    cb_adat.SetFocus;
  end
end;

procedure Tf_Indito.FormShow(Sender: TObject);
begin
  cb_adat.ItemIndex := 1;
  cb_adat.SetFocus;
end;

procedure Tf_Indito.FNevEnter(Sender: TObject);
begin
  FJelszo.SetFocus;
end;

procedure Tf_Indito.FJelszoEnter(Sender: TObject);
begin
  Belepes.SetFocus;
end;

procedure Tf_Indito.cb_adatEnter(Sender: TObject);
begin
  FNev.SetFocus;
end;

end.
