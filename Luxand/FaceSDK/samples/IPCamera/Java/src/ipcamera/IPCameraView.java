/*
 * IPCameraView.java
 * 
 * To edit GUI in visual editor of Netbeans 7.2+ you can install Swing Application Framework plugin:
 * http://plugins.netbeans.org/plugin/43853/swing-application-framework-support
 * Do not forget to restart Netbeans after installing the plugin!
 */

package IPCamera;

import org.jdesktop.application.Action;
import org.jdesktop.application.SingleFrameApplication;
import org.jdesktop.application.FrameView;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.*;
import java.awt.image.BufferedImage;
import javax.swing.*;
import Luxand.*;
import Luxand.FSDK.*;
import Luxand.FSDKCam.*;

/**
 * The application's main frame.
 */
public class IPCameraView extends FrameView {
   
    public IPCameraView(SingleFrameApplication app) {
        super(app);

        initComponents();
        
        final JPanel mainFrame = this.mainPanel;
        
        try {
            int r = FSDK.ActivateLibrary("Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M=");
            if (r != FSDK.FSDKE_OK){
               JOptionPane.showMessageDialog(mainPanel, "Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)", "Error activating FaceSDK", JOptionPane.ERROR_MESSAGE); 
               System.exit(r);
            }
        } 
        catch(java.lang.UnsatisfiedLinkError e) {
            JOptionPane.showMessageDialog(mainPanel, e.toString(), "Link Error", JOptionPane.ERROR_MESSAGE);
            System.exit(1);
        }    
            
        FSDK.Initialize();
        
        final HTracker tracker = new HTracker();
        FSDK.CreateTracker(tracker);

        // set realtime face detection parameters
        int [] err =  new int[1];
        FSDK.SetTrackerMultipleParameters(tracker, "RecognizeFaces=false; HandleArbitraryRotations=false; DetermineFaceRotationAngle=false; InternalResizeWidth=100; FaceDetectionThreshold=5;", err);
        
        CameraOpened = false;
        
        // Timer to draw image from camera
        
        drawingTimer = new Timer(40, new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                HImage imageHandle = new HImage();
                if (FSDKCam.GrabFrame(cameraHandle, imageHandle) == FSDK.FSDKE_OK)
                {
                    HImage ResizedImageHandle = new HImage();
                
                    Image awtImage[] = new Image[1];
                    
                    int imageWidthByReference[] = new int[1];
                    int imageHeightByReference[] = new int[1];
                    FSDK.GetImageWidth(imageHandle, imageWidthByReference);
                    FSDK.GetImageHeight(imageHandle, imageHeightByReference);
                    int width = imageWidthByReference[0];
                    int height = imageHeightByReference[0];
                        
                    int areawidth = mainFrame.getRootPane().getWidth();
                    int areaheight = mainFrame.getRootPane().getHeight() - 40;
                    double resize = Math.min(areawidth/(double)width, areaheight/(double)height);
                    FSDK.CreateEmptyImage(ResizedImageHandle);
                    FSDK.ResizeImage(imageHandle, resize, ResizedImageHandle);
                    FSDK.GetImageWidth(ResizedImageHandle, imageWidthByReference);
                    width = imageWidthByReference[0];
                    if (FSDK.SaveImageToAWTImage(ResizedImageHandle, awtImage, FSDK_IMAGEMODE.FSDK_IMAGE_COLOR_24BIT) == FSDK.FSDKE_OK)
                    {                        
                        BufferedImage bufImage = null;
                        
                        TFacePosition.ByReference facePosition = new TFacePosition.ByReference();
                        
                        long[] IDs = new long[256]; // maximum of 256 faces detected
                        long[] faceCount = new long[1];
                        
                        FSDK.FeedFrame(tracker, 0, imageHandle, faceCount, IDs); 
                        for (int i=0; i<faceCount[0]; ++i) {
                            FSDK.GetTrackerFacePosition(tracker, 0, IDs[i], facePosition);
                            
                            int left = facePosition.xc - (int)(facePosition.w * 0.6);
                            int top = facePosition.yc - (int)(facePosition.w * 0.5);
                            int w = (int)(facePosition.w * 1.2);
                            
                            bufImage = new BufferedImage(awtImage[0].getWidth(null), awtImage[0].getHeight(null), BufferedImage.TYPE_INT_ARGB);
                            Graphics gr = bufImage.getGraphics(); 
                            gr.drawImage(awtImage[0], 0, 0, null);
                            gr.setColor(Color.green);
                            gr.drawRect(left, top, w, w); // draw face rectangle
                        }                 
                                    
                        mainFrame.getRootPane().getGraphics().drawImage(bufImage!=null?bufImage:awtImage[0], (areawidth - width)/2, 0, null);
                    }
                    FSDK.FreeImage(ResizedImageHandle);
                    FSDK.FreeImage(imageHandle);
                }
            }
        });
    }


    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        mainPanel = new javax.swing.JPanel();
        jButton1 = new javax.swing.JButton();
        jLabel1 = new javax.swing.JLabel();
        jTextField1 = new javax.swing.JTextField();
        jLabel2 = new javax.swing.JLabel();
        jTextField2 = new javax.swing.JTextField();
        jTextField3 = new javax.swing.JTextField();
        jLabel3 = new javax.swing.JLabel();

        mainPanel.setAutoscrolls(true);
        mainPanel.setMaximumSize(new java.awt.Dimension(888, 556));
        mainPanel.setMinimumSize(new java.awt.Dimension(888, 556));
        mainPanel.setName("mainPanel"); // NOI18N

        javax.swing.ActionMap actionMap = org.jdesktop.application.Application.getInstance(IPCamera.IPCameraApp.class).getContext().getActionMap(IPCameraView.class, this);
        jButton1.setAction(actionMap.get("buttonStart")); // NOI18N
        org.jdesktop.application.ResourceMap resourceMap = org.jdesktop.application.Application.getInstance(IPCamera.IPCameraApp.class).getContext().getResourceMap(IPCameraView.class);
        jButton1.setText(resourceMap.getString("jButton1.text")); // NOI18N
        jButton1.setName("jButton1"); // NOI18N

        jLabel1.setText(resourceMap.getString("address.text")); // NOI18N
        jLabel1.setName("address"); // NOI18N

        jTextField1.setText(resourceMap.getString("AddressBox.text")); // NOI18N
        jTextField1.setName("AddressBox"); // NOI18N

        jLabel2.setText(resourceMap.getString("user.text")); // NOI18N
        jLabel2.setName("user"); // NOI18N

        jTextField2.setText(resourceMap.getString("PasswordBox.text")); // NOI18N
        jTextField2.setName("PasswordBox"); // NOI18N

        jTextField3.setText(resourceMap.getString("UsernameBox.text")); // NOI18N
        jTextField3.setName("UsernameBox"); // NOI18N

        jLabel3.setText(resourceMap.getString("pass.text")); // NOI18N
        jLabel3.setName("pass"); // NOI18N

        javax.swing.GroupLayout mainPanelLayout = new javax.swing.GroupLayout(mainPanel);
        mainPanel.setLayout(mainPanelLayout);
        mainPanelLayout.setHorizontalGroup(
            mainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(mainPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jLabel1)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, 357, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(jLabel2)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jTextField3, javax.swing.GroupLayout.PREFERRED_SIZE, 109, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(jLabel3)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, 109, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 43, Short.MAX_VALUE)
                .addComponent(jButton1)
                .addContainerGap())
        );
        mainPanelLayout.setVerticalGroup(
            mainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, mainPanelLayout.createSequentialGroup()
                .addContainerGap(522, Short.MAX_VALUE)
                .addGroup(mainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jButton1)
                    .addComponent(jLabel1)
                    .addComponent(jTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel3)
                    .addComponent(jTextField3, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel2))
                .addContainerGap())
        );

        setComponent(mainPanel);
    }// </editor-fold>//GEN-END:initComponents

    @Action
    public void buttonStart() {
        if (CameraOpened)
            FSDKCam.CloseVideoCamera(cameraHandle);
        else
            cameraHandle = new HCamera();
        String address = this.jTextField1.getText();
        String username = this.jTextField3.getText();
        String password = this.jTextField2.getText();
        int r = FSDKCam.OpenIPVideoCamera(FSDK.FSDK_VIDEOCOMPRESSIONTYPE.FSDK_MJPEG, address, username, password, 5, cameraHandle);
        if (FSDK.FSDKE_OK !=  r){
            JOptionPane.showMessageDialog(this.mainPanel, "Error opening camera"); 
            System.exit(r);
        }
            
        if (!CameraOpened)
        {
            CameraOpened = true;
            drawingTimer.start();
        }
    }
    
    public void closeCamera(){
        if (CameraOpened)
            FSDKCam.CloseVideoCamera(cameraHandle);
        FSDK.Finalize();
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton jButton1;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JTextField jTextField1;
    private javax.swing.JTextField jTextField2;
    private javax.swing.JTextField jTextField3;
    private javax.swing.JPanel mainPanel;
    // End of variables declaration//GEN-END:variables
    
    public final Timer drawingTimer;
    private HCamera cameraHandle;
    private Boolean CameraOpened;
 
}
