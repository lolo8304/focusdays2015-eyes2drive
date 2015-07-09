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
        sender.Height = formatList(0).Height + 60

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
        Button1.Hide()

        Dim tracker As Integer
        FSDK.CreateTracker(tracker)

        Dim err As Long ' set realtime face detection parameters
        FSDK.SetTrackerMultipleParameters(tracker, "RecognizeFaces=false; DetectFacialFeatures=true; HandleArbitraryRotations=false; DetermineFaceRotationAngle=false; InternalResizeWidth=100; FaceDetectionThreshold=5;", err)

        needClose = False

        Dim image As FSDK.CImage
        Dim frameImage As Image
        Dim faceCoords As FSDK.TFacePosition
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

                Dim FacialFeatures(FSDK.FSDK_FACIAL_FEATURE_COUNT) As FSDK.TPoint
                FSDK.GetTrackerFacialFeatures(tracker, 0, IDs(i), FacialFeatures)

                Dim left As Integer
                Dim top As Integer
                left = facePosition.xc - CInt(facePosition.w * 0.6)
                top = facePosition.yc - CInt(facePosition.w * 0.5)
                gr.DrawRectangle(Pens.LightGreen, left, top, CInt(facePosition.w * 1.2), CInt(facePosition.w * 1.2))
                Dim j As Integer
                For j = 0 To FSDK.FSDK_FACIAL_FEATURE_COUNT - 1
                    gr.FillEllipse(Brushes.DarkBlue, FacialFeatures(j).x, FacialFeatures(j).y, 5, 5)
                Next
            Next


            'faceCoords = image.DetectFace()
            'If (faceCoords.w <> 0) Then
            'Dim left As Integer
            'Dim top As Integer
            'Dim width As Integer
            'left = faceCoords.xc - 2 * faceCoords.w / 3
            'top = faceCoords.yc - faceCoords.w / 2
            'width = 4 * faceCoords.w / 3
            'gr.DrawRectangle(Pens.LightGreen, left, top, width, width)
            'Dim FacialFeatures() As FSDK.TPoint
            'FacialFeatures = image.DetectFacialFeaturesInRegion(faceCoords)
            'SmoothFacialFeatures(FacialFeatures)
            'Dim i As Integer
            'For i = 0 To FSDK.FSDK_FACIAL_FEATURE_COUNT - 1
            'gr.FillEllipse(Brushes.DarkBlue, FacialFeatures(i).x, FacialFeatures(i).y, 5, 5)
            'Next
            'Else
            'facialFeaturesArray.Clear()
            'End If

            ' display current frame
            PictureBox1.Image = frameImage

            GC.Collect() ' collect the garbage after the deletion
            ' make UI controls accessible
            Application.DoEvents()
        End While
        FSDKCam.CloseVideoCamera(cameraHandle)
        FSDKCam.FinalizeCapturing()
    End Sub
End Class
