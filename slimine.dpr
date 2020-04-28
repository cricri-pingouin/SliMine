program slimine;

uses
  Forms,
  Mine in 'Mine.pas' {frmMine},
  OPTIONS in 'OPTIONS.pas' {frmOptions},
  HIGHSCORES in 'HIGHSCORES.pas' {frmScores};

{$R *.res}
{$SetPEFlags 1}

begin
  Application.Initialize;
  Application.Title := 'SliMine';
  Application.CreateForm(TfrmMine, frmMine);
  Application.CreateForm(TfrmOptions, frmOptions);
  Application.CreateForm(TfrmScores, frmScores);
  Application.Run;
end.
