/*
 * FaceSDK Library Interface
 * Copyright Luxand, Inc. 2013
 */
package Luxand;

import com.sun.jna.Pointer;
import com.sun.jna.Memory;
import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.ptr.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.image.PixelGrabber;
import java.awt.color.ColorSpace;
import com.sun.jna.Platform; 

public class FSDK {
    
    // Error codes
    
    public static final int FSDKE_OK = 0;
    public static final int FSDKE_FAILED = -1;
    public static final int FSDKE_NOT_ACTIVATED = -2;
    public static final int FSDKE_OUT_OF_MEMORY	= -3;
    public static final int FSDKE_INVALID_ARGUMENT = -4;
    public static final int FSDKE_IO_ERROR = -5;
    public static final int FSDKE_IMAGE_TOO_SMALL = -6;
    public static final int FSDKE_FACE_NOT_FOUND = -7;
    public static final int FSDKE_INSUFFICIENT_BUFFER_SIZE = -8;
    public static final int FSDKE_UNSUPPORTED_IMAGE_EXTENSION =	-9;
    public static final int FSDKE_CANNOT_OPEN_FILE = -10;
    public static final int FSDKE_CANNOT_CREATE_FILE = -11;
    public static final int FSDKE_BAD_FILE_FORMAT = -12;
    public static final int FSDKE_FILE_NOT_FOUND = -13;
    public static final int FSDKE_CONNECTION_CLOSED = -14;
    public static final int FSDKE_CONNECTION_FAILED = -15;
    public static final int FSDKE_IP_INIT_FAILED = -16;
    public static final int FSDKE_NEED_SERVER_ACTIVATION = -17;
    public static final int FSDKE_ID_NOT_FOUND = -18;
    public static final int FSDKE_ATTRIBUTE_NOT_DETECTED = -19;
    public static final int FSDKE_INSUFFICIENT_TRACKER_MEMORY_LIMIT = -20;
    public static final int FSDKE_UNKNOWN_ATTRIBUTE = -21;
    public static final int FSDKE_UNSUPPORTED_FILE_VERSION = -22;
    public static final int FSDKE_SYNTAX_ERROR = -23;
    public static final int FSDKE_PARAMETER_NOT_FOUND = -24;
    public static final int FSDKE_INVALID_TEMPLATE = -25;
    public static final int FSDKE_UNSUPPORTED_TEMPLATE_VERSION = -26;

    
    // Facial feature count
    
    public static final int FSDK_FACIAL_FEATURE_COUNT = 66;

    
    // Types
    
    public static class FSDK_VIDEOCOMPRESSIONTYPE {
        public static final int FSDK_MJPEG = 0;
    }
    
    public static class FSDK_IMAGEMODE {
        public static final int FSDK_IMAGE_GRAYSCALE_8BIT = 0;
        public static final int FSDK_IMAGE_COLOR_24BIT = 1;
        public static final int FSDK_IMAGE_COLOR_32BIT = 2;
    }
    
    public static class HImage {  //to pass himage "by reference"
        protected int himage; 
    }

    public static class HTracker {  //to pass htracker "by reference"
        protected int htracker; 
    }
    
    public static class TFacePosition extends com.sun.jna.Structure {
        public static class ByValue extends TFacePosition implements com.sun.jna.Structure.ByValue { }
        public static class ByReference extends TFacePosition implements com.sun.jna.Structure.ByReference { }
        public int xc, yc, w;
        public double angle;
        public TFacePosition(){ 
            super(); 
        }
        public TFacePosition(Pointer p, int offset){  //TO BE ABLE TO CAST Pointer TO THIS Structure
            super();
            xc = p.getInt(offset + 0);
            yc = p.getInt(offset + 4);
            w = p.getInt(offset + 8);
            angle = p.getDouble(offset + 16);
        }
    }
    private static int sizeofTFacePosition = 24;
    
    public static class TFaces{
        public TFacePosition faces[];
        int maxFaces;
        public TFaces(){
            maxFaces = 100;
            faces = null;
        }
        public TFaces(int MaxFaces){
            maxFaces = MaxFaces;
            faces = null;
        }
    }
        
    public static class TPoint extends com.sun.jna.Structure {
        public static class ByValue extends TPoint implements com.sun.jna.Structure.ByValue { }
        public static class ByReference extends TPoint implements com.sun.jna.Structure.ByReference { }
        public int x, y;
    }
    
    public static class FSDK_Features extends com.sun.jna.Structure {
        public static class ByValue extends FSDK_Features implements com.sun.jna.Structure.ByValue {}
        public static class ByReference extends FSDK_Features implements com.sun.jna.Structure.ByReference {}
        public TPoint features[] = new TPoint[FSDK_FACIAL_FEATURE_COUNT];
    }
    
    /*
    public static class FSDK_Eyes extends com.sun.jna.Structure {
        public static class ByValue extends FSDK_Eyes implements com.sun.jna.Structure.ByValue {}
        public static class ByReference extends FSDK_Eyes implements com.sun.jna.Structure.ByReference {}
        public TPoint features[] = new TPoint[2];
    }
    */
    
    public static class FSDK_FaceTemplate extends com.sun.jna.Structure {
        public static class ByValue extends FSDK_FaceTemplate implements com.sun.jna.Structure.ByValue {}
        public static class ByReference extends FSDK_FaceTemplate implements com.sun.jna.Structure.ByReference {}
        public byte template[] = new byte[13324];
    }
    
    
        
    
    
    
    
    // Facial features

