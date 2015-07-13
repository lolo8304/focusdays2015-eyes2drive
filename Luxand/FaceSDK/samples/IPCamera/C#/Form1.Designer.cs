namespace FaceTracking
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.button1 = new System.Windows.Forms.Button();
            this.AddressBox = new System.Windows.Forms.TextBox();
            this.adress = new System.Windows.Forms.Label();
            this.user = new System.Windows.Forms.Label();
            this.UsernameBox = new System.Windows.Forms.TextBox();
            this.pass = new System.Windows.Forms.Label();
            this.PasswordBox = new System.Windows.Forms.TextBox();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.SuspendLayout();
            // 
            // pictureBox1
            // 
            this.pictureBox1.Location = new System.Drawing.Point(15, 12);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(890, 472);
            this.pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pictureBox1.TabIndex = 0;
            this.pictureBox1.TabStop = false;
            // 
            // button1
            // 
            this.button1.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
            this.button1.Location = new System.Drawing.Point(830, 490);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(75, 23);
            this.button1.TabIndex = 1;
            this.button1.Text = "Open";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // AddressBox
            // 
            this.AddressBox.Location = new System.Drawing.Point(59, 492);
            this.AddressBox.Name = "AddressBox";
            this.AddressBox.Size = new System.Drawing.Size(392, 20);
            this.AddressBox.TabIndex = 2;
            // 
            // adress
            // 
            this.adress.AutoSize = true;
            this.adress.Location = new System.Drawing.Point(12, 495);
            this.adress.Name = "adress";
            this.adress.Size = new System.Drawing.Size(41, 13);
            this.adress.TabIndex = 3;
            this.adress.Text = "adress:";
            // 
            // user
            // 
            this.user.AutoSize = true;
            this.user.Location = new System.Drawing.Point(457, 495);
            this.user.Name = "user";
            this.user.Size = new System.Drawing.Size(56, 13);
            this.user.TabIndex = 5;
            this.user.Text = "username:";
            // 
            // UsernameBox
            // 
            this.UsernameBox.Location = new System.Drawing.Point(519, 492);
            this.UsernameBox.Name = "UsernameBox";
            this.UsernameBox.Size = new System.Drawing.Size(101, 20);
            this.UsernameBox.TabIndex = 4;
            this.UsernameBox.Text = "admin";
            // 
            // pass
            // 
            this.pass.AutoSize = true;
            this.pass.Location = new System.Drawing.Point(626, 495);
            this.pass.Name = "pass";
            this.pass.Size = new System.Drawing.Size(55, 13);
            this.pass.TabIndex = 7;
            this.pass.Text = "password:";
            // 
            // PasswordBox
            // 
            this.PasswordBox.Location = new System.Drawing.Point(687, 492);
            this.PasswordBox.Name = "PasswordBox";
            this.PasswordBox.Size = new System.Drawing.Size(101, 20);
            this.PasswordBox.TabIndex = 6;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(919, 522);
            this.Controls.Add(this.pass);
            this.Controls.Add(this.PasswordBox);
            this.Controls.Add(this.user);
            this.Controls.Add(this.UsernameBox);
            this.Controls.Add(this.adress);
            this.Controls.Add(this.AddressBox);
            this.Controls.Add(this.button1);
            this.Controls.Add(this.pictureBox1);
            this.Name = "Form1";
            this.Text = "IP Camera Face Tracking";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.Shown += new System.EventHandler(this.Form1_Shown);
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.Form1_FormClosing);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.TextBox AddressBox;
        private System.Windows.Forms.Label adress;
        private System.Windows.Forms.Label user;
        private System.Windows.Forms.TextBox UsernameBox;
        private System.Windows.Forms.Label pass;
        private System.Windows.Forms.TextBox PasswordBox;
    }
}

