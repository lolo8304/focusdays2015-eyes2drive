//
//  FaceDetectionOpenCV.h
//  eyes2drive
//
//  Created by Lorenz Hänggi on 10/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/videoio/cap_ios.h>

@interface FaceDetectionOpenCV : NSObject<CvVideoCameraDelegate>

@property (nonatomic, readwrite) AVCaptureVideoOrientation orientation;

@property (nonatomic, readwrite) long msSinceLastDetection;
@property (nonatomic, readwrite) NSDate * timeLastDetection;

- (id) initWith: (AVCaptureVideoOrientation)orientation;
- (void) faceDetected;

@end
