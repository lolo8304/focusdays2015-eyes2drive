//
//  based on ColorTrackingViewController.m
//  from ColorTracking application
//  The source code for this application is available under a BSD license.
//  See ColorTrackingLicense.txt for details.
//  Created by Brad Larson on 10/7/2010.
//  Modified by Anton Malyshev on 6/21/2013.
//

#import "RecognitionViewController.h"

// GL attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXTUREPOSITON,
    NUM_ATTRIBUTES
};

@implementation RecognitionViewController

@synthesize glView = _glView;
@synthesize tracker = _tracker;
@synthesize templatePath = _templatePath;
@synthesize closing = _closing;
@synthesize processingImage = _processingImage;

//#define DEBUG

const NSString * help_text = @"Just tap any detected face and name it. The app will recognize this face further. For best results, hold the device at arm's length. You may slowly rotate the head for the app to memorize you at multiple views. The app can memorize several persons. If a face is not recognized, tap and name it again. The SDK is available for mobile developers: www.luxand.com/facesdk";
//for app description:
//@"Just tap any detected face and give it a name. The app will memorize the face and recognize it further. For best results, hold the device at arm's length. You may slowly rotate the head (or slowly change your location) for the app to memorize you at multiple views. The app can memorize several persons. If a face is not recognized, tap and name it again.\n\nThe SDK is available for mobile developers: www.luxand.com/facesdk";


#pragma mark -
#pragma mark Face frame functions 

inline bool PointInRectangle(int point_x, int point_y, int rect_x1, int rect_y1, int rect_x2, int rect_y2)
{
    return (point_x >= rect_x1) && (point_x <= rect_x2) && (point_y >= rect_y1) && (point_y <= rect_y2);  
}

int GetFaceFrame(const FSDK_Features * Features, int * x1, int * y1, int * x2, int * y2)
{
	if (!Features || !x1 || !y1 || !x2 || !y2)
		return FSDKE_INVALID_ARGUMENT;
    
    float u1 = (float)(*Features)[0].x;
    float v1 = (float)(*Features)[0].y;
    float u2 = (float)(*Features)[1].x;
    float v2 = (float)(*Features)[1].y;
    float xc = (u1 + u2) / 2;
    float yc = (v1 + v2) / 2;
    int w = (int)pow((u2 - u1) * (u2 - u1) + (v2 - v1) * (v2 - v1), 0.5f);
    
    *x1 = (int)(xc - w * 1.6 * 0.9);
    *y1 = (int)(yc - w * 1.1 * 0.9);
    *x2 = (int)(xc + w * 1.6 * 0.9);
    *y2 = (int)(yc + w * 2.1 * 0.9);
    if (*x2 - *x1 > *y2 - *y1) {
        *x2 = *x1 + *y2 - *y1;
    } else {
        *y2 = *y1 + *x2 - *x1;
    }
	return 0;
}



#pragma mark -
#pragma mark RecognitionViewController initialization, initializing face tracker

