using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.IO;
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
        [DllImport("gdi32.dll")]
        static extern bool DeleteObject(IntPtr hObject);

        public static float FaceDetectionThreshold = 3;
        public static float FARValue = 100;
        
        public static List<TFaceRecord> FaceList;
                      
        static ImageList imageList1;

        const string SQLServerAddress = "127.0.0.1";
        const string SQLServerPort = "1434";
        const string DatabaseName = "tests";

        private void SaveFaceInDB(TFaceRecord fr)
        {
            System.Data.SqlClient.SqlConnection sqlConnect = null;
            try
            {
                //preparing FaceRecord to save
                Image img = null;
                Image img_face = null;
                MemoryStream strm = new MemoryStream();
                MemoryStream strm_face = new MemoryStream();
                img = fr.image.ToCLRImage();
                img_face = fr.faceImage.ToCLRImage();
                img.Save(strm, System.Drawing.Imaging.ImageFormat.Jpeg);
                img_face.Save(strm_face, System.Drawing.Imaging.ImageFormat.Jpeg);
                byte [] img_array = new byte[strm.Length];
                byte [] img_face_array = new byte[strm_face.Length];
                strm.Position = 0;
                strm.Read(img_array, 0, img_array.Length);
                strm_face.Position = 0;
                strm_face.Read(img_face_array, 0, img_face_array.Length);
                
                //connect to Microsoft SQL Server and save FaceRecord
                sqlConnect = new System.Data.SqlClient.SqlConnection("server=" + SQLServerAddress + "," + SQLServerPort + "; initial catalog=" + DatabaseName + "; Integrated Security=SSPI");
                sqlConnect.Open();
                System.Data.SqlClient.SqlCommand sqlCmd = new System.Data.SqlClient.SqlCommand("INSERT INTO FaceList(ImageFileName, FacePositionXc, FacePositionYc, FacePositionW, FacePositionAngle, Eye1X, Eye1Y, Eye2X, Eye2Y, Template, Image, FaceImage) "+
                     " values(@ImageFileName, @FacePositionXc, @FacePositionYc, @FacePositionW, @FacePositionAngle, @Eye1X, @Eye1Y, @Eye2X, @Eye2Y, @Template, @Image, @FaceImage)", 
                     sqlConnect);
                
                sqlCmd.Parameters.Add("@ImageFileName", System.Data.SqlDbType.VarChar, 260);
                sqlCmd.Parameters.Add("@FacePositionXc", System.Data.SqlDbType.Int);
                sqlCmd.Parameters.Add("@FacePositionYc", System.Data.SqlDbType.Int);
                sqlCmd.Parameters.Add("@FacePositionW", System.Data.SqlDbType.Int);
                sqlCmd.Parameters.Add("@FacePositionAngle", System.Data.SqlDbType.Real);
                sqlCmd.Parameters.Add("@Eye1X", System.Data.SqlDbType.Int);
                sqlCmd.Parameters.Add("@Eye1Y", System.Data.SqlDbType.Int);
                sqlCmd.Parameters.Add("@Eye2X", System.Data.SqlDbType.Int);
                sqlCmd.Parameters.Add("@Eye2Y", System.Data.SqlDbType.Int);
                sqlCmd.Parameters.Add("@Template", System.Data.SqlDbType.VarBinary);
                sqlCmd.Parameters.Add("@Image", System.Data.SqlDbType.VarBinary);
                sqlCmd.Parameters.Add("@FaceImage", System.Data.SqlDbType.VarBinary);
                sqlCmd.Parameters["@ImageFileName"].Value = fr.ImageFileName;
                sqlCmd.Parameters["@FacePositionXc"].Value = fr.FacePosition.xc;
                sqlCmd.Parameters["@FacePositionYc"].Value = fr.FacePosition.yc;
                sqlCmd.Parameters["@FacePositionW"].Value = fr.FacePosition.w; 
                sqlCmd.Parameters["@FacePositionAngle"].Value = (float)fr.FacePosition.angle;
                sqlCmd.Parameters["@Eye1X"].Value = fr.FacialFeatures[0].x;
                sqlCmd.Parameters["@Eye1Y"].Value = fr.FacialFeatures[0].y;
                sqlCmd.Parameters["@Eye2X"].Value = fr.FacialFeatures[1].x;
                sqlCmd.Parameters["@Eye2Y"].Value = fr.FacialFeatures[1].y;
                sqlCmd.Parameters["@Template"].Value = fr.Template; 
                sqlCmd.Parameters["@Image"].Value = img_array;
                sqlCmd.Parameters["@FaceImage"].Value = img_face_array;

                int iresult = sqlCmd.ExecuteNonQuery();
                textBox1.Text += iresult + " rows modified in database.\r\n";

                img.Dispose();
                img_face.Dispose();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Exception on saving to database");
            }
            finally
            {
                if (sqlConnect != null)
                    sqlConnect.Close();
            }
        }

        private void LoadDB()
        {
            System.Data.SqlClient.SqlConnection sqlConnect = null;
            try
            {
                sqlConnect = new System.Data.SqlClient.SqlConnection("server=" + SQLServerAddress + "," + SQLServerPort + "; initial catalog=" + DatabaseName + "; Integrated Security=SSPI");
                sqlConnect.Open();

                System.Data.SqlClient.SqlCommand sqlCmd = new System.Data.SqlClient.SqlCommand("SELECT ImageFileName, FacePositionXc, FacePositionYc, FacePositionW, FacePositionAngle, Eye1X, Eye1Y, Eye2X, Eye2Y, Template, Image, FaceImage FROM FaceList", sqlConnect);

                System.Data.SqlClient.SqlDataReader reader = sqlCmd.ExecuteReader();
                while (reader.Read())
                {
                    TFaceRecord fr = new TFaceRecord();
                    fr.ImageFileName = reader.GetString(0);
                    
                    fr.FacePosition = new FSDK.TFacePosition();
                    fr.FacePosition.xc = reader.GetInt32(1);
                    fr.FacePosition.yc = reader.GetInt32(2);
                    fr.FacePosition.w = reader.GetInt32(3);
                    fr.FacePosition.angle = reader.GetFloat(4);

                    fr.FacialFeatures = new FSDK.TPoint[2];
                    fr.FacialFeatures[0] = new FSDK.TPoint();
                    fr.FacialFeatures[0].x = reader.GetInt32(5);
                    fr.FacialFeatures[0].y = reader.GetInt32(6);
                    fr.FacialFeatures[1] = new FSDK.TPoint();
                    fr.FacialFeatures[1].x = reader.GetInt32(7);
                    fr.FacialFeatures[1].y = reader.GetInt32(8);

                    fr.Template = new byte[FSDK.TemplateSize];
                    reader.GetBytes(9, 0, fr.Template, 0, FSDK.TemplateSize);

                    Image img = Image.FromStream(new System.IO.MemoryStream(reader.GetSqlBinary(10).Value));
                    Image img_face = Image.FromStream(new System.IO.MemoryStream(reader.GetSqlBinary(11).Value));
                    fr.image = new FSDK.CImage(img);
                    fr.faceImage = new FSDK.CImage(img_face);
                    
                    
                    FaceList.Add(fr);

                    imageList1.Images.Add(fr.faceImage.ToCLRImage());
                    string fn = fr.ImageFileName;
                    listView1.Items.Add((imageList1.Images.Count - 1).ToString(), fn.Split('\\')[fn.Split('\\').Length - 1], imageList1.Images.Count - 1);

                    textBox1.Text += "File '" + fn + "' read from database\r\n";
                    
                    img.Dispose();
                    img_face.Dispose();
                }
                
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Exception on loading database");
            }
            finally
            {
                if (sqlConnect != null)
                    sqlConnect.Close();
            }
        }

        private void ClearDB()
        {
            System.Data.SqlClient.SqlConnection sqlConnect = null;
            try
            {
                sqlConnect = new System.Data.SqlClient.SqlConnection("server=" + SQLServerAddress + "," + SQLServerPort + "; initial catalog=" + DatabaseName + "; Integrated Security=SSPI");
                sqlConnect.Open();
                System.Data.SqlClient.SqlCommand sqlCmd = new System.Data.SqlClient.SqlCommand("DELETE FROM FaceList", sqlConnect);

                int iresult = sqlCmd.ExecuteNonQuery();
                textBox1.Text += iresult + " rows modified in database.\r\n";
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Exception on clearing database");
            }
            finally
            {
                if (sqlConnect != null)
                    sqlConnect.Close();
            }
        }

        
       

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

            LoadDB();
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
            MessageBox.Show("Luxand Face Recognition Demo \r\n\r\n© 2010 Luxand, Inc.\r\nhttp://www.luxand.com", "About");
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
                            fr.FacialFeatures = fr.image.DetectEyesInRegion(ref fr.FacePosition);
                            fr.Template = fr.image.GetFaceTemplateInRegion(ref fr.FacePosition); // get template with higher precision
                            
                            SaveFaceInDB(fr);
                            FaceList.Add(fr);

                            imageList1.Images.Add(fr.faceImage.ToCLRImage());
                            listView1.Items.Add((imageList1.Images.Count - 1).ToString(), fn.Split('\\')[fn.Split('\\').Length - 1], imageList1.Images.Count - 1);

                            textBox1.Text += "File '" + fn + "' enrolled\r\n";
                            textBox1.Refresh();
                        }

                        listView1.SelectedIndices.Clear();
                        listView1.SelectedIndices.Add(listView1.Items.Count - 1);
                    }
                 
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Can't open image(s) with error: " + ex.Message.ToString(), "Error");
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
            ClearDB();
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

                        fr.image = new FSDK.CImage(fn);

                        fr.FacePosition = fr.image.DetectFace();
                        if (0 == fr.FacePosition.w)
                            MessageBox.Show("No faces found. Try to lower the Minimal Face Quality parameter in the Options dialog box.", "Enrollment error");
                        else
                        {
                            fr.faceImage = fr.image.CopyRect((int)(fr.FacePosition.xc - Math.Round(fr.FacePosition.w * 0.5)), (int)(fr.FacePosition.yc - Math.Round(fr.FacePosition.w * 0.5)), (int)(fr.FacePosition.xc + Math.Round(fr.FacePosition.w * 0.5)), (int)(fr.FacePosition.yc + Math.Round(fr.FacePosition.w * 0.5)));
                            fr.FacialFeatures = fr.image.DetectEyesInRegion(ref fr.FacePosition);
                            fr.Template = fr.image.GetFaceTemplateInRegion(ref fr.FacePosition); // get template with higher precision
                            Results frmResults = new Results();
                            frmResults.Go(fr);
                        }
                        
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
