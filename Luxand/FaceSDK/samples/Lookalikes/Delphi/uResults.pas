unit uResults;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls, uMain;

type
  TfrmSearchResults = class(TForm)
    grdMatchingResult: TDrawGrid;
    btnOK: TButton;
    imgSource: TImage;
    lblFacesMatched: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure grdMatchingResultDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
    Face: TFaceRecord;
    FormActive: boolean;

    ResultList: array of integer;
    SimilarityValues: array of Single;
  end;

var
  frmSearchResults: TfrmSearchResults;

implementation

uses LuxandFaceSDK, math;

{$R *.dfm}

procedure SortList(var List: array of integer; var Scores: array of Single; l, r: integer);
var
    i, j: integer;
    x: Single;
    c: Integer;
    t: Single;
begin
    i := l;
    j := r;
    x := Scores[(i + j) div 2];
    repeat
        while Scores[i] > x do inc(i);
        while Scores[j] < x do dec(j);
        if i <= j then
        begin
            c := List[i];
            List[i] := List[j];
            List[j] := c;

            t := Scores[i];
            Scores[i] := Scores[j];
            Scores[j] := t;

            inc(i);
            dec(j);
        end;
    until i>j;
    if j > l then SortList(List, Scores, l, j);
    if i < r then SortList(List, Scores, i, r);
end;


procedure TfrmSearchResults.FormActivate(Sender: TObject);
var
  ratio: double;
  ImageWidth, ImageHeight: integer;
  i, k: integer;
  left, top, right, bottom: integer;

  Threshold: Single;
  Similarity: single;
  Rect1: TGridRect;
begin
  imgSource.Picture.Assign(nil);

  ResultList := nil;
  SimilarityValues := nil;

  grdMatchingResult.ColCount := 1;
  grdMatchingResult.DefaultColWidth := FacePreviewWidth + 32;
  grdMatchingResult.DefaultRowHeight := FacePreviewWidth + 8 + 28 + 16;

  Rect1.Left := 0;
  Rect1.Top := 0;
  grdMatchingResult.Selection := Rect1;

  grdMatchingResult.Invalidate;
  Application.ProcessMessages;

  FSDK_GetImageWidth(Face.ImageHandle, @ImageWidth);
  FSDK_GetImageHeight(Face.ImageHandle, @ImageHeight);
  ratio := min(imgSource.Width/ImageWidth, imgSource.Height/ImageHeight);

  imgSource.Left := (ClientWidth - round(ImageWidth * ratio)) div 2;

  imgSource.Picture.Assign(Face.ImageBmp);

  imgSource.Canvas.Brush.Style := bsClear;
  imgSource.Canvas.Pen.Color := clLime;

  // Draw face position
  with Face.FacePosition do
    if w <> 0 then // If detected
    begin
      left := xc - w div 2;
      top := yc - w div 2;
      right := xc + w div 2;
      bottom := yc + w div 2;
      imgSource.Canvas.Rectangle(left, top, right, bottom);
    end;

  with Face do
    if (FacialFeatures[0].x <> 0) and (FacialFeatures[1].x <> 0) then // If detected
      for i := 0 to 1 do
      begin
        imgSource.Canvas.Pen.Color := clBlue; // Eyes
        imgSource.Canvas.Ellipse(FacialFeatures[i].x - 2, FacialFeatures[i].y - 2,
          FacialFeatures[i].x + 2, FacialFeatures[i].y + 2);
      end;
  Application.processmessages;

  // Match faces
  FSDK_GetMatchingThresholdAtFAR(MainForm.FARValue/100, @Threshold); // 0.02 False Acceptance Rate

  for i := 0 to length(FaceList) - 1 do
  begin
    FSDK_MatchFaces(@Face.Template, @FaceList[i].Template, @Similarity);
    if Similarity >= Threshold then
    begin
      k := length(ResultList);
      setlength(ResultList, k + 1);
      setlength(SimilarityValues, k + 1);
      ResultList[k] := i;
      SimilarityValues[k] := Similarity;
    end;
  end;

  lblFacesMatched.Caption := 'Faces Matched: ' + IntToStr(length(ResultList));

  if length(ResultList) = 0 then
    Application.MessageBox('No matches found. You can try to increase the FAR parameter in the Options dialog box.', 'No matches', mb_OK)
  else
    SortList(ResultList, SimilarityValues, 0, length(ResultList) - 1);

  // Add items
  grdMatchingResult.ColCount := length(ResultList);

  grdMatchingResult.Invalidate;
end;

procedure TfrmSearchResults.grdMatchingResultDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  s: string;
begin
  grdMatchingResult.Canvas.Brush.Style := bsSolid;
  grdMatchingResult.Canvas.Brush.Color := clWhite;
  grdMatchingResult.Canvas.Pen.Color := clWhite;
  grdMatchingResult.Canvas.Rectangle(Rect);

  if ACol >= length(ResultList) then
    exit;

  if FaceList[ResultList[ACol]].FaceImageBmp <> nil then
    grdMatchingResult.Canvas.Draw(Rect.Left + 16, Rect.Top + 8, FaceList[ResultList[ACol]].FaceImageBmp);

  s := MainForm.lbFaceList.Items[ResultList[ACol]];
  grdMatchingResult.Canvas.TextOut(Rect.Left + 16 + FacePreviewWidth div 2 - grdMatchingResult.Canvas.TextWidth(s) div 2,
    Rect.Top + FacePreviewWidth + 8 + 8, s);

  s := 'Similarity = ' + FloatToStrF(SimilarityValues[ACol]*100, ffFixed, 3, 2);
  grdMatchingResult.Canvas.TextOut(Rect.Left + 16 + FacePreviewWidth div 2 - grdMatchingResult.Canvas.TextWidth(s) div 2,
    Rect.Top + FacePreviewWidth + 8 + 8 + 16, s);
end;

end.
