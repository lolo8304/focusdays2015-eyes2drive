using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Drawing.Drawing2D;
using System.Globalization;
using System.Runtime.InteropServices;
using Luxand;

namespace Lookalikes
{

    public struct TFaceRecord
    {
        public byte [] Template; //Face Template;
        public FSDK.TFacePosition FacePosition;
        public FSDK.TPoint[] FacialFeatures; //Facial Features;

        public string ImageFileName;

        public FSDK.CImage image;
        public FSDK.CImage faceImage;
    }

    public partial class Form1 : Form
    {
        public static float FaceDetectionThreshold = 3;
        public static float FARValue = 100;
        
        public static List<TFaceRecord> FaceList;
                      
        static ImageList imageList1;
        
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            FaceList = new List<TFaceRecord>();

            imageList1 = new ImageList();
            Size size100x100 = new Size();
            size100x100.Height = 100;
            size100x100.Width = 100;
            imageList1.ImageSize = size100x100;
            imageList1.ColorDepth = ColorDepth.Depth24Bit;

            textBox1.Dock = DockStyle.Bottom;

            listView1.OwnerDraw = false;
            listView1.View = View.LargeIcon;
            listView1.Dock = DockStyle.Right;
            listView1.LargeImageList = imageList1;

            textBox1.Text += "Initializing Luxand FaceSDK...\r\n";

            if (FSDK.FSDKE_OK != FSDK.ActivateLibrary("Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M="))
            {
                MessageBox.Show("Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)", "Error activating FaceSDK", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Application.Exit();
            }

            if (FSDK.InitializeLibrary() != FSDK.FSDKE_OK)
                MessageBox.Show("Error initializing FaceSDK!", "Error");

            textBox1.Text += "Initialized\r\n";
        }

        private void listView1_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (this.listView1.SelectedIndices.Count > 0){
                Image img = FaceList[listView1.SelectedIndices[0]].image.ToCLRImage();
                pictureBox1.Height = img.Height;
                pictureBox1.Width = img.Width;
                pictureBox1.Image = img;

                pictureBox1.Refresh();
                Graphics gr = pictureBox1.CreateGraphics();
                gr.DrawRectangle(Pens.LightGreen, FaceList[listView1.SelectedIndices[0]].FacePosition.xc - FaceList[listView1.SelectedIndices[0]].FacePosition.w / 2, FaceList[listView1.SelectedIndices[0]].FacePosition.yc - FaceList[listView1.SelectedIndices[0]].FacePosition.w/2, FaceList[listView1.SelectedIndices[0]].FacePosition.w, FaceList[listView1.SelectedIndices[0]].FacePosition.w);

                for (int i = 0; i < 2; ++i){
                    FSDK.TPoint tp = FaceList[listView1.SelectedIndices[0]].FacialFeatures[i];
                    gr.DrawEllipse(Pens.Blue, tp.x, tp.y, 3, 3);
                }                
            }
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MessageBox.Show("Luxand Face Recognition Demo \r\n\r\n© 2011 Luxand, Inc.\r\nhttp://www.luxand.com", "About");
        }

