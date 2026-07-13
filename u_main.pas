{ Code parsed using PASFMT on 2026-07-13 18:20:39.997094 }

unit u_main;
interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  dm_Fashion,
  System.Rtti,
  FMX.Grid.Style,
  FMX.Grid,
  FMX.Layouts,
  Winapi.ShellAPI,
  Winapi.Windows,
  u_profile,
  u_listing,
  u_create,
  dm_logger;

type
  Tfrm_main = class(TForm)

    edt_Query: TEdit;
    btn_search: TButton;
    btn_Contact: TButton;
    edt_Username: TEdit;
    lbl_queery: TLabel;
    lbl_username: TLabel;
    pnl_main: TPanel;
    lbl_Fashion: TLabel;
    btn_Profile: TButton;
    edt_Listing: TEdit;
    btn_view: TButton;
    lbl_listing: TLabel;
    btn_Create: TButton;
    sg_afvoer: TStringGrid;
    sl_main: TScaledLayout;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    StringColumn5: TStringColumn;
    StringColumn6: TStringColumn;
    function verify_user(input: string): boolean;
    function verify_listing(input: string): boolean;
    procedure FormResize(Sender: TObject);
    procedure btn_searchClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btn_ContactClick(Sender: TObject);
    procedure Email_Open(sAddress: string);
    procedure btn_ProfileClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btn_viewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btn_CreateClick(Sender: TObject);
  private
  { Private declarations }
  public
  { Public declarations }
  end;

var
  frm_main: Tfrm_main;

implementation

{$R *.fmx}
{$R *.Windows.fmx MSWINDOWS}
{$R *.Surface.fmx MSWINDOWS}
{ Tfrm_main }

procedure Tfrm_main.btn_ContactClick(Sender: TObject);
var
  sUser: string;
begin
  // Vat die user se email uit die databasis en maak 'n email client oop
  // Gebruik die ShellAPI om dit te doen

  sUser := edt_username.Text;

  if not (verify_user(sUser)) then begin
    MessageDlg('User does not exist! Remember caps sensitivity.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
    exit;
  end;

  with dm_databasis do begin

    tbl_users.Open;

    if tbl_users.Locate('Username', sUser, []) then begin
      MessageDlg('Please wait while your email client is opening.', TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOk], 0);
      Email_open(tbl_users['Email']);
    end;

    tbl_users.Close;

  end;

end;

procedure Tfrm_main.btn_CreateClick(Sender: TObject);
begin

  dm_databasis.dmsTarget := dm_databasis.dmsUsername;
  u_create.frm_create.dms_frm_main := Self;
  u_create.frm_create.Show;
  Hide;

end;