- (id)initWithScreen:(UIScreen *)newScreenForDisplay
{
    // for screenshot for App Store {
    /*
    NSString * stringURL = @"http://luxand.com/facesdk/iPhoneScreen.png";
    NSURL  * url = [NSURL URLWithString:stringURL];
    NSData * urlData = [NSData dataWithContentsOfURL:url];
    if (urlData){
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectory = [paths objectAtIndex:0];  
        
        NSString * filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"iPhoneScreen.png"];
        [urlData writeToFile:filePath atomically:YES];
        image_for_screenshot = [[UIImage alloc] initWithContentsOfFile:filePath];
        CGSize sz = image_for_screenshot.size;
        NSLog(@"%f %f", sz.width, sz.height);
    }
    */
    //}

    faceDataLock = [[NSLock alloc] init];
    nameDataLock = [[NSLock alloc] init];
    enteredNameLock = [[NSLock alloc] init];
    idOfTouchedFaceLock = [[NSLock alloc] init];    
    for (int i=0; i<MAX_FACES; ++i) names[i] = new char[MAX_NAME_LEN + 1];
 
    NSString * templatePathO = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Memory50.dat"];
    const char * templatePath = [templatePathO UTF8String];
    _templatePath = (char *)malloc(strlen(templatePath)+1);
    strcpy(_templatePath, templatePath);
#if defined(DEBUG)
    NSLog(@"using templatePath: %s", _templatePath);
#endif
    if ((self = [super initWithNibName:nil bundle:nil])) {
        
        // Preload alert class for faster performance
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Enter your name" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert release];
        
        if (FSDKE_OK != FSDK_LoadTrackerMemoryFromFile(&_tracker, _templatePath))
            FSDK_CreateTracker(&_tracker);
        
        int errpos = 0;
        FSDK_SetTrackerMultipleParameters(_tracker, "ContinuousVideoFeed=true;RecognitionPrecision=0;Threshold=0.997;Threshold2=0.9995;ThresholdFeed=0.97;MemoryLimit=1000;HandleArbitraryRotations=false;DetermineFaceRotationAngle=false;InternalResizeWidth=70;FaceDetectionThreshold=5;", &errpos);
#if defined(DEBUG)
        if (errpos)
            NSLog(@"FSDK_SetTrackerMultipleParameters returned errpos = %d", errpos);
#endif
        
		screenForDisplay = newScreenForDisplay;
		        
		_processingImage = NO;
        rotating = NO;
        videoStarted = 0;
        faceTouched = NO;
        idOfTouchedFace = -1;
        enteredName = NULL;
        clearTracker = NO;
        
        memset(faces, 0, sizeof(FaceRectangle)*MAX_FACES);        
    }
    return self;
}

//init view, glview and camera
- (void)loadView 
{
	CGRect mainScreenFrame = [[UIScreen mainScreen] applicationFrame];
	UIView *primaryView = [[UIView alloc] initWithFrame:mainScreenFrame];
	self.view = primaryView;
	[primaryView release]; //now self is responsible for the view

    //CGRect applicationFrame = [screenForDisplay applicationFrame];
    //_glView = [[RecognitionGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, applicationFrame.size.width, applicationFrame.size.height)];
    
    _glView = [[RecognitionGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
    //_glView will be re-initialized in (void)drawFrame with proper size

	[self.view addSubview:_glView];
	[_glView release]; //now self.view is responsible for the view

	
    // Set up the toolbar at the bottom of the screen
	toolbar = [UIToolbar new];
	toolbar.barStyle = UIBarStyleBlackTranslucent;
	
	UIBarButtonItem * clearItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
        target:self action:@selector(clearAction:)];
    
    UIBarButtonItem * flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
    UIBarButtonItem * helpItem = [[UIBarButtonItem alloc] initWithTitle:@"?"
        style:UIBarButtonItemStylePlain
        target:self
        action:@selector(helpAction:)];
	
    toolbar.items = [NSArray arrayWithObjects: clearItem, flexibleSpace, helpItem, nil];
	[clearItem release];
    [flexibleSpace release];
    [helpItem release];
    
	// size up the toolbar and set its frame, note that it will work only for views without Navigation toolbars. 
	[toolbar sizeToFit];
    CGFloat toolbarHeight = [toolbar frame].size.height;
	CGRect mainViewBounds = self.view.bounds;
	[toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
								 CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight),
								 CGRectGetWidth(mainViewBounds),
								 toolbarHeight)];
	[self.view addSubview:toolbar];
    [toolbar release];
    
    
    [self loadVertexShader:@"DirectDisplayShader" fragmentShader:@"DirectDisplayShader" forProgram:&directDisplayProgram];
     
    // Creating MAX_FACES number of face tracking rectangles
    for (int i=0; i<MAX_FACES; ++i) {
        trackingRects[i] = [[CALayer alloc] init];
        trackingRects[i].bounds = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
        trackingRects[i].cornerRadius = 0.0f;
        trackingRects[i].borderColor = [[UIColor blueColor] CGColor];
        trackingRects[i].borderWidth = 2.0f;
        trackingRects[i].position = CGPointMake(100.0f, 100.0f);
        trackingRects[i].opacity = 0.0f;
        trackingRects[i].anchorPoint = CGPointMake(0.0f, 0.0f); //for position to be the top-left corner
        nameLabels[i] = [[CATextLayer alloc] init];
        [nameLabels[i] setFont:@"Helvetica-Bold"];
        [nameLabels[i] setFontSize:20];
        [nameLabels[i] setFrame:CGRectMake(10.0f, 10.0f, 200.0f, 20.0f)]; 
        [nameLabels[i] setString:@"Tap to name"];
        [nameLabels[i] setAlignmentMode:kCAAlignmentLeft];
        [nameLabels[i] setForegroundColor:[[UIColor greenColor] CGColor]];
        [nameLabels[i] setAlignmentMode:kCAAlignmentCenter];
        [trackingRects[i] addSublayer:nameLabels[i]];
        [nameLabels[i] release];
    }
    
    // Disable animations for move and resize (otherwise trackingRect will jump) 
	for (int i=0; i<MAX_FACES; ++i) {
        NSMutableDictionary * newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"position", [NSNull null], @"bounds", nil];
        trackingRects[i].actions = newActions;
        [newActions release];
    }
	for (int i=0; i<MAX_FACES; ++i) {
        NSMutableDictionary * newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"position", [NSNull null], @"bounds", nil];
        nameLabels[i].actions = newActions;
        [newActions release];
    }
	
    for (int i=0; i<MAX_FACES; ++i) {
        [_glView.layer addSublayer:trackingRects[i]];
    }    
    
	camera = [[RecognitionCamera alloc] init];
	camera.delegate = self; //we want to receive processNewCameraFrame messages
	[self cameraHasConnected]; //the method doesn't perform any work now
}

