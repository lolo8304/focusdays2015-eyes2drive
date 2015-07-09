Imports Luxand


Public Class Form1
    Dim image As FSDK.CImage
    Dim FacePosition As FSDK.TFacePosition
    Dim FacialFeatures(FSDK.FSDK_FACIAL_FEATURE_COUNT - 1) As FSDK.TPoint

    ' WinAPI procedure to release HBITMAP handles returned by FSDKCam.GrabFrame
    Declare Auto Function DeleteObject Lib "gdi32.dll" (ByVal hObject As IntPtr) As Boolean

    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        If (FSDK.ActivateLibrary("Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M=") <> FSDK.FSDKE_OK) Then
            MessageBox.Show("Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)", "Error activating FaceSDK")
            Close()
        End If
        FSDK.InitializeLibrary()
    End Sub

    Private Sub Button1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button1.Click
        Dim dlg As New OpenFileDialog
        dlg.Filter = "JPEG (*.jpg)|*.jpg|Windows bitmap (*.bmp)|*.bmp|All files|*.*"
        dlg.Multiselect = False

        If (dlg.ShowDialog() = DialogResult.OK) Then
            Try
                image = New FSDK.CImage(dlg.FileNames(0))

                ' resize image to fit the window width
                Dim ratio As Double
                ratio = System.Math.Min((PictureBox1.Width + 0.4) / image.Width, (PictureBox1.Height + 0.4) / image.Height)
                image = image.Resize(ratio)
                
                Dim frameImage As Image
                frameImage = image.ToCLRImage()

                ' display current frame
                PictureBox1.Image = frameImage
                PictureBox1.Refresh()
                FacePosition = image.DetectFace()

                If FacePosition.w = 0 Then
                    MessageBox.Show("No faces found", "Face Detection")
                Else
                    Dim gr As Graphics
                    gr = PictureBox1.CreateGraphics()
                    gr.DrawRectangle(Pens.LightGreen, CType(FacePosition.xc - FacePosition.w * 0.6, Integer), CType(FacePosition.yc - FacePosition.w * 0.5, Integer), CType(FacePosition.w * 1.2, Integer), CType(FacePosition.w * 1.2, Integer))
                    FacialFeatures = image.DetectFacialFeaturesInRegion(FacePosition)
                    Dim i As Integer
                    i = 1
                    Dim p As FSDK.TPoint
                    For Each p In FacialFeatures
                        If (i > 2) Then
                            gr.DrawEllipse(Pens.LightGreen, p.x, p.y, 3, 3)
                        Else
                            gr.DrawEllipse(Pens.Blue, p.x, p.y, 3, 3)
                        End If

                        i = i + 1
                    Next
                End If


            Catch ex As Exception
                MessageBox.Show(ex.Message, "Exception")
            End Try

        End If
    End Sub
End Class
