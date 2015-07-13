///////////////////////////////////////////////////
//
//        Luxand FaceSDK Library Samples
//
//  Copyright(c) 2005-2013 Luxand Development
//           http://www.luxand.com
//
///////////////////////////////////////////////////

unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, LuxandFaceSDK, StdCtrls, Buttons, ExtCtrls;

type
  TForm1 = class(TForm)
    Panel2: TPanel;
    btnLoadImage: TButton;
    imgSource: TImage;
    OpenDialog1: TOpenDialog;
    procedure btnLoadImageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses math;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  if FSDK_ActivateLibrary(PAnsiChar(AnsiString('Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M=')))<>FSDKE_OK then
  begin
    Application.MessageBox('Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)','Error activating FaceSDK');
    halt;
  end;
  FSDK_Initialize('');
  FSDK_SetFaceDetectionParameters(true, true, 256);
end;

procedure TForm1.btnLoadImageClick(Sender: TObject);
var
  i:integer;
  imageHandle, image2Handle: integer;
  hbitmapHandle: integer; // to store the HBITMAP handle
  frameImage: TBitMap;
  FacePosition: TFacePosition;
  FacialFeatures: FSDK_Features;
  left, top, right, bottom: integer;
  imageWidth, imageHeight: integer;
  ratio: double;

begin
  if OpenDialog1.Execute then
  begin
    if FSDK_LoadImageFromFile(@ImageHandle, PAnsiChar(AnsiString(OpenDialog1.FileName))) <> FSDKE_OK then
      Application.MessageBox('Error loading file', 'Error')
    else
    begin
      // resize image to fit the window width
      FSDK_GetImageWidth(imageHandle, @imageWidth);
      FSDK_GetImageHeight(imageHandle, @imageHeight);
      ratio := Min((imgSource.Width + 0.4) / imageWidth, (imgSource.Height + 0.4) / imageHeight);
      FSDK_CreateEmptyImage(@image2Handle);
      FSDK_ResizeImage(imageHandle, ratio, image2Handle);
      FSDK_CopyImage(image2Handle, imageHandle);
      FSDK_FreeImage(image2Handle);
      // save image into HBITMAP handle
      if FSDK_SaveImageToHBitmap(ImageHandle, @hbitmapHandle) <> FSDKE_OK then
        Application.MessageBox('Error displaying picture', 'Error')
      else
      begin
        frameImage := TBitMap.Create;
        frameImage.Handle := hbitmapHandle;
        // display current frame
        imgSource.Picture.Assign(frameImage);
        Application.ProcessMessages;
        if FSDK_DetectFace(ImageHandle, @FacePosition) <> FSDKE_OK then
          Application.MessageBox('Error detecting face', 'Error' )
        else
        begin
          left := FacePosition.xc - round(FacePosition.w*0.6);
          top := FacePosition.yc - round(FacePosition.w*0.5);
          right := FacePosition.xc + round(FacePosition.w*0.6);
          bottom := FacePosition.yc + round(FacePosition.w*0.7);

          imgSource.Canvas.Brush.Style := bsClear;
          imgSource.Canvas.Pen.Color := clLime;
          imgSource.Canvas.Rectangle(left, top, right, bottom);
          Application.ProcessMessages;

          FSDK_DetectFacialFeaturesinRegion(ImageHandle, @FacePosition, @FacialFeatures);
          for i := 2 to FSDK_FACIAL_FEATURE_COUNT - 1 do
            imgSource.Canvas.Ellipse(FacialFeatures[i].x - 2, FacialFeatures[i].y - 2, FacialFeatures[i].x + 2, FacialFeatures[i].y + 2);
          imgSource.Canvas.Pen.Color := clBlue;
          for i := 0 to 1 do
            imgSource.Canvas.Ellipse(FacialFeatures[i].x - 2, FacialFeatures[i].y - 2, FacialFeatures[i].x + 2, FacialFeatures[i].y + 2);
        end;
        frameImage.Free; // delete the TBitMap object
      end;
      FSDK_FreeImage(ImageHandle); // delete the FSDK image handle
    end;
  end;
end;
end.