- (void)didReceiveMemoryWarning 
{
//    [super didReceiveMemoryWarning];
}

- (void)dealloc 
{
    for (int i=0; i<MAX_FACES; ++i) {
        [trackingRects[i] release];
    }    
	[camera release];
    [super dealloc];
    [faceDataLock release], faceDataLock = NULL;
    
    [nameDataLock lock];
    for (int i=0; i<MAX_FACES; ++i) delete [] names[i];
    [nameDataLock unlock];
    [nameDataLock release], nameDataLock = NULL;
    
    [enteredNameLock release], enteredNameLock = NULL;
    [idOfTouchedFaceLock release], idOfTouchedFaceLock = NULL;
    
    if (enteredName) delete [] enteredName;
}



#pragma mark -
#pragma mark OpenGL ES 2.0 rendering

- (void)drawFrame // called by processNewCameraFrame
{    
    /*
    // mirrored square
    static const GLfloat squareVertices[] = {
        1.0f, -1.0f,
        -1.0f, -1.0f,
        1.0f,  1.0f,
        -1.0f,  1.0f,
    };
    */
    
    // standart square 
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    /*
    // mirrored texture (was used with standart square originally, result - mirrored image)
    static const GLfloat textureVertices[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f,  1.0f,
        0.0f,  0.0f,
    };
    */
    
    //OLD, OK WHEN NOT CHANGING ORIENTATION
    // standart texture
    /*
    static const GLfloat textureVertices[] = {
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f,  0.0f,
        0.0f,  1.0f,
    };
    */
    
    
    // Reinitialize GLView and Toolbar when orientation changed 
    
    static int old_orientation = 0;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation != old_orientation) {
        old_orientation = orientation;
        
        [self relocateSubviewsForOrientation:orientation];
    }
    
    // Rotate the texture (image from camera) accordingly to current orientation
    
    glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, videoFrameTexture);
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
    if (orientation == 0 || orientation == UIInterfaceOrientationPortrait) {
        GLfloat textureVertices[] = {
            1.0f, 0.0f,
            1.0f, 1.0f,
            0.0f, 0.0f,
            0.0f, 1.0f,
        };
        glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, textureVertices);
    } else if(orientation == UIInterfaceOrientationPortraitUpsideDown) {
        GLfloat textureVertices[] = {
            0.0f, 1.0f,
            0.0f, 0.0f,
            1.0f, 1.0f,
            1.0f, 0.0f,
        };
        glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, textureVertices);
    } else if(orientation == UIInterfaceOrientationLandscapeLeft) {
        GLfloat textureVertices[] = {
            1.0f, 1.0f,
            0.0f, 1.0f,
            1.0f, 0.0f,
            0.0f, 0.0f,
        };
        glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, textureVertices);
    } else if(orientation == UIInterfaceOrientationLandscapeRight) {
        GLfloat textureVertices[] = {
            0.0f, 0.0f,
            1.0f, 0.0f,
            0.0f, 1.0f,
            1.0f, 1.0f,
        };
        glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, textureVertices);
    }
    glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);
    
    //glDrawArrays(GL_TRIANGLE_STRIP, 0, 4); //not needed
	
    // Setting bounds and position of trackingRect using data received from FSDK_DetectFace
    
    [nameDataLock lock];
    for (int i=0; i<MAX_FACES; ++i) {
        if (strlen(names[i])) {
            [nameLabels[i] setString:[NSString stringWithUTF8String:names[i]]];
            [nameLabels[i] setForegroundColor:[[UIColor blueColor] CGColor]];                
        } else {
            [nameLabels[i] setString:@"Tap to name"];
            [nameLabels[i] setForegroundColor:[[UIColor greenColor] CGColor]];
        }
    }    
    [nameDataLock unlock];
    
    [faceDataLock lock];
    for (int i=0; i<MAX_FACES; ++i) {
        if (faces[i].x2) { // have face
            [nameLabels[i] setFrame:CGRectMake(10.0f, faces[i].y2 - faces[i].y1 + 10.0f, faces[i].x2-faces[i].x1-20.0f, 20.0f)];
            //[nameLabels[i] setFrame:CGRectMake(10.0f, 10.0f, faces[i].x2-faces[i].x1-20.0f, 20.0f)];
            
            trackingRects[i].position = CGPointMake(faces[i].x1, faces[i].y1);
            trackingRects[i].bounds = CGRectMake(0.0f, 0.0f, faces[i].x2-faces[i].x1, faces[i].y2 - faces[i].y1);
            trackingRects[i].opacity = 1.0f;
        } else { // no face
            trackingRects[i].opacity = 0.0f;
        }
    }        
    [faceDataLock unlock];
    
        
    [_glView setDisplayFramebuffer];
    glUseProgram(directDisplayProgram);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [_glView presentFramebuffer];
    
    videoStarted = 1;
}



