program tedi_jurta;



uses
  Vcl.Forms,
  SysUtils,
  IniFiles,
  Vcl.Themes,
  Vcl.Styles,
  Alap in 'Alap.pas',
  AlapAblak_unit in 'AlapAblak_unit.pas' {AlapAblak},
  AlapAdat in 'AlapAdat.pas' {AdatModul: TDataModule},
  AlapFuggveny in 'AlapFuggveny.pas',
  AlapSzures_Unit in 'AlapSzures_Unit.pas' {AlapSzures},
  f_Admin_Unit in 'f_Admin_Unit.pas' {f_Admin},
  f_Foablak_Unit in 'f_Foablak_Unit.pas' {f_Foablak},
  f_GridMezok_Unit in 'f_GridMezok_Unit.pas' {f_GridMezok},
  f_Indito_Unit in 'f_Indito_Unit.pas' {f_Indito},
  f_CimSzerkeszto_Unit in 'f_CimSzerkeszto_Unit.pas' {f_CimSzerkeszto},
  f_AdatMigracio_Unit in 'f_AdatMigracio_Unit.pas' {f_AdatMigracio},
  f_SzervezetKeres_Unit in 'f_SzervezetKeres_Unit.pas' {f_SzervezetKeres},
  f_EleresAdat_Unit in 'f_EleresAdat_Unit.pas' {f_EleresAdat},
  f_BerlemenyKereses_Unit in 'f_BerlemenyKereses_Unit.pas' {f_BerlemenyKereses},
  f_BerlemenyAdat_Unit in 'f_BerlemenyAdat_Unit.pas' {f_BerlemenyAdat};

{$R *.res}

Function AblakNyit(TF: TFormClass; F: TForm): Integer;
Begin
  F := TF.Create(Application);
  try
    result := F.ShowModal;
  finally
    F.Free;
    F := Nil;
  end;
End;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Luna');
  Application.CreateForm(TAdatModul, AdatModul);
  Application.CreateForm(Tf_Foablak, f_Foablak);
  try
//    If AblakNyit(Tf_Indito, f_Indito) = 19780712 Then
    Begin
      Application.Run;
    End
//    Else
//    begin
//      Application.Terminate;
//      Halt;
//    end;
  except
  end;

end.
