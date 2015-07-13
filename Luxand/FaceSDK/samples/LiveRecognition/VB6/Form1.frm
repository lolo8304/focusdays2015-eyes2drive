VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Live Recognition"
   ClientHeight    =   5355
   ClientLeft      =   165
   ClientTop       =   450
   ClientWidth     =   8535
   LinkTopic       =   "Form1"
   ScaleHeight     =   357
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   569
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command1 
      Caption         =   "Start"
      Height          =   375
      Left            =   3720
      TabIndex        =   1
      Top             =   4800
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
      ScaleWidth      =   521
      TabIndex        =   0
      Top             =   120
      Width           =   7815
   End
   Begin VB.Label Label2 
      AutoSize        =   -1  'True
      Caption         =   "Label2"
      Height          =   195
      Left            =   6120
      TabIndex        =   3
      Top             =   4800
      Visible         =   0   'False
      Width           =   480
   End
   Begin VB.Label Label1 
      AutoSize        =   -1  'True
      Height          =   195
      Left            =   3240
      TabIndex        =   2
      Top             =   4440
      Width           =   45
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Base 0
Option Explicit

' program states: waiting for the user to click 'Remember Me', storing the user's template,
' and recognizing user's face
Enum ProgramStateEnum
    psRemember
    psRecognize
End Enum
Dim programState As ProgramStateEnum

Dim cameraName
Dim needClose
Dim Username
Dim mouseX
Dim mouseY
Const TrackerMemoryFile = "tracker.dat"

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
    End If
    
    Dim Tracker As Long
    If (FSDKE_OK <> FSDKVB_LoadTrackerMemoryFromFile(Tracker, TrackerMemoryFile)) Then ' try to load saved tracker state
        FSDKVB_CreateTracker Tracker ' if could not be loaded, create a new tracker
    End If

    Dim err As Long ' set realtime face detection parameters
    FSDKVB_SetTrackerMultipleParameters Tracker, "HandleArbitraryRotations=false; DetermineFaceRotationAngle=false; InternalResizeWidth=100; FaceDetectionThreshold=5;", err
    
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

                Dim left_coord As Integer
                Dim top As Integer
                Dim w As Integer
                left_coord = facePosition.xc - CInt(facePosition.w * 0.6)
                top = facePosition.yc - CInt(facePosition.w * 0.5)
                w = CInt(facePosition.w * 1.2)

                Dim Name As String
                Name = Space$(256)
                Dim res As Integer
                res = FSDKVB_GetAllNames(Tracker, IDs(i), Name, 256) ' maximum of 256 characters
                
                Dim NullCharacterPos As Integer 'handle the null-terminated string
                NullCharacterPos = InStr(Name, Chr$(0))
                If (NullCharacterPos > 0) Then
                    Name = Left$(Name, NullCharacterPos - 1)
                End If
                
                If (FSDKE_OK = res And Len(Name) > 0) Then ' draw name
                    Label2.FontName = "Arial" ' Label2 is used for text centering
                    Label2.FontSize = 16
                    Label2.Caption = Name
                    Picture1.FontName = "Arial"
                    Picture1.FontSize = 16
                    Picture1.ForeColor = vbGreen
                    Picture1.CurrentX = facePosition.xc - Label2.Width / 2
                    Picture1.CurrentY = top + w + 5
                    Picture1.Print Name
                End If

                Dim cl As Variant
                cl = vbGreen

                If (mouseX >= left_coord And mouseX <= left_coord + w And mouseY >= top And mouseY <= top + w) Then
                    cl = vbBlue
                    If (psRemember = programState) Then
                        If (FSDKE_OK = FSDKVB_LockID(Tracker, IDs(i))) Then
                            Username = InputBox("Person's name:", "Enter person's name") 'get the user name
                            FSDKVB_SetName Tracker, IDs(i), Username
                            FSDKVB_UnlockID Tracker, IDs(i)
                        End If
                    End If
                End If

                Picture1.Line (left_coord, top)-(left_coord + w, top + w), cl, B
            Next
            Picture1.Refresh
            
            programState = psRecognize

            FSDKVB_FreeImage imageHandle ' delete the FSDK image handle
            DeleteObject hbitmapHandle ' delete the HBITMAP object
                
            ' make UI controls accessible
            DoEvents
        End If
    Wend
    
    FSDKVB_SaveTrackerMemoryToFile Tracker, TrackerMemoryFile
    FSDKVB_FreeTracker Tracker
    FSDKVB_CloseVideoCamera cameraHandle
    FSDKVB_FinalizeCapturing
End Sub

Private Sub Form_Activate()
    needClose = False
    programState = psRecognize
    mouseX = 0
    mouseY = 0
        
    Dim cameraList
    Dim Count
    FSDKVB_GetCameraList cameraList, Count
    
    If (0 = Count) Then
        MsgBox "Please attach a camera", vbCritical, "Error"
        Unload Me
    End If
    
    Dim formatList
    FSDKVB_GetVideoFormatList cameraList(0), formatList, Count
    Picture1.ScaleMode = 3
    Picture1.Width = formatList(0)(0)
    Picture1.Height = formatList(0)(1)
    Me.ScaleMode = 3
    Me.Width = (formatList(0)(0) + 48) * (Me.Width / Me.ScaleWidth)
    Me.Height = (formatList(0)(1) + 116) * (Me.Height / Me.ScaleHeight)
    Command1.Left = Picture1.Left + (Picture1.Width - (Command1.Width)) / 2
    Command1.top = Picture1.top + Picture1.Height + 50
    
    cameraName = cameraList(0)
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
    needClose = True
End Sub


Private Sub Picture1_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
    programState = psRemember
End Sub

Private Sub Picture1_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    mouseX = X
    mouseY = Y
End Sub