#pragma mark -
#pragma mark OpenGL ES 2.0 setup methods

- (BOOL)loadVertexShader:(NSString *)vertexShaderName fragmentShader:(NSString *)fragmentShaderName forProgram:(GLuint *)programPointer
{
    GLuint vertexShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    *programPointer = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:vertexShaderName ofType:@"vsh"];
    if (![self compileShader:&vertexShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
#if defined(DEBUG)
        NSLog(@"Failed to compile vertex shader");
#endif
        return FALSE;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:fragmentShaderName ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
#if defined(DEBUG)        
        NSLog(@"Failed to compile fragment shader");
#endif
        return FALSE;
    }
    
    // Attach vertex shader to program.
    glAttachShader(*programPointer, vertexShader);
    
    // Attach fragment shader to program.
    glAttachShader(*programPointer, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(*programPointer, ATTRIB_VERTEX, "position");
    glBindAttribLocation(*programPointer, ATTRIB_TEXTUREPOSITON, "inputTextureCoordinate");
    
    // Link program.
    if (![self linkProgram:*programPointer]) {
#if defined(DEBUG)
        NSLog(@"Failed to link program: %d", *programPointer);
#endif        
        // cleaning up
        if (vertexShader) {
            glDeleteShader(vertexShader);
            vertexShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (*programPointer) {
            glDeleteProgram(*programPointer);
            *programPointer = 0;
        }
        return FALSE;
    }
    
    // Release vertex and fragment shaders.
    if (vertexShader) {
        glDeleteShader(vertexShader);
	}
    if (fragShader) {
        glDeleteShader(fragShader);		
	}
    return TRUE;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    const GLchar * source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
#if defined(DEBUG)
        NSLog(@"Failed to load vertex shader");
#endif
        return FALSE;
    }
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    GLint status;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return FALSE;
    }
    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
    glLinkProgram(prog);
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    GLint status;
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
    return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog
{
    glValidateProgram(prog);
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
#endif
    GLint status;
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
    return TRUE;
}



#pragma mark -
#pragma mark RecognitionCameraDelegate methods: get image from camera and process it

- (void)cameraHasConnected
{
#if defined(DEBUG)
    NSLog(@"Connected to camera");
#endif
}

//only to make screenshot
/*
- (CVPixelBufferRef )pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey, 
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = kCVReturnSuccess;
    status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options, &pxbuffer);
    //CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32BGRA, (CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL); 
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, kCGImageAlphaPremultipliedLast);
    //CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, kCGImageAlphaLast);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    // Converting BGRA to RGBA
    
    unsigned char * p1line = (unsigned char *)pxdata;
    unsigned char * p2line = ((unsigned char *)pxdata)+2;
    for (int y=0; y<size.height; ++y) {
        unsigned char * p1 = p1line;
        unsigned char * p2 = p2line;
        p1line += ((int)size.width)*4;
        p2line += ((int)size.width)*4;
        for (int x=0; x<((int)size.width); ++x) {
            unsigned char tmp = *p1;
            *p1 = *p2;
            *p2 = tmp;
            p1 += 4;
            p2 += 4;
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}
*/

- (void)processNewCameraFrame:(CVImageBufferRef)cameraFrame
{
    if (rotating)
        return; //not updating GLView on rotating animation (it looks ugly)
    
    // for screenshot
    //CGSize size = [image_for_screenshot size];
    //cameraFrame = (CVPixelBufferRef)[self pixelBufferFromCGImage:[image_for_screenshot CGImage] size:size];
    
    
	CVPixelBufferLockBaseAddress(cameraFrame, 0);
	int bufferHeight = CVPixelBufferGetHeight(cameraFrame);
	int bufferWidth = CVPixelBufferGetWidth(cameraFrame);
	
    // Create a new texture from the camera frame data, draw it (calling drawFrame)
    glGenTextures(1, &videoFrameTexture);
	glBindTexture(GL_TEXTURE_2D, videoFrameTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	// This is necessary for non-power-of-two textures
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);	
	
    // Using BGRA extension to pull in video frame data directly
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, bufferWidth, bufferHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(cameraFrame));
	[self drawFrame];
    
    if (_processingImage == NO && faceTouched == NO) {
        if (_closing) return;
        _processingImage = YES;
        
        // Copy camera frame to buffer
        
        int scanline = CVPixelBufferGetBytesPerRow(cameraFrame);
        unsigned char * buffer = (unsigned char *)malloc(scanline * bufferHeight);
        if (buffer) { 
            memcpy(buffer, CVPixelBufferGetBaseAddress(cameraFrame), scanline * bufferHeight);
        } else {
            _processingImage = NO;
            glDeleteTextures(1, &videoFrameTexture);
            CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
            return;
        }
        
        // Execute face detection and recognition asynchronously
        
        DetectFaceParams args;
        args.width = bufferWidth;
        args.height = bufferHeight;
        args.scanline = scanline;
        args.buffer = buffer;
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == 0 || orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
            //args.ratio = (float)self.view.bounds.size.height/(float)bufferWidth;
            //using _glView size proportional to video size:
            args.ratio = (float)self.view.bounds.size.width/(float)bufferHeight;
        } else {
            //args.ratio = (float)self.view.bounds.size.width/(float)bufferWidth;
            //using _glView size proportional to video size:
            args.ratio = (float)self.view.bounds.size.height/(float)bufferHeight;
        }
        NSData * argsobj = [NSData dataWithBytes:&args length:sizeof(DetectFaceParams)];
        // will free (buffer) inside
        [self performSelectorInBackground:@selector(processImageAsyncWith:) withObject:argsobj];        
    }
    
    glDeleteTextures(1, &videoFrameTexture);
    CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
}



