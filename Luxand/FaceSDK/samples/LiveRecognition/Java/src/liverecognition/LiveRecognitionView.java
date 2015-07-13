/*
 * LiveRecognitionView.java
 * 
 * To edit GUI in visual editor of Netbeans 7.2+ you can install Swing Application Framework plugin:
 * http://plugins.netbeans.org/plugin/43853/swing-application-framework-support
 * Do not forget to restart Netbeans after installing the plugin!
 */

package liverecognition;

import org.jdesktop.application.Action;
import org.jdesktop.application.SingleFrameApplication;
import org.jdesktop.application.FrameView;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.*;
import java.awt.image.BufferedImage;
import javax.swing.*;
import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;
import Luxand.*;
import Luxand.FSDK.*;
import Luxand.FSDKCam.*;


/**
 * The application's main frame.
 */
public class LiveRecognitionView extends FrameView {
    public LiveRecognitionView(SingleFrameApplication app) {
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
           
        // creating a Tracker
        if (FSDK.FSDKE_OK != FSDK.LoadTrackerMemoryFromFile(tracker, TrackerMemoryFile)) // try to load saved tracker state
            FSDK.CreateTracker(tracker); // if could not be loaded, create a new tracker

        // set realtime face detection parameters
        int err[] = new int[1];
        err[0] = 0;
        FSDK.SetTrackerMultipleParameters(tracker, "HandleArbitraryRotations=false; DetermineFaceRotationAngle=false; InternalResizeWidth=100; FaceDetectionThreshold=5;", err);
        
        FSDKCam.InitializeCapturing();
                
        TCameras cameraList = new TCameras();
        int count[] = new int[1];
        FSDKCam.GetCameraList(cameraList, count);
        if (count[0] == 0){
            JOptionPane.showMessageDialog(mainFrame, "Please attach a camera"); 
            System.exit(1);
        }
        
        String cameraName = cameraList.cameras[0];
        
        FSDK_VideoFormats formatList = new FSDK_VideoFormats();
        FSDKCam.GetVideoFormatList(cameraName, formatList, count);
        FSDKCam.SetVideoFormat(cameraName, formatList.formats[0]);
        
        cameraHandle = new HCamera();
        int r = FSDKCam.OpenVideoCamera(cameraName, cameraHandle);
        if (r != FSDK.FSDKE_OK){
            JOptionPane.showMessageDialog(mainFrame, "Error opening camera"); 
            System.exit(r);
        }
        
        
        // Timer to draw and process image from camera
        drawingTimer = new Timer(40, new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                HImage imageHandle = new HImage();
                if (FSDKCam.GrabFrame(cameraHandle, imageHandle) == FSDK.FSDKE_OK){
                    Image awtImage[] = new Image[1];
                    if (FSDK.SaveImageToAWTImage(imageHandle, awtImage, FSDK_IMAGEMODE.FSDK_IMAGE_COLOR_24BIT) == FSDK.FSDKE_OK){
                        
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
                            
    			    String [] name = new String[1];
			    int res = FSDK.GetAllNames(tracker, IDs[i], name, 65536); // maximum of 65536 characters
    
			    if (FSDK.FSDKE_OK == res && name[0].length() > 0) { // draw name
                                gr.setFont(new Font("Arial", Font.BOLD, 16));
                                FontMetrics fm = gr.getFontMetrics();
                                java.awt.geom.Rectangle2D textRect = fm.getStringBounds(name[0], gr);
                                gr.drawString(name[0], (int)(facePosition.xc - textRect.getWidth()/2), (int)(top + w + textRect.getHeight()));
                            }

                            if (mouseX >= left && mouseX <= left + w && mouseY >= top && mouseY <= top + w){
                                gr.setColor(Color.blue);
                                
                                if (programStateRemember == programState) {
                                    if (FSDK.FSDKE_OK == FSDK.LockID(tracker, IDs[i]))
                                    {
                                        // get the user name
                                        userName = (String)JOptionPane.showInputDialog(mainFrame, "Your name:", "Enter your name", JOptionPane.QUESTION_MESSAGE, null, null, "User");
                                        FSDK.SetName(tracker, IDs[i], userName);
                                        FSDK.UnlockID(tracker, IDs[i]);
                                    }
                                }
                            }
                            programState = programStateRecognize;
                            
                            gr.drawRect(left, top, w, w); // draw face rectangle
                        }
                        
                        // display current frame
                        mainFrame.getRootPane().getGraphics().drawImage((bufImage != null) ? bufImage : awtImage[0], 0, 0, null);
                    }
                    FSDK.FreeImage(imageHandle); // delete the FaceSDK image handle
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

        mainPanel.setName("mainPanel"); // NOI18N
        mainPanel.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseEntered(java.awt.event.MouseEvent evt) {
                mainPanelMouseEntered(evt);
            }
            public void mouseExited(java.awt.event.MouseEvent evt) {
                mainPanelMouseExited(evt);
            }
            public void mouseReleased(java.awt.event.MouseEvent evt) {
                mainPanelMouseReleased(evt);
            }
        });
        mainPanel.addMouseMotionListener(new java.awt.event.MouseMotionAdapter() {
            public void mouseMoved(java.awt.event.MouseEvent evt) {
                mainPanelMouseMoved(evt);
            }
        });

