Imports Luxand
Public Class Form1
    Dim cameraHandle As Integer
    Dim needClose As Boolean

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
        ReDim cameralist(1)
        Dim count As Integer
        FSDKCam.GetCameraList(cameralist, count)

        If (0 = count) Then
            MessageBox.Show("Please attach a camera", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
            Close()
        End If


        Dim formatList() As FSDKCam.VideoFormatInfo
        ReDim formatList(1)
        FSDKCam.GetVideoFormatList(cameralist(0), formatList, count)
        PictureBox1.Width = formatList(0).Width
        PictureBox1.Height = formatList(0).Height
        sender.Width = formatList(0).Width + 36
        sender.Height = formatList(0).Height + 96

        Button1.Left = (sender.Width / 2) - 40
        Button1.Width = 80
        Button1.Top = sender.Height - 75
        Button1.Height = 25

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
        ' set realtime face detection parameters
        FSDK.SetFaceDetectionParameters(False, False, 100)
        FSDK.SetFaceDetectionThreshold(3)
        Dim maxFaces As Integer
        maxFaces = 20
        needClose = False

        Dim image As FSDK.CImage
        Dim frameImage As Image

        Dim tracker As Integer
        FSDK.CreateTracker(tracker)

        Dim err As Long ' set realtime face detection parameters
        FSDK.SetTrackerMultipleParameters(tracker, "RecognizeFaces=false; DetectGender=true; HandleArbitraryRotations=false; DetermineFaceRotationAngle=false; InternalResizeWidth=100; FaceDetectionThreshold=5;", err)

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
                left = facePosition.xc - CInt(facePosition.w * 0.6)
                top = facePosition.yc - CInt(facePosition.w * 0.5)
                gr.DrawRectangle(Pens.LightGreen, left, top, CInt(facePosition.w * 1.2), CInt(facePosition.w * 1.2))

                Dim AttributeValues As String
                AttributeValues = ""
                If 0 = FSDK.GetTrackerFacialAttribute(tracker, 0, IDs(i), "Gender", AttributeValues, 1024) Then
                    Dim ConfidenceMale As Single
                    Dim ConfidenceFemale As Single
                    FSDK.GetValueConfidence(AttributeValues, "Male", ConfidenceMale)
                    FSDK.GetValueConfidence(AttributeValues, "Female", ConfidenceFemale)

                    Dim str As String
                    If ConfidenceMale > ConfidenceFemale Then
                        str = "Male, " + CInt(ConfidenceMale * 100).ToString + "%"
                    Else : str = "Female, " + CInt(ConfidenceFemale * 100).ToString + "%"
                    End If

                    Dim format As StringFormat
                    format = New StringFormat
                    format.Alignment = StringAlignment.Center

                    gr.DrawString(str, New System.Drawing.Font("Arial", 16), _
                        New System.Drawing.SolidBrush(System.Drawing.Color.LightGreen), _
                        facePosition.xc, top + CInt(facePosition.w * 1.2) + 5, format)
                End If

            Next

            ' display current frame
            PictureBox1.Image = frameImage

            GC.Collect() ' collect the garbage after the deletion

            ' make UI controls accessible
            Application.DoEvents()
        End While
        FSDK.FreeTracker(tracker)

        FSDKCam.CloseVideoCamera(cameraHandle)
        FSDKCam.FinalizeCapturing()
    End Sub
End Class
