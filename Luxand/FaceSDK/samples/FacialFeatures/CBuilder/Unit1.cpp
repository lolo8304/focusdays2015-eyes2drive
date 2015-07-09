//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
#include <math.h>
#include <string.h>
#include "LuxandFaceSDK.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------


void __fastcall TForm1::FormActivate(TObject *Sender)
{
        if (FSDK_ActivateLibrary("Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M=") != FSDKE_OK)
        {
                Application->MessageBox("Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)", "Error activating FaceSDK", 0);
                Application->Terminate();
        }
        FSDK_Initialize("") != FSDKE_OK;
        FSDK_SetFaceDetectionParameters(true, true, 384);
}
//---------------------------------------------------------------------------





void __fastcall TForm1::Button1Click(TObject *Sender)
{
        OpenDialog1->Filter = "JPEG (*.jpg)|*.jpg|Windows bitmap (*.bmp)|*.bmp|All files|*.*";
        if( OpenDialog1->Execute() == True ){
                HImage imageHandle;
                if (FSDK_LoadImageFromFile(&imageHandle, OpenDialog1->FileName.c_str()) != FSDKE_OK)
                        Application->MessageBox("Error loading image", "Error", 0);
                else
                {
                        // resize image to fit the window width
                        int imageWidth;
                        int imageHeight;
                        FSDK_GetImageWidth(imageHandle, &imageWidth);
                        FSDK_GetImageHeight(imageHandle, &imageHeight);
                        double HorRatio = (double)Image1->Width/imageWidth;
                        double VerRatio = (double)Image1->Height/imageHeight;
                        double ratio = (HorRatio < VerRatio) ? HorRatio : VerRatio;
                        HImage image2Handle;
                        FSDK_CreateEmptyImage(&image2Handle);
                        FSDK_ResizeImage(imageHandle, ratio, image2Handle);
                        FSDK_CopyImage(image2Handle, imageHandle);
                        FSDK_FreeImage(image2Handle);

                        HBITMAP hbitmapHandle; // to store the HBITMAP handle
                        // save image into HBITMAP handle
                        FSDK_SaveImageToHBitmap(imageHandle, &hbitmapHandle);

                        Graphics::TBitmap *tpic = new Graphics::TBitmap;
                        tpic->Handle = hbitmapHandle;
                        // display current frame
                        Image1->Picture->Assign(tpic);
                        delete tpic;
                        Application->ProcessMessages();

                        TFacePosition facePosition;
                        if (FSDK_DetectFace(imageHandle, &facePosition) != FSDKE_OK)
                                MessageBox(this->Handle, "No faces detected", "Face Detection", 0);
                        else
                        {
                                int left = facePosition.xc - facePosition.w /2;
                                int top = facePosition.yc - facePosition.w /2;
                                int right = facePosition.xc + facePosition.w /2;
                                int bottom = facePosition.yc + facePosition.w /2;

                                Image1->Canvas->Brush->Style = bsClear;
                                Image1->Canvas->Pen->Color = clLime;
                                Image1->Canvas->Pen->Width = 1;
                                Image1->Canvas->Rectangle(left, top, right, bottom);
                                Application->ProcessMessages();
                                FSDK_Features facialFeatures;
                                FSDK_DetectFacialFeatures(imageHandle, &facialFeatures);

                                for (int i = 2; i < FSDK_FACIAL_FEATURE_COUNT; i++)
                                        Image1->Canvas->Ellipse(facialFeatures[i].x - 2, facialFeatures[i].y - 2,
                                                                facialFeatures[i].x + 2, facialFeatures[i].y + 2);
                                Image1->Canvas->Pen->Color = clBlue;
                                for (int i = 0; i < 2; i++)
                                        Image1->Canvas->Ellipse(facialFeatures[i].x - 2, facialFeatures[i].y - 2, facialFeatures[i].x + 2, facialFeatures[i].y + 2);
                        }
                        FSDK_FreeImage(imageHandle); // delete the FSDK image handle
                }
        }
}
//---------------------------------------------------------------------------

