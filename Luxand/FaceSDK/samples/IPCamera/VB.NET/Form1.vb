Imports Luxand
Public Class Form1
    Dim cameraHandle As Integer
    Dim needClose As Boolean
    Dim cameraOpened As Boolean

    ' WinAPI procedure to release HBITMAP handles returned by FSDKCam.GrabFrame
    Declare Auto Function DeleteObject Lib "gdi32.dll" (ByVal hObject As IntPtr) As Boolean

    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        If (FSDK.ActivateLibrary("Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M=") <> FSDK.FSDKE_OK) Then
            MessageBox.Show("Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)", "Error activating FaceSDK")
            Close()
        End If
        FSDK.InitializeLibrary()
    End Sub
    Private Sub Form1_FormClosing(ByVal sender As System.Object, ByVal e As System.Windows.Forms.FormClosingEventArgs) Handles MyBase.FormClosing
        needClose = True
    End Sub

    Private Sub Button1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button1.Click
        If (cameraOpened And FSDK.FSDKE_OK <> FSDKCam.CloseVideoCamera(cameraHandle)) Then
            MessageBox.Show("Error closing camera", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
            Application.Exit()
        End If

        If (FSDK.FSDKE_OK <> FSDKCam.OpenIPVideoCamera(FSDKCam.FSDK_VIDEOCOMPRESSIONTYPE.FSDK_MJPEG, AddressBox.Text, UsernameBox.Text, PasswordBox.Text, 50, cameraHandle)) Then
            MessageBox.Show("Error opening IP camera", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
            Application.Exit()
        End If
        cameraOpened = True
    End Sub
    Private Sub Form1_Shown(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Shown
        Dim tracker As Integer
        FSDK.CreateTracker(tracker)

        Dim err As Long ' set realtime face detection parameters
        FSDK.SetTrackerMultipleParameters(tracker, "RecognizeFaces=false; HandleArbitraryRotations=false; DetermineFaceRotationAngle=false; InternalResizeWidth=100; FaceDetectionThreshold=5;", err)

        needClose = False
        cameraOpened = False

        Dim frameImage As Image
        While Not needClose
            If (cameraOpened) Then
                Dim ImageHandle As Integer
                If (FSDKCam.GrabFrame(cameraHandle, ImageHandle) <> FSDK.FSDKE_OK) Then ' grab the current frame from the camera
                    Application.DoEvents()
                    Continue While
                End If

                Dim image = New FSDK.CImage(ImageHandle)

                Dim IDs() As Long
                ReDim IDs(0 To 256)
                Dim faceCount As Long
                Dim sizeOfLong = 8
                FSDK.FeedFrame(tracker, 0, Image.ImageHandle, faceCount, IDs, sizeOfLong * 256) ' maximum 256 faces detected
                Array.Resize(IDs, faceCount)

                frameImage = Image.ToCLRImage()

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
                Next

                ' display current frame
                PictureBox1.Image = frameImage

            End If

            GC.Collect() ' collect the garbage after the deletion

            ' make UI controls accessible
            Application.DoEvents()
        End While
        FSDKCam.CloseVideoCamera(cameraHandle)
        FSDK.FreeTracker(tracker)
    End Sub
End Class
