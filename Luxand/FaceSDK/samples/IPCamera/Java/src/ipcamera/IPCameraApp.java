/*
 * IPCameraApp.java
 */

package IPCamera;

import org.jdesktop.application.Application;
import org.jdesktop.application.SingleFrameApplication;
import java.awt.event.*;

/**
 * The main class of the application.
 */
public class IPCameraApp extends SingleFrameApplication {
    private IPCameraView IPCameraViewFrame;

    /**
     * At startup create and show the main frame of the application.
     */
    @Override protected void startup() {
        IPCameraViewFrame = new IPCameraView(this);
        show(IPCameraViewFrame);
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
                IPCameraViewFrame.drawingTimer.stop();
                try{
                    Thread.sleep(40);
                }
                catch (java.lang.InterruptedException exception){
                }
                IPCameraViewFrame.closeCamera();
            }
        });
    }

    /**
     * A convenient static getter for the application instance.
     * @return the instance of IPCameraApp
     */
    public static IPCameraApp getApplication() {
        return Application.getInstance(IPCameraApp.class);
    }

    /**
     * Main method launching the application.
     */
    public static void main(String[] args) {
        launch(IPCameraApp.class, args);
    }
}
