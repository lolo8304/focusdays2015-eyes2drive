///////////////////////////////////////////////////
//
//         Luxand FaceSDK Library
//
//  Copyright(c) 2005-2013 Luxand, Inc.
//         http://www.luxand.com
//
///////////////////////////////////////////////////

unit LuxandFaceSDK;

interface

uses windows;

// Error codes
const
    FSDKE_OK = 0;
    FSDKE_FAILED = -1;
    FSDKE_NOT_ACTIVATED = -2;
    FSDKE_OUT_OF_MEMORY = -3;
    FSDKE_INVALID_ARGUMENT = -4;
    FSDKE_IO_ERROR = -5;
    FSDKE_IMAGE_TOO_SMALL = -6;
    FSDKE_FACE_NOT_FOUND = -7;
    FSDKE_INSUFFICIENT_BUFFER_SIZE = -8;
    FSDKE_UNSUPPORTED_IMAGE_EXTENSION =	-9;
    FSDKE_CANNOT_OPEN_FILE = -10;
    FSDKE_CANNOT_CREATE_FILE = -11;
    FSDKE_BAD_FILE_FORMAT = -12;
    FSDKE_FILE_NOT_FOUND = -13;
    FSDKE_CONNECTION_CLOSED	= -14;
    FSDKE_CONNECTION_FAILED	= -15;
    FSDKE_IP_INIT_FAILED = -16;
    FSDKE_NEED_SERVER_ACTIVATION = -17;
    FSDKE_ID_NOT_FOUND = -18;
    FSDKE_ATTRIBUTE_NOT_DETECTED = -19;
    FSDKE_INSUFFICIENT_TRACKER_MEMORY_LIMIT = -20;
    FSDKE_UNKNOWN_ATTRIBUTE = -21;
    FSDKE_UNSUPPORTED_FILE_VERSION = -22;
    FSDKE_SYNTAX_ERROR = -23;
    FSDKE_PARAMETER_NOT_FOUND = -24;
    FSDKE_INVALID_TEMPLATE = -25;
    FSDKE_UNSUPPORTED_TEMPLATE_VERSION = -26;



const
    FSDK_FACIAL_FEATURE_COUNT = 66;

// Types
type
    HImage = integer;
    PHImage = ^HImage;

    PHBitmap = ^HBitmap;

    TPoint = record
        x, y: integer;
    end;
    PPoint = ^TPoint;
    TPointArray = array[0..65535] of TPoint;
    PPointArray = ^TPointArray;

    FSDK_Features = array[0..FSDK_FACIAL_FEATURE_COUNT - 1] of TPoint;
    PFSDK_Features = ^FSDK_Features;

    FSDK_FeatureArray = array[0..65535] of FSDK_Features;
    PFSDK_FeatureArray = ^FSDK_FeatureArray;

    FSDK_IMAGEMODE = (
    	FSDK_IMAGE_GRAYSCALE_8BIT,
    	FSDK_IMAGE_COLOR_24BIT,
    	FSDK_IMAGE_COLOR_32BIT
    );

    FSDK_VIDEOCOMPRESSIONTYPE = (
        FSDK_MJPEG
    );


    FSDK_FaceTemplate = record
        ftemplate: array[0..13324-1] of byte;
    end;

    PFSDK_FaceTemplate = ^FSDK_FaceTemplate;

    FSDK_ConfidenceLevels = array[0..FSDK_FACIAL_FEATURE_COUNT - 1] of single;
    PFSDK_ConfidenceLevels = ^FSDK_ConfidenceLevels;

    TFacePosition = record
        xc, yc, w: integer;
        padding: integer;
        angle: double;
    end;
    PFacePosition = ^TFacePosition;

    TFacePositionArray = array[0..1023] of TFacePosition;
    PFacePositionArray = ^TFacePositionArray;

    FSDK_ProgressCallbackFunction = procedure(Percent: integer); cdecl;

