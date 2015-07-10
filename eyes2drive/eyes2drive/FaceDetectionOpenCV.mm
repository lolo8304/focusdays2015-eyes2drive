//
//  FaceDetectionOpenCV.m
//  eyes2drive
//
//  Created by Lorenz Hänggi on 10/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//
// based on http://docs.opencv.org/doc/tutorials/objdetect/cascade_classifier/cascade_classifier.html

#import "FaceDetectionOpenCV.h"
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgproc/imgproc.hpp>
#include <opencv2/objdetect/objdetect.hpp>




@implementation FaceDetectionOpenCV

NSString * const face_cascade_name = @"haarcascade_frontalface_alt_tree";
NSString * const eyes_cascade_name = @"haarcascade_eye_tree_eyeglasses.1";

cv::CascadeClassifier face_cascade;
cv::CascadeClassifier eyes_cascade;

- (id) initWith: (AVCaptureVideoOrientation)orientation {
    self = [self init];
    if (self) {
        self.orientation = orientation;
        self.msSinceLastDetection = 0;
        self.timeLastDetection = [NSDate date];
        return self;
    }
    return nil;
}


- (id)init {
    self = [super init];
    if (self) {
        // Load the cascades
        NSURL *resourceURL = [[NSBundle mainBundle] URLForResource: face_cascade_name withExtension: @"xml"];
        printf("load face cascade classifier from %s.\n", [[resourceURL path] UTF8String]);
        if( !resourceURL || !face_cascade.load( [[resourceURL path] UTF8String] ) ){ printf("--(!)Error loading face cascade, please change face_cascade_name in source code.\n");
        };
        
        // Load the cascades
        NSURL *resourceURL_eyes = [[NSBundle mainBundle] URLForResource: eyes_cascade_name withExtension: @"xml"];
        printf("load eyes cascade classifier from %s.\n", [[resourceURL_eyes path] UTF8String]);
        if( !resourceURL_eyes || !eyes_cascade.load( [[resourceURL_eyes path] UTF8String] ) ){ printf("--(!)Error loading eyes cascade, please change face_cascade_name in source code.\n");
        };
        
    }
    return self;
}

- (void) faceDetected {
    if (self.timeLastDetection != nil) {
        self.msSinceLastDetection = [self.timeLastDetection timeIntervalSinceNow] * -1;
    } else {
        self.msSinceLastDetection = 0;
    }
        self.timeLastDetection = [NSDate date];

        if (self.msSinceLastDetection > 2000) {
            printf("not detected since 2s");
        }
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus


- (void)invertImage:(cv::Mat&)image; {
    
}

- (void)detectFace:(cv::Mat&)image; {
    std::vector<cv::Rect> faces;
    //cv::Mat frame_gray;
    
    std::vector<cv::Mat> rgbChannels(3);
    cv::split(image, rgbChannels);
    cv::Mat frame_gray = rgbChannels[2];
    
    //cvtColor( frame, frame_gray, CV_BGR2GRAY );
    //equalizeHist( frame_gray, frame_gray );
    //cv::pow(frame_gray, CV_64F, frame_gray);
    //-- Detect faces
    face_cascade.detectMultiScale( frame_gray, faces, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(100, 100) );
    
    for( int i = 0; i < faces.size(); i++ )
    {
        rectangle(image, faces[i], 1234);
        [self faceDetected];
        [self detectEyes: image gray: frame_gray face: faces[i] ];
    }

}


- (void)detectEyes:(cv::Mat&)image gray: (cv::Mat&)frame_gray face: (cv::Rect)face; {

    int eye_region_top = face.height * 0.5;
    cv::Rect eyeRegion(face.x, face.y, face.width, eye_region_top);
    
    cv::Mat faceROI = frame_gray( eyeRegion );
    std::vector<cv::Rect> eyes;
    
    eyes_cascade.detectMultiScale( faceROI, eyes, 1.1, 2, 0 |CV_HAAR_SCALE_IMAGE, cv::Size(20, 20) );
    
    for( size_t j = 0; j < eyes.size(); j++ )
    {
        cv::Point center( eyeRegion.x + eyes[j].x + eyes[j].width*0.5, eyeRegion.y + eyes[j].y + eyes[j].height*0.5 );
        //int radius = cvRound( (eyes[j].width + eyes[j].height)*0.25 );
        //circle( image, center, radius, cv::Scalar( 255, 0, 0 ), 4, 8, 0 );
        int radius = 5;
        circle( image, center, radius, cv::Scalar( 255, 0, 0 ));
    }
    
}





// delegate method for processing image frames
- (void)processImage:(cv::Mat&)image; {
    [self detectFace: image];
}


#endif


@end
