/*
 * FaceTrackingApp.java
 */

package facetracking;

import org.jdesktop.application.Application;
import org.jdesktop.application.SingleFrameApplication;
import java.awt.event.*;

/**
 * The main class of the application.
 */
public class FaceTrackingApp extends SingleFrameApplication {
    private FaceTrackingView faceTrackingViewFrame;

    /**
     * At startup create and show the main frame of the application.
     */
    @Override protected void startup() {
        faceTrackingViewFrame = new FaceTrackingView(this);
        show(faceTrackingViewFrame);
    }

    /**
     * This method is to initialize the specified window by injecting resources.
     * Windows shown in our application come fully initialized from the GUI
     * builder, so this additional configuration is not needed.
     */
    @Override protected void configureWindow(java.awt.Window root) {
        root.addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent e) {
                faceTrackingViewFrame.drawingTimer.stop();
                try{
                    Thread.sleep(40);
                }
                catch (java.lang.InterruptedException exception){
                }
                faceTrackingViewFrame.closeCamera();
            }
        });
    }

    /**
     * A convenient static getter for the application instance.
     * @return the instance of FaceTrackingApp
     */
    public static FaceTrackingApp getApplication() {
        return Application.getInstance(FaceTrackingApp.class);
    }

    /**
     * Main method launching the application.
     */
    public static void main(String[] args) {
        launch(FaceTrackingApp.class, args);
    }
}
