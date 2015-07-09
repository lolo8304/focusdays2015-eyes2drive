VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Face Tracking"
   ClientHeight    =   4920
   ClientLeft      =   165
   ClientTop       =   450
   ClientWidth     =   5310
   LinkTopic       =   "Form1"
   ScaleHeight     =   328
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   354
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command1 
      Caption         =   "Start"
      Height          =   375
      Left            =   1920
      TabIndex        =   1
      Top             =   4440
      Width           =   1215
   End
   Begin VB.PictureBox Picture1 
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BorderStyle     =   0  'None
      Height          =   4095
      Left            =   360
      ScaleHeight     =   273
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   305
      TabIndex        =   0
      Top             =   120
      Width           =   4575
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Base 0
Option Explicit

Dim cameraName
Dim needClose

' WinAPI procedure to release HBITMAP handles returned by FSDKVB_GrabFrame
Private Declare Function DeleteObject Lib "gdi32" (ByVal hObject As Long) As Long


Private Sub Command1_Click()
    Command1.Enabled = False
    Dim cameraHandle
    
    Dim r As Integer
    r = FSDKVB_OpenVideoCamera(cameraName, cameraHandle)
    If (r <> FSDKE_OK) Then
        MsgBox "Error opening the first camera", vbCritical, "Error"
        Unload Me
        Exit Sub
    End If
        
    Dim Tracker As Long
    FSDKVB_CreateTracker (Tracker)

    Dim err As Long ' set realtime face detection parameters
    FSDKVB_SetTrackerMultipleParameters Tracker, "RecognizeFaces=false; HandleArbitraryRotations=false; DetermineFaceRotationAngle=false; InternalResizeWidth=100; FaceDetectionThreshold=5;", err
            
    While Not needClose
        Dim imageHandle As Long
        If (FSDKVB_GrabFrame(cameraHandle, imageHandle) <> FSDKE_OK) Then  ' grab the current frame from the camera
            DoEvents
        Else
            Dim IDs() As Currency
            ReDim IDs(0 To 256)
            Dim FaceCount As Currency
            FaceCount = 0
            Dim sizeOfCurrency
            sizeOfCurrency = 8
            FSDKVB_FeedFrame Tracker, 0, imageHandle, FaceCount, IDs(0), sizeOfCurrency * 256 ' maximum 256 faces detected
        
            Dim hbitmapHandle As Long ' to store the HBITMAP handle
            FSDKVB_SaveImageToHBitmap imageHandle, hbitmapHandle
                
            ' display current frame
            FSDKVB_Paint Picture1.hDC, hbitmapHandle
        
            Dim i As Integer
            For i = 0 To FaceCount - 1
                Dim facePosition As TFacePosition
                FSDKVB_GetTrackerFacePosition Tracker, 0, IDs(i), facePosition
                
                Dim left As Integer
                Dim top As Integer
                Dim w As Integer
                left = facePosition.xc - CInt(facePosition.w * 0.6)
                top = facePosition.yc - CInt(facePosition.w * 0.5)
                w = CInt(facePosition.w * 1.2)

                Picture1.Line (left, top)-(left + w, top + w), vbGreen, B
            Next
        
            Picture1.Refresh
                
            FSDKVB_FreeImage imageHandle ' delete the FSDK image handle
            DeleteObject hbitmapHandle ' delete the HBITMAP object
                
            ' make UI controls accessible
            DoEvents
        End If
    Wend
    FSDKVB_FreeTracker Tracker
    
    FSDKVB_CloseVideoCamera cameraHandle
    FSDKVB_FinalizeCapturing
End Sub

Private Sub Form_Activate()
    needClose = False
        
    Dim cameraList
    Dim Count
            
    FSDKVB_GetCameraList cameraList, Count
    
    If (0 = Count) Then
        MsgBox "Please attach a camera", vbCritical, "Error"
        Unload Me
        Exit Sub
    End If
    
    Dim formatList
    FSDKVB_GetVideoFormatList cameraList(0), formatList, Count
    Picture1.ScaleMode = 3
    Picture1.Width = formatList(0)(0)
    Picture1.Height = formatList(0)(1)
    Me.ScaleMode = 3
    Me.Width = (formatList(0)(0) + 48) * (Me.Width / Me.ScaleWidth)
    Me.Height = (formatList(0)(1) + 96) * (Me.Height / Me.ScaleHeight)
    Command1.left = Picture1.left + (Picture1.Width - Command1.Width) / 2
    Command1.top = Picture1.top + Picture1.Height + 24
    
    cameraName = cameraList(0)
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
    needClose = True
End Sub


