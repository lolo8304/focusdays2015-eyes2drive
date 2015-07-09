//
//  FaceDetectionOpenCV.m
//  eyes2drive
//
//  Created by Lorenz Hänggi on 10/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

#import "FaceDetectionOpenCV.h"
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgproc/imgproc.hpp>

@implementation FaceDetectionOpenCV

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}



#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
// delegate method for processing image frames
- (void)processImage:(cv::Mat&)image; {
    // Do some OpenCV stuff with the image
    cv::Mat image_copy;
    cvtColor(image, image_copy, CV_BGRA2BGR);
    
    // invert image
    bitwise_not(image_copy, image_copy);
    cvtColor(image_copy, image, CV_BGR2BGRA);
}
#endif

@end
