/*
 * LiveFacialFeaturesView.java
 * 
 * To edit GUI in visual editor of Netbeans 7.2+ you can install Swing Application Framework plugin:
 * http://plugins.netbeans.org/plugin/43853/swing-application-framework-support
 * Do not forget to restart Netbeans after installing the plugin!
 */

package livefacialfeatures;

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
public class LiveFacialFeaturesView extends FrameView {
    public int width, height;
    public final Timer drawingTimer;
    private HCamera cameraHandle;
    private java.util.List<FSDK_Features.ByReference> facialFeaturesArray;
   
    public LiveFacialFeaturesView(SingleFrameApplication app) {
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
        FSDKCam.InitializeCapturing();
        
        final HTracker tracker = new HTracker();
        FSDK.CreateTracker(tracker);

        // set realtime face detection parameters
        int [] err =  new int[1];
        FSDK.SetTrackerMultipleParameters(tracker, "RecognizeFaces=false; DetectFacialFeatures=true; HandleArbitraryRotations=false; DetermineFaceRotationAngle=false; InternalResizeWidth=100; FaceDetectionThreshold=5;", err);
        
        
        TCameras cameraList = new TCameras();
        int count[] = new int[1];
        FSDKCam.GetCameraList(cameraList, count);
        if (count[0] == 0){
            JOptionPane.showMessageDialog(mainPanel, "Please attach a camera", "Error", JOptionPane.ERROR_MESSAGE); 
            System.exit(2);
        }
        String cameraName = cameraList.cameras[0];
        
        FSDK_VideoFormats formatList = new FSDK_VideoFormats();
        FSDKCam.GetVideoFormatList(cameraName, formatList, count);
        FSDKCam.SetVideoFormat(cameraName, formatList.formats[0]);
        
        this.width = formatList.formats[0].Width + 96;
        this.height = formatList.formats[0].Height + 96;
        
        cameraHandle = new HCamera();
        int r = FSDKCam.OpenVideoCamera(cameraName, cameraHandle);
        if (r != FSDK.FSDKE_OK){
            JOptionPane.showMessageDialog(mainFrame, "Error opening camera"); 
            System.exit(r);
        }        
        
        facialFeaturesArray = new java.util.LinkedList<FSDK_Features.ByReference>();
        
        // timer to draw image from camera
        drawingTimer = new Timer(40, new ActionListener() {
             public void actionPerformed(ActionEvent e) {
                HImage imageHandle = new HImage();
                if (FSDKCam.GrabFrame(cameraHandle, imageHandle) == FSDK.FSDKE_OK){
                    Image awtImage[] = new Image[1];
                    if (FSDK.SaveImageToAWTImage(imageHandle, awtImage, FSDK_IMAGEMODE.FSDK_IMAGE_COLOR_24BIT) == FSDK.FSDKE_OK){
                        BufferedImage bufImage = null;
                        TFacePosition.ByReference facePosition = new TFacePosition.ByReference();
                        FSDK_Features.ByReference facialFeatures = new FSDK_Features.ByReference();
                        
                        long[] IDs = new long[256]; // maximum of 256 faces detected
                        long[] faceCount = new long[1];
                        
                        FSDK.FeedFrame(tracker, 0, imageHandle, faceCount, IDs); 
                        for (int i=0; i<faceCount[0]; ++i) {
                            FSDK.GetTrackerFacePosition(tracker, 0, IDs[i], facePosition);
                            FSDK.GetTrackerFacialFeatures(tracker, 0, IDs[i], facialFeatures);

                            int left = facePosition.xc - (int)(facePosition.w * 0.6);
                            int top = facePosition.yc - (int)(facePosition.w * 0.5);
                            int w = (int)(facePosition.w * 1.2);
                            
                            bufImage = new BufferedImage(awtImage[0].getWidth(null), awtImage[0].getHeight(null), BufferedImage.TYPE_INT_ARGB);
                            Graphics gr = bufImage.getGraphics(); 
                            gr.drawImage(awtImage[0], 0, 0, null);
                            gr.setColor(Color.blue);
                            for (int j = 0; j < FSDK.FSDK_FACIAL_FEATURE_COUNT; j++){
                                gr.fillOval(facialFeatures.features[j].x, facialFeatures.features[j].y, 5, 5);
                            }
                            gr.setColor(Color.green);
                            gr.drawRect(left, top, w, w); // draw face rectangle
                        }                 
                        
                        
                        /*
                        // if a face is detected, we detect facial features
                        if (FSDK.FSDKE_OK == FSDK.DetectFace(imageHandle, facePosition)){
                            FSDK_Features.ByReference facialFeatures = new FSDK_Features.ByReference();
                            FSDK.DetectFacialFeaturesInRegion(imageHandle, facePosition, facialFeatures);
                            SmoothFacialFeatures(facialFeatures);
                            
                            bufImage = new BufferedImage(awtImage[0].getWidth(null), awtImage[0].getHeight(null), BufferedImage.TYPE_INT_ARGB);
                            Graphics gr = bufImage.getGraphics(); 
                            gr.drawImage(awtImage[0], 0, 0, null);
                            
                            gr.setColor(Color.blue);
                            for (int i = 0; i < FSDK.FSDK_FACIAL_FEATURE_COUNT; i++){
                                gr.fillOval(facialFeatures.features[i].x, facialFeatures.features[i].y, 5, 5);
                            }
                            gr.setColor(Color.green);
                            int left = facePosition.xc - (2 * facePosition.w) / 3;
                            int top = facePosition.yc - facePosition.w / 2;
                            gr.drawRect(left, top, 4 * facePosition.w / 3, 4 * facePosition.w / 3);
                        } else {
                            ResetSmoothing();
                        }
                        */
                                    
                        // display current frame
                        mainFrame.getRootPane().getGraphics().drawImage((bufImage != null) ? bufImage : awtImage[0], 0, 0, null);
                    }
                    
                    // delete the FSDK image handle
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

        mainPanel.setName("mainPanel"); // NOI18N
        mainPanel.setPreferredSize(new java.awt.Dimension(640, 480));

        javax.swing.ActionMap actionMap = org.jdesktop.application.Application.getInstance(livefacialfeatures.LiveFacialFeaturesApp.class).getContext().getActionMap(LiveFacialFeaturesView.class, this);
        jButton1.setAction(actionMap.get("buttonStart")); // NOI18N
        org.jdesktop.application.ResourceMap resourceMap = org.jdesktop.application.Application.getInstance(livefacialfeatures.LiveFacialFeaturesApp.class).getContext().getResourceMap(LiveFacialFeaturesView.class);
        jButton1.setText(resourceMap.getString("jButton1.text")); // NOI18N
        jButton1.setName("jButton1"); // NOI18N

        javax.swing.GroupLayout mainPanelLayout = new javax.swing.GroupLayout(mainPanel);
        mainPanel.setLayout(mainPanelLayout);
        mainPanelLayout.setHorizontalGroup(
            mainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, mainPanelLayout.createSequentialGroup()
                .addContainerGap(434, Short.MAX_VALUE)
                .addComponent(jButton1)
                .addContainerGap())
        );
        mainPanelLayout.setVerticalGroup(
            mainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, mainPanelLayout.createSequentialGroup()
                .addContainerGap(374, Short.MAX_VALUE)
                .addComponent(jButton1)
                .addContainerGap())
        );

        setComponent(mainPanel);
    }// </editor-fold>//GEN-END:initComponents

    @Action
    public void buttonStart() {
        drawingTimer.start();
        jButton1.setEnabled(false);
    }
    
    public void closeCamera(){
        FSDKCam.CloseVideoCamera(cameraHandle);
        FSDKCam.FinalizeCapturing();
        FSDK.Finalize();
    }
        
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton jButton1;
    private javax.swing.JPanel mainPanel;
    // End of variables declaration//GEN-END:variables
    

}
