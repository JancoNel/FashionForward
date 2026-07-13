{ Code parsed using PASFMT on 2026-07-13 18:20:39.997094 }

unit u_reviews;

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
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  dm_Fashion,
  dm_logger,
  FMX.Layouts,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  System.Rtti,
  FMX.Grid.Style,
  FMX.Grid;

type
  Tfrm_reviews = class(TForm)
    btn_Home: TButton;
    btn_review: TButton;
    btn_back: TButton;
    lbl_reviews: TLabel;
    sl_reviews: TScaledLayout;
    sg_reviews: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btn_reviewClick(Sender: TObject);
    procedure btn_backClick(Sender: TObject);
    procedure btn_HomeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
  { Private declarations }
  public
    { Public declarations }
    dms_frm_main: TForm;
    dms_secondary: TForm;
  end;

var
  frm_reviews: Tfrm_reviews;

implementation

{$R *.fmx}

procedure Tfrm_reviews.btn_backClick(Sender: TObject);
begin

  dms_frm_main.Show;
  Hide;

end;

procedure Tfrm_reviews.btn_HomeClick(Sender: TObject);
begin

  dms_secondary.Show;
  Hide;

end;

procedure Tfrm_reviews.btn_reviewClick(Sender: TObject);
var
  dtReview: TDateTime;
  sComment: string;
  rRating: real;
  iListingID, iBuyerID: integer;
begin

  // Inputbox spam lol
  dtReview := Now;
  sComment := inputbox('Comment', 'What is your review comment?', '');
  rRating := strtofloat(inputbox('Rating', 'What would you rate this comment from 0 - 5?', ''));

  iListingID := strtoint(dm_databasis.dmsListing);

  with dm_databasis do begin

    tbl_reviews.Open;
    tbl_users.Open;

    tbl_users.Locate('Username', dmsUsername, []);
    iBuyerID := tbl_users['ID'];

    tbl_users.close;

    tbl_reviews.Last;
    tbl_reviews.Insert;
    tbl_reviews['Buyer_ID'] := iBuyerID;
    tbl_reviews['Listing_ID'] := iListingID;
    tbl_reviews['Comment'] := sComment;
    tbl_reviews['Rating'] := rRating;
    tbl_reviews['Comment_Date'] := dtReview;

    tbl_reviews.Post;
    tbl_reviews.Close;

    dm_logger.logger.LogLine('Left review on: ' + inttostr(iListingID));

  end;

end;

procedure Tfrm_reviews.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure Tfrm_reviews.FormResize(Sender: TObject);
begin
  sl_reviews.Width := Self.Width;
  sl_reviews.Height := Self.Height;
end;

procedure Tfrm_reviews.FormShow(Sender: TObject);
var
  iTel: integer;
begin

  sg_reviews.RowCount := 1; // Reset
  iTel := 0;

  with dm_databasis do begin

    tbl_reviews.Open;
    tbl_reviews.First;

    while not tbl_reviews.eof do begin

      if tbl_reviews['Listing_ID'] = dmsListing then begin

        if iTel >= sg_reviews.RowCount then
          sg_reviews.RowCount := sg_reviews.RowCount + 1;

        sg_reviews.Cells[0, iTel] := tbl_reviews['Comment'];
        sg_reviews.Cells[1, iTel] := floattostr(tbl_reviews['Rating']);
        sg_reviews.Cells[2, iTel] := Datetostr(tbl_reviews['Comment_Date']);

        inc(iTel);

      end;

      tbl_reviews.Next;

    end;

    tbl_reviews.Close;

    if iTel = 0 then begin
      sg_reviews.RowCount := 2;
      ShowMessage('No reviews for this listing.');
    end;

  end;

end;

end.
