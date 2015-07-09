Attribute VB_Name = "LuxandFaceSDK"
Option Base 0
Option Explicit

' Error codes

Public Const FSDKE_OK = 0
Public Const FSDKE_FAILED = -1
Public Const FSDKE_NOT_ACTIVATED = -2
Public Const FSDKE_OUT_OF_MEMORY = -3
Public Const FSDKE_INVALID_ARGUMENT = -4
Public Const FSDKE_IO_ERROR = -5
Public Const FSDKE_IMAGE_TOO_SMALL = -6
Public Const FSDKE_FACE_NOT_FOUND = -7
Public Const FSDKE_INSUFFICIENT_BUFFER_SIZE = -8
Public Const FSDKE_UNSUPPORTED_IMAGE_EXTENSION = -9
Public Const FSDKE_CANNOT_OPEN_FILE = -10
Public Const FSDKE_CANNOT_CREATE_FILE = -11
Public Const FSDKE_BAD_FILE_FORMAT = -12
Public Const FSDKE_FILE_NOT_FOUND = -13
Public Const FSDKE_CONNECTION_CLOSED = -14
Public Const FSDKE_CONNECTION_FAILED = -15
Public Const FSDKE_IP_INIT_FAILED = -16
Public Const FSDKE_NEED_SERVER_ACTIVATION = -17
Public Const FSDKE_ID_NOT_FOUND = -18
Public Const FSDKE_ATTRIBUTE_NOT_DETECTED = -19
Public Const FSDKE_INSUFFICIENT_TRACKER_MEMORY_LIMIT = -20
Public Const FSDKE_UNKNOWN_ATTRIBUTE = -21
Public Const FSDKE_UNSUPPORTED_FILE_VERSION = -22
Public Const FSDKE_SYNTAX_ERROR = -23
Public Const FSDKE_PARAMETER_NOT_FOUND = -24
Public Const FSDKE_INVALID_TEMPLATE = -25
Public Const FSDKE_UNSUPPORTED_TEMPLATE_VERSION = -26



' Facial feature count

Public Const FSDK_FACIAL_FEATURE_COUNT = 66

' Types

Public Enum FSDK_IMAGEMODE
    FSDK_IMAGE_GRAYSCALE_8BIT
    FSDK_IMAGE_COLOR_24BIT
    FSDK_IMAGE_COLOR_32BIT
End Enum

Public Enum FSDK_VIDEOCOMPRESSIONTYPE
    FSDK_MJPEG
End Enum

    
Public Type FSDK_STRING
    c_str(1024) As Byte
End Type
   
    
Public Type TPoint
    X As Long
    Y As Long
End Type


Public Type TFacePosition
    xc As Long
    yc As Long
    w As Long
    blank_var_for_padding As Long
    angle As Double
End Type


Public Type FSDK_FaceTemplate
    FaceTemplate(13324) As Byte
End Type



' Facial features

