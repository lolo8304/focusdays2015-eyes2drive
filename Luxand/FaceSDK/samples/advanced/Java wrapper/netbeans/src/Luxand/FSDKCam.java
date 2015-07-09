/*
 * FaceSDK Library Interface
 */
package Luxand;

import com.sun.jna.Pointer;
import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.ptr.*;
import com.sun.jna.Platform; 
import Luxand.FSDK.*;

public class FSDKCam {
    
    // Types
    
    public static class HCamera {
        protected int hcamera;
    }
    
    public static class FSDK_VideoFormatInfo extends com.sun.jna.Structure {
        public static class ByValue extends FSDK_VideoFormatInfo implements com.sun.jna.Structure.ByValue {}
        public static class ByReference extends FSDK_VideoFormatInfo implements com.sun.jna.Structure.ByReference {}
        @Override
        public String toString(){
            return Integer.toString(Width).trim() + "x" + Integer.toString(Height).trim() + ", " + Integer.toString(BPP).trim() + " BPP";
        }
        public int Width, Height, BPP;
    }
    public static class FSDK_VideoFormats {
        public FSDK_VideoFormatInfo.ByValue formats[];
    }
    
    public static class TCameras {
        public String cameras[];
    }
    
        
    private interface IFaceSDK extends Library {
        IFaceSDK INSTANCE = (IFaceSDK) Native.loadLibrary((Platform.isWindows()||Platform.isWindowsCE()) ? "facesdk" : "fsdk", IFaceSDK.class); //-.dll, lib-, -.so, -.dylib auto-added
        
        // Webcam usage
        int FSDK_SetHTTPProxy(String ServerNameOrIPAddress, short Port, String UserName, String Password);
        int FSDK_InitializeCapturing();
        int FSDK_FinalizeCapturing();
        int FSDK_GetCameraList(PointerByReference CameraList, IntByReference CameraCount);
        int FSDK_GetCameraListEx(PointerByReference CameraNameList, PointerByReference CameraDevicePathList, IntByReference CameraCount);
        int FSDK_FreeCameraList(Pointer CameraList, int CameraCount);
        int FSDK_OpenIPVideoCamera(int CompressionType, String URL, String Username, String Password, int TimeoutSeconds, IntByReference CameraHandle);
        int FSDK_OpenVideoCamera(com.sun.jna.WString CameraName, IntByReference CameraHandle);
        int FSDK_CloseVideoCamera(int CameraHandle);
        int FSDK_GrabFrame(int CameraHandle, IntByReference Image);
        int FSDK_SetCameraNaming(byte UseDevicePathAsName);
        int FSDK_GetVideoFormatList(com.sun.jna.WString CameraName, PointerByReference VideoFormatList, IntByReference VideoFormatCount);
        int FSDK_FreeVideoFormatList(Pointer VideoFormatList);
        int FSDK_SetVideoFormat(com.sun.jna.WString CameraName, FSDK_VideoFormatInfo.ByValue VideoFormat);
    }
    
    // Public interface
    
    public static int SetHTTPProxy(String ServerNameOrIPAddress, int Port, String UserName, String Password){
        if (Port < 0 || Port > 65535)
            return FSDK.FSDKE_INVALID_ARGUMENT;
        return IFaceSDK.INSTANCE.FSDK_SetHTTPProxy(ServerNameOrIPAddress, (short)Port, UserName, Password);
    }
    
    public static int InitializeCapturing(){
        //if (Platform.isWindows() || Platform.isWindowsCE())
            return IFaceSDK.INSTANCE.FSDK_InitializeCapturing();
        //else
            //return FSDK.FSDKE_FAILED;
    }
    public static int FinalizeCapturing(){
        //if (Platform.isWindows() || Platform.isWindowsCE())
            return IFaceSDK.INSTANCE.FSDK_FinalizeCapturing();
        //else 
            //return FSDK.FSDKE_FAILED;
    }
    
    
    public static int GetCameraList(TCameras CameraList, int CameraCount[]){
        if (Platform.isWindows() || Platform.isWindowsCE()){
            if (CameraCount.length < 1)
                return FSDK.FSDKE_INVALID_ARGUMENT;
        
            PointerByReference ptmp = new PointerByReference();
            IntByReference tmp = new IntByReference();
            int res = IFaceSDK.INSTANCE.FSDK_GetCameraList(ptmp, tmp);
            if (res == FSDK.FSDKE_OK){
                int cnt = tmp.getValue();
                Pointer p = ptmp.getValue();
                CameraList.cameras = p.getStringArray(0, cnt, true);
                CameraCount[0] = cnt;
                IFaceSDK.INSTANCE.FSDK_FreeCameraList(p, cnt);
            }
            return res;
        } else {
            return FSDK.FSDKE_FAILED;
        }
    }
    