procedure Tfrm_main.btn_ProfileClick(Sender: TObject);
begin

  if not (verify_user(edt_Username.Text)) then begin
    MessageDlg('User does not exist! Remember caps sensitivity.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
    exit;
  end;

  // Sit target user in data module vir multi form gebruik.
  dm_databasis.dmsTarget := edt_Username.Text;
  u_profile.frm_profile.dms_frm_main := Self;
  u_profile.frm_profile.Show;
  Self.Hide;

  dm_logger.logger.LogLine('Viewed profile: ' + dm_databasis.dmsTarget);

end;

procedure Tfrm_main.btn_searchClick(Sender: TObject);
var
  sQer, sWord, sUser: string;
  iTel, k, i: integer;
begin
  // Filter

  dm_databasis.AQ1.DataSource := dm_databasis.dsr_listings;

  // Maak die stringgrid skoon
  for i := 0 to 5 do begin
    for k := 0 to sg_afvoer.rowcount - 1 do begin // -1 een want ons begin tel by 0

      sg_afvoer.Cells[i, k] := '';

    end;
  end;

  // Populate die stringgrid met die ADOqueery
  with dm_databasis do begin

    AQ1.Close;
    tbl_users.Open;

    sWord := edt_Query.Text;

    sQer := // Alle listings wat die woord in sWord bevat
        'SELECT * FROM tbl_Listings '
            + 'WHERE ProductName LIKE '
            + QuotedStr('%' + sWord + '%')
            + ' OR [Description] LIKE '
            + QuotedStr('%' + sWord + '%')
            + ' OR [Location] LIKE '
            + QuotedStr('%' + sWord + '%');

    AQ1.SQL.Text := sQer;

    AQ1.Open;

    iTel := 0;

    AQ1.First;

    while not AQ1.eof do begin

      sg_afvoer.Cells[0, iTel] := AQ1['ID'];
      sg_afvoer.Cells[1, iTel] := AQ1['ProductName'];
      sg_afvoer.Cells[2, iTel] := AQ1['Description'];

      // Seller se ID moet na die username convert word
      tbl_users.Locate('ID', AQ1['Seller_ID'], []);
      sUser := tbl_users['Username'];

      sg_afvoer.Cells[3, iTel] := sUser;

      // Price moet floattostrF gebruik vir currency
      sg_afvoer.Cells[4, iTel] := FloattostrF(AQ1['Price'], ffcurrency, 10, 2);

      sg_afvoer.Cells[5, iTel] := AQ1['Location'];

      inc(iTel);
      AQ1.Next;
    end;

    tbl_users.Close;

    dm_logger.logger.LogLine('Ran search queery: ' + sWord + '.');

  end;

end;

procedure Tfrm_main.btn_viewClick(Sender: TObject);
var
  iID: integer; // Tydelik omdat ons dit as string gaan hou;
  sID: string;
begin
  sID := Trim(edt_listing.Text);
  if not TryStrToInt(sID, iID) then begin
    MessageDlg('Invalid Listing ID. Please enter a number.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
    Exit;
  end;

  if not (verify_listing(sID)) then begin
    MessageDlg('Listing ID does not exist!', TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
    Exit;
  end;

  with dm_databasis do begin
    dmsListing := sID; // Hou as stttring;

    tbl_users.Open;
    tbl_listings.Open;

    if not tbl_listings.Locate('ID', dmsListing, []) then begin
      MessageDlg('Could not find listing!', TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
      Exit;
    end;

    iID := tbl_listings['Seller_ID'];
    tbl_users.Locate('ID', iID, []);
    dmsTarget := tbl_users['Username'];
    dm_logger.logger.LogLine('Viewed listing ID: ' + dmsListing);
  end;

  u_listing.frm_listing.dms_frm_main := Self;
  u_listing.frm_listing.Show;
  Hide;
end;

procedure Tfrm_main.Email_Open(sAddress: string);
var
  MailTo: string;
begin
  MailTo := 'mailto:' + sAddress;

  ShellExecute(0, 'open', PChar(MailTo), nil, nil, SW_SHOWNORMAL);
end;

procedure Tfrm_main.FormActivate(Sender: TObject);
begin

  // Strel die stringgrid na regte grote
  dm_databasis.tbl_listings.Open;

  if dm_databasis.tbl_listings.RecordCount > 0 then
    sg_afvoer.RowCount := dm_databasis.tbl_listings.RecordCount
  else
    sg_afvoer.RowCount := 1; // Keep at least 1 row
  //sg_afvoer.ColumnCount := 6;  Bestaan nie in firemonkey
  dm_databasis.tbl_listings.Close; // Die gaan heel moontlik bugs veroorsaak maar ons kkyk en sien;

end;

procedure Tfrm_main.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure Tfrm_main.FormCreate(Sender: TObject);
begin

  // Stylebook ding.
  if dm_Fashion.dm_databasis.arrSettings[2] = 'Jet' then
    stylebook := dm_databasis.StyleBook2;

  if dm_Fashion.dm_databasis.arrSettings[2] = 'Blue' then
    stylebook := dm_databasis.StyleBook1;

end;

procedure Tfrm_main.FormResize(Sender: TObject);
begin
  // Layout
  sl_main.Width := Self.Width;
  sl_main.Height := Self.Height;

end;

procedure Tfrm_main.FormShow(Sender: TObject);
var
  iID, iTel, i, k: integer;
  sUser: string;
begin

  iTel := 0;

  if FileExists('grap.lag') then begin

    DeleteFile('grap.lag'); // Alle grappies op 'n stokkie

    with dm_databasis do begin

      // Maak die stringgrid skoon
      for i := 0 to 5 do begin
        for k := 0 to sg_afvoer.rowcount - 1 do begin // -1 een want ons begin tel by 0

          sg_afvoer.Cells[i, k] := '';

        end;
      end;

      tbl_users.Open;
      tbl_users.Locate('Username', dmsTarget, []);

      iID := tbl_users['ID'];

      AQ1.Close;

      AQ1.SQL.Text := 'SELECT * FROM tbl_Listings WHERE Seller_ID = ' + inttostr(iID);

      AQ1.Open;

      if AQ1.recordcount = 0 then begin

        MessageDlg('This user has no listings.', TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOk], 0);
        exit;

      end;

      AQ1.First;

      while not AQ1.eof do begin

        sg_afvoer.Cells[0, iTel] := AQ1['ID'];
        sg_afvoer.Cells[1, iTel] := AQ1['ProductName'];
        sg_afvoer.Cells[2, iTel] := AQ1['Description'];

        // Seller se ID moet na die username convert word
        tbl_users.Locate('ID', AQ1['Seller_ID'], []);
        sUser := tbl_users['Username'];

        sg_afvoer.Cells[3, iTel] := sUser;

        // Price moet floattostrF gebruik vir currency
        sg_afvoer.Cells[4, iTel] := FloattostrF(AQ1['Price'], ffcurrency, 10, 2);

        sg_afvoer.Cells[5, iTel] := AQ1['Location'];

        inc(iTel);
        AQ1.Next;
      end;

      AQ1.Close;
      tbl_users.Close;

    end;

  end
  else begin
    // Die kode hardloop wanneer grap.lag nie bestaan nie.

    with dm_databasis do begin

      tbl_listings.Open;

      // Maak die stringgrid skoon
      for i := 0 to 5 do begin
        for k := 0 to sg_afvoer.rowcount - 1 do begin // -1 een want ons begin tel by 0

          sg_afvoer.Cells[i, k] := '';

        end;
      end;

      tbl_listings.First;

      while not tbl_listings.eof do begin

        sg_afvoer.Cells[0, iTel] := tbl_listings['ID'];
        sg_afvoer.Cells[1, iTel] := tbl_listings['ProductName'];
        sg_afvoer.Cells[2, iTel] := tbl_listings['Description'];

        // Seller se ID moet na die username convert word
        tbl_users.Locate('ID', tbl_listings['Seller_ID'], []);
        sUser := tbl_users['Username'];

        sg_afvoer.Cells[3, iTel] := sUser;

        // Price moet floattostrF gebruik vir currency
        sg_afvoer.Cells[4, iTel] := FloattostrF(tbl_listings['Price'], ffcurrency, 10, 2);

        sg_afvoer.Cells[5, iTel] := tbl_listings['Location'];

        inc(iTel);
        tbl_listings.Next;
      end;

      tbl_Listings.Close;
      tbl_users.Close;

    end;

  end;

end;

function Tfrm_main.verify_listing(input: string): boolean;
var
  bFlag: Boolean;
  iInput: integer;
begin
  try
    iInput := strtoint(input);
  except
    Result := False;
    Exit;
  end;

  with dm_Fashion.dm_databasis do begin

    tbl_Listings.Open;
    tbl_Listings.First;
    bFlag := False;

    while (not tbl_Listings.eof) and (bFlag = False) do begin
      if tbl_Listings['ID'] = iInput then begin
        bFlag := True;
      end;

      tbl_Listings.Next;

    end;

  end;

  Result := bFlag;

end;

function Tfrm_main.verify_user(input: string): boolean;
var
  bFlag: Boolean;
begin

  with dm_Fashion.dm_databasis do begin
    tbl_users.Open;
    bFlag := tbl_users.Locate('Username', input, []);
    tbl_users.Close;
  end;

  Result := bFlag;

end;

end.
