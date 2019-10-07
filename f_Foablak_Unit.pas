unit f_Foablak_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ComCtrls,
  Vcl.ToolWin, Alap, Alapfuggveny, Vcl.Themes, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.WinXCtrls, Vcl.Buttons, Vcl.Samples.Spin, System.ImageList, Vcl.ImgList,
  Registry, IniFiles, TypInfo;

type
  Tf_Foablak = class(TForm)
    hc_fejlec: THeaderControl;
    sv_beallitasok: TSplitView;
    sb_foablak: TStatusBar;
    cb_latvany: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    se_betu: TSpinEdit;
    cb_figyeles: TCheckBox;
    fomenu: TMainMenu;
    Brlemnyek1: TMenuItem;
    Laksok1: TMenuItem;
    Helyisgek1: TMenuItem;
    Csarnok1: TMenuItem;
    Brlk1: TMenuItem;
    Adminisztrci1: TMenuItem;
    Keresse1: TMenuItem;
    Listja1: TMenuItem;
    sb_beallitas: TSpeedButton;
    fd_betu: TFontDialog;
    sb_betutipus: TSpeedButton;
    ColorDialog1: TColorDialog;
    l_szin: TLabel;
    Adatmigrci1: TMenuItem;
    N1: TMenuItem;
    Szemlyek1: TMenuItem;
    Szervezetek1: TMenuItem;
    procedure ActiveControlChanged(Sender: TObject);
    procedure cb_latvanyChange(Sender: TObject);
    procedure se_betuChange(Sender: TObject);
    procedure sb_beallitasClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Alaphelyzet1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure sb_betutipusClick(Sender: TObject);
    procedure l_szinClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Adatmigrci1Click(Sender: TObject);
    procedure Csarnok1Click(Sender: TObject);
    procedure Szervezetek1Click(Sender: TObject);
    procedure Laksok1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  f_Foablak: Tf_Foablak;
  LastControl: TControl;
  LastColor: TColor;
  Shape_CurControl: TShape;

implementation

{$R *.dfm}

uses f_Admin_Unit, f_BerloKeres_Unit, f_BerlemenyKereses_Unit,
  f_SzerzodesKeres_Unit, f_SzamlaKeres_Unit, f_TamogatasSzures_Unit,
  f_ReszletfizetesSzures_Unit, f_BefizetesSzures_Unit,
  f_LakasKeres_unit, f_PenztarKeres_Unit, f_AdatMigracio_Unit,
  f_EgyebKeres_Unit, f_HelyisegKeres_Unit, f_SzervezetKeres_Unit;

procedure Tf_Foablak.ActiveControlChanged(Sender: TObject);
Var I: Extended;
begin
  Try
    If Shape_CurControl <> nil Then FreeAndNil(Shape_CurControl);
    If Screen.ActiveControl is TForm Then Exit;
    I:=0;
    If I = 0 Then Begin
       Shape_CurControl:= TShape.Create(Screen.ActiveControl.Parent);
       Shape_CurControl.Parent:= Screen.ActiveControl.Parent;
       Shape_CurControl.Top:=Screen.ActiveControl.Top - 3;
       Shape_CurControl.Left:=Screen.ActiveControl.Left - 3;
       Shape_CurControl.Height:=Screen.ActiveControl.Height + 6;
       Shape_CurControl.Width:=Screen.ActiveControl.Width + 6;
       Shape_CurControl.Shape := stRectangle;
       Shape_CurControl.Brush.Style := bsClear;
       Shape_CurControl.Pen.Style := psSolid;
       Shape_CurControl.Pen.Color := clRed;
       Shape_CurControl.Pen.Width := 3;
       Shape_CurControl.Visible:=True;
    End;
    try
      If LastControl <> nil Then
         SetPropValue(LastControl, 'Color', LastColor);
    Except End;
    LastControl:=nil;
    If (Screen.ActiveControl is TButton) Then Exit;
    LastControl:=Screen.ActiveControl;
    LastColor:=GetPropValue(Screen.ActiveControl, 'Color');
    If IsPublishedProp (Screen.ActiveControl, 'Color') then Begin
       If LastColor = KotelezoMezoSzin Then I:= $00FF80FF Else I:= $00D9ECE9;
       SetPropValue(Screen.ActiveControl, 'Color', I);
    End;
  Except
  End;
End;


procedure Tf_Foablak.Adatmigrci1Click(Sender: TObject);
begin
  AblakNyit(Tf_AdatMigracio, TForm(f_AdatMigracio));
