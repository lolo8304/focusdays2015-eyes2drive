/*
 * LiveRecognitionApp.java
 */

package liverecognition;

import org.jdesktop.application.Application;
import org.jdesktop.application.SingleFrameApplication;
import java.awt.event.*;

/**
 * The main class of the application.
 */
public class LiveRecognitionApp extends SingleFrameApplication {
    private LiveRecognitionView liveRecognitionViewFrame;

    /**
     * At startup create and show the main frame of the application.
     */
    @Override protected void startup() {
        liveRecognitionViewFrame = new LiveRecognitionView(this);
        show(liveRecognitionViewFrame);
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
                liveRecognitionViewFrame.drawingTimer.stop();
                try{
                    Thread.sleep(40);
                }
                catch (java.lang.InterruptedException exception){
                }
                liveRecognitionViewFrame.saveTracker();
                liveRecognitionViewFrame.closeCamera();
            }
        });
    }

    /**
     * A convenient static getter for the application instance.
     * @return the instance of LiveRecognitionApp
     */
    public static LiveRecognitionApp getApplication() {
        return Application.getInstance(LiveRecognitionApp.class);
    }

    /**
     * Main method launching the application.
     */
    public static void main(String[] args) {
        launch(LiveRecognitionApp.class, args);
    }
}
