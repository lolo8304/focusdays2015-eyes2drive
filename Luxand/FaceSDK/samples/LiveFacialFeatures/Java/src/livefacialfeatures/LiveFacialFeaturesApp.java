/*
 * LiveFacialFeaturesApp.java
 */

package livefacialfeatures;

import org.jdesktop.application.Application;
import org.jdesktop.application.SingleFrameApplication;
import java.awt.event.*;

/**
 * The main class of the application.
 */
public class LiveFacialFeaturesApp extends SingleFrameApplication {
    private LiveFacialFeaturesView liveFacialFeaturesViewFrame;

    /**
     * At startup create and show the main frame of the application.
     */
    @Override protected void startup() {
        liveFacialFeaturesViewFrame = new LiveFacialFeaturesView(this);
        show(liveFacialFeaturesViewFrame);
        liveFacialFeaturesViewFrame.getFrame().setSize(liveFacialFeaturesViewFrame.width, liveFacialFeaturesViewFrame.height);
        liveFacialFeaturesViewFrame.getFrame().setResizable(false);
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
                liveFacialFeaturesViewFrame.drawingTimer.stop();
                try{
                    Thread.sleep(40);
                }
                catch (java.lang.InterruptedException exception){
                }
                liveFacialFeaturesViewFrame.closeCamera();
            }
        });
    }

    /**
     * A convenient static getter for the application instance.
     * @return the instance of LiveFacialFeaturesApp
     */
    public static LiveFacialFeaturesApp getApplication() {
        return Application.getInstance(LiveFacialFeaturesApp.class);
    }

    /**
     * Main method launching the application.
     */
    public static void main(String[] args) {
        launch(LiveFacialFeaturesApp.class, args);
    }
}
