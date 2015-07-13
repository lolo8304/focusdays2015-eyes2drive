using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace Lookalikes
{
    public partial class Options : Form
    {
        public Options()
        {
            InitializeComponent();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            this.Dispose();
        }

        private void Options_Load(object sender, EventArgs e)
        {
            numericUpDown1.Value = (decimal) Form1.FaceDetectionThreshold;
            numericUpDown2.Value = (decimal) Form1.FARValue;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Form1.FaceDetectionThreshold = (float)numericUpDown1.Value;
            Form1.FARValue = (float)numericUpDown2.Value;
            this.Dispose();
        }
    }
}
