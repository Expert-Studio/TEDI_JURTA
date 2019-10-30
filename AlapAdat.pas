unit AlapAdat;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB;

type
  TAdatModul = class(TDataModule)
    ADOConn: TADOConnection;
    ADOQuery1: TADOQuery;
    ADOQuery2: TADOQuery;
    ADOQuery3: TADOQuery;
    JURTA: TADOConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AdatModul: TAdatModul;

implementation

{$R *.dfm}

procedure TAdatModul.DataModuleCreate(Sender: TObject);
begin
//  JURTA.Connected := False;
//  JURTA.ConnectionString := 'Provider=SQLOLEDB.1;' +
//    'Password=Rozsa8183;' + 'Persist Security Info=False;' + 'User ID=sa;' +
//    'Initial Catalog=JurtaTV;' + 'Data Source=192.168.99.3';
//  ADOConn.ConnectionString := 'Provider=SQLOLEDB.1;' +
//    'Password=Rozsa8183;' + 'Persist Security Info=False;' + 'User ID=sa;' +
//    'Initial Catalog=TIR;' + 'Data Source=192.168.99.3';
end;

end.
