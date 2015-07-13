unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Math;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    AddressLabel: TLabel;
    AddressBox: TEdit;
    UserLabel: TLabel;
    UserNameBox: TEdit;
    PassworBox: TEdit;
    PasswordLabel: TLabel;
    procedure OnClose(Sender: TObject; var Action: TCloseAction);
    procedure OnCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  NeedInterrupt: boolean;
  cameraOpened: boolean;
  cameraHandle: integer;


implementation

uses LuxandFaceSDK;


{$R *.dfm}

procedure TForm1.OnCreate(Sender: TObject);

begin
  if FSDK_ActivateLibrary(PAnsiChar(AnsiString('Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M=')))<>FSDKE_OK then
  begin
    Application.MessageBox('Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)','Error activating FaceSDK');
    exit;
  end;

  FSDK_Initialize('');

  image1.Canvas.Brush.Style := bsClear;
  image1.Canvas.Pen.Color := clLime;
  image1.Canvas.Pen.Width := 1;

  NeedInterrupt := false;
  cameraOpened := false;
end;

procedure TForm1.OnClose(Sender: TObject; var Action: TCloseAction);
begin
  NeedInterrupt := true;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  bmp1:TBitMap;
  hbitmapHandl:HBitMap; // to store the HBITMAP handle
  imageHandle, ResizedImageHandle: HImage;
  tracker: HTracker;
  errorPosition: integer;
  IDs: TIDArray;
  i: longint;
  faceCount: integer;
  faceCoords: TFacePosition;
  left, top, right, bottom: integer;
  width, height: integer;
  resizeCoeffitient: double;

begin
  if (cameraOpened) and (FSDKE_OK <> FSDK_CloseVideoCamera(cameraHandle)) then
  begin
    Application.MessageBox('Error closing camera','Error');
    FSDK_Finalize;
    halt(2);
  end;

  if FSDKE_OK <> FSDK_OpenIPVideoCamera(FSDK_MJPEG, PAnsiChar(AnsiString(self.AddressBox.Text)), PAnsiChar(AnsiString(self.UserNameBox.Text)),
                                          PAnsiChar(AnsiString(self.PassworBox.Text)), 50, @CameraHandle) then
  begin
    Application.MessageBox('Error opening camera','Error');
    FSDK_Finalize;
    halt(1);
  end;

  if (not CameraOpened) then
  begin
    cameraOpened := true;

    FSDK_CreateTracker(@tracker);
    // set realtime face detection parameters
    FSDK_SetTrackerMultipleParameters(tracker, 'RecognizeFaces=false; HandleArbitraryRotations=false; DetermineFaceRotationAngle=false; InternalResizeWidth=100; FaceDetectionThreshold=5;', @errorPosition);

    faceCount := 0;

    while not NeedInterrupt do
    begin
      if FSDKE_OK <> FSDK_GrabFrame(cameraHandle, @imageHandle) then // grab the current frame from the camera
      begin
        application.ProcessMessages;
        continue;
      end;

      FSDK_FeedFrame(tracker, 0, imageHandle, @faceCount, @IDs, sizeof(int64) * 65536);
      // maximum of 65536 faces detected, see definition of TIDArray in LuxandFaceSDK.pas

      FSDK_GetImageWidth(imageHandle, @width);
      FSDK_GetImageHeight(imageHandle, @height);
      resizeCoeffitient := min(image1.Width/width, image1.Height/height);

      FSDK_CreateEmptyImage(@ResizedImageHandle);
      FSDK_ResizeImage(imageHandle, resizeCoeffitient, ResizedImageHandle);

      FSDK_GetImageWidth(ResizedImageHandle, @width);
      FSDK_GetImageHeight(ResizedImageHandle, @height);

      FSDK_SaveImageToHbitmap(ResizedImageHandle, @hbitmapHandl);

      bmp1 := TBitMap.Create;
      bmp1.Handle := hbitmapHandl;

      // display current frame
      image1.Canvas.Draw((image1.Width - width) div 2, 0, bmp1);
      for i:= 0 to faceCount-1 do
      begin
        FSDK_GetTrackerFacePosition(tracker, 0, IDs[i], @faceCoords);

        left := min(width - 1, max(0, trunc((faceCoords.xc - faceCoords.w div 2) * resizeCoeffitient)))
                    + (image1.Width - width) div 2;
        top := min(height - 1, max(0, trunc((faceCoords.yc - faceCoords.w div 2) * resizeCoeffitient)));
        right := min(width - 1, max(0, trunc((faceCoords.xc + faceCoords.w div 2) * resizeCoeffitient)))
                    + (image1.Width - width) div 2;
        bottom := min(height - 1, max(0, trunc((faceCoords.yc + faceCoords.w div 2) * resizeCoeffitient)));
        image1.Canvas.Rectangle(left, top, right, bottom);
      end;

      bmp1.Free; // delete the TBitMap object
      FSDK_FreeImage(ResizedImageHandle);
      FSDK_FreeImage(imageHandle); // delete the FSDK image handle

      // make UI controls accessible
      application.processmessages;
      sleep(10);
    end;

    FSDK_CloseVideoCamera(cameraHandle);
    FSDK_FreeTracker(tracker);
    FSDK_Finalize;
  end;
end;

end.