// Facial features
const
    FSDKP_LEFT_EYE = 0;
    FSDKP_RIGHT_EYE = 1;
    FSDKP_LEFT_EYE_INNER_CORNER = 24;
    FSDKP_LEFT_EYE_OUTER_CORNER = 23;
    FSDKP_LEFT_EYE_LOWER_LINE1 = 38;
    FSDKP_LEFT_EYE_LOWER_LINE2 = 27;
    FSDKP_LEFT_EYE_LOWER_LINE3 = 37;
    FSDKP_LEFT_EYE_UPPER_LINE1 = 35;
    FSDKP_LEFT_EYE_UPPER_LINE2 = 28;
    FSDKP_LEFT_EYE_UPPER_LINE3 = 36;
    FSDKP_LEFT_EYE_LEFT_IRIS_CORNER = 29;
    FSDKP_LEFT_EYE_RIGHT_IRIS_CORNER = 30;
    FSDKP_RIGHT_EYE_INNER_CORNER = 25;
    FSDKP_RIGHT_EYE_OUTER_CORNER = 26;
    FSDKP_RIGHT_EYE_LOWER_LINE1 = 41;
    FSDKP_RIGHT_EYE_LOWER_LINE2 = 31;
    FSDKP_RIGHT_EYE_LOWER_LINE3 = 42;
    FSDKP_RIGHT_EYE_UPPER_LINE1 = 40;
    FSDKP_RIGHT_EYE_UPPER_LINE2 = 32;
    FSDKP_RIGHT_EYE_UPPER_LINE3 = 39;
    FSDKP_RIGHT_EYE_LEFT_IRIS_CORNER = 33;
    FSDKP_RIGHT_EYE_RIGHT_IRIS_CORNER = 34;
    FSDKP_LEFT_EYEBROW_INNER_CORNER = 13;
    FSDKP_LEFT_EYEBROW_MIDDLE = 16;
    FSDKP_LEFT_EYEBROW_MIDDLE_LEFT = 18;
    FSDKP_LEFT_EYEBROW_MIDDLE_RIGHT = 19;
    FSDKP_LEFT_EYEBROW_OUTER_CORNER = 12;
    FSDKP_RIGHT_EYEBROW_INNER_CORNER = 14;
    FSDKP_RIGHT_EYEBROW_MIDDLE = 17;
    FSDKP_RIGHT_EYEBROW_MIDDLE_LEFT = 20;
    FSDKP_RIGHT_EYEBROW_MIDDLE_RIGHT = 21;
    FSDKP_RIGHT_EYEBROW_OUTER_CORNER = 15;
    FSDKP_NOSE_TIP = 2;
    FSDKP_NOSE_BOTTOM = 49;
    FSDKP_NOSE_BRIDGE = 22;
    FSDKP_NOSE_LEFT_WING = 43;
    FSDKP_NOSE_LEFT_WING_OUTER = 45;
    FSDKP_NOSE_LEFT_WING_LOWER = 47;
    FSDKP_NOSE_RIGHT_WING = 44;
    FSDKP_NOSE_RIGHT_WING_OUTER = 46;
    FSDKP_NOSE_RIGHT_WING_LOWER = 48;
    FSDKP_MOUTH_RIGHT_CORNER = 3;
    FSDKP_MOUTH_LEFT_CORNER = 4;
    FSDKP_MOUTH_TOP = 54;
    FSDKP_MOUTH_TOP_INNER = 61;
    FSDKP_MOUTH_BOTTOM = 55;
    FSDKP_MOUTH_BOTTOM_INNER = 64;
    FSDKP_MOUTH_LEFT_TOP = 56;
    FSDKP_MOUTH_LEFT_TOP_INNER = 60;
    FSDKP_MOUTH_RIGHT_TOP = 57;
    FSDKP_MOUTH_RIGHT_TOP_INNER = 62;
    FSDKP_MOUTH_LEFT_BOTTOM = 58;
    FSDKP_MOUTH_LEFT_BOTTOM_INNER = 63;
    FSDKP_MOUTH_RIGHT_BOTTOM = 59;
    FSDKP_MOUTH_RIGHT_BOTTOM_INNER = 65;
    FSDKP_NASOLABIAL_FOLD_LEFT_UPPER = 50;
    FSDKP_NASOLABIAL_FOLD_LEFT_LOWER = 52;
    FSDKP_NASOLABIAL_FOLD_RIGHT_UPPER = 51;
    FSDKP_NASOLABIAL_FOLD_RIGHT_LOWER = 53;
    FSDKP_CHIN_BOTTOM = 11;
    FSDKP_CHIN_LEFT = 9;
    FSDKP_CHIN_RIGHT = 10;
    FSDKP_FACE_CONTOUR1 = 7;
    FSDKP_FACE_CONTOUR2 = 5;
    FSDKP_FACE_CONTOUR12 = 6;
    FSDKP_FACE_CONTOUR13 = 8;