Public Const FSDKP_LEFT_EYE = 0
Public Const FSDKP_RIGHT_EYE = 1
Public Const FSDKP_LEFT_EYE_INNER_CORNER = 24
Public Const FSDKP_LEFT_EYE_OUTER_CORNER = 23
Public Const FSDKP_LEFT_EYE_LOWER_LINE1 = 38
Public Const FSDKP_LEFT_EYE_LOWER_LINE2 = 27
Public Const FSDKP_LEFT_EYE_LOWER_LINE3 = 37
Public Const FSDKP_LEFT_EYE_UPPER_LINE1 = 35
Public Const FSDKP_LEFT_EYE_UPPER_LINE2 = 28
Public Const FSDKP_LEFT_EYE_UPPER_LINE3 = 36
Public Const FSDKP_LEFT_EYE_LEFT_IRIS_CORNER = 29
Public Const FSDKP_LEFT_EYE_RIGHT_IRIS_CORNER = 30
Public Const FSDKP_RIGHT_EYE_INNER_CORNER = 25
Public Const FSDKP_RIGHT_EYE_OUTER_CORNER = 26
Public Const FSDKP_RIGHT_EYE_LOWER_LINE1 = 41
Public Const FSDKP_RIGHT_EYE_LOWER_LINE2 = 31
Public Const FSDKP_RIGHT_EYE_LOWER_LINE3 = 42
Public Const FSDKP_RIGHT_EYE_UPPER_LINE1 = 40
Public Const FSDKP_RIGHT_EYE_UPPER_LINE2 = 32
Public Const FSDKP_RIGHT_EYE_UPPER_LINE3 = 39
Public Const FSDKP_RIGHT_EYE_LEFT_IRIS_CORNER = 33
Public Const FSDKP_RIGHT_EYE_RIGHT_IRIS_CORNER = 34
Public Const FSDKP_LEFT_EYEBROW_INNER_CORNER = 13
Public Const FSDKP_LEFT_EYEBROW_MIDDLE = 16
Public Const FSDKP_LEFT_EYEBROW_MIDDLE_LEFT = 18
Public Const FSDKP_LEFT_EYEBROW_MIDDLE_RIGHT = 19
Public Const FSDKP_LEFT_EYEBROW_OUTER_CORNER = 12
Public Const FSDKP_RIGHT_EYEBROW_INNER_CORNER = 14
Public Const FSDKP_RIGHT_EYEBROW_MIDDLE = 17
Public Const FSDKP_RIGHT_EYEBROW_MIDDLE_LEFT = 20
Public Const FSDKP_RIGHT_EYEBROW_MIDDLE_RIGHT = 21
Public Const FSDKP_RIGHT_EYEBROW_OUTER_CORNER = 15
Public Const FSDKP_NOSE_TIP = 2
Public Const FSDKP_NOSE_BOTTOM = 49
Public Const FSDKP_NOSE_BRIDGE = 22
Public Const FSDKP_NOSE_LEFT_WING = 43
Public Const FSDKP_NOSE_LEFT_WING_OUTER = 45
Public Const FSDKP_NOSE_LEFT_WING_LOWER = 47
Public Const FSDKP_NOSE_RIGHT_WING = 44
Public Const FSDKP_NOSE_RIGHT_WING_OUTER = 46
Public Const FSDKP_NOSE_RIGHT_WING_LOWER = 48
Public Const FSDKP_MOUTH_RIGHT_CORNER = 3
Public Const FSDKP_MOUTH_LEFT_CORNER = 4
Public Const FSDKP_MOUTH_TOP = 54
Public Const FSDKP_MOUTH_TOP_INNER = 61
Public Const FSDKP_MOUTH_BOTTOM = 55
Public Const FSDKP_MOUTH_BOTTOM_INNER = 64
Public Const FSDKP_MOUTH_LEFT_TOP = 56
Public Const FSDKP_MOUTH_LEFT_TOP_INNER = 60
Public Const FSDKP_MOUTH_RIGHT_TOP = 57
Public Const FSDKP_MOUTH_RIGHT_TOP_INNER = 62
Public Const FSDKP_MOUTH_LEFT_BOTTOM = 58
Public Const FSDKP_MOUTH_LEFT_BOTTOM_INNER = 63
Public Const FSDKP_MOUTH_RIGHT_BOTTOM = 59
Public Const FSDKP_MOUTH_RIGHT_BOTTOM_INNER = 65
Public Const FSDKP_NASOLABIAL_FOLD_LEFT_UPPER = 50
Public Const FSDKP_NASOLABIAL_FOLD_LEFT_LOWER = 52
Public Const FSDKP_NASOLABIAL_FOLD_RIGHT_UPPER = 51
Public Const FSDKP_NASOLABIAL_FOLD_RIGHT_LOWER = 53
Public Const FSDKP_CHIN_BOTTOM = 11
Public Const FSDKP_CHIN_LEFT = 9
Public Const FSDKP_CHIN_RIGHT = 10
Public Const FSDKP_FACE_CONTOUR1 = 7
Public Const FSDKP_FACE_CONTOUR2 = 5
Public Const FSDKP_FACE_CONTOUR12 = 6
Public Const FSDKP_FACE_CONTOUR13 = 8


' Initialization functions

Declare Function FSDKVB_ActivateLibrary Lib "facesdk-vb.dll" (ByVal LicenseKey As String) As Long

Declare Function FSDKVB_GetHardware_ID Lib "facesdk-vb.dll" (ByRef HardwareID As Byte) As Long
Declare Function FSDKVB_GetLicenseInfo Lib "facesdk-vb.dll" (ByRef LicenseInfo As Byte) As Long

Declare Function FSDKVB_SetNumThreads Lib "facesdk-vb.dll" (ByVal Num As Long) As Long
Declare Function FSDKVB_GetNumThreads Lib "facesdk-vb.dll" (ByRef Num As Long) As Long

Declare Function FSDKVB_Initialize Lib "facesdk-vb.dll" (ByVal DataFilesPath As String) As Long
Declare Function FSDKVB_Finalize Lib "facesdk-vb.dll" () As Long

' Face detection functions