#pragma mark -
#pragma mark Buttons

- (void)clearAction:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure to clear the memory?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    alert.tag = 0xC;
    [alert show];
    [alert release];
    
	//clearTracker = YES;
}

- (void)helpAction:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Luxand Face Recognition" message:(NSString *)help_text delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    //alert.tag = 1; // is not needed, delegate is set no nil
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{             
    if (alertView.tag == 0xC) { // Clear memory
        
        if (buttonIndex == 1) { // Ok.
            clearTracker = YES;
        }
        
    } else if (alertView.tag == 0xF) { // enter name for the Face
        if (buttonIndex == 0) { // Cancel.
            faceTouched = NO;
            return;
        }
        
        [idOfTouchedFaceLock lock];
        if (idOfTouchedFace == -1) {
#if defined(DEBUG)
            NSLog(@"idOfTouchedFace == -1, this shouldn't happen");
#endif
            [idOfTouchedFaceLock unlock];
            faceTouched = NO;
            return;
        }
        [idOfTouchedFaceLock unlock];
        
        NSString * name = [alertView textFieldAtIndex:0].text;
        const char * name_c_str = [name UTF8String];
        int len = strlen(name_c_str);
        
        [enteredNameLock lock];
        [idOfTouchedFaceLock lock];
        namedFaceID = idOfTouchedFace;
        [idOfTouchedFaceLock unlock];
        enteredName = new char[len+1];
        if (enteredName) strcpy(enteredName, name_c_str);
        [enteredNameLock unlock];
        
        // immediately display the name 
        [nameDataLock lock];
        memset(names[indexOfTouchedFace], 0, MAX_NAME_LEN+1);
        strncpy(names[indexOfTouchedFace], name_c_str, MIN(MAX_NAME_LEN, len));
        [nameDataLock unlock];
        
        faceTouched = NO;
    }
}