// Initialization functions
function FSDK_ActivateLibrary(LicenseKey: PAnsiChar): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetHardware_ID(HardwareID: PAnsiChar): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetLicenseInfo(LicenseInfo: PAnsiChar): integer; cdecl; external 'FaceSDK.dll';
function FSDK_SetNumThreads(Num: integer): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetNumThreads(Num: PInteger): integer; cdecl; external 'FaceSDK.dll';
function FSDK_Initialize(DataFilesPath: PAnsiChar): integer; cdecl; external 'FaceSDK.dll';
function FSDK_Finalize: integer; cdecl; external 'FaceSDK.dll';

// Face detection functions
function FSDK_DetectEyes(Image: HImage; FacialFeatures: PFSDK_Features): integer; cdecl; external 'FaceSDK.dll';
function FSDK_DetectEyesInRegion(Image: HImage; FacePosition: PFacePosition; FacialFeatures: PFSDK_Features): integer; cdecl; external 'FaceSDK.dll';
function FSDK_DetectFace(Image: HImage; FacePosition: PFacePosition): integer; cdecl; external 'FaceSDK.dll';
function FSDK_DetectMultipleFaces(Image: HImage; DetectedCount: PInteger; FaceArray: PFacePositionArray; MaxSizeInBytes: integer): integer; cdecl; external 'FaceSDK.dll';
function FSDK_DetectFacialFeatures(Image: HImage; FacialFeatures: PFSDK_Features): integer; cdecl; external 'FaceSDK.dll';
function FSDK_DetectFacialFeaturesInRegion(Image: HImage; FacePosition: PFacePosition; FacialFeatures: PFSDK_Features): integer; cdecl; external 'FaceSDK.dll';
function FSDK_DetectFacialFeaturesEx(Image: HImage; FacialFeatures: PFSDK_Features; ConfidenceLevels: PFSDK_ConfidenceLevels): integer; cdecl; external 'FaceSDK.dll';
function FSDK_DetectFacialFeaturesInRegionEx(Image: HImage; FacePosition: PFacePosition; FacialFeatures: PFSDK_Features; ConfidenceLevels: PFSDK_ConfidenceLevels): integer; cdecl; external 'FaceSDK.dll';
function FSDK_SetFaceDetectionParameters(HandleArbitraryRotations: boolean; DetermineFaceRotationAngle: boolean; InternalResizeWidth: integer): integer; cdecl; external 'FaceSDK.dll';
function FSDK_SetFaceDetectionThreshold(Threshold: integer): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetDetectedFaceConfidence(Confidence: PInteger): integer; cdecl; external 'FaceSDK.dll';

