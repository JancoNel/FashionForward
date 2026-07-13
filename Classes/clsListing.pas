{ Code parsed using PASFMT on 2026-07-13 18:20:39.997094 }

unit clsListing;

interface

uses
  dm_Fashion,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants;

type
  TListing = class

  private

    fID, fSeller_ID: integer;
    fPrice: real;
    fProductName, fDescription, fLocation: string;

  public

    Constructor Create;

    // Ek gebruik slegs functions sodat ek return codes kan doen
    // Exit code van 0 beteken flawless execution
    // Exit code van 1 beteken error
    // Sien vir meer inligting:

    // https://www.geeksforgeeks.org/cpp/exit-codes-in-c-c-with-examples/

    const
      SUCCESS = 0;
    const
      FAILURE = 1;

    // Ek weier ook om try en except te gebruik in hierdie class
    // Die idee is dat hierdie soos 'n retro C library voel.

    // Load en save
    function LoadFromID(ID: string): integer;
    function SaveListing(Existing: Boolean): integer;

    // Mutators
    function SetData: integer;

    function SetID(iID: integer): integer;
    function SetSeller(iID: integer): integer;

    function SetPrice(rPrice: real): integer;

    function SetName(sName: string): integer;
    function SetDesc(sDesc: string): integer;
    function setLocation(sLoc: string): integer;

    // Assesors
    function GetID: integer;
    function GetSeller: integer;

    function GetPrice: real;

    function GetName: string;
    function GetDesc: string;
    function GetLocation: string;

    // To string methods
    function toString: string;

  end;

implementation

{ TListing }

constructor TListing.Create;
begin

  fID := -5;

end;

function TListing.GetDesc: string;
begin
  Result := fDescription;
end;

function TListing.GetID: integer;
begin
  Result := fID;
end;

function TListing.GetLocation: string;
begin
  Result := fLocation;
end;

function TListing.GetName: string;
begin
  Result := fProductName;
end;

function TListing.GetPrice: real;
begin
  Result := fPrice;
end;

function TListing.GetSeller: integer;
begin
  Result := fSeller_ID;
end;

function TListing.LoadFromID(ID: string): integer;
begin

  fID := strtoint(ID);

  with dm_databasis do begin
    tbl_listings.Open;
    tbl_listings.Locate('ID', fID, []);

    fDescription := tbl_listings['Description'];
    fSeller_ID := tbl_listings['Seller_ID'];
    fProductName := tbl_listings['ProductName'];
    fPrice := tbl_listings['Price'];
    fLocation := tbl_listings['Location'];

    tbl_listings.Close;

    Result := 0;

  end;

end;

function TListing.SaveListing(Existing: Boolean): integer;
begin

  if Existing then begin
    // Weergawe 1 ek dink

    // Toets of FID 'n waarde het;
    if fID = -5 then begin
      Result := FAILURE;
      exit;
    end;

    with dm_databasis do begin
      tbl_listings.Open;

      if tbl_listings.Locate('ID', fID, []) then begin

        tbl_listings.Edit;

        tbl_listings['Description'] := fDescription;
        tbl_listings['Seller_ID'] := fSeller_ID;
        tbl_listings['ProductName'] := fProductName;
        tbl_listings['Price'] := fPrice;
        tbl_listings['Location'] := fLocation;

        Result := SUCCESS;

      end
      else begin
        Result := FAILURE;
      end;

      tbl_listings.Close;

    end;

    Exit;

  end;

  // As nuwe record...
  With dm_databasis do begin

    tbl_listings.Open;
    tbl_listings.Last;
    tbl_listings.Insert;

    tbl_listings['Description'] := fDescription;
    tbl_listings['Seller_ID'] := fSeller_ID;
    tbl_listings['ProductName'] := fProductName;
    tbl_listings['Price'] := fPrice;
    tbl_listings['Location'] := fLocation;

    //fID := tbl_listings['ID'];

    tbl_listings.Post;

    fID := tbl_listings['ID'];

    tbl_listings.Close;

    Result := 0;

  end;

end;

function TListing.SetData: integer;
begin
  // TODO: Figure 'n manier uit om my idee te implimenteer
end;

function TListing.SetDesc(sDesc: string): integer;
begin

  fDescription := sDesc;
  Result := success;

end;

function TListing.SetID(iID: integer): integer;
begin
  fID := iID;
  Result := success;
end;

function TListing.setLocation(sLoc: string): integer;
begin
  fLocation := sLoc;
  Result := success;
end;

function TListing.SetName(sName: string): integer;
begin
  fProductName := sName;
  Result := success;
end;

function TListing.SetPrice(rPrice: real): integer;
begin
  fPrice := rPrice;
  Result := success;
end;

function TListing.SetSeller(iID: integer): integer;
begin
  fSeller_ID := iID;
  Result := success;
end;

function TListing.toString: string;
begin

  // TODO: Json.stringify yap

end;

end.