    public static final int FSDKP_LEFT_EYE = 0;
    public static final int FSDKP_RIGHT_EYE	= 1;
    public static final int FSDKP_LEFT_EYE_INNER_CORNER =	24;
    public static final int FSDKP_LEFT_EYE_OUTER_CORNER =	23;
    public static final int FSDKP_LEFT_EYE_LOWER_LINE1 =	38;
    public static final int FSDKP_LEFT_EYE_LOWER_LINE2 =	27;
    public static final int FSDKP_LEFT_EYE_LOWER_LINE3 =	37;
    public static final int FSDKP_LEFT_EYE_UPPER_LINE1 =	35;
    public static final int FSDKP_LEFT_EYE_UPPER_LINE2 =	28;
    public static final int FSDKP_LEFT_EYE_UPPER_LINE3 =	36;
    public static final int FSDKP_LEFT_EYE_LEFT_IRIS_CORNER =	29;
    public static final int FSDKP_LEFT_EYE_RIGHT_IRIS_CORNER =	30;
    public static final int FSDKP_RIGHT_EYE_INNER_CORNER =	25;
    public static final int FSDKP_RIGHT_EYE_OUTER_CORNER =	26;
    public static final int FSDKP_RIGHT_EYE_LOWER_LINE1 =	41;
    public static final int FSDKP_RIGHT_EYE_LOWER_LINE2 =	31;
    public static final int FSDKP_RIGHT_EYE_LOWER_LINE3 =	42;
    public static final int FSDKP_RIGHT_EYE_UPPER_LINE1 =	40;
    public static final int FSDKP_RIGHT_EYE_UPPER_LINE2 =	32;
    public static final int FSDKP_RIGHT_EYE_UPPER_LINE3 =	39;
    public static final int FSDKP_RIGHT_EYE_LEFT_IRIS_CORNER =	33;
    public static final int FSDKP_RIGHT_EYE_RIGHT_IRIS_CORNER =	34;
    public static final int FSDKP_LEFT_EYEBROW_INNER_CORNER	 = 13;
    public static final int FSDKP_LEFT_EYEBROW_MIDDLE =	16;
    public static final int FSDKP_LEFT_EYEBROW_MIDDLE_LEFT =	18;
    public static final int FSDKP_LEFT_EYEBROW_MIDDLE_RIGHT	= 19;
    public static final int FSDKP_LEFT_EYEBROW_OUTER_CORNER	= 12;
    public static final int FSDKP_RIGHT_EYEBROW_INNER_CORNER =	14;
    public static final int FSDKP_RIGHT_EYEBROW_MIDDLE =	17;
    public static final int FSDKP_RIGHT_EYEBROW_MIDDLE_LEFT =	20;
    public static final int FSDKP_RIGHT_EYEBROW_MIDDLE_RIGHT =	21;
    public static final int FSDKP_RIGHT_EYEBROW_OUTER_CORNER =	15;
    public static final int FSDKP_NOSE_TIP =	2;
    public static final int FSDKP_NOSE_BOTTOM =	49;
    public static final int FSDKP_NOSE_BRIDGE =	22;
    public static final int FSDKP_NOSE_LEFT_WING =	43;
    public static final int FSDKP_NOSE_LEFT_WING_OUTER =	45;
    public static final int FSDKP_NOSE_LEFT_WING_LOWER =	47;
    public static final int FSDKP_NOSE_RIGHT_WING =	44;
    public static final int FSDKP_NOSE_RIGHT_WING_OUTER =	46;
    public static final int FSDKP_NOSE_RIGHT_WING_LOWER =	48;
    public static final int FSDKP_MOUTH_RIGHT_CORNER =	3;
    public static final int FSDKP_MOUTH_LEFT_CORNER	= 4;
    public static final int FSDKP_MOUTH_TOP	= 54;
    public static final int FSDKP_MOUTH_TOP_INNER	= 61;
    public static final int FSDKP_MOUTH_BOTTOM =	55;
    public static final int FSDKP_MOUTH_BOTTOM_INNER =	64;
    public static final int FSDKP_MOUTH_LEFT_TOP =	56;
    public static final int FSDKP_MOUTH_LEFT_TOP_INNER =	60;
    public static final int FSDKP_MOUTH_RIGHT_TOP =	57;
    public static final int FSDKP_MOUTH_RIGHT_TOP_INNER =	62;
    public static final int FSDKP_MOUTH_LEFT_BOTTOM =	58;
    public static final int FSDKP_MOUTH_LEFT_BOTTOM_INNER =	63;
    public static final int FSDKP_MOUTH_RIGHT_BOTTOM =	59;
    public static final int FSDKP_MOUTH_RIGHT_BOTTOM_INNER =	65;
    public static final int FSDKP_NASOLABIAL_FOLD_LEFT_UPPER =	50;
    public static final int FSDKP_NASOLABIAL_FOLD_LEFT_LOWER =	52;
    public static final int FSDKP_NASOLABIAL_FOLD_RIGHT_UPPER =	51;
    public static final int FSDKP_NASOLABIAL_FOLD_RIGHT_LOWER =	53;
    public static final int FSDKP_CHIN_BOTTOM =	11;
    public static final int FSDKP_CHIN_LEFT =	9;
    public static final int FSDKP_CHIN_RIGHT =	10;
    public static final int FSDKP_FACE_CONTOUR1 =	7;
    public static final int FSDKP_FACE_CONTOUR2 =	5;
    public static final int FSDKP_FACE_CONTOUR12 =	6;
    public static final int FSDKP_FACE_CONTOUR13 =	8;	
    
    
    
    
    
    
    private interface IFaceSDK extends Library {
        IFaceSDK INSTANCE = (IFaceSDK) Native.loadLibrary((Platform.isWindows()||Platform.isWindowsCE()) ? "facesdk" : "fsdk", IFaceSDK.class); //-.dll, lib-, -.so, -.dylib auto-added

        // Initialization functions
        int FSDK_ActivateLibrary(String key);
        int FSDK_SetNumThreads(int Num);
        int FSDK_GetNumThreads(IntByReference Num);
        int FSDK_Initialize(String notused);
        int FSDK_GetHardware_ID(Pointer HardwareID);
        int FSDK_GetLicenseInfo(Pointer LicenseInfo);
        int FSDK_Finalize();
        
        // Face detection functions
        int FSDK_DetectFace(int Image, TFacePosition.ByReference FacePosition);
        int FSDK_DetectMultipleFaces(int Image, IntByReference DetectedCount, Pointer FaceArray, int MaxSizeInBytes);
        int FSDK_DetectEyes(int Image, FSDK_Features.ByReference FacialFeatures);        
        int FSDK_DetectEyesInRegion(int Image, TFacePosition FacePosition, FSDK_Features.ByReference FacialFeatures);        
        int FSDK_DetectFacialFeatures(int Image, FSDK_Features.ByReference FacialFeatures);        
        int FSDK_DetectFacialFeaturesInRegion(int Image, TFacePosition FacePosition, FSDK_Features.ByReference FacialFeatures); 
        int FSDK_SetFaceDetectionParameters(byte HandleArbitraryRotations, byte DetermineFaceRotationAngle, int InternalResizeWidth);
        int FSDK_SetFaceDetectionThreshold(int Threshold);
        