// Image manipulation functions
function FSDK_CreateEmptyImage(Image: PHImage): integer; cdecl; external 'FaceSDK.dll';
function FSDK_LoadImageFromFile(Image: PHImage; FileName: PAnsiChar): integer; cdecl; external 'FaceSDK.dll';
function FSDK_LoadImageFromFileW(Image: PHImage; FileName: PWideChar): integer; cdecl; external 'FaceSDK.dll';
function FSDK_LoadImageFromHBitmap(Image: PHImage; BitmapHandle: HBitmap): integer; cdecl; external 'FaceSDK.dll';
function FSDK_LoadImageFromBuffer(Image: PHImage; var Buffer; Width, Height: integer; ScanLine: integer; ImageMode: FSDK_IMAGEMODE): integer; cdecl; external 'FaceSDK.dll';
function FSDK_AssignImageFromBuffer(Image: HImage; Buffer: pointer; Width, Height: integer; ScanLine: integer; ImageMode: FSDK_IMAGEMODE): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetImageData(Image: HImage; var Data: pointer; Width, Height, ScanLine: PInteger; var ImageMode: FSDK_IMAGEMODE): integer; cdecl; external 'FaceSDK.dll';
function FSDK_FreeImage(Image: HImage): integer; cdecl; external 'FaceSDK.dll';
function FSDK_SaveImageToFile(Image: HImage; FileName: PAnsiChar): integer; cdecl; external 'FaceSDK.dll';
function FSDK_SaveImageToFileW(Image: HImage; FileName: PWideChar): integer; cdecl; external 'FaceSDK.dll';
function FSDK_SaveImageToHBitmap(Image: HImage; BitmapHandle: PHBitmap): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetImageBufferSize(Image: HImage; BufSize: PInteger; ImageMode: FSDK_IMAGEMODE): integer; cdecl; external 'FaceSDK.dll';
function FSDK_SaveImageToBuffer(Image: HImage; var Buffer; ImageMode: FSDK_IMAGEMODE): integer; cdecl; external 'FaceSDK.dll';
function FSDK_SetJpegCompressionQuality(Quality: integer): integer; cdecl; external 'FaceSDK.dll';
function FSDK_CopyImage(SourceImage: HImage; DestImage: HImage): integer; cdecl; external 'FaceSDK.dll';
function FSDK_ResizeImage(SourceImage: HImage; ratio: double; DestImage: HImage): integer; cdecl; external 'FaceSDK.dll';
function FSDK_MirrorImage(Image: HImage; VerticalMirroringInsteadOfHorizontal: boolean): integer; cdecl; external 'FaceSDK.dll';
function FSDK_RotateImage90(SourceImage: HImage; Multiplier: integer; DestImage: HImage): integer; cdecl; external 'FaceSDK.dll';
function FSDK_RotateImage(SourceImage: HImage; angle: double; DestImage: HImage): integer; cdecl; external 'FaceSDK.dll';
function FSDK_CopyRect(SourceImage: HImage; x1, y1, x2, y2: integer; DestImage: HImage): integer; cdecl; external 'FaceSDK.dll';
function FSDK_CopyRectReplicateBorder(SourceImage: HImage; x1, y1, x2, y2: integer; DestImage: HImage): integer; cdecl; external 'FaceSDK.dll';
function FSDK_PutImage(SourceImage: HImage; x, y: integer; BackgroundImage: HImage; DestImage: HImage): integer; cdecl; external 'FaceSDK.dll';
function FSDK_PutImageAdjustColors(SourceImage: HImage; x, y: integer; BackgroundImage: HImage; DestImage: HImage): integer; cdecl; external 'FaceSDK.dll';
function FSDK_PutImageAdjustColorsRGB(SourceImage: HImage; x, y: integer; BackgroundImage: HImage; DestImage: HImage; R, G, B: Single): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetImageWidth(SourceImage: HImage; Width: PInteger): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetImageHeight(SourceImage: HImage; Height: PInteger): integer; cdecl; external 'FaceSDK.dll';
function FSDK_ExtractFaceImage(Image: HImage; FacialFeatures: PFSDK_Features; Width: integer; Height: integer; ExtractedFaceImage: PHImage; ResizedFeatures: PFSDK_Features): integer; cdecl; external 'FaceSDK.dll';

