unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, LuxandFaceSDK;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure OnClose(Sender: TObject; var Action: TCloseAction);
    procedure OnCreate(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  // program states: waiting for the user to click 'Remember Me', storing the user's template,
  // and recognizing user's face
  ProgramStates = (psNormal, psRemember, psRecognize);

var
  Form1: TForm1;
  NeedInterrupt: boolean;
  cameraHandle: integer;
  programState: ProgramStates;
  mouseX, mouseY: integer;

const
  TrackerMemoryFile: string = 'tracker.dat';

implementation

{$R *.dfm}

procedure TForm1.OnCreate(Sender: TObject);
var
  CameraList: PFSDK_CameraList;
  CameraCount: integer;
  VideoFormatList: PFSDK_VideoFormatInfoArray;
  VideoFormatCount: integer;
begin
  if FSDK_ActivateLibrary(PAnsiChar(AnsiString('Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M=')))<>FSDKE_OK then
  begin
    Application.MessageBox('Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)','Error activating FaceSDK');
    exit;
  end;
	FSDK_Initialize('');
  FSDK_InitializeCapturing();

  CameraList := nil;
  FSDK_GetCameraList(@CameraList, @CameraCount);
	VideoFormatList := nil;
	VideoFormatCount := 0;
	FSDK_GetVideoFormatList(CameraList[0], @VideoFormatList, @VideoFormatCount);

  image1.Height := VideoFormatList[0].Height;
  image1.Width := VideoFormatList[0].Width;
  image1.Canvas.Brush.Style := bsClear;
  image1.Canvas.Pen.Color := clLime;
  image1.Canvas.Pen.Width := 1;

  self.Width := image1.Width+30;
  self.Height := image1.Height+120;

  button1.Left := (self.Width div 2)-40;
  button1.Width := 80;
  button1.Top := self.Height-75;
  button1.Height := 25;

  label1.Left := (self.Width div 2)-100;
  label1.Width := 200;
  label1.Top := self.Height-100;
  label1.Height := 25;

  mouseX := 0;
  mouseY := 0;

  FSDK_SetVideoFormat(CameraList[0], VideoFormatList[0]);
	if (FSDK_OpenVideoCamera(CameraList[0], @cameraHandle) < 0) then
  begin
    Application.MessageBox('Error opening camera','Error');
    FSDK_Finalize;
    Application.Terminate;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  bmp1:TBitMap;
  hbitmapHandl:HBitMap; // to store the HBITMAP handle
  imageHandle: HImage;
  faceCoords: TFacePosition;
  left, top, right, bottom, w: integer;
  r: integer;
  Template: FSDK_FaceTemplate;
  k: integer;
  userName: array[0..1023] of char;
  i: integer;
  threshold, similarity: Single;
  match: bool;
  TextWidth: integer;

  faceCount: integer;
  tracker: integer;
  err: integer;
  IDs: array[0..255] of int64;
  res: integer;
  inputName: string;

begin
  button1.Enabled := false;
  NeedInterrupt := false;
  programState:= psNormal;

  tracker := 0;
  if (FSDKE_OK <> FSDK_LoadTrackerMemoryFromFile(@tracker, PAnsiChar(TrackerMemoryFile))) then // try to load saved tracker state
    FSDK_CreateTracker(@tracker);

  err := 0; // set realtime face detection parameters
  FSDK_SetTrackerMultipleParameters(tracker, 'HandleArbitraryRotations=false; DetermineFaceRotationAngle=false; InternalResizeWidth=100; FaceDetectionThreshold=5;', @err);

  while not NeedInterrupt do
  begin
    if (FSDKE_OK <>FSDK_GrabFrame(cameraHandle, @imageHandle)) then // grab the current frame from the camera
    begin
      application.ProcessMessages;
      continue;
    end;

		faceCount := 0;
    FSDK_FeedFrame(tracker, 0, imageHandle, @faceCount, @IDs, sizeof(IDs)); // maximum 256 faces detected

    FSDK_SaveImageToHbitmap(imageHandle, @hbitmapHandl);

    bmp1 := TBitMap.Create;
    bmp1.Handle := hbitmapHandl;

    // display current frame
    image1.Canvas.Draw(0, 0, bmp1);
    for i:= 0 to faceCount-1 do
    begin
      FSDK_GetTrackerFacePosition(tracker, 0, IDs[i], @faceCoords);

      left := faceCoords.xc - round(faceCoords.w*0.6);
      top := faceCoords.yc - round(faceCoords.w*0.5);
      right := faceCoords.xc + round(faceCoords.w*0.6);
      bottom := faceCoords.yc + round(faceCoords.w*0.7);
      w := round(faceCoords.w * 1.2);

      res := FSDK_GetAllNames(tracker, IDs[i], @userName, sizeof(userName)); // maximum of 65536 characters
      if (FSDKE_OK = res) and (length(string(userName)) > 0) then
      begin // draw name
        image1.Canvas.Font.Color := clLime;
        image1.Canvas.Font.Size := 20;
        image1.Canvas.Font.Name := 'Arial';
        TextWidth := image1.Canvas.TextWidth(userName);
        image1.Canvas.TextOut((left+right-TextWidth) div 2, bottom, userName);
      end;

      image1.Canvas.Pen.Color := clLime;
      if ((mouseX >= left) and (mouseX <= left + w) and (mouseY >= top) and (mouseY <= top + w)) then
      begin
        image1.Canvas.Pen.Color := clBlue;
        if (psRemember = programState) then
        begin
            if (FSDKE_OK = FSDK_LockID(tracker, IDs[i])) then
            begin
                // get the user name
                if (InputQuery('Enter your name', 'Your name:', inputName)) then
                begin
                    FSDK_SetName(tracker, IDs[i], PAnsiChar(inputName));
                    FSDK_UnlockID(tracker, IDs[i]);
                end;
            end;
        end;
      end;
      image1.Canvas.Rectangle(left, top, right, bottom);
    end;
    programState := psRecognize;

    // make UI controls accessible
    application.processmessages;

    bmp1.Free; // delete the TBitMap object
    FSDK_FreeImage(imageHandle); // delete the FSDK image handle
  end;

  FSDK_CloseVideoCamera(cameraHandle);
  FSDK_SaveTrackerMemoryToFile(tracker, PAnsiChar(TrackerMemoryFile));
  FSDK_FreeTracker(tracker);
  FSDK_Finalize;
end;

procedure TForm1.OnClose(Sender: TObject; var Action: TCloseAction);
begin
  NeedInterrupt := true;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  programState := psRemember;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  mouseX := X;
  mouseY := Y;
end;

end.