Declare Function FSDKVB_DetectEyes Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef FacialFeatures As TPoint) As Long
Declare Function FSDKVB_DetectEyesInRegion Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef facePosition As TFacePosition, ByRef FacialFeatures As TPoint) As Long
Declare Function FSDKVB_DetectFace Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef facePosition As TFacePosition) As Long
Declare Function FSDKVB_DetectMultipleFaces Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef DetectedCount As Long, ByRef FaceArray As TFacePosition, ByVal MaxSize As Long) As Long
Declare Function FSDKVB_DetectFacialFeatures Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef FacialFeatures As TPoint) As Long
Declare Function FSDKVB_DetectFacialFeaturesInRegion Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef facePosition As TFacePosition, ByRef FacialFeatures As TPoint) As Long
Declare Function FSDKVB_DetectFacialFeaturesEx Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef FacialFeatures As TPoint, ByRef ConfidenceLevels As Single) As Long
Declare Function FSDKVB_DetectFacialFeaturesInRegionEx Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef facePosition As TFacePosition, ByRef FacialFeatures As TPoint, ByRef ConfidenceLevels As Single) As Long
Declare Function FSDKVB_SetFaceDetectionParameters Lib "facesdk-vb.dll" (ByVal HandleArbitraryRotations As Boolean, ByVal DetermineFaceRotationAngle As Boolean, ByVal InternalResizeWidth As Long) As Long
Declare Function FSDKVB_SetFaceDetectionThreshold Lib "facesdk-vb.dll" (ByVal threshold As Long) As Long

' Image manipulation functions

Declare Function FSDKVB_CreateEmptyImage Lib "facesdk-vb.dll" (ByRef Image As Long) As Long
Declare Function FSDKVB_LoadImageFromFile Lib "facesdk-vb.dll" (ByRef Image As Long, ByVal FileName As String) As Long


Declare Function FSDKVB_LoadImageFromBuffer Lib "facesdk-vb.dll" (ByRef Image As Long, ByRef Buffer As Byte, ByVal Width As Long, ByVal Height As Long, ByVal ScanLine As Long, ByVal ImageMode As FSDK_IMAGEMODE) As Long
Declare Function FSDKVB_LoadImageFromJpegBuffer Lib "facesdk-vb.dll" (ByRef Image As Long, ByRef Buffer As Byte, ByVal BufferLength As Long) As Long
Declare Function FSDKVB_LoadImageFromPngBuffer Lib "facesdk-vb.dll" (ByRef Image As Long, ByRef Buffer As Byte, ByVal BufferLength As Long) As Long


Declare Function FSDKVB_FreeImage Lib "facesdk-vb.dll" (ByVal Image As Long) As Long

Declare Function FSDKVB_SaveImageToFile Lib "facesdk-vb.dll" (ByVal Image As Long, ByVal FileName As String) As Long

Declare Function FSDKVB_LoadImageFromHBitmap Lib "facesdk-vb.dll" (ByRef Image As Long, ByVal BitmapHandle As Long) As Long
Declare Function FSDKVB_SaveImageToHBitmap Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef BitmapHandle As Long) As Long


Declare Function FSDKVB_GetImageBufferSize Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef BufSize As Long, ByVal ImageMode As FSDK_IMAGEMODE) As Long
Declare Function FSDKVB_SaveImageToBuffer Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef Buffer As Byte, ByVal ImageMode As FSDK_IMAGEMODE) As Long

Declare Function FSDKVB_SetJpegCompressionQuality Lib "facesdk-vb.dll" (ByVal Quality As Long) As Long

Declare Function FSDKVB_CopyImage Lib "facesdk-vb.dll" (ByVal SourceImage As Long, ByVal DestImage As Long) As Long
Declare Function FSDKVB_ResizeImage Lib "facesdk-vb.dll" (ByVal SourceImage As Long, ByVal ratio As Double, ByVal DestImage As Long) As Long
Declare Function FSDKVB_MirrorImage Lib "facesdk-vb.dll" (ByVal Image As Long, ByVal UseVerticalInsteadOfHorizontalMirroring As Boolean) As Long
Declare Function FSDKVB_RotateImage90 Lib "facesdk-vb.dll" (ByVal SourceImage As Long, ByVal Multiplier As Long, ByVal DestImage As Long) As Long
Declare Function FSDKVB_RotateImage Lib "facesdk-vb.dll" (ByVal SourceImage As Long, ByVal angle As Double, ByVal DestImage As Long) As Long
Declare Function FSDKVB_RotateImageCenter Lib "facesdk-vb.dll" (ByVal SourceImage As Long, ByVal angle As Double, ByVal xCenter As Double, ByVal yCenter As Double, ByVal DestImage As Long) As Long
Declare Function FSDKVB_CopyRect Lib "facesdk-vb.dll" (ByVal SourceImage As Long, ByVal x1 As Long, ByVal y1 As Long, ByVal x2 As Long, ByVal y2 As Long, ByVal DestImage As Long) As Long
Declare Function FSDKVB_CopyRectReplicateBorder Lib "facesdk-vb.dll" (ByVal SourceImage As Long, ByVal x1 As Long, ByVal y1 As Long, ByVal x2 As Long, ByVal y2 As Long, ByVal DestImage As Long) As Long