// Matching
function FSDK_GetFaceTemplate(Image: HImage; FaceTemplate: PFSDK_FaceTemplate): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetFaceTemplateInRegion(Image: HImage; FacePosition: PFacePosition; FaceTemplate: PFSDK_FaceTemplate): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetFaceTemplateUsingFeatures(Image: HImage; FacialFeatures: PFSDK_Features; FaceTemplate: PFSDK_FaceTemplate): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetFaceTemplateUsingEyes(Image: HImage; eyeCoords: PFSDK_Features; FaceTemplate: PFSDK_FaceTemplate): integer; cdecl; external 'FaceSDK.dll';
function FSDK_MatchFaces(FaceTemplate1, FaceTemplate2: PFSDK_FaceTemplate; Similarity: PSingle): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetMatchingThresholdAtFAR(FARValue: single; Threshold: PSingle): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetMatchingThresholdAtFRR(FRRValue: single; Threshold: PSingle): integer; cdecl; external 'FaceSDK.dll';

// Obsolete functions
function FSDK_LocateFace(Image: HImage; x1, y1, x2, y2: PInteger; LeftEyeX, LeftEyeY, RightEyeX, RightEyeY: PInteger;
                         ExtractFaceImage: integer; Width: integer; Height: integer; ExtractedFaceImage: PHImage;
                         ExtractedLeftEyeX, ExtractedLeftEyeY, ExtractedRightEyeX, ExtractedRightEyeY: PInteger): integer; cdecl; external 'FaceSDK.dll';
function FSDK_LocateFacialFeatures(Image: HImage; FacialFeatures: PFSDK_Features): integer; cdecl; external 'FaceSDK.dll';

// Camera
type
    FSDK_VideoFormatInfo = record
	    Width: integer;
    	Height: integer;
    	BPP: integer;
    end;

    PFSDK_VideoFormatInfo = ^FSDK_VideoFormatInfo;
    FSDK_VideoFormatInfoArray = array[0..255] of FSDK_VideoFormatInfo;
    PFSDK_VideoFormatInfoArray = ^FSDK_VideoFormatInfoArray;

    FSDK_CameraList = array[0..255] of PWideChar;
    PFSDK_CameraList = ^FSDK_CameraList;

function FSDK_SetCameraNaming(UseDevicePathAsName: boolean): integer; cdecl; external 'facesdk.dll';
function FSDK_InitializeCapturing: integer; cdecl; external 'facesdk.dll';
function FSDK_FinalizeCapturing: integer; cdecl; external 'facesdk.dll';
function FSDK_GetCameraList(CameraList: PWideChar; CameraCount: PInteger): integer; cdecl; external 'facesdk.dll';
function FSDK_GetCameraListEx(CameraNameList: PWideChar; CameraDevicePathList: PWideChar; CameraCount: PInteger): integer; cdecl; external 'facesdk.dll';
function FSDK_FreeCameraList(CameraList: Pointer; CameraCount: integer): integer; cdecl; external 'facesdk.dll';
function FSDK_GetVideoFormatList(CameraName: PWideChar; VideoFormatList: PFSDK_VideoFormatInfo; VideoFormatCount: PInteger): integer; cdecl; external 'facesdk.dll';
function FSDK_FreeVideoFormatList(VideoFormatList: Pointer): integer; cdecl; external 'facesdk.dll';
function FSDK_SetVideoFormat(CameraName: PWideChar; VideoFormat: FSDK_VideoFormatInfo ): integer; cdecl; external 'facesdk.dll';
function FSDK_OpenVideoCamera(CameraName: PWideChar; CameraHandle: PInteger): integer; cdecl; external 'facesdk.dll';
function FSDK_CloseVideoCamera(CameraHandle: integer): integer; cdecl; external 'facesdk.dll';
function FSDK_GrabFrame(CameraHandle: integer; Image: PHImage): integer; cdecl; external 'facesdk.dll';
function FSDK_OpenIPVideoCamera(CompressionType: FSDK_VIDEOCOMPRESSIONTYPE; URL: PAnsiChar; Username: PAnsiChar; Password: PAnsiChar; TimeoutSeconds: integer; CameraHandle: PInteger): integer; cdecl; external 'FaceSDK.dll';

function FSDK_SetHTTPProxy(ServerNameOrIPAddress: PAnsiChar; Port: Word; Username: PAnsiChar; Password: PAnsiChar): integer; cdecl; external 'FaceSDK.dll';