#pragma mark -
#pragma mark Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    currentTouchPoint = [[touches anyObject] locationInView:self.view];
    int x = currentTouchPoint.x;
    int y = currentTouchPoint.y;
    
    [idOfTouchedFaceLock lock];
    idOfTouchedFace = -1;
    [idOfTouchedFaceLock unlock];
    
    [faceDataLock lock];
    for (int i=0; i<MAX_FACES; ++i) {
        if (PointInRectangle(x, y, faces[i].x1, faces[i].y1, faces[i].x2, faces[i].y2 + 30)) {
            indexOfTouchedFace = i;
            [idOfTouchedFaceLock lock];
            idOfTouchedFace = IDs[i];
            [idOfTouchedFaceLock unlock];
            break;
        }
    }
    [faceDataLock unlock];
    
    [idOfTouchedFaceLock lock];
    if (idOfTouchedFace != -1) {
        [idOfTouchedFaceLock unlock];
        
        faceTouched = YES;
#if defined(DEBUG)        
        NSLog(@"FACE TOUCHED");
#endif        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Enter person's name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 0xF;
        [alert show];
        [alert release];
    } else {
        [idOfTouchedFaceLock unlock];
    }
#if defined(DEBUG)
    NSLog(@"touch at (%d, %d)", x, y);
#endif
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//CGPoint movedPoint = [[touches anyObject] locationInView:self.view]; 
	//CGFloat distanceMoved = sqrt( (movedPoint.x - currentTouchPoint.x) * (movedPoint.x - currentTouchPoint.x) + (movedPoint.y - currentTouchPoint.y) * (movedPoint.y - currentTouchPoint.y) );
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
}



#pragma mark -
#pragma mark Device rotation support

//auto-rotate enabler (if compiling for iOS6+ only use the project's properties to enable orientations and change this method to shouldAutorotate)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //if (video_started) {
    //    rotating = YES;
    //}
    return YES;
}

/* does not work:
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if (video_started) {
        rotating = YES;
    }
    [UIView setAnimationDuration:duration];
    [UIView beginAnimations:nil context:NULL];
    _glView.transform = CGAffineTransformMakeRotation(M_PI/2);
    [UIView commitAnimations];
}
*/

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    //orientation = toInterfaceOrientation;
    rotating = YES;
    for (int i=0; i<MAX_FACES; ++i) {
        [trackingRects[i] setHidden:YES];
    }
    [toolbar setHidden:YES];
    [_glView setHidden:YES];
    //[UIView setAnimationsEnabled:NO];
}