        // Image manipulation functions
        int FSDK_CreateEmptyImage(IntByReference Image);
        int FSDK_LoadImageFromFile(IntByReference Image, String FileName);
        int FSDK_LoadImageFromFileWithAlpha(IntByReference Image, String FileName);
        int FSDK_LoadImageFromFileW(IntByReference Image, com.sun.jna.WString FileName);
        int FSDK_LoadImageFromFileWithAlphaW(IntByReference Image, com.sun.jna.WString FileName);
        int FSDK_LoadImageFromBuffer(IntByReference Image, byte[] Buffer, int Width, int Height, int ScanLine, int ImageMode);
        int FSDK_FreeImage(int Image);
        int FSDK_SaveImageToFile(int Image, String FileName);
        int FSDK_SaveImageToFileW(int Image, com.sun.jna.WString FileName);
        int FSDK_GetImageBufferSize(int Image, IntByReference BufSize, int ImageMode);
        int FSDK_SaveImageToBuffer(int Image, Pointer Buffer, int ImageMode);
        int FSDK_SetJpegCompressionQuality(int Quality);
        int FSDK_CopyImage(int SourceImage, int DestImage);
        int FSDK_ResizeImage(int SourceImage, double ratio, int DestImage);
        int FSDK_RotateImage90(int SourceImage, int Multiplier, int DestImage);
        int FSDK_RotateImage(int SourceImage, double angle, int DestImage);
        int FSDK_RotateImageCenter(int SourceImage, double angle, double xCenter, double yCenter, int DestImage);
        int FSDK_CopyRect(int SourceImage, int x1, int y1, int x2, int y2, int DestImage);
        int FSDK_CopyRectReplicateBorder(int SourceImage, int x1, int y1, int x2, int y2, int DestImage);
        int FSDK_MirrorImage(int Image, byte UseVerticalMirroringInsteadOfHorizontal);
        int FSDK_GetImageWidth(int Image, IntByReference Width);
        int FSDK_GetImageHeight(int Image, IntByReference Height);
        int FSDK_ExtractFaceImage(int Image, FSDK_Features.ByReference FacialFeatures, int Width, int Height, IntByReference ExtractedFaceImage, FSDK_Features.ByReference ResizedFeatures);
        
        // Matching
        int FSDK_GetFaceTemplate(int Image, FSDK_FaceTemplate.ByReference FaceTemplate);
        int FSDK_MatchFaces(FSDK_FaceTemplate.ByReference FaceTemplate1, FSDK_FaceTemplate.ByReference FaceTemplate2, FloatByReference Similarity);
        int FSDK_GetFaceTemplateInRegion(int Image, TFacePosition FacePosition, FSDK_FaceTemplate.ByReference FaceTemplate);
        int FSDK_GetFaceTemplateUsingFeatures(int Image, FSDK_Features FacialFeatures, FSDK_FaceTemplate.ByReference FaceTemplate);
        int FSDK_GetFaceTemplateUsingEyes(int Image, FSDK_Features eyeCoords, FSDK_FaceTemplate.ByReference FaceTemplate);
        int FSDK_GetMatchingThresholdAtFAR(float FARValue, FloatByReference Threshold);
        int FSDK_GetMatchingThresholdAtFRR(float FRRValue, FloatByReference Threshold);
        int FSDK_GetDetectedFaceConfidence(IntByReference Confidence);

        // Tracker
        int FSDK_CreateTracker(IntByReference Tracker);
        int FSDK_FreeTracker(int Tracker);
        int FSDK_ClearTracker(int Tracker);
        int FSDK_SetTrackerParameter(int Tracker, String ParameterName, String ParameterValue);
        int FSDK_SetTrackerMultipleParameters(int Tracker, String Parameters, IntByReference ErrorPosition);
        int FSDK_GetTrackerParameter(int Tracker, String ParameterName, Pointer ParameterValue, long MaxSizeInBytes); 
        int FSDK_FeedFrame(int Tracker, long CameraIdx, int Image, LongByReference FaceCount, Pointer IDs, long MaxSizeInBytes);
        int FSDK_GetTrackerEyes(int Tracker, long CameraIdx, long ID, FSDK_Features.ByReference FacialFeatures);
        int FSDK_GetTrackerFacialFeatures(int Tracker, long CameraIdx, long ID, FSDK_Features.ByReference FacialFeatures);
        int FSDK_GetTrackerFacePosition(int Tracker, long CameraIdx, long ID, TFacePosition.ByReference FacePosition);
        int FSDK_LockID(int Tracker, long ID);
        int FSDK_UnlockID(int Tracker, long ID);
        int FSDK_GetName(int Tracker, long ID, Pointer Name, long MaxSizeInBytes);
        int FSDK_SetName(int Tracker, long ID, String Name);
        int FSDK_GetIDReassignment(int Tracker, long ID, LongByReference ReassignedID);
        int FSDK_GetSimilarIDCount(int Tracker, long ID, LongByReference Count);
        int FSDK_GetSimilarIDList(int Tracker, long ID, Pointer SimilarIDList, long MaxSizeInBytes);
        int FSDK_GetAllNames(int Tracker, long ID, Pointer Names, long MaxSizeInBytes);    
        int FSDK_LoadTrackerMemoryFromFile(IntByReference Tracker, String FileName);    
        int FSDK_SaveTrackerMemoryToFile(int Tracker, String FileName);
        int FSDK_LoadTrackerMemoryFromBuffer(IntByReference Tracker, byte[] Buffer);
        int FSDK_GetTrackerMemoryBufferSize(int Tracker, LongByReference BufSize);
        int FSDK_SaveTrackerMemoryToBuffer(int Tracker, byte[] Buffer, long MaxSizeInBytes);
        
        //Attribute detection
        int FSDK_GetTrackerFacialAttribute(int Tracker, long CameraIdx, long ID, String AttributeName, Pointer AttributeValues, long MaxSizeInBytes); 
        int FSDK_DetectFacialAttributeUsingFeatures(int Image, FSDK_Features FacialFeatures, String AttributeName, Pointer AttributeValues, long MaxSizeInBytes);
        int FSDK_GetValueConfidence(String AttributeValues, String Value, FloatByReference Confidence);

        
    }
    
