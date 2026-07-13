{ Code parsed using PASFMT on 2026-07-13 18:20:39.997094 }

unit dm_logger;

interface

uses
  System.SysUtils,
  System.Classes,
  DateUtils;

type
  Tlogger = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    function LogLine(sLog: string): integer;
  private
  { Private declarations }
  public
    LogFile: Textfile;
  { Public declarations }
  end;

var
  logger: Tlogger;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure Tlogger.DataModuleCreate(Sender: TObject);
begin
  // Start logger

  AssignFile(LogFile, 'Logs.txt');

  if FileExists('Logs.txt') then
    append(LogFile)
  else
    rewrite(LogFile)

end;

procedure Tlogger.DataModuleDestroy(Sender: TObject);
begin

  CloseFile(LogFile);

end;

function Tlogger.LogLine(sLog: string): integer;
var
  sLyn: string;
  DT: TDateTime;
begin
  // Log elke aksie met timestamp in die textfile
  DT := Now;
  sLyn := DateToStr(DT) + #9 + sLog;

  Try
    WriteLn(LogFile, sLyn);
    Result := 0; // C++ style exit code vir funksie
  except
    Result := 1; // 1 = failure, 0 = success
  End;

end;

end.