//not called on first times screen rotating in iOS (on start):
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //[UIView setAnimationsEnabled:YES];
    for (int i=0; i<MAX_FACES; ++i) {
        [trackingRects[i] setHidden:NO];
    }
    rotating = NO;
}

- (void)relocateSubviewsForOrientation:(UIInterfaceOrientation)orientation
{
    [_glView removeFromSuperview];
    CGRect applicationFrame = [screenForDisplay applicationFrame];
    
    //DEBUG
    //const int video_width = 352;
    //const int video_height = 288;
    
    const int video_width = 640;
    const int video_height = 480;
    if (orientation == 0 || orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        //_glView = [[RecognitionGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, applicationFrame.size.width, applicationFrame.size.height)];
        //using _glView size proportional to video size:
        _glView = [[RecognitionGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, applicationFrame.size.width, applicationFrame.size.width * (video_width*1.0f/video_height))];
    } else {
        //_glView = [[RecognitionGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, applicationFrame.size.height, applicationFrame.size.width)];
        //using _glView size proportional to video size:
        _glView = [[RecognitionGLView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, applicationFrame.size.width * (video_width*1.0f/video_height), applicationFrame.size.width)];
    }
    [self.view addSubview:_glView];
    [_glView release]; //now self.view is responsible for the view
    [self loadVertexShader:@"DirectDisplayShader" fragmentShader:@"DirectDisplayShader" forProgram:&directDisplayProgram];
    for (int i=0; i<MAX_FACES; ++i) {
        [_glView.layer addSublayer:trackingRects[i]];
    }
    
    // Toolbar re-alignment
    CGFloat toolbarHeight = [toolbar frame].size.height;
    CGRect mainViewBounds = self.view.bounds;
    [toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
                                 CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight),
                                 CGRectGetWidth(mainViewBounds),
                                 toolbarHeight)];
    [toolbar setHidden:NO];
    [self.view sendSubviewToBack:_glView];
}



#pragma mark -
#pragma mark Face detection and recognition

