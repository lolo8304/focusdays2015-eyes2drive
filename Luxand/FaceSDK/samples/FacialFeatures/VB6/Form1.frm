VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form Form1 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Facial Features"
   ClientHeight    =   6480
   ClientLeft      =   3525
   ClientTop       =   1815
   ClientWidth     =   8670
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   6480
   ScaleWidth      =   8670
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.PictureBox Picture2 
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      Height          =   495
      Left            =   480
      ScaleHeight     =   435
      ScaleWidth      =   435
      TabIndex        =   2
      Top             =   6000
      Visible         =   0   'False
      Width           =   495
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Open Photo"
      Height          =   375
      Left            =   3830
      TabIndex        =   1
      Top             =   6000
      Width           =   1100
   End
   Begin VB.PictureBox Picture1 
      BorderStyle     =   0  'None
      Height          =   5775
      Left            =   0
      ScaleHeight     =   5775
      ScaleWidth      =   8655
      TabIndex        =   0
      Top             =   0
      Width           =   8655
   End
   Begin MSComDlg.CommonDialog CommonDialog1 
      Left            =   0
      Top             =   6000
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Base 0
Option Explicit

Dim ImageHandle As Long
Dim FaceCoords As TFacePosition
Dim FacialFeatures(FSDK_FACIAL_FEATURE_COUNT - 1) As TPoint


Private Sub Command1_Click()
    CommonDialog1.Filter = "JPEG (*.jpg)|*.jpg|Windows bitmap (*.bmp)|*.bmp|All files|*.*"
    
    CommonDialog1.CancelError = True

    On Error Resume Next
    CommonDialog1.ShowOpen
    If Err.Number = cdlCancel Then
        Exit Sub
    End If
    On Error GoTo 0
    
    Dim fn As String
    fn = CommonDialog1.FileName
       
    If (FSDKVB_LoadImageFromFile(ImageHandle, fn) <> FSDKE_OK) Then
        MsgBox "Error loading file", vbOKOnly, "Error"
    Else
        Picture1.Picture = LoadPicture("")
        Picture1.ScaleMode = 3
        Picture2.ScaleMode = 3
        ' resize image to fit the window width
        Dim imageWidth As Long
        Dim imageHeight As Long
        FSDKVB_GetImageWidth ImageHandle, imageWidth
        FSDKVB_GetImageHeight ImageHandle, imageHeight
        Dim HorRatio As Double
        Dim VerRatio As Double
        Dim ratio As Double
        HorRatio = Picture1.ScaleWidth / imageWidth
        VerRatio = Picture1.ScaleHeight / imageHeight
        If HorRatio < VerRatio Then
            ratio = HorRatio
        Else
            ratio = VerRatio
        End If
        Dim Image2Handle As Long
        FSDKVB_CreateEmptyImage Image2Handle
        FSDKVB_ResizeImage ImageHandle, ratio, Image2Handle
        FSDKVB_CopyImage Image2Handle, ImageHandle
        FSDKVB_FreeImage Image2Handle
        FSDKVB_GetImageWidth ImageHandle, imageWidth
        FSDKVB_GetImageHeight ImageHandle, imageHeight
        
        Picture2.Picture = LoadPicture(fn)
        ' display current frame
        Picture1.PaintPicture Picture2.Picture, 0, 0, imageWidth, imageHeight
        
        If (FSDKVB_DetectFace(ImageHandle, FaceCoords) <> FSDKE_OK) Then
            MsgBox "No faces found"
        Else
            Picture1.Line (FaceCoords.xc - FaceCoords.w / 2, FaceCoords.yc - FaceCoords.w / 2)-(FaceCoords.xc + FaceCoords.w / 2, FaceCoords.yc + FaceCoords.w / 2), vbGreen, B
            FSDKVB_DetectFacialFeatures ImageHandle, FacialFeatures(0)
            Dim i As Integer
            For i = 0 To FSDK_FACIAL_FEATURE_COUNT - 1
                If (i > 1) Then
                    Picture1.Circle (FacialFeatures(i).x, FacialFeatures(i).y), 2, vbGreen
                Else
                    Picture1.Circle (FacialFeatures(i).x, FacialFeatures(i).y), 2, vbBlue
                End If
            Next
        End If
        FSDKVB_FreeImage (ImageHandle) ' delete the FSDK image handle
    End If
End Sub
