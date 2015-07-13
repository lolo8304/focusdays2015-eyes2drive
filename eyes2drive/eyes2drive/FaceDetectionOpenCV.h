//
//  FaceDetectionOpenCV.h
//  eyes2drive
//
//  Created by Lorenz Hänggi on 10/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/videoio/cap_ios.h>
#import "FeatureDetectionTime.h"

@interface FaceDetectionOpenCV : NSObject<CvVideoCameraDelegate, FeatureDetectionDelegate>

@property (nonatomic) AVCaptureVideoOrientation orientation;
@property (nonatomic, weak) ViewController * controller;

@property (nonatomic, strong) FeatureDetectionTime * faceDetected;
@property (nonatomic, strong) FeatureDetectionTime * eyesDetected;
@property (nonatomic, strong) FeatureDetectionTime * twoEyesDetected;
@property (nonatomic) CFTimeInterval tripStartTime;
@property (nonatomic) CFTimeInterval tripStopTime;
@property (atomic, strong) NSDictionary * events;

- (id) initWith: (AVCaptureVideoOrientation)orientation controller: (ViewController *)controller;
- (void) faceDetected: (BOOL)detected;
- (void) eyesDetected: (BOOL)detected;
- (void) twoEyesDetected: (BOOL)detected;

- (void)startTrip;
- (void)stopTrip;
- (CFTimeInterval)tripElapsedTime;

- (State *) getLastState: (FeatureDetection) feature;
- (FeatureAlertColor)getLastColor: (FeatureDetection)  feature;
- (NSMutableArray *) getAllStates: (FeatureDetection) feature;
- (NSMutableArray *) getNofStates: (FeatureDetection)  feature;


@end
