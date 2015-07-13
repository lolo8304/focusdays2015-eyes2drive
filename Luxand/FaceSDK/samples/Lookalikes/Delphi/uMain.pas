///////////////////////////////////////////////////
//
//        Luxand FaceSDK Library Samples
//
//  Copyright(c) 2005-2011 Luxand Development
//           http://www.luxand.com
//
///////////////////////////////////////////////////

unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, LuxandFaceSDK, StdCtrls, Buttons, ExtCtrls, jpeg, Menus,
  ComCtrls;

type
  TMainForm = class(TForm)
    LogMemo: TMemo;
    OpenDialog1: TOpenDialog;
    mnuMainMenu: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    EnrollPictures1: TMenuItem;
    MatchPictures1: TMenuItem;
    N1: TMenuItem;
    Options1: TMenuItem;
    Options2: TMenuItem;
    N2: TMenuItem;
    ClearDatabase1: TMenuItem;
    pnlSourceImage: TPanel;
    pnlFaceList: TPanel;
    imgSource: TImage;
    lbFaceList: TListBox;
    OpenDialogMulti: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Options2Click(Sender: TObject);
    procedure lbFaceListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbFaceListClick(Sender: TObject);
    procedure EnrollPictures1Click(Sender: TObject);
    procedure ClearDatabase1Click(Sender: TObject);
    procedure MatchPictures1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FaceDetectionThreshold: integer;
    FARValue: integer;

    procedure EnrollPicture(FileName: string);
    procedure RedrawCurrentImage;
  end;

type
  TFaceRecord = record
    Template: FSDK_FaceTemplate; //Face Template;
    FacePosition: TFacePosition;
    FacialFeatures: FSDK_Features; //Facial Features;

    ImageFileName: string;
    ImageHandle: HImage; // FSDK Image Handle
    ImageBmp: TBitMap; //TBitMap

    FaceImageHandle: HImage;
    FaceImageBmp: TBitMap;
  end;

const
  FacePreviewWidth = 96;

var
  MainForm: TMainForm;
  FaceList: array of TFaceRecord;

implementation

