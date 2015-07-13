<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Form1
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.PictureBox1 = New System.Windows.Forms.PictureBox
        Me.Button1 = New System.Windows.Forms.Button
        Me.PasswordBox = New System.Windows.Forms.TextBox
        Me.UsernameBox = New System.Windows.Forms.TextBox
        Me.Pass = New System.Windows.Forms.Label
        Me.User = New System.Windows.Forms.Label
        Me.address = New System.Windows.Forms.Label
        Me.AddressBox = New System.Windows.Forms.TextBox
        CType(Me.PictureBox1, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'PictureBox1
        '
        Me.PictureBox1.Location = New System.Drawing.Point(15, 12)
        Me.PictureBox1.Name = "PictureBox1"
        Me.PictureBox1.Size = New System.Drawing.Size(959, 565)
        Me.PictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom
        Me.PictureBox1.TabIndex = 0
        Me.PictureBox1.TabStop = False
        '
        'Button1
        '
        Me.Button1.Location = New System.Drawing.Point(864, 583)
        Me.Button1.Name = "Button1"
        Me.Button1.Size = New System.Drawing.Size(110, 28)
        Me.Button1.TabIndex = 1
        Me.Button1.Text = "Start"
        Me.Button1.UseVisualStyleBackColor = True
        '
        'PasswordBox
        '
        Me.PasswordBox.Location = New System.Drawing.Point(740, 588)
        Me.PasswordBox.Name = "PasswordBox"
        Me.PasswordBox.Size = New System.Drawing.Size(118, 20)
        Me.PasswordBox.TabIndex = 2
        '
        'UsernameBox
        '
        Me.UsernameBox.Location = New System.Drawing.Point(555, 588)
        Me.UsernameBox.Name = "UsernameBox"
        Me.UsernameBox.Size = New System.Drawing.Size(118, 20)
        Me.UsernameBox.TabIndex = 3
        Me.UsernameBox.Text = "admin"
        '
        'Pass
        '
        Me.Pass.AutoSize = True
        Me.Pass.Location = New System.Drawing.Point(679, 591)
        Me.Pass.Name = "Pass"
        Me.Pass.Size = New System.Drawing.Size(55, 13)
        Me.Pass.TabIndex = 4
        Me.Pass.Text = "password:"
        '
        'User
        '
        Me.User.AutoSize = True
        Me.User.Location = New System.Drawing.Point(493, 591)
        Me.User.Name = "User"
        Me.User.Size = New System.Drawing.Size(56, 13)
        Me.User.TabIndex = 5
        Me.User.Text = "username:"
        '
        'address
        '
        Me.address.AutoSize = True
        Me.address.Location = New System.Drawing.Point(12, 591)
        Me.address.Name = "address"
        Me.address.Size = New System.Drawing.Size(47, 13)
        Me.address.TabIndex = 6
        Me.address.Text = "address:"
        '
        'AddressBox
        '
        Me.AddressBox.Location = New System.Drawing.Point(65, 588)
        Me.AddressBox.Name = "AddressBox"
        Me.AddressBox.Size = New System.Drawing.Size(422, 20)
        Me.AddressBox.TabIndex = 7
        '
        'Form1
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(986, 623)
        Me.Controls.Add(Me.AddressBox)
        Me.Controls.Add(Me.address)
        Me.Controls.Add(Me.User)
        Me.Controls.Add(Me.Pass)
        Me.Controls.Add(Me.UsernameBox)
        Me.Controls.Add(Me.PasswordBox)
        Me.Controls.Add(Me.Button1)
        Me.Controls.Add(Me.PictureBox1)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Me.MaximizeBox = False
        Me.MinimizeBox = False
        Me.Name = "Form1"
        Me.Text = " IP Camera Face Tracking"
        CType(Me.PictureBox1, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents PictureBox1 As System.Windows.Forms.PictureBox
    Friend WithEvents Button1 As System.Windows.Forms.Button
    Friend WithEvents PasswordBox As System.Windows.Forms.TextBox
    Friend WithEvents UsernameBox As System.Windows.Forms.TextBox
    Friend WithEvents Pass As System.Windows.Forms.Label
    Friend WithEvents User As System.Windows.Forms.Label
    Friend WithEvents address As System.Windows.Forms.Label
    Friend WithEvents AddressBox As System.Windows.Forms.TextBox

End Class
