//
//  based on ColorTrackingCamera.h
//  from ColorTracking application
//  The source code for this application is available under a BSD license.
//  See ColorTrackingLicense.txt for details.
//  Created by Brad Larson on 10/7/2010.
//  Modified by Anton Malyshev on 6/21/2013.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@protocol RecognitionCameraDelegate;

@interface RecognitionCamera : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
{
	AVCaptureVideoPreviewLayer *videoPreviewLayer;
	AVCaptureSession *captureSession;
	AVCaptureDeviceInput *videoInput;
	AVCaptureVideoDataOutput *videoOutput;
}

@property(nonatomic, assign) id<RecognitionCameraDelegate> delegate;
@property(readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@protocol RecognitionCameraDelegate
- (void)cameraHasConnected;
- (void)processNewCameraFrame:(CVImageBufferRef)cameraFrame;
@end
