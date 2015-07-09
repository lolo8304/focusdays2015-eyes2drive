using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using Luxand;

namespace Lookalikes
{
    public partial class Results : Form
    {
        static ImageList imageList1;

        public Results()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.Dispose();
        }

        public void Go(TFaceRecord SearchFace)
        {
            Image img = SearchFace.image.ToCLRImage();
            pictureBox1.Image = img;
            pictureBox1.Height = img.Height;
            pictureBox1.Width = img.Width;

            imageList1 = new ImageList();
            Size size100x100 = new Size();
            size100x100.Height = 100;
            size100x100.Width = 100;
            imageList1.ImageSize = size100x100;
            imageList1.ColorDepth = ColorDepth.Depth24Bit;
            
            listView1.OwnerDraw = false;
            listView1.View = View.LargeIcon;
            listView1.Dock = DockStyle.Bottom;
            listView1.LargeImageList = imageList1;

            label1.Dock = DockStyle.Bottom;

            float Threshold = 0.0f;
            FSDK.GetMatchingThresholdAtFAR(Form1.FARValue/100, ref Threshold);

            int MatchedCount = 0;
            int FaceCount = Form1.FaceList.Count;
            float[] Similarities = new float[FaceCount];
            int[] Numbers = new int[FaceCount]; 
            
            for (int i = 0; i < Form1.FaceList.Count; i++) {
                float Similarity = 0.0f;
                TFaceRecord CurrentFace = Form1.FaceList[i];
                FSDK.MatchFaces(ref SearchFace.Template, ref CurrentFace.Template, ref Similarity);
                if (Similarity >= Threshold) {
                    Similarities[MatchedCount] = Similarity;
                    Numbers[MatchedCount] = i;
                    ++MatchedCount;
                } 
            }

            if (MatchedCount == 0)
                MessageBox.Show("No matches found. You can try to increase the FAR parameter in the Options dialog box.", "No matches");
            else {
                floatReverseComparer cmp = new floatReverseComparer();
                Array.Sort(Similarities, Numbers, 0, MatchedCount, (IComparer<float>)cmp);

                label1.Text = "Faces Matched: " + MatchedCount.ToString();
                for (int i = 0; i < MatchedCount; i++){
                    imageList1.Images.Add(Form1.FaceList[Numbers[i]].faceImage.ToCLRImage());
                    listView1.Items.Add((Similarities[i] * 100.0f).ToString(System.Globalization.CultureInfo.InvariantCulture.NumberFormat),
                        Form1.FaceList[Numbers[i]].ImageFileName.Split('\\')[Form1.FaceList[Numbers[i]].ImageFileName.Split('\\').Length - 1] +
                        "\r\nSimilarity = " + (Similarities[i] * 100).ToString(),
                        imageList1.Images.Count - 1);
                }
            }
            
                   
            this.Show();
        }

    }
    public class floatReverseComparer : IComparer<float>
    {
        public int Compare(float x, float y)
        {
            return y.CompareTo(x);
        }
    }
}
