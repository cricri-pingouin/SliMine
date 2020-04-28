unit Mine;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Buttons, Menus, INIfiles;

type
  TfrmMine = class(TForm)
    tmrGameTime: TTimer;
    mnuMain: TMainMenu;
    mnuTime: TMenuItem;
    mnuMines: TMenuItem;
    mnuGame: TMenuItem;
    mnuNew: TMenuItem;
    mnuOptions: TMenuItem;
    mnuScores: TMenuItem;
    mnuSep: TMenuItem;
    mnuExit: TMenuItem;
    img0: TImage;
    img1: TImage;
    img2: TImage;
    img3: TImage;
    img4: TImage;
    img5: TImage;
    img6: TImage;
    img7: TImage;
    img8: TImage;
    imgBlank: TImage;
    imgFlag: TImage;
    imgMaybe: TImage;
    imgBoom: TImage;
    imgWrong: TImage;
    imgRight: TImage;
    procedure DrawSquare(X, Y, SquareIndex: Integer);
    procedure ClickSquare(X, Y: Integer);
    procedure Uncover(X, Y: Integer);
    function MinesFlagged(): Integer;
    procedure NewGame();
    procedure EndGame();
    procedure tmrGameTimeTimer(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure mnuOptionsClick(Sender: TObject);
    procedure mnuScoresClick(Sender: TObject);
    procedure mnuNewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    //High scores
    HSname: array[1..10] of string;
    HSmines: array[1..10] of DWORD;
    HStime: array[1..10] of DWORD;
    BoardSizeX, BoardSizeY, NumMines: Integer;
    AllowMarks: Boolean;
    procedure Paint; override; //Paint override needed to display new game from FormCreate
  end;

const
  StatusNone = 0;
  StatusFlag = 1;
  StatusMaybe = 2;
  StatusOpen = 3;
  SquareMine = 9; //Could be anything greater than 8 (max number of neighbour mines)
  SquareSize = 24; //Size of BMPs
  MaxX = 70;
  MaxY = 40;

type
  GameBoard = array[0..MaxX + 1, 0..MaxY + 1] of Byte;

var
  frmMine: TfrmMine;
  NumNotMines, FlaggedMines: Integer;
  BoardStatus: GameBoard; // 0 = nothing; 1 = open; 2 = flagged
  BoardField: GameBoard; // 0..8 = neighbour mines count; 9 = mine
  GameTime: DWORD;
  GameRunning: Boolean;
  SquarePic: array[0..14] of^TBitmap;

implementation

uses
  OPTIONS, HIGHSCORES;

{$R *.dfm}

procedure TfrmMine.DrawSquare(X, Y, SquareIndex: Integer);
begin
  frmMine.Canvas.Draw((X - 1) * SquareSize, (Y - 1) * SquareSize, SquarePic[SquareIndex]^);
end;

procedure TfrmMine.ClickSquare(X, Y: Integer);
var
  DispX, DispY: Integer;
begin
  //If square status not none (i.e. 1=flagged, 2=maybe, 3=opened): exit
  if (BoardStatus[X, Y] <> StatusNone) then
    Exit;
    //Is it a bomb?
  if (BoardField[X, Y] = SquareMine) then
  begin
    //Yes: game over
    tmrGameTime.Enabled := False;
    GameRunning := False;
    //Reveal bombs locations
    for DispX := 1 to BoardSizeX do
      for DispY := 1 to BoardSizeY do
      begin
        //Reveal unflagged mines
        if (BoardField[DispX, DispY] = SquareMine) and (BoardStatus[DispX, DispY] <> StatusFlag) then
          DrawSquare(DispX, DispY, 12);
        //Reveal wrongly flagged mines
        if (BoardField[DispX, DispY] < SquareMine) and (BoardStatus[DispX, DispY] = StatusFlag) then
          DrawSquare(DispX, DispY, 13);
      end;
    //Oops, that's where you clicked
    DrawSquare(X, Y, 14);
    ShowMessage('You lose!');
  end
  else
  begin
    //Recursively uncover square and its neighbours if needed
    Uncover(X, Y);
    //Demined everything?
    if (NumNotMines = 0) then
    begin
      tmrGameTime.Enabled := False;
      GameRunning := False;
      //Flag mines
      for DispX := 1 to BoardSizeX do
        for DispY := 1 to BoardSizeY do
          if (BoardField[DispX, DispY] = SquareMine) then
            DrawSquare(DispX, DispY, 10);
      EndGame();
    end;
  end;
end;

procedure TfrmMine.Uncover(X, Y: Integer);
begin
  //Uncover this square
  DrawSquare(X, Y, BoardField[X, Y]);
  BoardStatus[X, Y] := StatusOpen;
  Dec(NumNotMines);
  //Recursively uncover neighbours
  if (BoardField[X, Y] = 0) then
  begin
    //Top left
    if (BoardStatus[X - 1, Y - 1] = StatusNone) or (BoardStatus[X - 1, Y - 1] = StatusMaybe) then
      Uncover(X - 1, Y - 1);
    //Left
    if (BoardStatus[X - 1, Y] = StatusNone) or (BoardStatus[X - 1, Y] = StatusMaybe) then
      Uncover(X - 1, Y);
    //Bottom left
    if (BoardStatus[X - 1, Y + 1] = StatusNone) or (BoardStatus[X - 1, Y + 1] = StatusMaybe) then
      Uncover(X - 1, Y + 1);
    //Top
    if (BoardStatus[X, Y - 1] = StatusNone) or (BoardStatus[X, Y - 1] = StatusMaybe) then
      Uncover(X, Y - 1);
    //Bottom
    if (BoardStatus[X, Y + 1] = StatusNone) or (BoardStatus[X, Y + 1] = StatusMaybe) then
      Uncover(X, Y + 1);
    //Top right
    if (BoardStatus[X + 1, Y - 1] = StatusNone) or (BoardStatus[X + 1, Y - 1] = StatusMaybe) then
      Uncover(X + 1, Y - 1);
    //Right
    if (BoardStatus[X + 1, Y] = StatusNone) or (BoardStatus[X + 1, Y] = StatusMaybe) then
      Uncover(X + 1, Y);
    //Bottom right
    if (BoardStatus[X + 1, Y + 1] = StatusNone) or (BoardStatus[X + 1, Y + 1] = StatusMaybe) then
      Uncover(X + 1, Y + 1);
  end;
end;

function TfrmMine.MinesFlagged(): Integer;
var
  X, Y: Integer;
begin
  Result := 0;
  for X := 1 to BoardSizeX do
    for Y := 1 to BoardSizeY do
      if (BoardStatus[X, Y] = StatusFlag) then
        Inc(Result);
end;

procedure TfrmMine.NewGame();
var
  i, X, Y: Integer;
begin
  frmMine.ClientWidth := BoardSizeX * SquareSize;
  frmMine.ClientHeight := BoardSizeY * SquareSize;
  //Draw empty board
  for X := 1 to BoardSizeX do
    for Y := 1 to BoardSizeY do
      DrawSquare(X, Y, 9);
  //Initialise boards
  for X := 0 to MaxX + 1 do
    for Y := 0 to MaxY + 1 do
    begin
      BoardField[X, Y] := 0;
      BoardStatus[X, Y] := StatusNone;
    end;
  //Pretend borders are revealed to save us some tests later
  for X := 0 to MaxX + 1 do
  begin
    BoardStatus[X, 0] := StatusOpen;
    BoardStatus[X, BoardSizeY + 1] := StatusOpen;
  end;
  for Y := 0 to MaxY + 1 do
  begin
    BoardStatus[0, Y] := StatusOpen;
    BoardStatus[BoardSizeX + 1, Y] := StatusOpen;
  end;
  //Randomly place mines
  Randomize;
  if (NumMines < (BoardSizeX * BoardSizeY) div 2) then
  begin
    //Less than 50%: randomly put mines
    for i := 1 to NumMines do
    begin
    //Keep getting random position until it isn't already a mine
      repeat
        X := Random(BoardSizeX) + 1;
        Y := Random(BoardSizeY) + 1;
      until (BoardField[X, Y] <> SquareMine);
      BoardField[X, Y] := SquareMine;
    end;
  end
  else
  begin
    //More than 50%: initialise all as mines then randomly remove some
    for X := 1 to BoardSizeX do
      for Y := 1 to BoardSizeY do
        BoardField[X, Y] := SquareMine;
    for i := 1 to (BoardSizeX * BoardSizeY - NumMines) do
    begin
    //Keep getting random position until it isn't already empty
      repeat
        X := Random(BoardSizeX) + 1;
        Y := Random(BoardSizeY) + 1;
      until (BoardField[X, Y] <> 0);
      BoardField[X, Y] := 0;
    end;
  end;
  //Count neighbour mines and store in Field
  for X := 1 to BoardSizeX do
    for Y := 1 to BoardSizeY do
      if BoardField[X, Y] <> SquareMine then //Only do so for squares that are not mines
      begin
        //Initialise count
        i := 0;
        //Check all 8 neighbours
        if BoardField[X - 1, Y - 1] = SquareMine then
          Inc(i);
        if BoardField[X, Y - 1] = SquareMine then
          Inc(i);
        if BoardField[X + 1, Y - 1] = SquareMine then
          Inc(i);
        if BoardField[X - 1, Y] = SquareMine then
          Inc(i);
        if BoardField[X + 1, Y] = SquareMine then
          Inc(i);
        if BoardField[X - 1, Y + 1] = SquareMine then
          Inc(i);
        if BoardField[X, Y + 1] = SquareMine then
          Inc(i);
        if BoardField[X + 1, Y + 1] = SquareMine then
          Inc(i);
        //Store count
        BoardField[X, Y] := i;
      end;
  //Set flag as game running
  GameTime := 0;
  GameRunning := True;
  mnuTime.Caption := 'Time=0';
  mnuMines.Caption := 'Mines=' + IntToStr(NumMines);
  NumNotMines := BoardSizeX * BoardSizeY - NumMines;
end;

procedure TfrmMine.EndGame();
var
  X, Y: Byte;
  myINI: TINIFile;
  //High score
  WinnerName: string;
begin
  //Highscore?
  for X := 1 to 10 do
  begin
    if (GameTime < HStime[X]) then
    begin
      //Get name
      WinnerName := InputBox('You''re Winner!', 'You placed #' + IntToStr(X) + ' with your time of ' + IntToStr(GameTime) + '.' + slinebreak + 'Enter your name:', HSname[1]);
      //Shift high scores downwards; If placed 10, skip as we'll simply overwrite last score
      if X < 10 then
        for Y := 10 downto X + 1 do
        begin
          HSname[Y] := HSname[Y - 1];
          HSmines[Y] := HSmines[Y - 1];
          HStime[Y] := HStime[Y - 1];
        end;
      //Set new high score
      HSname[X] := WinnerName;
      HSmines[X] := NumMines;
      HStime[X] := GameTime;
      //Save high scores to INI file
      myINI := TINIFile.Create(ExtractFilePath(Application.EXEName) + 'SliMine.ini');
      for Y := 1 to 10 do
      begin
        myINI.WriteString('HighScores', 'Name' + IntToStr(Y), HSname[Y]);
        myINI.WriteInteger('HighScores', 'Mines' + IntToStr(Y), HSmines[Y]);
        myINI.WriteInteger('HighScores', 'Time' + IntToStr(Y), HStime[Y]);
      end;
      //Close INI file
      myINI.Free;
      //Exit so that we only get 1 high score!
      Exit;
    end;
  end;
  ShowMessage('You win but your time of ' + IntToStr(GameTime) + ' is not a high score.');
end;

procedure TfrmMine.Paint;
//Paint override needed, otherwise won't display game if started from FormCreate
begin
  NewGame();
end;

procedure TfrmMine.mnuExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMine.mnuNewClick(Sender: TObject);
begin
  NewGame();
end;

procedure TfrmMine.mnuOptionsClick(Sender: TObject);
begin
  if frmOptions.visible = false then
    frmOptions.show
  else
    frmOptions.hide;
end;

procedure TfrmMine.mnuScoresClick(Sender: TObject);
begin
  if frmScores.visible = false then
    frmScores.show
  else
    frmScores.hide;
end;

procedure TfrmMine.FormCreate(Sender: TObject);
var
  myINI: TINIFile;
  i: Byte;
begin
  //Initialise options from INI file
  myINI := TINIFile.Create(ExtractFilePath(Application.EXEName) + 'SliMine.ini');
  BoardSizeX := myINI.ReadInteger('Settings', 'BoardSizeX', 16);
  BoardSizeY := myINI.ReadInteger('Settings', 'BoardSizeY', 16);
  NumMines := myINI.ReadInteger('Settings', 'NumMines', 40);
  AllowMarks := myINI.ReadBool('Settings', 'AllowMarks', True);
  //Read high scores from INI file
  for i := 1 to 10 do
  begin
    HSname[i] := myINI.ReadString('HighScores', 'Name' + IntToStr(i), 'Nobody');
    HSmines[i] := myINI.ReadInteger('HighScores', 'Mines' + IntToStr(i), 5);
    HStime[i] := myINI.ReadInteger('HighScores', 'Time' + IntToStr(i), 999);
  end;
  myINI.Free;
  //Initialise shapes images: 0-8: uncovered, 9=blank, 10=flag, 11=maybe
  New(SquarePic[0]);
  SquarePic[0]^ := img0.Picture.Bitmap;
  New(SquarePic[1]);
  SquarePic[1]^ := img1.Picture.Bitmap;
  New(SquarePic[2]);
  SquarePic[2]^ := img2.Picture.Bitmap;
  New(SquarePic[3]);
  SquarePic[3]^ := img3.Picture.Bitmap;
  New(SquarePic[4]);
  SquarePic[4]^ := img4.Picture.Bitmap;
  New(SquarePic[5]);
  SquarePic[5]^ := img5.Picture.Bitmap;
  New(SquarePic[6]);
  SquarePic[6]^ := img6.Picture.Bitmap;
  New(SquarePic[7]);
  SquarePic[7]^ := img7.Picture.Bitmap;
  New(SquarePic[8]);
  SquarePic[8]^ := img8.Picture.Bitmap;
  New(SquarePic[9]);
  SquarePic[9]^ := imgBlank.Picture.Bitmap;
  New(SquarePic[10]);
  SquarePic[10]^ := imgFlag.Picture.Bitmap;
  New(SquarePic[11]);
  SquarePic[11]^ := imgMaybe.Picture.Bitmap;
  New(SquarePic[12]);
  SquarePic[12]^ := imgRight.Picture.Bitmap;
  New(SquarePic[13]);
  SquarePic[13]^ := imgWrong.Picture.Bitmap;
  New(SquarePic[14]);
  SquarePic[14]^ := imgBoom.Picture.Bitmap;
  //Launch a new game
  NewGame;
end;

procedure TfrmMine.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  SquareX, SquareY, TempFlag: Integer; //TempFlag serves dual purpose
begin
  if GameRunning then
  begin
    SquareX := X div SquareSize + 1;
    SquareY := Y div SquareSize + 1;
    tmrGameTime.Enabled := True;
    //If already uncovered, allow middle click only
    if (BoardStatus[SquareX, SquareY] = StatusOpen) then
    begin
      if Button = mbMiddle then
      begin
        //Count flagged neighbours
        TempFlag := 0;
        if BoardStatus[SquareX - 1, SquareY - 1] = StatusFlag then
          Inc(TempFlag);
        if BoardStatus[SquareX, SquareY - 1] = StatusFlag then
          Inc(TempFlag);
        if BoardStatus[SquareX + 1, SquareY - 1] = StatusFlag then
          Inc(TempFlag);
        if BoardStatus[SquareX - 1, SquareY] = StatusFlag then
          Inc(TempFlag);
        if BoardStatus[SquareX + 1, SquareY] = StatusFlag then
          Inc(TempFlag);
        if BoardStatus[SquareX - 1, SquareY + 1] = StatusFlag then
          Inc(TempFlag);
        if BoardStatus[SquareX, SquareY + 1] = StatusFlag then
          Inc(TempFlag);
        if BoardStatus[SquareX + 1, SquareY + 1] = StatusFlag then
          Inc(TempFlag);
        //If flagged as many neighbours as expected, uncover remaining ones
        if BoardField[SquareX, SquareY] = TempFlag then
        begin
          ClickSquare(SquareX - 1, SquareY - 1);
          ClickSquare(SquareX, SquareY - 1);
          ClickSquare(SquareX + 1, SquareY - 1);
          ClickSquare(SquareX - 1, SquareY);
          ClickSquare(SquareX + 1, SquareY);
          ClickSquare(SquareX - 1, SquareY + 1);
          ClickSquare(SquareX, SquareY + 1);
          ClickSquare(SquareX + 1, SquareY + 1);
        end;
      end;
      Exit;
    end;
    //Left click
    if Button = mbLeft then
    begin
      ClickSquare(SquareX, SquareY);
      Exit;
    end
    else if Button = mbRight then
    begin
      //Increase flag value
      TempFlag := BoardStatus[SquareX, SquareY] + 1;
      //Wrap value; check >= as had a bug when cliking both buttons simultaneously!
      if (TempFlag >= StatusOpen) then
        TempFlag := StatusNone;
      if (TempFlag >= StatusMaybe) and not AllowMarks then
        TempFlag := StatusNone;
      //Set value
      BoardStatus[SquareX, SquareY] := TempFlag;
      //Update graphic
      DrawSquare(SquareX, SquareY, 9 + TempFlag);
      //Re-count flagged mines and update counter
      mnuMines.Caption := 'Mines=' + IntToStr(NumMines - MinesFlagged());
    end
  end;
end;

procedure TfrmMine.tmrGameTimeTimer(Sender: TObject);
begin
  //Increment counter
  Inc(GameTime);
  //Update counter
  mnuTime.Caption := 'Time=' + IntToStr(GameTime);
end;

end.