        javax.swing.ActionMap actionMap = org.jdesktop.application.Application.getInstance(liverecognition.LiveRecognitionApp.class).getContext().getActionMap(LiveRecognitionView.class, this);
        jButton1.setAction(actionMap.get("buttonStart")); // NOI18N
        org.jdesktop.application.ResourceMap resourceMap = org.jdesktop.application.Application.getInstance(liverecognition.LiveRecognitionApp.class).getContext().getResourceMap(LiveRecognitionView.class);
        jButton1.setText(resourceMap.getString("jButton1.text")); // NOI18N
        jButton1.setName("jButton1"); // NOI18N

        jLabel1.setText(resourceMap.getString("jLabel1.text")); // NOI18N
        jLabel1.setName("jLabel1"); // NOI18N

        javax.swing.GroupLayout mainPanelLayout = new javax.swing.GroupLayout(mainPanel);
        mainPanel.setLayout(mainPanelLayout);
        mainPanelLayout.setHorizontalGroup(
            mainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(mainPanelLayout.createSequentialGroup()
                .addContainerGap(327, Short.MAX_VALUE)
                .addGroup(mainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, mainPanelLayout.createSequentialGroup()
                        .addComponent(jLabel1)
                        .addGap(101, 101, 101))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, mainPanelLayout.createSequentialGroup()
                        .addComponent(jButton1, javax.swing.GroupLayout.PREFERRED_SIZE, 80, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addContainerGap())))
        );
        mainPanelLayout.setVerticalGroup(
            mainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, mainPanelLayout.createSequentialGroup()
                .addContainerGap(314, Short.MAX_VALUE)
                .addComponent(jLabel1)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jButton1)
                .addContainerGap())
        );

        jLabel1.getAccessibleContext().setAccessibleName(resourceMap.getString("jLabel1.AccessibleContext.accessibleName")); // NOI18N

        setComponent(mainPanel);
    }// </editor-fold>//GEN-END:initComponents

    private void mainPanelMouseReleased(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_mainPanelMouseReleased
        programState = programStateRemember;
    }//GEN-LAST:event_mainPanelMouseReleased

    private void mainPanelMouseEntered(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_mainPanelMouseEntered
    }//GEN-LAST:event_mainPanelMouseEntered

    private void mainPanelMouseExited(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_mainPanelMouseExited
        mouseX = 0;
        mouseY = 0;
    }//GEN-LAST:event_mainPanelMouseExited

    private void mainPanelMouseMoved(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_mainPanelMouseMoved
        mouseX = evt.getX();
        mouseY = evt.getY();
    }//GEN-LAST:event_mainPanelMouseMoved

    @Action
    public void buttonStart() {
        this.jButton1.setEnabled(false);
        drawingTimer.start();
    }
    
    public void saveTracker(){
        FSDK.SaveTrackerMemoryToFile(tracker, TrackerMemoryFile);
    }
    
    public void closeCamera(){
        FSDKCam.CloseVideoCamera(cameraHandle);
        FSDKCam.FinalizeCapturing();
        FSDK.Finalize();
    }

    
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton jButton1;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JPanel mainPanel;
    // End of variables declaration//GEN-END:variables
    
    public final Timer drawingTimer;
    private HCamera cameraHandle;
    private String userName;
    
    private List<FSDK_FaceTemplate.ByReference> faceTemplates; // set of face templates (we store 10)
    
    // program states: waiting for the user to click a face
    // and recognizing user's face
    final int programStateRemember = 1;
    final int programStateRecognize = 2;
    private int programState = programStateRecognize;
    
    private String TrackerMemoryFile = "tracker.dat";
    private int mouseX = 0;
    private int mouseY = 0;
    
    HTracker tracker = new HTracker(); 
}
