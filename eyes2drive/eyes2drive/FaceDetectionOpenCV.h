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

- (id) initWith: (AVCaptureVideoOrientation)orientation controller: (ViewController *)controller;
- (void) faceDetected: (BOOL)detected;
- (void) eyesDetected: (BOOL)detected;
- (void) twoEyesDetected: (BOOL)detected;

@end
