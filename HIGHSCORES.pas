unit HIGHSCORES;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, Mine;

type
  TfrmScores = class(TForm)
    strngrdHS: TStringGrid;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmScores: TfrmScores;

implementation

{$R *.dfm}

procedure TfrmScores.FormShow(Sender: TObject);
var
  I: Integer;
begin
  strngrdHS.Cells[1, 0] := 'Name';
  strngrdHS.Cells[2, 0] := 'Mines';
  strngrdHS.Cells[3, 0] := 'Time';
  for I := 1 to 10 do
  begin
    strngrdHS.Cells[0, I] := IntToStr(I);
    strngrdHS.Cells[1, I] := frmMine.HSname[I];
    strngrdHS.Cells[2, I] := IntToStr(frmMine.HSmines[I]);
    strngrdHS.Cells[3, I] := IntToStr(frmMine.HStime[I]);
  end;
end;

end.