end;

procedure Tf_Foablak.Alaphelyzet1Click(Sender: TObject);
Var R: TRegistry;
begin
  If Rakerdez('Biztosan törölhetem az ablakok pozícióját és egyéb mentett tulajdonságát?') Then
  Begin
    R:=TRegistry.Create;
    R.RootKey:=HKEY_CURRENT_USER;
    R.DeleteKey(RegistryKulcs+ 'Ablakok');
  End;
  R.CloseKey;
  R.Free;
end;

procedure Tf_Foablak.cb_latvanyChange(Sender: TObject);
begin
  try
    STILUS:=cb_latvany.Text;
    TStyleManager.SetStyle(STILUS);
  except
  end;
  Application.ProcessMessages;
end;

procedure Tf_Foablak.Csarnok1Click(Sender: TObject);
begin
  AblakNyit(Tf_EgyebKeres, TForm(f_EgyebKeres));
end;

procedure Tf_Foablak.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Reg: TRegistry;
  Sr: TSearchRec;
begin
  UJ := 0;
  Reg := TRegistry.Create;
  Try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(RegistryKulcs + 'Ablakok\' + Self.Name, True) then
    Begin
      Reg.WriteInteger('Top', Self.Top);
      Reg.WriteInteger('Left', Self.Left);
      Reg.WriteInteger('Width', Self.Width);
      Reg.WriteInteger('Height', Self.Height);
      Reg.WriteString('Style', STILUS);
      Reg.WriteInteger('FontSize', BETUMERET);
      Reg.WriteString('FontType', BETUTIPUS);
      Reg.WriteInteger('Color',KIJELOLES_SZIN);
      Reg.WriteInteger('NewWindow', UJ);
    End;
  Except
  End;
  Reg.CloseKey;
  Reg.Free;
  // Törölni a megnyított állományokat
  If FindFirst(MEGOSZTAS + '\aa_*.*', $3F, Sr) = 0 Then
  Begin
    Repeat
      If (Sr.Name <> '.') And (Sr.Name <> '..') Then
        DeleteFile(MEGOSZTAS + '\' + Sr.Name);
    Until FindNext(Sr) <> 0;
    FindClose(Sr);
  End;
  Halt;
end;

procedure Tf_Foablak.FormCreate(Sender: TObject);
var Reg : TRegistry;
  StyleName: string;
  WFormatoBR: TFormatSettings;
begin
  WFormatoBR := TFormatSettings.Create;
  WFormatoBR.DecimalSeparator := ',';
  WFormatoBR.ThousandSeparator := ' ';
  WFormatoBR.CurrencyDecimals := 2;
  WFormatoBR.DateSeparator := '.';
  WFormatoBR.ShortDateFormat := 'yyyy.MM.dd';
  WFormatoBR.LongDateFormat := 'yyyy.MM.dd';
  WFormatoBR.TimeSeparator := ':';
  WFormatoBR.TimeAMString := 'DE';
  WFormatoBR.TimePMString := 'DU';
  WFormatoBR.ShortTimeFormat := 'hh:nn';
  WFormatoBR.LongTimeFormat := 'hh:nn:ss';
  // WFormatoBR.CurrencyString      := 'R$';
  System.SysUtils.FormatSettings := WFormatoBR;
  // s:=PAnsiChar(MEGOSZTAS);
  // SetCurrentDirectory(s);
  sv_beallitasok.Opened:=False;
  for StyleName in TStyleManager.StyleNames do
    cb_latvany.Items.Add(StyleName);
  hc_fejlec.Sections[0].Text := 'tvnzrt-sql';
  hc_fejlec.Sections[1].Text := 'TEDI teszt';
  hc_fejlec.Sections[2].Text := 'adminisztrátor';
  hc_fejlec.Sections[3].Text := 'Altmann Attila';
  hc_fejlec.Sections[4].Text := 'Verzió:'+VERZIO;
  hc_fejlec.Sections[5].Text := DateToStr(Date());
  LastControl := nil;
  Screen.OnActiveControlChange := ActiveControlChanged;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(RegistryKulcs + 'Ablakok\' + Self.Name, True) then
    Begin
      Self.Top := Reg.ReadInteger('Top');
      Self.Left := Reg.ReadInteger('Left');
      Self.Width := Reg.ReadInteger('Width');
      Self.Height := Reg.ReadInteger('Height');
      STILUS := Reg.ReadString('Style');
      BETUMERET := Reg.ReadInteger('FontSize');
      BETUTIPUS := Reg.ReadString('FontType');
      KIJELOLES_SZIN:=Reg.ReadInteger('Color');
      UJ := Reg.ReadInteger('NewWindow');
      Self.Position := poDesigned;
    End;
  Except
  end;
  Reg.CloseKey;
  Reg.Free;
  try
    TStyleManager.SetStyle(STILUS);
    Application.DefaultFont.Size:=BETUMERET;
    Application.DefaultFont.Name:=BETUTIPUS;
    cb_latvany.Text:=STILUS;
    se_betu.Value:=BETUMERET;
  except end;
  Font.Size := BETUMERET;
  l_szin.Font.Color:=KIJELOLES_SZIN;
  ColorDialog1.Color:=KIJELOLES_SZIN;
  Application.ProcessMessages;
  LastControl := nil;
  Screen.OnActiveControlChange := ActiveControlChanged;
end;

procedure Tf_Foablak.FormShow(Sender: TObject);
var StyleName: string;
    s: PWideChar;
    WFormatoBR: TFormatSettings;
begin
  WFormatoBR := TFormatSettings.Create;
  WFormatoBR.DecimalSeparator := ',';
  WFormatoBR.ThousandSeparator := ' ';
  WFormatoBR.CurrencyDecimals := 2;
  WFormatoBR.DateSeparator := '.';
  WFormatoBR.ShortDateFormat := 'yyyy.MM.dd';
  WFormatoBR.LongDateFormat := 'yyyy.MM.dd';
  WFormatoBR.TimeSeparator := ':';
  WFormatoBR.TimeAMString := 'DE';
  WFormatoBR.TimePMString := 'DU';
  WFormatoBR.ShortTimeFormat := 'hh:nn';
  WFormatoBR.LongTimeFormat := 'hh:nn:ss';
  // WFormatoBR.CurrencyString      := 'R$';
  System.SysUtils.FormatSettings := WFormatoBR;
  for StyleName in TStyleManager.StyleNames do
      cb_latvany.Items.Add(StyleName);
  try
    cb_latvany.Text:=STILUS;
    se_betu.Value:=BETUMERET;
  except end;
  l_szin.Font.Color:=KIJELOLES_SZIN;
  ColorDialog1.Color:=KIJELOLES_SZIN;
end;

procedure Tf_Foablak.Laksok1Click(Sender: TObject);
begin
  AblakNyit(Tf_BerlemenyKereses, TForm(f_BerlemenyKereses));
end;

procedure Tf_Foablak.l_szinClick(Sender: TObject);
begin
  if ColorDialog1.Execute then
  begin
    l_szin.Font.Color:=ColorDialog1.Color;
    KIJELOLES_SZIN:=ColorDialog1.Color;
  end;
end;

procedure Tf_Foablak.sb_beallitasClick(Sender: TObject);
begin
  If sv_beallitasok.Opened Then
    sv_beallitasok.Close
  Else
    sv_beallitasok.Open;
end;

procedure Tf_Foablak.se_betuChange(Sender: TObject);
begin
  BETUMERET:=se_betu.Value;
  Application.DefaultFont.Size:=BETUMERET;
  Application.ProcessMessages;
end;

procedure Tf_Foablak.SpeedButton1Click(Sender: TObject);
begin
  if fd_betu.Execute then
  begin
    Application.DefaultFont.Name:=fd_betu.Font.Name;
    BETUTIPUS:=fd_betu.Font.Name;
    BETUMERET:=fd_betu.Font.Size;
    se_betu.Value:=BETUMERET;
    Application.DefaultFont.Style:=fd_betu.Font.Style;
    Application.DefaultFont.Color:=fd_betu.Font.Color;
    Application.DefaultFont.Size:=fd_betu.Font.Size;
    Application.ProcessMessages;
  end;
end;

procedure Tf_Foablak.Szervezetek1Click(Sender: TObject);
begin
  AblakNyit(Tf_SzervezetKeres, TForm(f_SzervezetKeres));
end;

procedure Tf_Foablak.sb_betutipusClick(Sender: TObject);
begin
  if fd_betu.Execute then
  begin
     Application.DefaultFont.Name:=fd_betu.Font.Name;
     BETUTIPUS:=fd_betu.Font.Name;
     Application.DefaultFont.Style:=fd_betu.Font.Style;
     Application.DefaultFont.Color:=fd_betu.Font.Color;
     Application.DefaultFont.Size:=fd_betu.Font.Size;
     se_betu.Value:=fd_betu.Font.Size;
  end;
end;

end.