    // Public interface
    
    public static int GetHardware_ID(String HardwareID[]){
        if (HardwareID.length < 1)
            return FSDKE_INVALID_ARGUMENT;
        Pointer buf = new Memory(1024);
        int res = IFaceSDK.INSTANCE.FSDK_GetHardware_ID(buf);
        if (res == FSDKE_OK)
            HardwareID[0] = buf.getString(0);
        return res;
    }
    
    public static int GetLicenseInfo(String LicenseInfo[]){
        if (LicenseInfo.length < 1)
            return FSDKE_INVALID_ARGUMENT;
        Pointer buf = new Memory(1024);
        int res = IFaceSDK.INSTANCE.FSDK_GetLicenseInfo(buf);
        if (res == FSDKE_OK)
            LicenseInfo[0] = buf.getString(0);
        return res;
    }
        
    public static int ActivateLibrary(String LicenseKey){
        return IFaceSDK.INSTANCE.FSDK_ActivateLibrary(LicenseKey);
    }
    
    public static int SetNumThreads(int Num){
        return IFaceSDK.INSTANCE.FSDK_SetNumThreads(Num);
    }
    
    public static int GetNumThreads(int Num[]){
        if (Num.length < 1)
            return FSDKE_INVALID_ARGUMENT;
        IntByReference tmp = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_GetNumThreads(tmp);
        Num[0] = tmp.getValue();
        return res;
    }
    
    public static int Initialize(){
        return IFaceSDK.INSTANCE.FSDK_Initialize("");
    }
            
    public static int Finalize(){
        return IFaceSDK.INSTANCE.FSDK_Finalize();
    }
    
    public static int CreateEmptyImage(HImage Image){
        IntByReference tmp = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_CreateEmptyImage(tmp);
        Image.himage = tmp.getValue();
        return res;
    }
    
    public static int FreeImage(HImage Image){
        return IFaceSDK.INSTANCE.FSDK_FreeImage(Image.himage);
    }
    
    public static int LoadImageFromFile(HImage Image, String FileName){
        IntByReference tmp = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_LoadImageFromFile(tmp, FileName);
        Image.himage = tmp.getValue();
        return res;
    }
    
    public static int LoadImageFromFileW(HImage Image, String FileName){
        IntByReference tmp = new IntByReference();
        int res = FSDKE_OK;
        if (Platform.isWindows() || Platform.isWindowsCE()){
            res = IFaceSDK.INSTANCE.FSDK_LoadImageFromFileW(tmp, new com.sun.jna.WString(FileName));
        } else { 
            res = IFaceSDK.INSTANCE.FSDK_LoadImageFromFile(tmp, FileName);
        }
        Image.himage = tmp.getValue();
        return res;
    }
    
    public static int LoadImageFromFileWithAlpha(HImage Image, String FileName){
        IntByReference tmp = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_LoadImageFromFileWithAlpha(tmp, FileName);
        Image.himage = tmp.getValue();
        return res;
    }
    
    public static int LoadImageFromFileWithAlphaW(HImage Image, String FileName){
        IntByReference tmp = new IntByReference();
        int res = FSDKE_OK;
        if (Platform.isWindows() || Platform.isWindowsCE()){
            res = IFaceSDK.INSTANCE.FSDK_LoadImageFromFileWithAlphaW(tmp, new com.sun.jna.WString(FileName));
        } else { 
            res = IFaceSDK.INSTANCE.FSDK_LoadImageFromFileWithAlpha(tmp, FileName);
        }
        Image.himage = tmp.getValue();
        return res;
    }
    
    public static int SaveImageToFile(HImage Image, String FileName){
        return IFaceSDK.INSTANCE.FSDK_SaveImageToFile(Image.himage, FileName);
    }
    
    public static int SaveImageToFileW(HImage Image, String FileName){
        if (Platform.isWindows() || Platform.isWindowsCE()){
            return IFaceSDK.INSTANCE.FSDK_SaveImageToFileW(Image.himage, new com.sun.jna.WString(FileName));
        } else { 
            return IFaceSDK.INSTANCE.FSDK_SaveImageToFile(Image.himage, FileName);
        }
    }
        
    public static int GetImageWidth(HImage Image, int Width[]){
        if (Width.length < 1)
            return FSDKE_INVALID_ARGUMENT;
        IntByReference tmp = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_GetImageWidth(Image.himage, tmp);
        if (res == FSDKE_OK)
            Width[0] = tmp.getValue();
        return res;
    }
    public static int GetImageHeight(HImage Image, int Height[]){
        if (Height.length < 1)
            return FSDKE_INVALID_ARGUMENT;
        IntByReference tmp = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_GetImageHeight(Image.himage, tmp);
        if (res == FSDKE_OK)
            Height[0] = tmp.getValue();
        return res;
    }
    
