unit f_BerlemenyKereses_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, AlapSzures_Unit, Data.DB, Vcl.StdCtrls,
  Alapfuggveny, f_GridMezok_Unit,
  Vcl.ExtCtrls, Data.Win.ADODB, Vcl.Grids, Vcl.DBGrids, Vcl.Buttons, Alap,
  VDComboBox, Vcl.WinXCtrls;

type
  Tf_BerlemenyKereses = class(TAlapSzures)
    le_cim: TLabeledEdit;
    le_hrsz: TLabeledEdit;
    rg_tipus: TRadioGroup;
    le_jurta_cim: TLabeledEdit;
    le_jurta_kod: TLabeledEdit;
    Label1: TLabel;
    rg_jurta_tipus: TRadioGroup;
    Label2: TLabel;
    BitBtn1: TBitBtn;
    JURTA: TADOQuery;
    JURTAds: TDataSource;
    ts_aktiv: TToggleSwitch;
    Panel2: TPanel;
    DBGrid1: TDBGrid;
    Splitter1: TSplitter;
    DBGrid2: TDBGrid;
    BitBtn2: TBitBtn;
    le_tir_jurta: TLabeledEdit;
    BitBtn3: TBitBtn;
    procedure bb_keresClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure SZURESAfterScroll(DataSet: TDataSet);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure DBGrid2KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBGrid1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure DBGrid2TitleClick(Column: TColumn);
    procedure BitBtn3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  f_BerlemenyKereses: Tf_BerlemenyKereses;

implementation

{$R *.dfm}

uses AlapAdat;

procedure Tf_BerlemenyKereses.bb_keresClick(Sender: TObject);
var
  s: String;
begin
  case rg_tipus.ItemIndex of
    0:
      s := 'SELECT a.*, ' +
        '  (Select x.es_nev From ellenstatusz x Where x.es_id=a.es_id) as statusz, '
        + ' a.lakas_osszes_terulete as terulet, '
        + '  (Select x.komfort_nev From l_komfortfokozat x Where x.komfort_id=a.komfort_id) as komfort, '
        + '  (Select x.helyrajziszam From helyrajzi_szamok x Where a.hrsz_id=x.hrsz_id) as hrsz, '
        + '  (Select x.hrsz_id From helyrajzi_szamok x Where a.hrsz_id=x.hrsz_id) as hrsz_id, '
        + '  (Select x.helyrajzi_szam_foresz From helyrajzi_szamok x Where a.hrsz_id=x.hrsz_id) as foresz, '
        + '  (Select x.helyrajzi_szam_alatores From helyrajzi_szamok x Where a.hrsz_id=x.hrsz_id) as alatores, '
        + '  (Select x.cim_sor_1 From cim x Where a.hrsz_id=x.hrsz_id) as cim, '
        + '  (Select x.cim_id From cim x Where a.hrsz_id=x.hrsz_id) as cim_id '
        + 'FROM l_lakas a WHERE a.lakas_id>0 ';
    1:
      s := 'SELECT a.*, ' +
        '  (Select x.es_nev From ellenstatusz x Where x.es_id=a.es_id) as statusz, '
        + '  a.osszes_terulet as terulet, '
        + '  (Select x.helyrajziszam From helyrajzi_szamok x Where a.hrsz_id=x.hrsz_id) as hrsz, '
        + '  (Select x.hrsz_id From helyrajzi_szamok x Where a.hrsz_id=x.hrsz_id) as hrsz_id, '
        + '  (Select x.helyrajzi_szam_foresz From helyrajzi_szamok x Where a.hrsz_id=x.hrsz_id) as foresz, '
        + '  (Select x.helyrajzi_szam_alatores From helyrajzi_szamok x Where a.hrsz_id=x.hrsz_id) as alatores, '
        + '  (Select x.cim_sor_1 From cim x Where a.hrsz_id=x.hrsz_id) as cim, '
        + '  (Select x.cim_id From cim x Where a.hrsz_id=x.hrsz_id) as cim_id '
        + 'FROM b_nem_lakas a WHERE a.nem_lakas_id>0 ';
    2:
      s := 'SELECT a.*, ' +
        '  (Select x.es_nev From ellenstatusz x Where x.es_id=a.es_id) as statusz, '
        + '  (Select x.helyrajziszam From helyrajzi_szamok x Where a.hrsz_id=x.hrsz_id) as hrsz, '
        + '  (Select x.hrsz_id From helyrajzi_szamok x Where a.hrsz_id=x.hrsz_id) as hrsz_id, '
        + '  (Select x.helyrajzi_szam_foresz From helyrajzi_szamok x Where a.hrsz_id=x.hrsz_id) as foresz, '
        + '  (Select x.helyrajzi_szam_alatores From helyrajzi_szamok x Where a.hrsz_id=x.hrsz_id) as alatores, '
        + '  (Select x.cim_sor_1 From cim x Where a.hrsz_id=x.hrsz_id) as cim, '
        + '  (Select x.cim_id From cim x Where a.hrsz_id=x.hrsz_id) as cim_id '
        + 'FROM berlemeny a WHERE a.berl_id>0 ';
    else
      begin
        Uzenet('Válassz bérlemény típust!');
        Exit;
      end;
  end;
  SZURES.SQL.Text := s;
  if le_cim.Text <> '' then
    SZURES.SQL.Add
      ('and (Select x.cim_sor_1 From cim x Where a.hrsz_id=x.hrsz_id) like ' +
      IDCHAR + '%' + le_cim.Text + '%' + IDCHAR + ' ');
  if le_hrsz.Text <> '' then
    SZURES.SQL.Add
      ('and (Select x.helyrajziszam From helyrajzi_szamok x Where a.hrsz_id=x.hrsz_id) like '
      + IDCHAR + '%' + le_hrsz.Text + '%' + IDCHAR + ' ');
  if le_tir_jurta.Text <> '' then
      SZURES.SQL.Add
      ('and jurta_kod like ' + IDCHAR + '%' + le_tir_jurta.Text + '%' + IDCHAR);
  try
    inherited;
  except
    Uzenet('Hibás lekérdezés!');
  end;
  //Jurta lekérdezés
  case rg_jurta_tipus.ItemIndex of
    0:
      s := 'SELECT a.* from Lakasok a Where a.kod is not null ';
    1:
      s := 'SELECT a.* from Nemlakas a Where a.kod is not null ';
    else
      begin
        Uzenet('Válassz bérlemény típust!');
        Exit;
      end;
  end;
  JURTA.SQL.Text := s;
  if le_jurta_cim.Text <> '' then
    JURTA.SQL.Add
      ('and a.cim like '+IDCHAR + '%' + le_jurta_cim.Text + '%' + IDCHAR+' ');
  if le_jurta_kod.Text <> '' then
    JURTA.SQL.Add
      ('and a.kod like '+ IDCHAR + '%' + le_jurta_kod.Text + '%' + IDCHAR+' ');
  if ts_aktiv.State=tssOn then
    JURTA.SQL.Add('and a.aktiv=1 ');
  JURTA.SQL.Add('Order By a.CIM');
  try
    JURTA.Active:=True;
  except
    Uzenet('Hibás lekérdezés!');
  end;
