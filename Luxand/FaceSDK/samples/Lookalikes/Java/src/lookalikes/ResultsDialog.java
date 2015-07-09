/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * ResultsDialog.java
 *
 * Created on Sep 13, 2013, 7:02:30 AM
 */
package lookalikes;

import java.awt.*;
import java.awt.image.BufferedImage;
import javax.swing.*;
import java.util.*;
import Luxand.*;
import Luxand.FSDK.*;

/**
 *
 * @author root
 */
public class ResultsDialog extends javax.swing.JDialog {
    public LookalikesView.TFaceRecord faceRecord;
    
    private final ImagePanel imagePanel = new ImagePanel();
    private ImagePanel oldImagePanel = null;
    
    public final DefaultListModel listModel = new DefaultListModel();
    public final java.util.List<ImageIcon> listImages = new ArrayList<ImageIcon>();
    public final java.util.List<String> listStrings = new ArrayList<String>();
    private final MyJListCellRenderer listRenderer = new MyJListCellRenderer();
    
    
    class MyJListCellRenderer extends JLabel implements ListCellRenderer  
    {
        public MyJListCellRenderer() {
            setOpaque(true);
            setHorizontalAlignment(CENTER);
            setVerticalAlignment(CENTER);
            setHorizontalTextPosition(CENTER);
            setVerticalTextPosition(BOTTOM);
        }
        @Override
        public Component getListCellRendererComponent(JList list, Object value, int index, boolean isSelected, boolean cellHasFocus)  
        {
            //Get the selected index. (The index param isn't
            //always valid, so just using the value as index.)
            int selectedIndex = ((Integer)value).intValue();
            
            if (isSelected) {
                //setBackground(list.getSelectionBackground());
                //setForeground(list.getSelectionForeground());
                // do not need to mark selected item here
                setBackground(list.getBackground());
                setForeground(list.getForeground());
            } else {
                setBackground(list.getBackground());
                setForeground(list.getForeground());
            }
            
            ImageIcon icon = listImages.get(selectedIndex);
            String str = listStrings.get(selectedIndex);
            setIcon(icon);
            if (icon != null) {
                setText(str);
            } else {
                setText("(no image available) " + str);
            }
            return this;  
        }  
    }
    
    // Component to draw image on
    private class ImagePanel extends JPanel {
        Image image;
        public void setImage(Image image) {
            this.image = image;
        }
        @Override
        public void paintComponent(Graphics gr) {
            if(image != null) {
                gr.clearRect(0, 0, LookalikesView.width, LookalikesView.height);
                gr.drawImage(image, 0, 0, this);
            }
        }
        @Override
        public Dimension getPreferredSize() {
            int w, h;
            if(image == null) {
                return new Dimension(0, 0);
            }
            w = image.getWidth(null);
            h = image.getHeight(null);
            return new Dimension((w > 0) ? w : 0, (h > 0) ? h : 0);
        }
    }

    public void DrawFaceImage(LookalikesView.TFaceRecord fr) {
        // resize image to fit the window width/height
        int imageWidthByReference[] = new int[1];
        int imageHeightByReference[] = new int[1];
        FSDK.GetImageWidth(fr.image, imageWidthByReference);
        FSDK.GetImageHeight(fr.image, imageHeightByReference);
        int imageWidth = imageWidthByReference[0];
        int imageHeight = imageHeightByReference[0];
        double ratio = java.lang.Math.min((LookalikesView.width + 0.4) / imageWidth,
            (LookalikesView.height + 0.4) / imageHeight);
        HImage tempImage = new HImage();
        FSDK.CreateEmptyImage(tempImage);
        FSDK.ResizeImage(fr.image, ratio, tempImage);


        // save image to awt.Image
        Image awtImage[] = new Image[1];
        int res = FSDK.SaveImageToAWTImage(tempImage, awtImage, FSDK.FSDK_IMAGEMODE.FSDK_IMAGE_COLOR_24BIT);
        FSDK.FreeImage(tempImage);
        FSDK.FreeImage(fr.image);
        FSDK.FreeImage(fr.faceImage);
        if (res != FSDK.FSDKE_OK){
            JOptionPane.showMessageDialog(getContentPane(), "Error displaying picture");
            this.setVisible(false);
        } 
        BufferedImage bimg = new BufferedImage(awtImage[0].getWidth(null), awtImage[0].getHeight(null), BufferedImage.TYPE_INT_ARGB);
        Graphics gr = bimg.getGraphics(); 
        gr.drawImage(awtImage[0], 0, 0, null);
          
        // draw image on window
        imagePanel.setImage((bimg != null) ? bimg : awtImage[0]);

        GroupLayout layout = (GroupLayout)getContentPane().getLayout();
        if (oldImagePanel == null) {
            layout.replace(jPanel1, imagePanel);
        } else {
            layout.replace(oldImagePanel, imagePanel);
        }
        oldImagePanel = imagePanel;
    }
    
    /** Creates new form ResultsDialog */
    public ResultsDialog(java.awt.Frame parent, boolean modal) {
        super(parent, modal);
        initComponents();
        
        this.setSize(640, 760); 
        
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jScrollPane1 = new javax.swing.JScrollPane();
        jList1 = new javax.swing.JList();
        jLabel1 = new javax.swing.JLabel();
        jPanel1 = new javax.swing.JPanel();

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        org.jdesktop.application.ResourceMap resourceMap = org.jdesktop.application.Application.getInstance(lookalikes.LookalikesApp.class).getContext().getResourceMap(ResultsDialog.class);
        setTitle(resourceMap.getString("Form.title")); // NOI18N
        setName("Form"); // NOI18N

        jScrollPane1.setName("jScrollPane1"); // NOI18N

        jList1.setModel(listModel);
        jList1.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_SELECTION);
        jList1.setCellRenderer(listRenderer);
        jList1.setLayoutOrientation(javax.swing.JList.HORIZONTAL_WRAP);
        jList1.setName("jList1"); // NOI18N
        jList1.setVisibleRowCount(1);
        jScrollPane1.setViewportView(jList1);

        jLabel1.setText(resourceMap.getString("jLabel1.text")); // NOI18N
        jLabel1.setName("jLabel1"); // NOI18N
        jLabel1.setOpaque(true);

        jPanel1.setName("jPanel1"); // NOI18N

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 100, Short.MAX_VALUE)
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 100, Short.MAX_VALUE)
        );

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 597, Short.MAX_VALUE)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jLabel1)
                .addContainerGap(511, Short.MAX_VALUE))
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(487, Short.MAX_VALUE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 179, Short.MAX_VALUE)
                .addComponent(jLabel1)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 150, javax.swing.GroupLayout.PREFERRED_SIZE))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    /**
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(new Runnable() {

            public void run() {
                ResultsDialog dialog = new ResultsDialog(new javax.swing.JFrame(), true);
                dialog.addWindowListener(new java.awt.event.WindowAdapter() {

                    public void windowClosing(java.awt.event.WindowEvent e) {
                        System.exit(0);
                    }
                });
                dialog.setVisible(true);
            }
        });
    }
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JLabel jLabel1;
    private javax.swing.JList jList1;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JScrollPane jScrollPane1;
    // End of variables declaration//GEN-END:variables
}