    public static int SaveImageToAWTImage(HImage Image, java.awt.Image DestImage[], int ImageMode){
        if (DestImage.length < 1)
            return FSDKE_INVALID_ARGUMENT;
        IntByReference bufSize = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_GetImageBufferSize(Image.himage, bufSize, ImageMode);
        if (res != FSDKE_OK) return res;
        int w[] = new int[1];
        res = GetImageWidth(Image, w);
        if (res != FSDKE_OK) return res;
        int h[] = new int[1];
        res = GetImageHeight(Image, h);
        if (res != FSDKE_OK) return res;
        byte Buffer[] = null;
        if (w[0] != 0 && h[0] != 0){
            Pointer buf = new Memory(bufSize.getValue());
            res = IFaceSDK.INSTANCE.FSDK_SaveImageToBuffer(Image.himage, buf, ImageMode);
            if (res == FSDKE_OK)
                 Buffer = buf.getByteArray(0, bufSize.getValue());
        }
        if (res != FSDKE_OK) {
            return res;
        } else {
            if (ImageMode == FSDK_IMAGEMODE.FSDK_IMAGE_COLOR_24BIT){
                int pix[] = new int[w[0]*h[0]];
                for (int i=0; i<bufSize.getValue()/3; ++i){
                    int r = Buffer[i*3+0];
                    int g = Buffer[i*3+1];
                    int b = Buffer[i*3+2];
                    pix[i] = (255 << 24) + (r << 16) + (g << 8) + b;
                }
                DestImage[0] = Toolkit.getDefaultToolkit().createImage(new java.awt.image.MemoryImageSource(w[0], h[0], pix, 0, w[0]));
            } else if (ImageMode == FSDK_IMAGEMODE.FSDK_IMAGE_COLOR_32BIT) {
                int pix[] = new int[w[0]*h[0]];
                for (int i=0; i<bufSize.getValue()/4; ++i){
                    int a = Buffer[i*4+3];
                    if (a == 0){  //FIXING STRANGE ALPHA CHANNEL PROCESSING IN JAVA
                        pix[i] = 0;
                    } else {
                        int r = Buffer[i*4+0];
                        int g = Buffer[i*4+1];
                        int b = Buffer[i*4+2];
                        pix[i] = (a << 24) + (r << 16) + (g << 8) + b;
                    }
                }
                ColorModel cm = new DirectColorModel(ColorSpace.getInstance(ColorSpace.CS_sRGB), 32, 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000, false, DataBuffer.TYPE_INT);
                //ColorModel cm = new DirectColorModel(ColorSpace.getInstance(ColorSpace.CS_sRGB), 32, 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000, true, DataBuffer.TYPE_INT);
                
                //ColorModel cm = ColorModel.getRGBdefault();
                /*
                 Number of bits:        32
                 Red mask:              0x00ff0000
                 Green mask:            0x0000ff00
                 Blue mask:             0x000000ff
                 Alpha mask:            0xff000000
                 Color space:           sRGB
                 isAlphaPremultiplied:  False
                 Transparency:          Transparency.TRANSLUCENT
                 transferType:          DataBuffer.TYPE_INT
                 */
                
                //return Toolkit.getDefaultToolkit().createImage(new java.awt.image.MemoryImageSource(w, h, cm, pix, 0, w));
                DestImage[0] = Toolkit.getDefaultToolkit().createImage(new java.awt.image.MemoryImageSource(w[0], h[0], cm, pix, 0, w[0]));
                
                //WARNING: loading from byte buffer doesn't work
                //ColorModel cm = new ComponentColorModel(ColorSpace.getInstance(ColorSpace.CS_sRGB), new int[] {8,8,8,8}, true, false, ComponentColorModel.TRANSLUCENT, DataBuffer.TYPE_BYTE);
                //MemoryImageSource ms = new java.awt.image.MemoryImageSource(w, h, cm, Buffer, 0, 4*w);
                //Image im = Toolkit.getDefaultToolkit().createImage(ms);
                //return im;
            } else if (ImageMode == FSDK_IMAGEMODE.FSDK_IMAGE_GRAYSCALE_8BIT){
                int pix[] = new int[w[0]*h[0]];
                for (int i=0; i<bufSize.getValue(); ++i){
                    int p = Buffer[i];
                    pix[i] = (255 << 24) + (p << 16) + (p << 8) + p;
                }
                ColorModel cm = ColorModel.getRGBdefault();
                DestImage[0] = Toolkit.getDefaultToolkit().createImage(new java.awt.image.MemoryImageSource(w[0], h[0], cm, pix, 0, w[0]));
            } else {
                return FSDKE_INVALID_ARGUMENT;
            }
            return FSDKE_OK;
        }
    }
    
    
    public static int LoadImageFromAWTImage(HImage Image, java.awt.Image SourceImage, int ImageMode){   //Using DirectColorModel with default channels order
        PixelGrabber pg = new PixelGrabber(SourceImage, 0, 0, SourceImage.getWidth(null), SourceImage.getHeight(null), false);//true);
        
        try {
            if (pg.grabPixels()){
                int w = pg.getWidth();
                int h = pg.getHeight();
                Object grabbed = pg.getPixels();
                if (ImageMode == FSDK_IMAGEMODE.FSDK_IMAGE_GRAYSCALE_8BIT && grabbed instanceof byte[]){
                    byte [] Buffer = (byte []) grabbed;
                    IntByReference tmp = new IntByReference();
                    int res = IFaceSDK.INSTANCE.FSDK_LoadImageFromBuffer(tmp, Buffer, w, h, w, ImageMode);
                    Image.himage = tmp.getValue();
                    return res;
                } else if (ImageMode == FSDK_IMAGEMODE.FSDK_IMAGE_COLOR_32BIT && grabbed instanceof int[]) {
                    int [] intBuffer = (int []) grabbed;
                    byte [] Buffer = new byte[w*h*4];
                    for (int i=0; i<w*h; ++i){
                        int pixel = intBuffer[i];
                        Buffer[i*4+0] = (byte)((pixel >> 16) & 0xff); //r
                        Buffer[i*4+1] = (byte)((pixel >>  8) & 0xff); //g
                        Buffer[i*4+2] = (byte)((pixel      ) & 0xff); //b
                        Buffer[i*4+3] = (byte)((pixel >> 24) & 0xff); //a
                    }
                    IntByReference tmp = new IntByReference();
                    int res = IFaceSDK.INSTANCE.FSDK_LoadImageFromBuffer(tmp, Buffer, w, h, 4*w, ImageMode);
                    Image.himage = tmp.getValue();
                    return res;
                } else if (ImageMode == FSDK_IMAGEMODE.FSDK_IMAGE_COLOR_24BIT && grabbed instanceof int[]) {
                    int [] intBuffer = (int []) grabbed;
                    byte [] Buffer = new byte[w*h*3];
                    for (int i=0; i<w*h; ++i){
                        int pixel = intBuffer[i];
                        Buffer[i*3+0] = (byte)((pixel >> 16) & 0xff); //r
                        Buffer[i*3+1] = (byte)((pixel >>  8) & 0xff); //g
                        Buffer[i*3+2] = (byte)((pixel      ) & 0xff); //b
                    }
                    IntByReference tmp = new IntByReference();
                    int res = IFaceSDK.INSTANCE.FSDK_LoadImageFromBuffer(tmp, Buffer, w, h, 3*w, ImageMode);
                    Image.himage = tmp.getValue();
                    return res;
                } else {
                    return FSDKE_INVALID_ARGUMENT;
                }
            } else {
                return FSDKE_IO_ERROR;
            }
        }
        catch (InterruptedException e1) {
            return FSDKE_FAILED;
        }
    }
    
