//
//  based on ColorTrackingCamera.m
//  from ColorTracking application
//  The source code for this application is available under a BSD license.
//  See ColorTrackingLicense.txt for details.
//  Created by Brad Larson on 10/7/2010.
//  Modified by Anton Malyshev on 6/21/2013.
//

#import "RecognitionCamera.h"

@implementation RecognitionCamera

#pragma mark -
#pragma mark Initialization and teardown

- (id)init; 
{
	if (!(self = [super init]))
		return nil;
	
	// Grab the front-facing camera
	AVCaptureDevice * camera = nil;
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices) {
		if ([device position] == AVCaptureDevicePositionFront) {
			camera = device;
		}
	}
	
	// Create the capture session
	captureSession = [[AVCaptureSession alloc] init];
	
	// Add the video input	
	NSError *error = nil;
	videoInput = [[[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error] autorelease];
	if ([captureSession canAddInput:videoInput]) {
		[captureSession addInput:videoInput];
	}
	
	[self videoPreviewLayer];
	// Add the video frame output	
	videoOutput = [[AVCaptureVideoDataOutput alloc] init];
	[videoOutput setAlwaysDiscardsLateVideoFrames:YES];
	// Use RGB frames instead of YUV to ease color processing
    
    [videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    //NOT SUPPORTED:
    //[videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32RGBA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
	//dispatch_queue_t videoQueue = dispatch_queue_create("com.sunsetlakesoftware.colortracking.videoqueue", NULL);
    //[videoOutput setSampleBufferDelegate:self queue:videoQueue];
    
    [videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

	if ([captureSession canAddOutput:videoOutput]) {
		[captureSession addOutput:videoOutput];
	} else {
#if defined(DEBUG)
		NSLog(@"Couldn't add video output");
#endif
	}

	// Start capturing
    //[captureSession setSessionPreset:AVCaptureSessionPresetHigh];
	[captureSession setSessionPreset:AVCaptureSessionPreset640x480];
	
    //DEBUG
    //[captureSession setSessionPreset:AVCaptureSessionPreset352x288];
	
    if (![captureSession isRunning]) {
		[captureSession startRunning];
	};
	
	return self;
}

- (void)dealloc 
{
	[captureSession stopRunning];
	[captureSession release];
	[videoPreviewLayer release];
	[videoOutput release];
	[videoInput release];
	[super dealloc];
}

#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	[self.delegate processNewCameraFrame:pixelBuffer];
}

#pragma mark -
#pragma mark Accessors

@synthesize delegate;
@synthesize videoPreviewLayer;

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer;
{
	if (videoPreviewLayer == nil) {
		videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
        
        //isOrientationSupported & setOrientation are deprecated in iOS 6
        //if ([videoPreviewLayer isOrientationSupported]) {
        //    [videoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
        //}
        
        [videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	}
	return videoPreviewLayer;
}

@end
