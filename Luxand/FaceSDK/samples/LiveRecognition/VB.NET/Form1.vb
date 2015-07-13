Imports Luxand
Public Class Form1
    Dim cameraHandle As Integer
    Dim needClose As Boolean
    Dim userName As String
    Const TrackerMemoryFile = "tracker.dat"
    Dim mouseX As Integer = 0
    Dim mouseY As Integer = 0

    ' program states: waiting for the user to click 'Remember Me', storing the user's template,
    ' and recognizing user's face
    Enum ProgramStates
        psRemember
        psRecognize
    End Enum
    Dim programState As ProgramStates

    ' WinAPI procedure to release HBITMAP handles returned by FSDKCam.GrabFrame
    Declare Auto Function DeleteObject Lib "gdi32.dll" (ByVal hObject As IntPtr) As Boolean

    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        If (FSDK.ActivateLibrary("Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M=") <> FSDK.FSDKE_OK) Then
            MessageBox.Show("Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)", "Error activating FaceSDK")
            Close()
        End If
        FSDK.InitializeLibrary()
        FSDKCam.InitializeCapturing()

        Dim cameralist() As String
        Dim count As Integer
        FSDKCam.GetCameraList(cameralist, count)

        If (0 = count) Then
            MessageBox.Show("Please attach a camera", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
            Close()
        End If


        Dim formatList() As FSDKCam.VideoFormatInfo
        FSDKCam.GetVideoFormatList(cameralist(0), formatList, count)
        PictureBox1.Width = formatList(0).Width
        PictureBox1.Height = formatList(0).Height
        sender.Width = formatList(0).Width + 36
        sender.Height = formatList(0).Height + 126

        Dim cameraName As String
        cameraName = cameralist(0)
        If (FSDKCam.OpenVideoCamera(cameraName, cameraHandle) <> FSDK.FSDKE_OK) Then
            MessageBox.Show("Error opening the first camera", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
            Close()
        End If
    End Sub
    Private Sub Form1_FormClosing(ByVal sender As System.Object, ByVal e As System.Windows.Forms.FormClosingEventArgs) Handles MyBase.FormClosing
        needClose = True
    End Sub

    Private Sub Button1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button1.Click
        Button1.Enabled = False
        needClose = False

        Dim tracker As Integer = 0  ' creating a Tracker
        If (FSDK.FSDKE_OK <> FSDK.LoadTrackerMemoryFromFile(tracker, TrackerMemoryFile)) Then ' try to load saved tracker state
            FSDK.CreateTracker(tracker) ' if could not be loaded, create a new tracker
        End If

        Dim err As Integer = 0 ' set realtime face detection parameters
        FSDK.SetTrackerMultipleParameters(tracker, "HandleArbitraryRotations=false; DetermineFaceRotationAngle=false; InternalResizeWidth=100; FaceDetectionThreshold=5;", err)


        Dim image As FSDK.CImage
        Dim frameImage As Image
        While Not needClose
            Dim ImageHandle As Integer
            If (FSDKCam.GrabFrame(cameraHandle, ImageHandle) <> FSDK.FSDKE_OK) Then ' grab the current frame from the camera
                Application.DoEvents()
                Continue While
            End If

            image = New FSDK.CImage(ImageHandle)

            Dim IDs() As Long
            ReDim IDs(0 To 256)
            Dim faceCount As Long
            Dim sizeOfLong = 8
            FSDK.FeedFrame(tracker, 0, image.ImageHandle, faceCount, IDs, sizeOfLong * 256) ' maximum 256 faces detected
            Array.Resize(IDs, faceCount)

            frameImage = image.ToCLRImage()

            Dim gr As Graphics
            gr = Graphics.FromImage(frameImage)

            Dim i As Integer
            For i = 0 To IDs.Length - 1
                Dim facePosition As FSDK.TFacePosition
                facePosition = New FSDK.TFacePosition
                FSDK.GetTrackerFacePosition(tracker, 0, IDs(i), facePosition)

                Dim left As Integer
                Dim top As Integer
                Dim w As Integer
                left = facePosition.xc - CInt(facePosition.w * 0.6)
                top = facePosition.yc - CInt(facePosition.w * 0.5)
                w = facePosition.w * 1.2

                Dim name As String
                Dim res As Integer
                res = FSDK.GetAllNames(tracker, IDs(i), name, 65536) ' maximum of 65536 characters
                If (FSDK.FSDKE_OK = res And name.Length > 0) Then ' draw name
                    Dim format As New StringFormat()
                    format.Alignment = StringAlignment.Center

                    gr.DrawString(name, New System.Drawing.Font("Arial", 16), _
                            New System.Drawing.SolidBrush(System.Drawing.Color.LightGreen), _
                            facePosition.xc, top + w + 5, format)
                End If

                Dim pen As Pen = Pens.LightGreen

                If (mouseX >= left And mouseX <= left + w And mouseY >= top And mouseY <= top + w) Then
                    pen = Pens.Blue
                    If (programState.psRemember = programState) Then
                        If (FSDK.FSDKE_OK = FSDK.LockID(tracker, IDs(i))) Then
                            userName = InputBox("Your name:", "Enter your name") 'get the user name
                            If userName Is Nothing Then
                                FSDK.SetName(tracker, IDs(i), "")
                            Else
                                FSDK.SetName(tracker, IDs(i), userName)
                            End If
                            FSDK.UnlockID(tracker, IDs(i))
                        End If
                    End If
                End If
                gr.DrawRectangle(pen, left, top, w, w)
            Next
            programState = programState.psRecognize

            PictureBox1.Image = frameImage ' display current frame
            GC.Collect() ' collect the garbage after the deletion
            Application.DoEvents() ' make UI controls accessible
        End While

        FSDK.SaveTrackerMemoryToFile(tracker, TrackerMemoryFile)
        FSDK.FreeTracker(tracker)
        FSDKCam.CloseVideoCamera(cameraHandle)
        FSDKCam.FinalizeCapturing()
    End Sub

    Private Sub PictureBox1_MouseLeave(ByVal sender As Object, ByVal e As System.EventArgs) Handles PictureBox1.MouseLeave
        mouseX = 0
        mouseY = 0
    End Sub

    Private Sub PictureBox1_MouseMove(ByVal sender As Object, ByVal e As System.Windows.Forms.MouseEventArgs) Handles PictureBox1.MouseMove
        mouseX = e.X
        mouseY = e.Y
    End Sub

    Private Sub PictureBox1_MouseUp(ByVal sender As Object, ByVal e As System.Windows.Forms.MouseEventArgs) Handles PictureBox1.MouseUp
        programState = programState.psRemember
    End Sub
End Class
