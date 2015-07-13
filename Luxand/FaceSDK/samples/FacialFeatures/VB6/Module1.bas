Attribute VB_Name = "Module1"
Option Base 0
Option Explicit


Sub Main()
    If (FSDKVB_ActivateLibrary("Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M=") <> FSDKE_OK) Then
        MsgBox "Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)", vbOKOnly, "Error activating FaceSDK"
        Exit Sub
    End If
    
    FSDKVB_Initialize ""
 
    Dim frmMain As New Form1
    frmMain.Show
  
  
End Sub