Declare Function FSDKVB_GetImageWidth Lib "facesdk-vb.dll" (ByVal SourceImage As Long, ByRef Width As Long) As Long
Declare Function FSDKVB_GetImageHeight Lib "facesdk-vb.dll" (ByVal SourceImage As Long, ByRef Height As Long) As Long

Declare Function FSDKVB_ExtractFaceImage Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef FacialFeatures As TPoint, ByVal Width As Long, ByVal Height As Long, ByRef ExtractedFaceImage As Long, ByRef ResizedFeatures As TPoint) As Long



' Matching

Declare Function FSDKVB_GetFaceTemplate Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef FaceTemplate As Byte) As Long
Declare Function FSDKVB_GetFaceTemplateInRegion Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef facePosition As TFacePosition, ByRef FaceTemplate As Byte) As Long
Declare Function FSDKVB_GetFaceTemplateUsingFeatures Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef FacialFeatures As TPoint, ByRef FaceTemplate As Byte) As Long
Declare Function FSDKVB_GetFaceTemplateUsingEyes Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef eyeCoords As TPoint, ByRef FaceTemplate As Byte) As Long
Declare Function FSDKVB_MatchFaces Lib "facesdk-vb.dll" (ByRef FaceTemplate1 As Byte, ByRef FaceTemplate2 As Byte, ByRef similarity As Single) As Long
Declare Function FSDKVB_GetMatchingThresholdAtFAR Lib "facesdk-vb.dll" (ByVal FARValue As Single, ByRef threshold As Single) As Long
Declare Function FSDKVB_GetMatchingThresholdAtFRR Lib "facesdk-vb.dll" (ByVal FRRValue As Single, ByRef threshold As Single) As Long
Declare Function FSDKVB_GetDetectedFaceConfidence Lib "facesdk-vb.dll" (ByRef Confidence As Long) As Long


' Webcam

Public Type FSDK_VideoFormatInfo
    Width As Long
    Height As Long
    BPP As Long
End Type


Declare Function FSDKVB_InitializeCapturing Lib "facesdk-vb.dll" () As Long
Declare Function FSDKVB_FinalizeCapturing Lib "facesdk-vb.dll" () As Long
Declare Function FSDKVB_SetCameraNaming Lib "facesdk-vb.dll" (ByVal UseDevicePathAsName As Boolean) As Long
Declare Function FSDKVB_GetCameraList Lib "facesdk-vb.dll" (ByRef VCameraList As Variant, ByRef CameraCount As Long) As Long
Declare Function FSDKVB_GetCameraListEx Lib "facesdk-vb.dll" (ByRef VCameraNameList As Variant, ByRef VCameraDevicePathList As Variant, ByRef CameraCount As Long) As Long
Declare Function FSDKVB_GetVideoFormatList Lib "facesdk-vb.dll" (ByVal cameraName As String, ByRef VVideoFormatList As Variant, ByRef VideoFormatCount As Long) As Long
Declare Function FSDKVB_SetVideoFormat Lib "facesdk-vb.dll" (ByVal cameraName As String, ByRef VideoFormat As FSDK_VideoFormatInfo) As Long
Declare Function FSDKVB_OpenVideoCamera Lib "facesdk-vb.dll" (ByVal cameraName As String, ByRef cameraHandle As Long) As Long
Declare Function FSDKVB_CloseVideoCamera Lib "facesdk-vb.dll" (ByVal cameraHandle As Long) As Long
Declare Function FSDKVB_GrabFrame Lib "facesdk-vb.dll" (ByVal cameraHandle As Long, ByRef Image As Long) As Long
Declare Function FSDKVB_Paint Lib "facesdk-vb.dll" (ByVal DC As Long, ByVal Image As Long) As Long


