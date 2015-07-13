/*
 * LookalikesApp.java
 */

package lookalikes;

import org.jdesktop.application.Application;
import org.jdesktop.application.SingleFrameApplication;
import java.awt.event.*;

/**
 * The main class of the application.
 */
public class LookalikesApp extends SingleFrameApplication {
    private LookalikesView lookalikesViewFrame;

    /**
     * At startup create and show the main frame of the application.
     */
    @Override protected void startup() {
        lookalikesViewFrame = new LookalikesView(this);
        show(lookalikesViewFrame);
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
                lookalikesViewFrame.closeFrame();
            }
        });
    }

    /**
     * A convenient static getter for the application instance.
     * @return the instance of LookalikesApp
     */
    public static LookalikesApp getApplication() {
        return Application.getInstance(LookalikesApp.class);
    }

    /**
     * Main method launching the application.
     */
    public static void main(String[] args) {
        launch(LookalikesApp.class, args);
    }
}