    public static int DetectFace(HImage Image, TFacePosition.ByReference FacePosition){
        return IFaceSDK.INSTANCE.FSDK_DetectFace(Image.himage, FacePosition);
    }
    
    public static int DetectFacialFeatures(HImage Image, FSDK_Features.ByReference FacialFeatures){
        return IFaceSDK.INSTANCE.FSDK_DetectFacialFeatures(Image.himage, FacialFeatures);
    }

    public static int DetectFacialFeaturesInRegion(HImage Image, TFacePosition FacePosition, FSDK_Features.ByReference FacialFeatures){
        return IFaceSDK.INSTANCE.FSDK_DetectFacialFeaturesInRegion(Image.himage, FacePosition, FacialFeatures);
    }
    
    public static int DetectEyes(HImage Image, FSDK_Features.ByReference Eyes){
        return IFaceSDK.INSTANCE.FSDK_DetectEyes(Image.himage, Eyes);
    }

    public static int DetectEyesInRegion(HImage Image, TFacePosition FacePosition, FSDK_Features.ByReference Eyes){
        return IFaceSDK.INSTANCE.FSDK_DetectEyesInRegion(Image.himage, FacePosition, Eyes);
    }
    
    public static int DetectMultipleFaces(HImage Image, TFaces FacePositions){ 
        int bs = sizeofTFacePosition * FacePositions.maxFaces;
        Pointer facepos = new Memory(bs);
        IntByReference detected = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_DetectMultipleFaces(Image.himage, detected, facepos, bs);
        int det = detected.getValue();
        if (res == FSDKE_OK && det > 0){
            FacePositions.faces = new TFacePosition[det];
            for (int i=0; i < det; i++)
                FacePositions.faces[i] = new TFacePosition(facepos, i*sizeofTFacePosition);
        }
        return res;
    }
    
    public static int SetFaceDetectionParameters(boolean HandleArbitraryRotations, boolean DetermineFaceRotationAngle, int InternalResizeWidth){
        byte bHandleArbitraryRotations = (byte)(HandleArbitraryRotations?1:0);
        byte bDetermineFaceRotationAngle = (byte)(DetermineFaceRotationAngle?1:0);
        return IFaceSDK.INSTANCE.FSDK_SetFaceDetectionParameters(bHandleArbitraryRotations, bDetermineFaceRotationAngle, InternalResizeWidth);
    }
    
    public static int SetFaceDetectionThreshold(int Threshold){
        return IFaceSDK.INSTANCE.FSDK_SetFaceDetectionThreshold(Threshold);
    }

    public static int SetJpegCompressionQuality(int Quality){
        return IFaceSDK.INSTANCE.FSDK_SetJpegCompressionQuality(Quality);
    }
    public static int CopyImage(HImage SourceImage, HImage DestImage){
        return IFaceSDK.INSTANCE.FSDK_CopyImage(SourceImage.himage, DestImage.himage);
    }
    public static int ResizeImage(HImage SourceImage, double ratio, HImage DestImage){
        return IFaceSDK.INSTANCE.FSDK_ResizeImage(SourceImage.himage, ratio, DestImage.himage);
    }
    public static int RotateImage90(HImage SourceImage, int Multiplier, HImage DestImage){
        return IFaceSDK.INSTANCE.FSDK_RotateImage90(SourceImage.himage, Multiplier, DestImage.himage);
    }
    public static int RotateImage(HImage SourceImage, double angle, HImage DestImage){
        return IFaceSDK.INSTANCE.FSDK_RotateImage(SourceImage.himage, angle, DestImage.himage);
    }
    public static int RotateImageCenter(HImage SourceImage, double angle, double xCenter, double yCenter, HImage DestImage){
        return IFaceSDK.INSTANCE.FSDK_RotateImageCenter(SourceImage.himage, angle, xCenter, yCenter, DestImage.himage);
    }
    public static int CopyRect(HImage SourceImage, int x1, int y1, int x2, int y2, HImage DestImage){
        return IFaceSDK.INSTANCE.FSDK_CopyRect(SourceImage.himage, x1, y1, x2, y2, DestImage.himage);
    }
    public static int CopyRectReplicateBorder(HImage SourceImage, int x1, int y1, int x2, int y2, HImage DestImage){
        return IFaceSDK.INSTANCE.FSDK_CopyRectReplicateBorder(SourceImage.himage, x1, y1, x2, y2, DestImage.himage);
    }
    public static int MirrorImage(HImage Image, boolean UseVerticalMirroringInsteadOfHorizontal){
        byte bUseVerticalMirroringInsteadOfHorizontal = (byte)(UseVerticalMirroringInsteadOfHorizontal?1:0);
        return IFaceSDK.INSTANCE.FSDK_MirrorImage(Image.himage, bUseVerticalMirroringInsteadOfHorizontal);
    }
    public static int ExtractFaceImage(HImage Image, FSDK_Features.ByReference FacialFeatures, int Width, int Height, HImage ExtractedFaceImage, FSDK_Features.ByReference ResizedFeatures){
        IntByReference tmp = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_ExtractFaceImage(Image.himage, FacialFeatures, Width, Height, tmp, ResizedFeatures);
        ExtractedFaceImage.himage = tmp.getValue();
        return res;
    }
    
    
    
