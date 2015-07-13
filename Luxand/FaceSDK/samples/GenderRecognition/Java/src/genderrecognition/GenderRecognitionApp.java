/*
 * GenderRecognitionApp.java
 */

package genderrecognition;

import org.jdesktop.application.Application;
import org.jdesktop.application.SingleFrameApplication;
import java.awt.event.*;

/**
 * The main class of the application.
 */
public class GenderRecognitionApp extends SingleFrameApplication {
    private GenderRecognitionView genderRecognitionViewFrame;

    /**
     * At startup create and show the main frame of the application.
     */
    @Override protected void startup() {
        genderRecognitionViewFrame = new GenderRecognitionView(this);
        show(genderRecognitionViewFrame);
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
                genderRecognitionViewFrame.drawingTimer.stop();
                try{
                    Thread.sleep(40);
                }
                catch (java.lang.InterruptedException exception){
                }
                genderRecognitionViewFrame.closeCamera();
            }
        });
    }

    /**
     * A convenient static getter for the application instance.
     * @return the instance of GenderRecognitionApp
     */
    public static GenderRecognitionApp getApplication() {
        return Application.getInstance(GenderRecognitionApp.class);
    }

    /**
     * Main method launching the application.
     */
    public static void main(String[] args) {
        launch(GenderRecognitionApp.class, args);
    }
}