    public static int GetCameraListEx(TCameras CameraNameList, TCameras CameraDevicePathList, int CameraCount[]){
        if (Platform.isWindows() || Platform.isWindowsCE()){
            if (CameraCount.length < 1)
                return FSDK.FSDKE_INVALID_ARGUMENT;
        
            PointerByReference ptmp = new PointerByReference();
            PointerByReference ptmp2 = new PointerByReference();
            IntByReference tmp = new IntByReference();
            int res = IFaceSDK.INSTANCE.FSDK_GetCameraListEx(ptmp, ptmp2, tmp);
            if (res == FSDK.FSDKE_OK){
                int cnt = tmp.getValue();
                Pointer p = ptmp.getValue();
                Pointer p2 = ptmp2.getValue();
                CameraNameList.cameras = p.getStringArray(0, cnt, true);
                CameraDevicePathList.cameras = p2.getStringArray(0, cnt, true);
                CameraCount[0] = cnt;
                IFaceSDK.INSTANCE.FSDK_FreeCameraList(p, cnt);
                IFaceSDK.INSTANCE.FSDK_FreeCameraList(p2, cnt);
            }
            return res;
        } else {
            return FSDK.FSDKE_FAILED;
        }
    }
    
    
    public static int OpenIPVideoCamera(int CompressionType, String URL, String Username, String Password, int TimeoutSeconds, HCamera CameraHandle){
        IntByReference tmp = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_OpenIPVideoCamera(CompressionType, URL, Username, Password, TimeoutSeconds, tmp);
        CameraHandle.hcamera = tmp.getValue();
        return res;
    }
    public static int CloseVideoCamera(HCamera CameraHandle){
        return IFaceSDK.INSTANCE.FSDK_CloseVideoCamera(CameraHandle.hcamera);
    }
    public static int GrabFrame(HCamera CameraHandle, HImage Image){
        IntByReference tmp = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_GrabFrame(CameraHandle.hcamera, tmp);
        Image.himage = tmp.getValue();
        return res;
    }
    
    public static int OpenVideoCamera (String CameraName, HCamera CameraHandle) {
        if (Platform.isWindows() || Platform.isWindowsCE()){
            IntByReference tmp = new IntByReference();
            int res = IFaceSDK.INSTANCE.FSDK_OpenVideoCamera(new com.sun.jna.WString(CameraName), tmp);
            CameraHandle.hcamera = tmp.getValue();
            return res;
        } else {
            return FSDK.FSDKE_FAILED;
        }
        
    }
    public static int SetCameraNaming (boolean UseDevicePathAsName){
        if (Platform.isWindows() || Platform.isWindowsCE()){
            byte bUseDevicePathAsName = (byte)(UseDevicePathAsName?1:0);
            return IFaceSDK.INSTANCE.FSDK_SetCameraNaming(bUseDevicePathAsName);
        } else {
            return FSDK.FSDKE_FAILED;
        }
    }
    public static int GetVideoFormatList(String CameraName, FSDK_VideoFormats VideoFormatList, int VideoFormatCount[]){
        if (Platform.isWindows() || Platform.isWindowsCE()){
            if (VideoFormatCount.length < 1)
                return FSDK.FSDKE_INVALID_ARGUMENT;
            PointerByReference ptmp = new PointerByReference();
            IntByReference count = new IntByReference();
            int res =  IFaceSDK.INSTANCE.FSDK_GetVideoFormatList(new com.sun.jna.WString(CameraName), ptmp, count);
            if (res == FSDK.FSDKE_OK){
                int cnt = count.getValue();
                VideoFormatList.formats = new FSDK_VideoFormatInfo.ByValue[cnt];
                Pointer pt = ptmp.getValue();
                for (int i=0; i<cnt; i++){
                    VideoFormatList.formats[i] = new FSDK_VideoFormatInfo.ByValue();
                    VideoFormatList.formats[i].Width = pt.getInt(i*12 + 0);
                    VideoFormatList.formats[i].Height = pt.getInt(i*12 + 4);
                    VideoFormatList.formats[i].BPP = pt.getInt(i*12 + 8);
                }
                VideoFormatCount[0] = cnt;
                IFaceSDK.INSTANCE.FSDK_FreeVideoFormatList(pt);
            }
            return res;
        } else {
            return FSDK.FSDKE_FAILED;
        }
    }
    public static int SetVideoFormat(String CameraName, FSDK_VideoFormatInfo.ByValue VideoFormat){
        if (Platform.isWindows() || Platform.isWindowsCE()){
            return IFaceSDK.INSTANCE.FSDK_SetVideoFormat(new com.sun.jna.WString(CameraName), VideoFormat);
        } else {
            return FSDK.FSDKE_FAILED;
        }
    }

    
}