end;

procedure Tf_BerlemenyKereses.BitBtn1Click(Sender: TObject);
var a: String;
begin
  inherited;
  if Rakerdez('Biztos másolja a JURTA kódot?') then
  begin
    case rg_tipus.ItemIndex of
      0:
      begin
          a:=SZURES.FieldByName('LAKAS_ID').AsString;
          Modositas('L_LAKAS',['JURTA_KOD='+JURTA.FieldByName('KOD').AsString],'LAKAS_ID='+LAK_ID);
      end;
      1:
      begin
          a:=SZURES.FieldByName('NEM_LAKAS_ID').AsString;
          Modositas('B_NEM_LAKAS',['JURTA_KOD='+JURTA.FieldByName('KOD').AsString],'NEM_LAKAS_ID='+NLAK_ID);
      end;
      2: Modositas('B_NEM_LAKAS',['JURTA_KOD='+JURTA.FieldByName('KOD').AsString],'NEM_LAKAS_ID='+NLAK_ID);
    end;
  end;
  bb_keresClick(Self);
  case rg_tipus.ItemIndex of
  0: SZURES.Locate('LAKAS_ID',a,[loPartialKey]);
  1: SZURES.Locate('NEM_LAKAS_ID',a,[loPartialKey]);
  end;
end;

procedure Tf_BerlemenyKereses.BitBtn2Click(Sender: TObject);
var s: String;
begin
  inherited;
  if Rakerdez('Biztos másolja a JURTA kódot?') then
  begin
    case rg_tipus.ItemIndex of
      0:
        begin
          s:=SZURES.FieldByName('LAKAS_ID').AsString;
          Modositas('L_LAKAS',['JURTA_KOD='+''],'LAKAS_ID='+LAK_ID);
        end;
      1:
        begin
          s:=SZURES.FieldByName('NEM_LAKAS_ID').AsString;
          Modositas('B_NEM_LAKAS',['JURTA_KOD='+''],'NEM_LAKAS_ID='+NLAK_ID);
        end;
      2: Modositas('B_NEM_LAKAS',['JURTA_KOD='+''],'NEM_LAKAS_ID='+NLAK_ID);
    end;
    bb_keresClick(Self);
    case rg_tipus.ItemIndex of
    0: SZURES.Locate('LAKAS_ID',s,[loPartialKey]);
    1: SZURES.Locate('NEM_LAKAS_ID',s,[loPartialKey]);
    end;
  end;
end;

procedure Tf_BerlemenyKereses.BitBtn3Click(Sender: TObject);
begin
  inherited;
  le_tir_jurta.Text:=JURTA.FieldByName('KOD').AsString;
end;

procedure Tf_BerlemenyKereses.DBGrid1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  If Key = vk_F12 Then
    GridMezok(DBGrid1);
end;

procedure Tf_BerlemenyKereses.DBGrid1TitleClick(Column: TColumn);
begin
  inherited;
  dbg_TitleClick(DBGrid1, Column);
end;

procedure Tf_BerlemenyKereses.DBGrid2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  If Key = vk_F12 Then
    GridMezok(DBGrid2);
end;

procedure Tf_BerlemenyKereses.DBGrid2TitleClick(Column: TColumn);
begin
  inherited;
  dbg_TitleClick(DBGrid2, Column);
end;

procedure Tf_BerlemenyKereses.FormKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if key = CRCHAR then
    bb_keresClick(Self);
end;

procedure Tf_BerlemenyKereses.SZURESAfterScroll(DataSet: TDataSet);
begin
  inherited;
  LAK_ID:='';
  NLAK_ID:='';
  BERL_ID:='';
  case rg_tipus.ItemIndex of
  0:  LAK_ID:=SZURES.FieldByName('lakas_id').AsString;
  1:  NLAK_ID:=SZURES.FieldByName('nem_lakas_id').AsString;
  2:  BERL_ID:=SZURES.FieldByName('berl_id').AsString;
  end;
  CIM_ID:=SZURES.FieldByName('cim_id').AsString;
  CIM_SOR:=SZURES.FieldByName('cim').AsString;
  HRSZ_SOR:=SZURES.FieldByName('hrsz').AsString;
end;

end.