    public static int GetFaceTemplate(HImage Image, FSDK_FaceTemplate.ByReference FaceTemplate){
        return IFaceSDK.INSTANCE.FSDK_GetFaceTemplate(Image.himage, FaceTemplate);
    }
    public static int GetFaceTemplateInRegion(HImage Image, TFacePosition FacePosition, FSDK_FaceTemplate.ByReference FaceTemplate){
        return IFaceSDK.INSTANCE.FSDK_GetFaceTemplateInRegion(Image.himage, FacePosition, FaceTemplate);
    }
    public static int GetFaceTemplateUsingFeatures(HImage Image, FSDK_Features FacialFeatures, FSDK_FaceTemplate.ByReference FaceTemplate){
        return IFaceSDK.INSTANCE.FSDK_GetFaceTemplateUsingFeatures(Image.himage, FacialFeatures, FaceTemplate);
    }
    public static int GetFaceTemplateUsingEyes(HImage Image, FSDK_Features EyeCoords, FSDK_FaceTemplate.ByReference FaceTemplate){
        return IFaceSDK.INSTANCE.FSDK_GetFaceTemplateUsingEyes(Image.himage, EyeCoords, FaceTemplate);
    }
    public static int MatchFaces(FSDK_FaceTemplate.ByReference FaceTemplate1, FSDK_FaceTemplate.ByReference FaceTemplate2, float Similarity[]){
        if (Similarity.length < 1)
                return FSDKE_INVALID_ARGUMENT;
        FloatByReference tmp = new FloatByReference();
        int res = IFaceSDK.INSTANCE.FSDK_MatchFaces(FaceTemplate1, FaceTemplate2, tmp);
        Similarity[0] = tmp.getValue();
        return res;
    }
    public static int GetMatchingThresholdAtFAR(float FARValue, float Threshold[]){
        if (Threshold.length < 1)
                return FSDKE_INVALID_ARGUMENT;
        FloatByReference tmp = new FloatByReference();
        int res = IFaceSDK.INSTANCE.FSDK_GetMatchingThresholdAtFAR(FARValue, tmp);
        Threshold[0] = tmp.getValue();
        return res;
    }
    public static int GetMatchingThresholdAtFRR(float FRRValue, float Threshold[]){
        if (Threshold.length < 1)
                return FSDKE_INVALID_ARGUMENT;
        FloatByReference tmp = new FloatByReference();
        int res = IFaceSDK.INSTANCE.FSDK_GetMatchingThresholdAtFRR(FRRValue, tmp);
        Threshold[0] = tmp.getValue();
        return res;
    }
    public static int GetDetectedFaceConfidence(int Confidence[]){
        if (Confidence.length < 1)
                return FSDKE_INVALID_ARGUMENT;
        IntByReference tmp = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_GetDetectedFaceConfidence(tmp);
        Confidence[0] = tmp.getValue();
        return res;
    }

    
    //Tracker functions
    