uses uOptions, math, uResults;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin

  LogMemo.Lines.Add('Initializing Luxand FaceSDK...');

  if FSDK_ActivateLibrary(PAnsiChar(AnsiString('Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M=')))<>FSDKE_OK then
  begin
    Application.MessageBox('Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)','Error activating FaceSDK');
    exit;
  end;

  FSDK_Initialize('');

  LogMemo.Lines.Add('Initialized');

  lbFaceList.ItemHeight := FacePreviewWidth + 8 + 28;

  FaceDetectionThreshold := 3;
  FARValue := 100;

  FaceList := nil;
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
    MessageBox(Handle, 'Luxand Face Recognition Demo' + #10#10 + '© 2010 Luxand, Inc. ' + #10 + 'http://www.luxand.com', 'About', mb_OK);
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
    Close;
end;

procedure TMainForm.Options2Click(Sender: TObject);
begin
    frmOptions.udFAR.Position := FARValue;
    frmOptions.udMinimalFaceQuality.Position := FaceDetectionThreshold;
    frmOptions.ShowModal;
    FARValue := frmOptions.udFAR.Position;
    FaceDetectionThreshold := frmOptions.udMinimalFaceQuality.Position;
end;

procedure TMainForm.lbFaceListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  BrushColor, PenColor: integer;
begin
  BrushColor := lbFaceList.Canvas.Brush.Color;
  PenColor := lbFaceList.Canvas.Pen.Color;

  lbFaceList.Canvas.Brush.Style := bsSolid;
  lbFaceList.Canvas.Brush.Color := clWhite;
  lbFaceList.Canvas.Pen.Color := clWhite;
  lbFaceList.Canvas.Rectangle(Rect);

  if FaceList[Index].FaceImageBmp <> nil then
    lbFaceList.Canvas.Draw(Rect.Left + 16, Rect.Top + 8, FaceList[Index].FaceImageBmp);

  lbFaceList.Canvas.TextOut(Rect.Left + 16 + FacePreviewWidth div 2 - lbFaceList.Canvas.TextWidth(lbFaceList.Items[Index]) div 2,
    Rect.Top + FacePreviewWidth + 8 + 8, lbFaceList.Items[Index]);

  lbFaceList.Canvas.Brush.Color := BrushColor;
  lbFaceList.Canvas.Pen.Color := PenColor;
end;

procedure TMainForm.lbFaceListClick(Sender: TObject);
begin
  RedrawCurrentImage;
end;

procedure TMainForm.RedrawCurrentImage;
var
  i: integer;
  left, top, right, bottom: integer;
begin
  if (lbFaceList.ItemIndex >= 0) and (lbFaceList.ItemIndex < length(FaceList)) then
  begin
    imgSource.Picture.Assign(FaceList[lbFaceList.ItemIndex].ImageBmp);

    imgSource.Canvas.Brush.Style := bsClear;
    imgSource.Canvas.Pen.Color := clLime;

    // Draw face position
    with FaceList[lbFaceList.ItemIndex].FacePosition do
      if w <> 0 then // If detected
      begin
        left := xc - w div 2;
        top := yc - w div 2;
        right := xc + w div 2;
        bottom := yc + w div 2;

        imgSource.Canvas.Rectangle(left, top, right, bottom);
      end;

    // Draw facial feature positions
    with FaceList[lbFaceList.ItemIndex] do
      if (FacialFeatures[0].x <> 0) and (FacialFeatures[1].x <> 0) then // If detected
        for i := 0 to 1 do
        begin
          imgSource.Canvas.Pen.Color := clBlue; // Eyes

          imgSource.Canvas.Ellipse(FacialFeatures[i].x - 2, FacialFeatures[i].y - 2,
            FacialFeatures[i].x + 2, FacialFeatures[i].y + 2);
        end;
  end
  else
    imgSource.Picture.Assign(nil);

end;

procedure TMainForm.EnrollPicture(FileName: string);
var
  hbitmapHandle: integer;
  imageHandle: integer;
  r: integer;
  k: integer;
  w: integer;
  imageWidth, imageHeight: integer;
  ratio: double;
begin
  k := length(FaceList);
  setlength(FaceList, k+1);
  FillChar(FaceList[k], SizeOf(FaceList[k]), 0); //NEW

  r := FSDK_LoadImageFromFile(@ImageHandle, PAnsiChar(AnsiString(FileName)));
  if r <> FSDKE_OK then
    Application.MessageBox('Error loading file', 'Error')
  else
  begin
    LogMemo.Lines.Add('Enrolling ' +  ExtractFileName(FileName));
    FSDK_GetImageWidth(imageHandle, @imageWidth);
    FSDK_GetImageHeight(imageHandle, @imageHeight);
    ratio := Min((imgSource.Width + 0.4) / imageWidth, (imgSource.Height + 0.4) / imageHeight);
    FSDK_CreateEmptyImage(@FaceList[k].imageHandle);
    FSDK_ResizeImage(imageHandle, ratio, FaceList[k].ImageHandle);
    FSDK_FreeImage(imageHandle);
    FSDK_SaveImageToHBitmap(FaceList[k].ImageHandle, @hbitmapHandle);

    FaceList[k].ImageBmp := TBitMap.Create;
    FaceList[k].ImageBmp.Handle := hbitmapHandle;
    FaceList[k].ImageFileName := FileName;

    lbFaceList.Items.Add(ExtractFileName(FileName));
    lbFaceList.ItemIndex := k;

    RedrawCurrentImage;
    Application.processmessages;

    //Assuming that faces are always vertical (HandleArbitraryRotations = false) to speed up face detection
    FSDK_SetFaceDetectionParameters(false, true, 384);
    FSDK_SetFaceDetectionThreshold(FaceDetectionThreshold);

    r := FSDK_DetectFace(FaceList[k].ImageHandle, @FaceList[k].FacePosition);

    if r <> FSDKE_OK then
    begin
      if OpenDialogMulti.Files.Count <= 1 then
        Application.MessageBox('No faces found. Try to lower the Minimal Face Quality parameter in the Options dialog box.', 'Enrollment error')
      else
        LogMemo.Lines.Add(ExtractFileName(FileName) + ': No faces found. Try to lower the Minimal Face Quality parameter in the Options dialog box.')
    end
    else
    begin
      RedrawCurrentImage;
      Application.processmessages;

      // extract face area
      FSDK_CreateEmptyImage(@ImageHandle);
      with FaceList[k].FacePosition do
        FSDK_CopyRect(FaceList[k].ImageHandle, xc - round(w*0.5), yc - round(w*0.5), xc + round(w*0.5), yc + round(w*0.5), ImageHandle);
      FSDK_GetImageWidth(ImageHandle, @w);
      FSDK_CreateEmptyImage(@FaceList[k].FaceImageHandle);
      FSDK_ResizeImage(ImageHandle, FacePreviewWidth/w, FaceList[k].FaceImageHandle);
      FSDK_SaveImageToHBitmap(FaceList[k].FaceImageHandle, @hbitmapHandle);
      FSDK_FreeImage(ImageHandle);

      FSDK_FreeImage(FaceList[k].FaceImageHandle);

      FaceList[k].FaceImageBmp := TBitMap.Create;
      FaceList[k].FaceImageBmp.Handle := hbitmapHandle;
      // redraw list
      lbFaceList.Repaint;

      r := FSDK_DetectEyesInRegion(FaceList[k].ImageHandle, @FaceList[k].FacePosition, @FaceList[k].FacialFeatures);
      if r <> FSDKE_OK then
        Application.MessageBox('Error detection facial features.', 'Error' )
      else
      begin
        RedrawCurrentImage;
        Application.processmessages;

        r := FSDK_GetFaceTemplateInRegion(FaceList[k].ImageHandle, @FaceList[k].FacePosition, @FaceList[k].Template);
        if r <> FSDKE_OK then
          Application.MessageBox('Error retrieving face template.', 'Error' );
      end;
    end;
  end;

  if r <> FSDKE_OK then
  begin
    // Delete the added image
    if FaceList[k].ImageBmp <> nil then
    begin
      FSDK_FreeImage(FaceList[k].ImageHandle); // Free the loaded image
      FaceList[k].ImageBmp.Free; // Free the created Bitmap
    end;
    if FaceList[k].FaceImageBmp <> nil then
    begin
      FaceList[k].FaceImageBmp.Free;
      FSDK_FreeImage(FaceList[k].FaceImageHandle);
    end;

    lbFaceList.Items.Delete(lbFaceList.ItemIndex); // Delete the list element
    SetLength(FaceList, k); // Delete the last element
    lbFaceList.ItemIndex := k-1;

    RedrawCurrentImage;
    exit;
  end;

  LogMemo.Lines.Add('File ' +  ExtractFileName(FileName) +
    ' enrolled'); //  Template size: ' + IntTostr(SizeOf(FaceList[k].Template)) + ' bytes');
end;

procedure TMainForm.EnrollPictures1Click(Sender: TObject);
var
  i: integer;
begin
  try
    if OpenDialogMulti.Execute then
      for i := 0 to OpenDialogMulti.Files.Count - 1 do
      begin
        Enabled := false;
        EnrollPicture(OpenDialogMulti.Files[i]);
        Application.processmessages;
        Enabled := true;
      end;
  finally
  end;
end;

procedure TMainForm.ClearDatabase1Click(Sender: TObject);
var
  k: integer;
begin
  for k := 0 to length(FaceList) - 1 do
  begin
    FSDK_FreeImage(FaceList[k].ImageHandle); // Free the loaded image
    FaceList[k].ImageBmp.Free; // Free the created Bitmap

    if FaceList[k].FaceImageBmp <> nil then
    begin
      FaceList[k].FaceImageBmp.Free;
      FSDK_FreeImage(FaceList[k].FaceImageHandle);
    end;
  end;

  lbFaceList.Items.Clear;
  SetLength(FaceList, 0); // Delete the last element

  RedrawCurrentImage;
end;

procedure TMainForm.MatchPictures1Click(Sender: TObject);
var
  hbitmapHandle: integer;
  image2Handle: integer;
  imageWidth, imageHeight: integer;
  ratio: double;
begin
  if length(FaceList) = 0 then
  begin
      Application.MessageBox('Please enroll faces first', 'Error');
      exit;
  end;

  if OpenDialog1.Execute then
  begin
    FillChar(frmSearchResults.Face, SizeOf(frmSearchResults.Face), 0); //NEW
    with frmSearchResults.Face do
    begin
      if FSDK_LoadImageFromFile(@ImageHandle, PAnsiChar(AnsiString(OpenDialog1.FileName))) <> FSDKE_OK then
      begin
        Application.MessageBox('Error loading file', 'Error');
        exit;
      end
      else
      begin
        FSDK_GetImageWidth(imageHandle, @imageWidth);
        FSDK_GetImageHeight(imageHandle, @imageHeight);
        ratio := Min((frmSearchResults.imgSource.Width + 0.4) / imageWidth, (frmSearchResults.imgSource.Height + 0.4) / imageHeight);
        FSDK_CreateEmptyImage(@image2Handle);
        FSDK_ResizeImage(imageHandle, ratio, image2Handle);
        FSDK_CopyImage(image2Handle, imageHandle);
        FSDK_FreeImage(image2Handle);
        FSDK_SaveImageToHBitmap(ImageHandle, @hbitmapHandle);
        ImageBmp := TBitMap.Create;
        ImageBmp.Handle := hbitmapHandle;

        FSDK_SetFaceDetectionParameters(false, true, 384);
        FSDK_SetFaceDetectionThreshold(MainForm.FaceDetectionThreshold);
        if FSDK_DetectFace(ImageHandle, @FacePosition) <> FSDKE_OK then
          Application.MessageBox('No faces found. Try to lower the Minimal Face Quality parameter in the Options dialog box.', 'Enrollment error' )
        else
          if FSDK_DetectEyesInRegion(ImageHandle, @FacePosition, @FacialFeatures) <> FSDKE_OK then
            Application.MessageBox('Error detection facial features.', 'Error' )
          else
            if FSDK_GetFaceTemplateInRegion(ImageHandle, @FacePosition, @Template) <> FSDKE_OK then
              Application.MessageBox('Error retrieving face template.', 'Error' )
            else
              frmSearchResults.ShowModal;
      end;
    end;

    FSDK_FreeImage(frmSearchResults.Face.ImageHandle); // Free the loaded image
    frmSearchResults.Face.ImageBmp.Free; // Free the created Bitmap
  end;
end;

end.