Declare Function FSDKVB_OpenIPVideoCamera Lib "facesdk-vb.dll" (ByVal CompressionType As FSDK_VIDEOCOMPRESSIONTYPE, ByVal URL As String, ByVal Username As String, ByVal Password As String, ByVal TimeoutSeconds As Long, ByRef cameraHandle As Long) As Long

Declare Function FSDKVB_SetHTTPProxy Lib "facesdk-vb.dll" (ByVal ServerNameOrIPAddress As String, ByVal Port As Long, ByVal Username As String, ByVal Password As String) As Long


' Tracker

Declare Function FSDKVB_CreateTracker Lib "facesdk-vb.dll" (ByRef Tracker As Long) As Long
Declare Function FSDKVB_FreeTracker Lib "facesdk-vb.dll" (ByVal Tracker As Long) As Long
Declare Function FSDKVB_ClearTracker Lib "facesdk-vb.dll" (ByVal Tracker As Long) As Long
Declare Function FSDKVB_SetTrackerParameter Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal ParameterName As String, ByVal ParameterValue As String) As Long
Declare Function FSDKVB_SetTrackerMultipleParameters Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal Parameters As String, ByRef ErrorPosition As Long) As Long
Declare Function FSDKVB_GetTrackerParameter Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal ParameterName As String, ByVal ParameterValue As String, ByVal MaxSizeInBytes As Currency) As Long
Declare Function FSDKVB_FeedFrame Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal CameraIdx As Currency, ByVal Image As Long, ByRef FaceCount As Currency, ByRef IDs As Currency, ByVal MaxSizeInBytes As Currency) As Long
Declare Function FSDKVB_GetTrackerEyes Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal CameraIdx As Currency, ByVal id As Currency, ByRef FacialFeatures As TPoint) As Long
Declare Function FSDKVB_GetTrackerFacialFeatures Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal CameraIdx As Currency, ByVal id As Currency, ByRef FacialFeatures As TPoint) As Long
Declare Function FSDKVB_GetTrackerFacePosition Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal CameraIdx As Currency, ByVal id As Currency, ByRef facePosition As TFacePosition) As Long
Declare Function FSDKVB_LockID Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal id As Currency) As Long
Declare Function FSDKVB_UnlockID Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal id As Currency) As Long
Declare Function FSDKVB_GetName Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal id As Currency, ByVal Name As String, ByVal MaxSizeInBytes As Currency) As Long
Declare Function FSDKVB_GetAllNames Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal id As Currency, ByVal Names As String, ByVal MaxSizeInBytes As Currency) As Long

Declare Function FSDKVB_SetName Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal id As Currency, ByVal Name As String) As Long
Declare Function FSDKVB_GetIDReassignment Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal id As Currency, ByRef ReassignedID As Currency) As Long
Declare Function FSDKVB_GetSimilarIDCount Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal id As Currency, ByRef Count As Currency) As Long
Declare Function FSDKVB_GetSimilarIDList Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal id As Currency, ByRef SimilarIDList As Currency, ByVal MaxSizeInBytes As Currency) As Long
Declare Function FSDKVB_SaveTrackerMemoryToFile Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal FileName As String) As Long
Declare Function FSDKVB_LoadTrackerMemoryFromFile Lib "facesdk-vb.dll" (ByRef Tracker As Long, ByVal FileName As String) As Long
Declare Function FSDKVB_GetTrackerMemoryBufferSize Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByRef BufSize As Currency) As Long
Declare Function FSDKVB_SaveTrackerMemoryToBuffer Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByRef Buffer As Byte, ByVal MaxSizeInBytes As Currency) As Long
Declare Function FSDKVB_LoadTrackerMemoryFromBuffer Lib "facesdk-vb.dll" (ByRef Tracker As Long, ByRef Buffer As Byte) As Long

' Facial attributes

Declare Function FSDKVB_GetTrackerFacialAttribute Lib "facesdk-vb.dll" (ByVal Tracker As Long, ByVal CameraIdx As Currency, ByVal id As Currency, ByVal AttributeName As String, ByVal AttributeValues As String, ByVal MaxSizeInBytes As Currency) As Long
Declare Function FSDKVB_DetectFacialAttributeUsingFeatures Lib "facesdk-vb.dll" (ByVal Image As Long, ByRef FacialFeatures As TPoint, ByVal AttributeName As String, ByVal AttributeValues As String, ByVal MaxSizeInBytes As Currency) As Long
Declare Function FSDKVB_GetValueConfidence Lib "facesdk-vb.dll" (ByVal AttributeValues As String, ByVal Value As String, ByRef Confidence As Single) As Long



