using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using Luxand;

namespace FaceTracking
{
    public partial class Form1 : Form
    {
        bool needClose = false;
        bool CameraOpened = false;

        int cameraHandle = 0;

        // WinAPI procedure to release HBITMAP handles returned by FSDKCam.GrabFrame
        [DllImport("gdi32.dll")]
        static extern bool DeleteObject(IntPtr hObject);

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            if (FSDK.FSDKE_OK != FSDK.ActivateLibrary("Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M="))
            {
                MessageBox.Show("Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)", "Error activating FaceSDK", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Application.Exit();
            }

            FSDK.InitializeLibrary();
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            needClose = true;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (CameraOpened && FSDK.FSDKE_OK != FSDKCam.CloseVideoCamera(cameraHandle))
            {
                MessageBox.Show("Error closing camera", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Application.Exit();
            }

            if (FSDK.FSDKE_OK != FSDKCam.OpenIPVideoCamera(FSDKCam.FSDK_VIDEOCOMPRESSIONTYPE.FSDK_MJPEG, AddressBox.Text, UsernameBox.Text, PasswordBox.Text, 50, ref cameraHandle))
            {
                MessageBox.Show("Error opening IP camera", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Application.Exit();
            }
            CameraOpened = true;           
        }

        private void Form1_Shown(object sender, EventArgs e)
        {
            int tracker = 0;
            FSDK.CreateTracker(ref tracker);

            int err = 0; // set realtime face detection parameters
            FSDK.SetTrackerMultipleParameters(tracker, "RecognizeFaces=false; HandleArbitraryRotations=false; DetermineFaceRotationAngle=false; InternalResizeWidth=100; FaceDetectionThreshold=5;", ref err);
            
            while (!needClose)
            {
                if (CameraOpened)
                {
                    Int32 imageHandle = 0;
                    if (FSDK.FSDKE_OK != FSDKCam.GrabFrame(cameraHandle, ref imageHandle)) // grab the current frame from the camera
                    {
                        MessageBox.Show("Error in FSDK_GrabFrame", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        Application.DoEvents();
                        continue;
                    }
                    FSDK.CImage image = new FSDK.CImage(imageHandle);

                    long[] IDs;
                    long faceCount = 0;
                    FSDK.FeedFrame(tracker, 0, image.ImageHandle, ref faceCount, out IDs, sizeof(long) * 256); // maximum of 256 faces detected
                    Array.Resize(ref IDs, (int)faceCount);

                    Image frameImage = image.ToCLRImage();
                    Graphics gr = Graphics.FromImage(frameImage);

                    for (int i = 0; i < IDs.Length; ++i)
                    {
                        FSDK.TFacePosition facePosition = new FSDK.TFacePosition();
                        FSDK.GetTrackerFacePosition(tracker, 0, IDs[i], ref facePosition);

                        int left = facePosition.xc - (int)(facePosition.w * 0.6);
                        int top = facePosition.yc - (int)(facePosition.w * 0.5);
                        gr.DrawRectangle(Pens.LightGreen, left, top, (int)(facePosition.w * 1.2), (int)(facePosition.w * 1.2));
                    }

                    // display current frame
                    pictureBox1.Image = frameImage;
                }
                GC.Collect(); // collect the garbage after the deletion

                // make UI controls accessible
                Application.DoEvents();
            }

            if (CameraOpened)
                FSDKCam.CloseVideoCamera(cameraHandle);
        }
    }
}