        private void optionsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Options frmOptions = new Options();
            frmOptions.Show();
        }

        private void enrollFacesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OpenFileDialog dlg = new OpenFileDialog();
            dlg.Filter = "JPEG (*.jpg)|*.jpg|Windows bitmap (*.bmp)|*.bmp|All files|*.*";
            dlg.Multiselect = true;

            if (dlg.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    //Assuming that faces are vertical (HandleArbitraryRotations = false) to speed up face detection
                    FSDK.SetFaceDetectionParameters(false, true, 384);
                    FSDK.SetFaceDetectionThreshold((int)FaceDetectionThreshold);


                    foreach (string fn in dlg.FileNames)
                    {
                        TFaceRecord fr = new TFaceRecord();
                        fr.ImageFileName = fn;
                        fr.FacePosition = new FSDK.TFacePosition();
                        fr.FacialFeatures = new FSDK.TPoint[2];
                        fr.Template = new byte[FSDK.TemplateSize];


                        fr.image = new FSDK.CImage(fn);
                        
                        textBox1.Text += "Enrolling '" + fn + "'\r\n";
                        textBox1.Refresh();
                        fr.FacePosition = fr.image.DetectFace();
                        if (0 == fr.FacePosition.w)
                            if (dlg.FileNames.Length <= 1)
                                MessageBox.Show("No faces found. Try to lower the Minimal Face Quality parameter in the Options dialog box.", "Enrollment error");
                            else
                                textBox1.Text += (fn + ": No faces found. Try to lower the Minimal Face Quality parameter in the Options dialog box.\r\n");
                        else
                        {
                            fr.faceImage = fr.image.CopyRect((int)(fr.FacePosition.xc - Math.Round(fr.FacePosition.w * 0.5)), (int)(fr.FacePosition.yc - Math.Round(fr.FacePosition.w * 0.5)), (int)(fr.FacePosition.xc + Math.Round(fr.FacePosition.w * 0.5)), (int)(fr.FacePosition.yc + Math.Round(fr.FacePosition.w * 0.5)));

                            try
                            {
                                fr.FacialFeatures = fr.image.DetectEyesInRegion(ref fr.FacePosition);
                            }
                            catch (Exception ex2)
                            {
                                MessageBox.Show(ex2.Message, "Error detecting eyes.");
                            }

                            try
                            {
                                fr.Template = fr.image.GetFaceTemplateInRegion(ref fr.FacePosition); // get template with higher precision
                            }
                            catch (Exception ex2)
                            {
                                MessageBox.Show(ex2.Message, "Error retrieving face template.");
                            }

                            FaceList.Add(fr);

                            imageList1.Images.Add(fr.faceImage.ToCLRImage());
                            listView1.Items.Add((imageList1.Images.Count - 1).ToString(), fn.Split('\\')[fn.Split('\\').Length - 1], imageList1.Images.Count - 1);

                            textBox1.Text += "File '" + fn + "' enrolled\r\n";
                            textBox1.Refresh();

                            listView1.SelectedIndices.Clear();
                            listView1.SelectedIndices.Add(listView1.Items.Count - 1);
                        }
                    }
                 
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message.ToString(), "Exception");
                }
            }
        }

        private void clearDatabaseToolStripMenuItem_Click(object sender, EventArgs e)
        {
            FaceList.Clear();
            listView1.Items.Clear();
            imageList1.Images.Clear();
            pictureBox1.Width = 0;
            pictureBox1.Height = 0;
            GC.Collect();
        }

        private void matchFaceToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (FaceList.Count == 0)
                MessageBox.Show("Please enroll faces first", "Error");
            else {
                OpenFileDialog dlg = new OpenFileDialog();
                dlg.Filter = "JPEG (*.jpg)|*.jpg|Windows bitmap (*.bmp)|*.bmp|All files|*.*";
                
                if (dlg.ShowDialog() == DialogResult.OK)
                {
                    try
                    {
                        string fn = dlg.FileNames[0];
                        TFaceRecord fr = new TFaceRecord();
                        fr.ImageFileName = fn;
                        fr.FacePosition = new FSDK.TFacePosition();
                        fr.FacialFeatures = new FSDK.TPoint[FSDK.FSDK_FACIAL_FEATURE_COUNT];
                        fr.Template = new byte[FSDK.TemplateSize];

                        try
                        {
                            fr.image = new FSDK.CImage(fn);
                        }
                        catch (Exception ex)
                        {
                            MessageBox.Show(ex.Message, "Error loading file");
                        }

                        fr.FacePosition = fr.image.DetectFace();
                        if (0 == fr.FacePosition.w)
                            MessageBox.Show("No faces found. Try to lower the Minimal Face Quality parameter in the Options dialog box.", "Enrollment error");
                        else
                        {
                            fr.faceImage = fr.image.CopyRect((int)(fr.FacePosition.xc - Math.Round(fr.FacePosition.w * 0.5)), (int)(fr.FacePosition.yc - Math.Round(fr.FacePosition.w * 0.5)), (int)(fr.FacePosition.xc + Math.Round(fr.FacePosition.w * 0.5)), (int)(fr.FacePosition.yc + Math.Round(fr.FacePosition.w * 0.5)));

                            bool eyesDetected = false;
                            try
                            {
                                fr.FacialFeatures = fr.image.DetectEyesInRegion(ref fr.FacePosition);
                                eyesDetected = true;
                            }
                            catch (Exception ex)
                            {
                                MessageBox.Show(ex.Message, "Error detecting eyes.");
                            }

                            if (eyesDetected)
                            {
                                fr.Template = fr.image.GetFaceTemplateInRegion(ref fr.FacePosition); // get template with higher precision
                            }
                        }
                        
                        Results frmResults = new Results();
                        frmResults.Go(fr);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show("Can't open image(s) with error: " + ex.Message.ToString(), "Error");
                    }

                }
            }
        }

    }
}
