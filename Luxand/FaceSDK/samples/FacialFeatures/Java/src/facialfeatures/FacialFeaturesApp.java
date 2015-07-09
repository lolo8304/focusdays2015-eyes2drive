/*
 * FacialFeaturesApp.java
 */

package facialfeatures;

import org.jdesktop.application.Application;
import org.jdesktop.application.SingleFrameApplication;
import java.awt.event.*;

/**
 * The main class of the application.
 */
public class FacialFeaturesApp extends SingleFrameApplication {
    private FacialFeaturesView facialFeaturesViewFrame;

    /**
     * At startup create and show the main frame of the application.
     */
    @Override protected void startup() {
        facialFeaturesViewFrame = new FacialFeaturesView(this);
        show(facialFeaturesViewFrame);
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
                facialFeaturesViewFrame.closeFrame();
            }
        });
    }

    /**
     * A convenient static getter for the application instance.
     * @return the instance of FacialFeaturesApp
     */
    public static FacialFeaturesApp getApplication() {
        return Application.getInstance(FacialFeaturesApp.class);
    }

    /**
     * Main method launching the application.
     */
    public static void main(String[] args) {
        launch(FacialFeaturesApp.class, args);
    }
}