    public static int CreateTracker(HTracker Tracker){
        IntByReference tmp = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_CreateTracker(tmp);
        Tracker.htracker = tmp.getValue();
        return res;
    }
    public static int FreeTracker(HTracker Tracker){
        return IFaceSDK.INSTANCE.FSDK_FreeTracker(Tracker.htracker);
    }
    public static int ClearTracker(HTracker Tracker){
        return IFaceSDK.INSTANCE.FSDK_ClearTracker(Tracker.htracker);
    }
    public static int SetTrackerParameter(HTracker Tracker, String ParameterName, String ParameterValue){
        return IFaceSDK.INSTANCE.FSDK_SetTrackerParameter(Tracker.htracker, ParameterName, ParameterValue);
    }
    public static int SetTrackerMultipleParameters(HTracker Tracker, String Parameters, int ErrorPosition[]){
        if (ErrorPosition.length < 1)
            return FSDKE_INVALID_ARGUMENT;
        IntByReference tmp = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_SetTrackerMultipleParameters(Tracker.htracker, Parameters, tmp);
        ErrorPosition[0] = tmp.getValue();
        return res;
    }
    public static int GetTrackerParameter(HTracker Tracker, String ParameterName, String ParameterValue[], long MaxSizeInBytes){
        if (MaxSizeInBytes < 1 || ParameterValue.length < 1)
            return FSDKE_INVALID_ARGUMENT;
        Pointer buf = new Memory(MaxSizeInBytes);
        int res = IFaceSDK.INSTANCE.FSDK_GetTrackerParameter(Tracker.htracker, ParameterName, buf, MaxSizeInBytes);
        if (res == FSDKE_OK)
            ParameterValue[0] = buf.getString(0);
        return res;
    }
    public static int FeedFrame(HTracker Tracker, long CameraIdx, HImage Image, long FaceCount[], long IDs[]){
        final int LONGLONGSIZE = 8;
        long IDsLen = IDs.length; //length is int in java!
        long MaxSizeInBytes = IDsLen * LONGLONGSIZE;
        if (FaceCount.length < 1 || IDsLen < 1)
            return FSDKE_INVALID_ARGUMENT;       
        LongByReference tmp = new LongByReference();
        Pointer buf = new Memory(MaxSizeInBytes);
        int res = IFaceSDK.INSTANCE.FSDK_FeedFrame(Tracker.htracker, CameraIdx, Image.himage, tmp, buf, MaxSizeInBytes);
        if (res == FSDKE_OK){
            FaceCount[0] = tmp.getValue();
            for (int i=0; i<IDsLen; ++i)
                IDs[i] = buf.getLong(LONGLONGSIZE*i); //offset - byte offset from pointer to perform the indirection
        }
        return res;
    }
    public static int GetTrackerEyes(HTracker Tracker, long CameraIdx, long ID, FSDK_Features.ByReference FacialFeatures){
        return IFaceSDK.INSTANCE.FSDK_GetTrackerEyes(Tracker.htracker, CameraIdx, ID, FacialFeatures);
    }
    public static int GetTrackerFacialFeatures(HTracker Tracker, long CameraIdx, long ID, FSDK_Features.ByReference FacialFeatures){
        return IFaceSDK.INSTANCE.FSDK_GetTrackerFacialFeatures(Tracker.htracker, CameraIdx, ID, FacialFeatures);
    }
    public static int GetTrackerFacePosition(HTracker Tracker, long CameraIdx, long ID, TFacePosition.ByReference FacePosition){
        return IFaceSDK.INSTANCE.FSDK_GetTrackerFacePosition(Tracker.htracker, CameraIdx, ID, FacePosition);
    }
    public static int LockID(HTracker Tracker, long ID){
        return IFaceSDK.INSTANCE.FSDK_LockID(Tracker.htracker, ID);
    }
    public static int UnlockID(HTracker Tracker, long ID){
        return IFaceSDK.INSTANCE.FSDK_UnlockID(Tracker.htracker, ID);
    }
    public static int SetName(HTracker Tracker, long ID, String Name){
        return IFaceSDK.INSTANCE.FSDK_SetName(Tracker.htracker, ID, Name);
    }
    public static int GetName(HTracker Tracker, long ID, String Name[], long MaxSizeInBytes){
        if (MaxSizeInBytes < 1 || Name.length < 1)
            return FSDKE_INVALID_ARGUMENT;
        Pointer buf = new Memory(MaxSizeInBytes);
        int res = IFaceSDK.INSTANCE.FSDK_GetName(Tracker.htracker, ID, buf, MaxSizeInBytes);
        if (res == FSDKE_OK)
            Name[0] = buf.getString(0);
        return res;
    }
    public static int GetAllNames(HTracker Tracker, long ID, String Names[], long MaxSizeInBytes){
        if (MaxSizeInBytes < 1 || Names.length < 1)
            return FSDKE_INVALID_ARGUMENT;
        Pointer buf = new Memory(MaxSizeInBytes);
        int res = IFaceSDK.INSTANCE.FSDK_GetAllNames(Tracker.htracker, ID, buf, MaxSizeInBytes);
        if (res == FSDKE_OK)
            Names[0] = buf.getString(0);
        return res;
    }
    public static int GetIDReassignment(HTracker Tracker, long ID, long ReassignedID[]){
        if (ReassignedID.length < 1)
            return FSDKE_INVALID_ARGUMENT;
        LongByReference tmp = new LongByReference();
        int res = IFaceSDK.INSTANCE.FSDK_GetIDReassignment(Tracker.htracker, ID, tmp);
        if (res == FSDKE_OK)
            ReassignedID[0] = tmp.getValue();
        return res;
    }
    public static int GetSimilarIDCount(HTracker Tracker, long ID, long Count[]){
        if (Count.length < 1)
            return FSDKE_INVALID_ARGUMENT;
        LongByReference tmp = new LongByReference();
        int res = IFaceSDK.INSTANCE.FSDK_GetSimilarIDCount(Tracker.htracker, ID, tmp);
        if (res == FSDKE_OK)
            Count[0] = tmp.getValue();
        return res;        
    }
    public static int GetSimilarIDList(HTracker Tracker, long ID, long SimilarIDList[]){
        final int LONGLONGSIZE = 8;
        long sLen = SimilarIDList.length; //length is int!
        long MaxSizeInBytes = sLen * LONGLONGSIZE;
        if (sLen < 1)
            return FSDKE_INVALID_ARGUMENT;       
        Pointer buf = new Memory(MaxSizeInBytes);
        int res = IFaceSDK.INSTANCE.FSDK_GetSimilarIDList(Tracker.htracker, ID, buf, MaxSizeInBytes);
        if (res == FSDKE_OK){
            for (int i=0; i<sLen; ++i)
                SimilarIDList[i] = buf.getLong(LONGLONGSIZE*i); //offset - byte offset from pointer to perform the indirection
        }
        return res;
    }
    public static int LoadTrackerMemoryFromFile(HTracker Tracker, String FileName){
        IntByReference tmp = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_LoadTrackerMemoryFromFile(tmp, FileName);
        Tracker.htracker = tmp.getValue();
        return res;
    }
    public static int SaveTrackerMemoryToFile(HTracker Tracker, String FileName){
        return IFaceSDK.INSTANCE.FSDK_SaveTrackerMemoryToFile(Tracker.htracker, FileName);
    }
    public static int LoadTrackerMemoryFromBuffer(HTracker Tracker, byte Buffer[]){
        IntByReference tmp = new IntByReference();
        int res = IFaceSDK.INSTANCE.FSDK_LoadTrackerMemoryFromBuffer(tmp, Buffer);
        Tracker.htracker = tmp.getValue();
        return res;
    }
    public static int GetTrackerMemoryBufferSize(HTracker Tracker, long BufSize[]){
        if (BufSize.length < 1)
            return FSDKE_INVALID_ARGUMENT;
        LongByReference tmp = new LongByReference();
        int res = IFaceSDK.INSTANCE.FSDK_GetTrackerMemoryBufferSize(Tracker.htracker, tmp);
        if (res == FSDKE_OK)
            BufSize[0] = tmp.getValue();
        return res;
    }
    public static int SaveTrackerMemoryToBuffer(HTracker Tracker, byte Buffer[]){
        long MaxSizeInBytes = Buffer.length;
        if (MaxSizeInBytes < 1)
           return FSDKE_INVALID_ARGUMENT;
        return IFaceSDK.INSTANCE.FSDK_SaveTrackerMemoryToBuffer(Tracker.htracker, Buffer, MaxSizeInBytes);
    }
    
    
    //Attribute detection
    
    public static int GetTrackerFacialAttribute(HTracker Tracker, long CameraIdx, long ID, String AttributeName, String AttributeValues[], long MaxSizeInBytes){
        if (MaxSizeInBytes < 1 || AttributeValues.length < 1)
            return FSDKE_INVALID_ARGUMENT;
        Pointer buf = new Memory(MaxSizeInBytes);
        int res = IFaceSDK.INSTANCE.FSDK_GetTrackerFacialAttribute(Tracker.htracker, CameraIdx, ID, AttributeName, buf, MaxSizeInBytes);
        if (res == FSDKE_OK)
            AttributeValues[0] = buf.getString(0);
        return res;
    } 
    
    public static int DetectFacialAttributeUsingFeatures(HImage Image, FSDK_Features FacialFeatures, String AttributeName, String AttributeValues[], long MaxSizeInBytes){
        if (MaxSizeInBytes < 1 || AttributeValues.length < 1)
            return FSDKE_INVALID_ARGUMENT;
        Pointer buf = new Memory(MaxSizeInBytes);
        int res = IFaceSDK.INSTANCE.FSDK_DetectFacialAttributeUsingFeatures(Image.himage, FacialFeatures, AttributeName, buf, MaxSizeInBytes);
        if (res == FSDKE_OK)
            AttributeValues[0] = buf.getString(0);
        return res;
    }

    public static int GetValueConfidence(String AttributeValues, String Value, float Confidence[]){
        if (Confidence.length < 1)
                return FSDKE_INVALID_ARGUMENT;
        FloatByReference tmp = new FloatByReference();
        int res = IFaceSDK.INSTANCE.FSDK_GetValueConfidence(AttributeValues, Value, tmp);
        Confidence[0] = tmp.getValue();
        return res;
    }

    
    
}
