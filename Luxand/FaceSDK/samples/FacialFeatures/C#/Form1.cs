using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using Luxand;

namespace FacialFeatures
{
    public partial class Form1 : Form
    {
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
            FSDK.SetFaceDetectionParameters(true, true, 384);
        }

        private void btnOpenPhoto_Click(object sender, EventArgs e)
        {
            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    FSDK.CImage image = new FSDK.CImage(openFileDialog1.FileName);

                    // resize image to fit the window width
                    double ratio = System.Math.Min((pictureBox1.Width + 0.4) / image.Width,
                        (pictureBox1.Height + 0.4) / image.Height);
                    image = image.Resize(ratio);
                    
                    Image frameImage = image.ToCLRImage();
                    Graphics gr = Graphics.FromImage(frameImage);

                    FSDK.TFacePosition facePosition = image.DetectFace();
                    if (0 == facePosition.w)
                        MessageBox.Show("No faces detected", "Face Detection");
                    else
                    {
                        int left = facePosition.xc - (int)(facePosition.w*0.6f);
                        int top = facePosition.yc - (int)(facePosition.w*0.5f);
                        gr.DrawRectangle(Pens.LightGreen, left, top, (int)(facePosition.w*1.2), (int)(facePosition.w*1.2));

                        FSDK.TPoint[] facialFeatures = image.DetectFacialFeaturesInRegion(ref facePosition);
                        int i = 0;
                        foreach (FSDK.TPoint point in facialFeatures)
                            gr.DrawEllipse((++i > 2) ? Pens.LightGreen : Pens.Blue, point.x, point.y, 3, 3);

                        gr.Flush();
                    }

                    // display image
                    pictureBox1.Image = frameImage;
                    pictureBox1.Refresh();
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message, "Exception");
                }
            }
        }
    }
}
