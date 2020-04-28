unit OPTIONS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Mine, IniFiles;

type
  tfrmOptions = class(TForm)
    lblX: TLabel;
    scrlX: TScrollBar;
    lblY: TLabel;
    scrlY: TScrollBar;
    btnCancel: TButton;
    btnOk: TButton;
    lblXval: TLabel;
    lblYval: TLabel;
    scrlMines: TScrollBar;
    lblMines: TLabel;
    lblMinesVal: TLabel;
    chkMarks: TCheckBox;
    btnBeginner: TButton;
    btnIntermediate: TButton;
    btnExpert: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure scrlXChange(Sender: TObject);
    procedure scrlYChange(Sender: TObject);
    procedure scrlMinesChange(Sender: TObject);
    procedure btnBeginnerClick(Sender: TObject);
    procedure btnIntermediateClick(Sender: TObject);
    procedure btnExpertClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmOptions: tfrmOptions;

implementation

{$R *.dfm}

procedure tfrmOptions.btnBeginnerClick(Sender: TObject);
begin
  scrlX.Position := 9;
  scrlY.Position := 9;
  scrlMines.Position := 10;
end;

procedure tfrmOptions.btnIntermediateClick(Sender: TObject);
begin
  scrlX.Position := 16;
  scrlY.Position := 16;
  scrlMines.Position := 40;
end;

procedure tfrmOptions.btnExpertClick(Sender: TObject);
begin
  scrlX.Position := 16;
  scrlY.Position := 30;
  scrlMines.Position := 99;
end;

procedure tfrmOptions.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure tfrmOptions.btnOkClick(Sender: TObject);
var
  myINI: TINIFile;
begin
  frmMine.BoardSizeX := scrlX.Position;
  frmMine.BoardSizeY := scrlY.Position;
  frmMine.NumMines := scrlMines.Position;
  frmMine.AllowMarks := chkMarks.Checked;
  //Save settings to INI file
  myINI := TINIFile.Create(ExtractFilePath(Application.EXEName) + 'SliMine.ini');
  myINI.WriteInteger('Settings', 'BoardSizeX', frmMine.BoardSizeX);
  myINI.WriteInteger('Settings', 'BoardSizeY', frmMine.BoardSizeY);
  myINI.WriteInteger('Settings', 'NumMines', frmMine.NumMines);
  myINI.WriteBool('Settings', 'AllowMarks', frmMine.AllowMarks);
  myINI.Free;
  Close;
end;

procedure tfrmOptions.FormCreate(Sender: TObject);
begin
  scrlX.Position := frmMine.BoardSizeX;
  lblXval.Caption := IntToStr(scrlX.Position);
  scrlY.Position := frmMine.BoardSizeY;
  lblYval.Caption := IntToStr(scrlY.Position);
  scrlMines.Position := frmMine.NumMines;
  lblMinesVal.Caption := IntToStr(scrlMines.Position);
  scrlMines.Max := (scrlX.Position - 1) * (scrlY.Position - 1);
  chkMarks.Checked := frmMine.AllowMarks;
end;

procedure tfrmOptions.scrlXChange(Sender: TObject);
begin
  lblXval.Caption := IntToStr(scrlX.Position);
  scrlMines.Max := (scrlX.Position - 1) * (scrlY.Position - 1);
end;

procedure tfrmOptions.scrlYChange(Sender: TObject);
begin
  lblYval.Caption := IntToStr(scrlY.Position);
  scrlMines.Max := (scrlX.Position - 1) * (scrlY.Position - 1);
end;

procedure tfrmOptions.scrlMinesChange(Sender: TObject);
begin
  lblMinesVal.Caption := IntToStr(scrlMines.Position);
end;

end.

