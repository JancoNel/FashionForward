{ Code parsed using PASFMT on 2026-07-13 18:20:39.997094 }

unit dm_FASHION;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.Win.ADODB,
  Data.DB,
  FMX.Types,
  FMX.Controls,
  FMX.Dialogs;

type
  Tdm_databasis = class(TDataModule)
    con_db: TADOConnection;
    AQ1: TADOQuery;
    tbl_users: TADOTable;
    dsr_users: TDataSource;
    dsr_listings: TDataSource;
    dsr_reviews: TDataSource;
    tbl_listings: TADOTable;
    tbl_reviews: TADOTable;
    StyleBook1: TStyleBook;
    StyleBook2: TStyleBook;
    AQ2: TADOQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
  { Private declarations }
  public
    { Public declarations }
    arrSettings: array[1..2] of string;

    dmsUsername: string;
    dmsTarget: string;
    dmsListing: string;

  end;

var
  dm_databasis: Tdm_databasis;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure Tdm_databasis.DataModuleCreate(Sender: TObject);
var
  SettingsFile: Textfile;
  iTel: integer;
  sLyn, sCon, sDBPAth, sDBDIR: string;
begin

  sDBDir := ExtractFilePath(ParamStr(0));
  sDBPath := ExtractFilePath(ParamStr(0)) + 'db_local.mdb';

  // Verwyder trailing backslash
  if sDBDir[Length(sDBDir)] = '\' then
    Delete(sDBDir, Length(sDBDir), 1);

  sCon :=
      'Provider=Microsoft OLE DB Provider for ODBC Drivers;'
          + 'Driver={Microsoft Access Driver (*.mdb, *.accdb)};'
          + 'DBQ='
          + sDBPath
          + ';';

  con_db.ConnectionString := sCon;

  con_db.Connected := True;

  tbl_users.Active := True;
  tbl_Reviews.Active := True;
  tbl_Listings.Active := True;

  AssignFile(SettingsFile, 'Settings.txt');

  Try
    Reset(SettingsFile);

    iTel := 0;

    While not EOF(SettingsFile) do begin

      inc(iTel);
      readln(SettingsFile, sLyn);

      arrSettings[iTel] := sLyn;

    end;

  except
    rewrite(SettingsFile);

    arrSettings[1] := '';
    arrSettings[2] := 'Jet'; // Blue vs Jet

  End;

  CloseFile(SettingsFile)

end;

procedure Tdm_databasis.DataModuleDestroy(Sender: TObject);
var
  SettingsFile: Textfile;
  iTel: integer;
  sLyn: string;
begin

  DeleteFile('Settings.txt');

  AssignFile(SettingsFile, 'Settings.txt');

  Rewrite(SettingsFile);

  for sLyn in arrSettings do begin

    WriteLn(SettingsFile, sLyn);

  end;

  CloseFIle(SettingsFile);

end;

end.
