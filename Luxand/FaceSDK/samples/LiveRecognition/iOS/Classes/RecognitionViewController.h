//
//  based on ColorTrackingViewController.h
//  from ColorTracking application
//  The source code for this application is available under a BSD license.
//  See ColorTrackingLicense.txt for details.
//  Created by Brad Larson on 10/7/2010.
//  Modified by Anton Malyshev on 6/21/2013.
//

#import <UIKit/UIKit.h>
#import "RecognitionCamera.h"
#import "RecognitionGLView.h"
#include "LuxandFaceSDK.h"

#define MAX_FACES 5

#define MAX_NAME_LEN 1024

typedef struct {
    unsigned char * buffer;
    int width, height, scanline;
    float ratio;
} DetectFaceParams;

typedef struct {
    int x1, x2, y1, y2;
} FaceRectangle;


@interface RecognitionViewController : UIViewController <RecognitionCameraDelegate>
{
	RecognitionCamera * camera;
	UIScreen * screenForDisplay;
    
    GLuint directDisplayProgram;
	GLuint videoFrameTexture;
	GLubyte * rawPositionPixels;

    NSLock * enteredNameLock;
    char * enteredName;
    volatile int namedFaceID;
    
    CALayer * trackingRects[MAX_FACES];
    CATextLayer * nameLabels[MAX_FACES];
    
    //volatile int processingImage;
    
    NSLock * faceDataLock;
    FaceRectangle faces[MAX_FACES];
    NSLock * nameDataLock;
    char * names[MAX_FACES];
    long long IDs[MAX_FACES];
    volatile int faceTouched;
    volatile int indexOfTouchedFace;
    NSLock * idOfTouchedFaceLock;
    long long idOfTouchedFace;
    CGPoint currentTouchPoint;
	
    volatile int rotating;
    char videoStarted;
    
    volatile int clearTracker;
    UIToolbar * toolbar;
    
    //UIImage * image_for_screenshot;
    
    //NOTE: use locks accessing (volatile int) variables if int is not machine word 
}

@property(readonly) RecognitionGLView * glView;
@property(readonly) HTracker tracker;
@property(readwrite) char * templatePath;
@property(readwrite) volatile int closing;
@property(readonly) volatile int processingImage;

// Initialization and teardown
- (id)initWithScreen:(UIScreen *)newScreenForDisplay;

// OpenGL ES 2.0 setup methods
- (BOOL)loadVertexShader:(NSString *)vertexShaderName fragmentShader:(NSString *)fragmentShaderName forProgram:(GLuint *)programPointer;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

// Device rotating support
- (void)relocateSubviewsForOrientation:(UIInterfaceOrientation)orientation;

// Image processing in FaceSDK
- (void)processImageAsyncWith:(NSData *)args;

@end