// Tracker
type
    HTracker = integer;
    PHTracker = ^HTracker;
    TIDArray = array[0..65535] of int64;
    PIDArray = ^TIDArray;

function FSDK_CreateTracker(Tracker: PHTracker): integer; cdecl; external 'FaceSDK.dll';
function FSDK_FreeTracker(Tracker: HTracker): integer; cdecl; external 'FaceSDK.dll';
function FSDK_ClearTracker(Tracker: HTracker): integer; cdecl; external 'FaceSDK.dll';
function FSDK_SetTrackerParameter(Tracker: HTracker; ParameterName, ParameterValue: PAnsiChar): integer; cdecl; external 'FaceSDK.dll';
function FSDK_SetTrackerMultipleParameters(Tracker: HTracker; Parameters: PAnsiChar; ErrorPosition: PInteger): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetTrackerParameter(Tracker: HTracker; ParameterName, ParameterValue: PAnsiChar; MaxSizeInBytes: int64): integer; cdecl; external 'FaceSDK.dll';
function FSDK_FeedFrame(Tracker: HTracker; CameraIdx: int64; Image: HImage; FaceCount: PInt64; IDs: PIDArray; MaxSizeInBytes: int64): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetTrackerEyes(Tracker: HTracker; CameraIdx, ID: int64; FacialFeatures: PFSDK_Features): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetTrackerFacialFeatures(Tracker: HTracker; CameraIdx, ID: int64; FacialFeatures: PFSDK_Features): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetTrackerFacePosition(Tracker: HTracker; CameraIdx, ID: int64; FacePosition: PFacePosition): integer; cdecl; external 'FaceSDK.dll';
function FSDK_LockID(Tracker: HTracker; ID: int64): integer; cdecl; external 'FaceSDK.dll';
function FSDK_UnlockID(Tracker: HTracker; ID: int64): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetName(Tracker: HTracker; ID: int64; Name: PAnsiChar; MaxSizeInBytes: int64): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetAllNames(Tracker: HTracker; ID: int64; Names: PAnsiChar; MaxSizeInBytes: int64): integer; cdecl; external 'FaceSDK.dll';
function FSDK_SetName(Tracker: HTracker; ID: int64; Name: PAnsiChar): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetIDReassignment(Tracker: HTracker; ID: int64; ReassignedID: PInt64): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetSimilarIDCount(Tracker: HTracker; ID: int64; Count: PInt64): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetSimilarIDList(Tracker: HTracker; ID: int64; SimilarIDList: PIDArray; MaxSizeInBytes: int64): integer; cdecl; external 'FaceSDK.dll';
function FSDK_SaveTrackerMemoryToFile(Tracker: HTracker; FileName: PAnsiChar): integer; cdecl; external 'FaceSDK.dll';
function FSDK_LoadTrackerMemoryFromFile(Tracker: PHTracker; FileName: PAnsiChar): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetTrackerMemoryBufferSize(Tracker: HTracker; BufSize: PInt64): integer; cdecl; external 'FaceSDK.dll';
function FSDK_SaveTrackerMemoryToBuffer(Tracker: HTracker; var Buffer; MaxSizeInBytes: int64): integer; cdecl; external 'FaceSDK.dll';
function FSDK_LoadTrackerMemoryFromBuffer(Tracker: PHTracker; var Buffer): integer; cdecl; external 'FaceSDK.dll';

// Facial attributes

function FSDK_GetTrackerFacialAttribute(Tracker: HTracker; CameraIdx, ID: int64; AttributeName, AttributeValues: PAnsiChar; MaxSizeInBytes: int64): integer; cdecl; external 'FaceSDK.dll';
function FSDK_DetectFacialAttributeUsingFeatures(Image: HImage; FacialFeatures: PFSDK_Features; AttributeName, AttributeValues: PAnsiChar; MaxSizeInBytes: int64): integer; cdecl; external 'FaceSDK.dll';
function FSDK_GetValueConfidence(AttributeValues, Value: PAnsiChar; Confidence: PSingle): integer; cdecl; external 'FaceSDK.dll';


implementation

end.
