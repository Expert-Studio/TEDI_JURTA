object AdatModul: TAdatModul
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 198
  Width = 434
  object ADOConn: TADOConnection
    ConnectionString = 
      'Provider=SQLNCLI11.1;Persist Security Info=False;User ID=sa;Init' +
      'ial Catalog=TIR_teszt;Data Source=TVVRT-SQL;Initial File Name=""' +
      ';Server SPN=""'
    CursorLocation = clUseServer
    LoginPrompt = False
    Mode = cmReadWrite
    Provider = 'SQLNCLI11.1'
    Left = 40
    Top = 72
  end
  object ADOQuery1: TADOQuery
    Connection = ADOConn
    Parameters = <>
    Left = 240
    Top = 16
  end
  object ADOQuery2: TADOQuery
    Connection = ADOConn
    Parameters = <>
    Left = 248
    Top = 72
  end
  object ADOQuery3: TADOQuery
    Connection = ADOConn
    Parameters = <>
    Left = 256
    Top = 128
  end
  object JURTA: TADOConnection
    ConnectionString = 
      'Provider=SQLNCLI11.1;Persist Security Info=False;User ID=sa;Init' +
      'ial Catalog=TIR_teszt;Data Source=TVVRT-SQL;Initial File Name=""' +
      ';Server SPN="";'
    CursorLocation = clUseServer
    LoginPrompt = False
    Mode = cmReadWrite
    Provider = 'SQLNCLI11.1'
    Left = 122
    Top = 112
  end
end
