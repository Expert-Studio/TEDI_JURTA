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
    procedure BitBtn2Click(Sender: TObject);
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
  SZURES.Active:=False;
  SZURES.SQL.Text:=
    'Select a.* From JurtaTV_teszt.dbo.Nberlok a Where a.AKTIV=1 Order By a.NEV ';
  SZURES.Active:=True;
  SZURES.First;
  while not SZURES.Eof do
  begin
    s:=''; t:=''; u:='';
    //Nincs a TIR-ben
    if SZURES.FieldByName('SZERVEZET_ID').AsString='' then
    begin
      if SZURES.FieldByName('FIZETESMOD').AsString='�tutal�s' then s:='1';
      if SZURES.FieldByName('FIZETESMOD').AsString='Csekk' then s:='3';
      if SZURES.FieldByName('TIPUS').AsString='Szem�ly' then t:='42';
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
      SZER_ID:=Beszuras('SZERVEZET',[
        'szervezet_nev='+SZURES.FieldByName('NEV').AsString,
        'adoszam='+SZURES.FieldByName('ADOSZAM').AsString,
        'cegjegyzekszam='+SZURES.FieldByName('CEGJEGYZEKSZAM').AsString,
        'bankszamlaszam='+SZURES.FieldByName('BANKSZAMLA').AsString,
        'szervezet_vege='+MAXDAT,
        'fm_id='+s,
        'tev_id='+u,
        'szervezet_tipus_id='+t,
        'megjegyzes='+SZURES.FieldByName('MEGJEGYZES').AsString,
        'jurta_kod='+SZURES.FieldByName('KOD').AsString
        ]);
      LISTA.SQL.Text:=
        'Select szervezet_id From szervezet Where jurta_kod='+
        SZURES.FieldByName('KOD').AsString;
      LISTA.Active:=True;
      if LISTA.FieldByName('szervezet_id').AsString<>'' then
      begin
        SZER_ID:=LISTA.FieldByName('szervezet_id').AsString;
        if SZURES.FieldByName('TELEFON').AsString<>'' then
        begin
          //Van m�r telefon (5) el�r�se?
          LISTA.SQL.Text:=
            'Select b.eleres_id From szervezet_eleres a, eleres b Where '+
            'a.szervezet_id=b.szervezet_id and b.eleres_tipus_id=5 and '+
            'a.szervezet_id='+SZER_ID;
          LISTA.Active:=True;
          if LISTA.RecordCount>0 then //Ha igen, akkor m�dos�juk
          begin
            Modositas('eleres',[
              'eleres_nev='+SZURES.FieldByName('telefon').AsString
            ],'eleres_id='+LISTA.FieldByName('eleres_id').AsString);
          end
          else
          begin
            ELE_ID:=Beszuras('eleres',[
              'eleres_nev='+SZURES.FieldByName('telefon').AsString,
              'eleres_megjegyzes='+'JURTA adatkonvert�l�s',
              'eleres_tipus_id=5',
              'eleres_kezdete='+'20000101',
              'eleres_vege='+MAXDAT
            ]);
            Beszuras('szervezet_eleres',[
              'szervezet_id='+SZER_ID,
              'eleres_id='+ELE_ID,
              'szer_eleres_kezdete='+'20000101',
              'szer_eleres_vege='+MAXDAT
            ]);
          end;
        end;
        if SZURES.FieldByName('EMAIL').AsString<>'' then
        begin
          //Van m�r e-mail (9) el�r�se?
          LISTA.SQL.Text:=
            'Select b.eleres_id From szervezet_eleres a, eleres b Where '+
            'a.szervezet_id=b.szervezet_id and b.eleres_tipus_id=9 and '+
            'a.szervezet_id='+SZER_ID;
          LISTA.Active:=True;
          if LISTA.RecordCount>0 then //Ha igen, akkor m�dos�juk
          begin
            Modositas('eleres',[
              'eleres_nev='+SZURES.FieldByName('email').AsString
            ],'eleres_id='+LISTA.FieldByName('eleres_id').AsString);
          end
          else
          begin
            ELE_ID:=Beszuras('eleres',[
              'eleres_nev='+SZURES.FieldByName('email').AsString,
              'eleres_megjegyzes='+'JURTA adatkonvert�l�s',
              'eleres_tipus_id=9',
              'eleres_kezdete='+'20000101',
              'eleres_vege='+MAXDAT
            ]);
            Beszuras('szervezet_eleres',[
              'szervezet_id='+SZER_ID,
              'eleres_id='+ELE_ID,
              'szer_eleres_kezdete='+'20000101',
              'szer_eleres_vege='+MAXDAT
            ]);
          end;
        end;
        if SZURES.FieldByName('IRSZ').AsString<>'' then
        begin
          //Van m�r levelez�si (postai) c�m (8) el�r�se?
          LISTA.SQL.Text:=
            'Select b.eleres_id From szervezet_eleres a, eleres b Where '+
            'a.szervezet_id=b.szervezet_id and b.eleres_tipus_id=8 and '+
            'a.szervezet_id='+SZER_ID;
          LISTA.Active:=True;
          if LISTA.RecordCount>0 then //Ha igen, akkor m�dos�juk
          begin
            Modositas('eleres',[
              'eleres_nev='+SZURES.FieldByName('IRSZ').AsString+' '+SZURES.FieldByName('helyseg').AsString+', '+SZURES.FieldByName('utca').AsString
            ],'eleres_id='+LISTA.FieldByName('eleres_id').AsString);
          end
          else
          begin
            //Most "csak" az el�r�s t�bl�ban r�gz�tj�k �s nem lesz CIM t�bla kapcsolata
            ELE_ID:=Beszuras('eleres',[
              'eleres_nev='+SZURES.FieldByName('IRSZ').AsString+' '+SZURES.FieldByName('helyseg').AsString+', '+SZURES.FieldByName('utca').AsString,
              'eleres_megjegyzes='+'JURTA adatkonvert�l�s',
              'eleres_tipus_id=8',
              'eleres_kezdete='+'20000101',
              'eleres_vege='+MAXDAT
            ]);
            Beszuras('szervezet_eleres',[
              'szervezet_id='+SZER_ID,
              'eleres_id='+ELE_ID,
              'szer_eleres_kezdete='+'20000101',
              'szer_eleres_vege='+MAXDAT
            ]);
          end;
        end;
        if SZURES.FieldByName('SZEKHELY').AsString<>'' then
        begin
          //Van m�r sz�khely c�m (12) el�r�se?
          LISTA.SQL.Text:=
            'Select b.eleres_id From szervezet_eleres a, eleres b Where '+
            'a.szervezet_id=b.szervezet_id and b.eleres_tipus_id=12 and '+
            'a.szervezet_id='+SZER_ID;
          LISTA.Active:=True;
          if LISTA.RecordCount>0 then //Ha igen, akkor m�dos�juk
          begin
            Modositas('eleres',[
              'eleres_nev='+SZURES.FieldByName('szekhely').AsString
            ],'eleres_id='+LISTA.FieldByName('eleres_id').AsString);
          end
          else
          begin
            //Most "csak" az el�r�s t�bl�ban r�gz�tj�k �s nem lesz CIM t�bla kapcsolata
            ELE_ID:=Beszuras('eleres',[
              'eleres_nev='+SZURES.FieldByName('szekhely').AsString,
              'eleres_megjegyzes='+'JURTA adatkonvert�l�s',
              'eleres_tipus_id=12',
              'eleres_kezdete='+'20000101',
              'eleres_vege='+MAXDAT
            ]);
            Beszuras('szervezet_eleres',[
              'szervezet_id='+SZER_ID,
              'eleres_id='+ELE_ID,
              'szer_eleres_kezdete='+'20000101',
              'szer_eleres_vege='+MAXDAT
            ]);
          end;
        end;
        //K�pvisel�i adatok kezel�se
        if SZURES.FieldByName('KEPVISELO').AsString<>'' then
        begin
          //R�gz�teni szem�lyk�nt
          l.Clear;
          l:=ParseString(SZURES.FieldByName('KEPVISELO').AsString,' ',False,'',1);
          s:=LeftStr(l[0],20);
          t:=LeftStr(l[1],20);
          SZEM_ID:=Beszuras('szemely',[
            'szerepkor_id=22',
            'vezetekneve1='+s,
            'keresztneve1='+t,
            'anyja_neve='+SZURES.FieldByName('ANYJANEVE').AsString,
            'szemely_teljes_neve='+SZURES.FieldByName('KEPVISELO').AsString,
            'szemely_megjegyzes='+'JURTA adatkonvert�l�s',
            'szuletesi_hely='+SZURES.FieldByName('SZULETESIHELY').AsString,
            'szemelyi_szam='+LeftStr(SZURES.FieldByName('SZIGSZAM').AsString,11),
            'szemely_kezdete='+'20000101',
            'szemely_vege='+MAXDAT
          ]);
          Beszuras('szervezet_szemely',[
            'szervezet_id='+SZER_ID,
            'szemely_id='+SZEM_ID,
            'szerepkor_id=22',
            'szsz_mettol='+'20000101',
            'szsz_meddig='+MAXDAT
          ]);
          //Most "csak" az el�r�s t�bl�ban r�gz�tj�k �s nem lesz CIM t�bla kapcsolata
          ELE_ID:=Beszuras('eleres',[
            'eleres_nev='+SZURES.FieldByName('LAKCIM').AsString,
            'eleres_megjegyzes='+'JURTA adatkonvert�l�s',
            'eleres_tipus_id=8',
            'eleres_kezdete='+'20000101',
            'eleres_vege='+MAXDAT
          ]);
          Beszuras('szemely_eleres',[
            'szemely_id='+SZEM_ID,
            'eleres_id='+ELE_ID,
            'szem_eleres_kezdete='+'20000101',
            'szem_eleres_vege='+MAXDAT
          ]);
        end;
        //�gyint�z� adatok kezel�se
        if SZURES.FieldByName('UGYINTEZO').AsString<>'' then
        begin
          //R�gz�teni szem�lyk�nt
          l.Clear;
          l:=ParseString(SZURES.FieldByName('UGYINTEZO').AsString,' ',False,'',1);
          s:=LeftStr(l[0],20);
          t:=LeftStr(l[1],20);
          SZEM_ID:=Beszuras('szemely',[
            'szerepkor_id=8', //�gyint�z�
            'vezetekneve1='+s,
            'keresztneve1='+t,
            'szemely_teljes_neve='+SZURES.FieldByName('UGYINTEZO').AsString,
            'szemely_megjegyzes='+'JURTA adatkonvert�l�s',
            'szemely_kezdete='+'20000101',
            'szemely_vege='+MAXDAT
          ]);
          Beszuras('szervezet_szemely',[
            'szervezet_id='+SZER_ID,
            'szemely_id='+SZEM_ID,
            'szerepkor_id=8',
            'szsz_mettol='+'20000101',
            'szsz_meddig='+MAXDAT
          ]);
        end;
        //Kapcsolattart� adatok kezel�se
        if SZURES.FieldByName('levelnev').AsString<>'' then
        begin
          //R�gz�teni szem�lyk�nt
          l.Clear;
          l:=ParseString(SZURES.FieldByName('levelnev').AsString,' ',False,'',1);
          s:=LeftStr(l[0],20);
          t:=LeftStr(l[1],20);
          SZEM_ID:=Beszuras('szemely',[
            'szerepkor_id=23', //kapcsolattart�
            'vezetekneve1='+s,
            'keresztneve1='+t,
            'szemely_teljes_neve='+SZURES.FieldByName('levelnev').AsString,
            'szemely_megjegyzes='+'JURTA adatkonvert�l�s',
            'szemely_kezdete='+'20000101',
            'szemely_vege='+MAXDAT
          ]);
          Beszuras('szervezet_szemely',[
            'szervezet_id='+SZER_ID,
            'szemely_id='+SZEM_ID,
            'szerepkor_id=23',
            'szsz_mettol='+'20000101',
            'szsz_meddig='+MAXDAT
          ]);
        end;
      end;
    end;
    SZURES.Next;
  end;
  //Csarnok b�rl�k feldolgoz�sa

end;

end.