- (void)processImageAsyncWith:(NSData *)args
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init]; //required for async execution
    // Do not forget to [pool release] on exit!
    
    if (_closing) {
        [pool release];
        return;
    }
    
    // Cleaning tracker memory, if the button was pressed

    if (clearTracker) {
        FSDK_ClearTracker(_tracker);
        clearTracker = NO;
    }
    
    // Reading buffer parameters
    
    DetectFaceParams a;
    [args getBytes:&a length:sizeof(DetectFaceParams)];
    unsigned char * buffer = a.buffer;
    int width = a.width;
    int height = a.height;
    int scanline = a.scanline;
    float ratio = a.ratio;
    
    // Converting BGRA to RGBA
    
    unsigned char * p1line = buffer;
    unsigned char * p2line = buffer+2;
    for (int y=0; y<height; ++y) {
        unsigned char * p1 = p1line;
        unsigned char * p2 = p2line;
        p1line += scanline;
        p2line += scanline;
        for (int x=0; x<width; ++x) {
            unsigned char tmp = *p1;
            *p1 = *p2;
            *p2 = tmp;
            p1 += 4;
            p2 += 4;
        }
    }
    
    HImage image;
    int res = FSDK_LoadImageFromBuffer(&image, buffer, width, height, scanline, FSDK_IMAGE_COLOR_32BIT);
    free(buffer);
    if (res != FSDKE_OK) {
#if defined(DEBUG)
        NSLog(@"FSDK_LoadImageFromBuffer failed with %d", res);
#endif
        [pool release];
        _processingImage = NO;
        return;
    }
    
    // Rotating image basing on orientation
    
    HImage derotated_image;
    res = FSDK_CreateEmptyImage(&derotated_image);
    if (res != FSDKE_OK) {
#if defined(DEBUG)
        NSLog(@"FSDK_CreateEmptyImage failed with %d", res);
#endif
        FSDK_FreeImage(image);
        [pool release];
        _processingImage = NO;
        return;
    }
    UIInterfaceOrientation df_orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (df_orientation == 0 || df_orientation == UIInterfaceOrientationPortrait) {
        res = FSDK_RotateImage90(image, 1, derotated_image);
    } else if (df_orientation == UIInterfaceOrientationPortraitUpsideDown) {
        res = FSDK_RotateImage90(image, -1, derotated_image);
    } else if (df_orientation == UIInterfaceOrientationLandscapeLeft) {
        res = FSDK_RotateImage90(image, 0, derotated_image); //will simply copy image
    } else if (df_orientation == UIInterfaceOrientationLandscapeRight) {
        res = FSDK_RotateImage90(image, 2, derotated_image);
    }
    if (res != FSDKE_OK) {
#if defined(DEBUG)
        NSLog(@"FSDK_RotateImage90 failed with %d", res);
#endif
        FSDK_FreeImage(image);
        FSDK_FreeImage(derotated_image);
        [pool release];
        _processingImage = NO;
        return;
    }
    
    res = FSDK_MirrorImage(derotated_image, true);
    if (res != FSDKE_OK) {
#if defined(DEBUG)
        NSLog(@"FSDK_MirrorImage failed with %d", res);
#endif
        FSDK_FreeImage(image);
        FSDK_FreeImage(derotated_image);
        [pool release];
        _processingImage = NO;
        return;
    }
    
    // Passing entered name to FaceSDK 
    
    [enteredNameLock lock];
    if (enteredName) {
        if (FSDKE_OK == FSDK_LockID(_tracker, namedFaceID)) {
            FSDK_SetName(_tracker, namedFaceID, enteredName);
            FSDK_UnlockID(_tracker, namedFaceID);
        }
#if defined(DEBUG)
        NSLog(@"name set: %s", enteredName);
#endif
    }
    delete [] enteredName, enteredName = NULL;
    [enteredNameLock unlock];
    
    // Passing frame to FaceSDK, reading face coordinates and names
    
    long long count = 0;
    FSDK_FeedFrame(_tracker, 0, derotated_image, &count, IDs, sizeof(IDs));

    [faceDataLock lock];
    memset(faces, 0, sizeof(FaceRectangle)*MAX_FACES);
    for (size_t i = 0; i < (size_t)count; ++i) {
        memset(names[i], 0, MAX_NAME_LEN + 1);
        //if (IDs[i] != -1) { //not needed anymore
        [nameDataLock lock];
        int result = FSDK_GetAllNames(_tracker, IDs[i], names[i], MAX_NAME_LEN);
        [nameDataLock unlock];
        if (FSDKE_OK != result) break; //continue;
        //}
        FSDK_Features Eyes;
        FSDK_GetTrackerEyes(_tracker, 0, IDs[i], &Eyes);
        GetFaceFrame(&Eyes, &(faces[i].x1), &(faces[i].y1), &(faces[i].x2), &(faces[i].y2));   
        
        faces[i].x1 *= ratio;
        faces[i].x2 *= ratio;
        faces[i].y1 *= ratio;
        faces[i].y2 *= ratio;
        //NSLog(@"w=%d x=%d y=%d", faces[i].w, faces[i].xc, faces[i].yc);
    }
    [faceDataLock unlock];
    
    
    // Saving image to gallery (debug)
    
    /*
    static BOOL image_saved = NO;
    static int framenum = 0;
    if (!image_saved && framenum++ > 10) {
        NSString * imagePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.png"];
        //res = FSDK_SaveImageToFile(image, (char *)[imagePath UTF8String]);
        res = FSDK_SaveImageToFile(derotated_image, (char *)[imagePath UTF8String]);
        NSLog(@"saved to %s with %d", [imagePath UTF8String], res);
        UIImage * cocoa_image = [UIImage imageWithContentsOfFile:imagePath];
        UIImageWriteToSavedPhotosAlbum(cocoa_image, nil, nil, nil);
         
        image_saved = YES;
    }
    */
    
    
    FSDK_FreeImage(image);
    FSDK_FreeImage(derotated_image);
    [pool release];
    _processingImage = NO;
}

@end
