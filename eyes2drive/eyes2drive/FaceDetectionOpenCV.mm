//
//  FaceDetectionOpenCV.m
//  eyes2drive
//
//  Created by Lorenz Hänggi on 10/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//
// based on http://docs.opencv.org/doc/tutorials/objdetect/cascade_classifier/cascade_classifier.html

#import "ViewController.h"
#import "FaceDetectionOpenCV.h"

#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgproc/imgproc.hpp>
#include <opencv2/objdetect/objdetect.hpp>




@implementation FaceDetectionOpenCV


NSString * const C_face_cascade_name = @"haarcascade_frontalface_alt_tree";
NSString * const C_eyes_cascade_name = @"haarcascade_eye_tree_eyeglasses.1";

cv::CascadeClassifier face_cascade;
cv::CascadeClassifier eyes_cascade;

- (id) initWith: (AVCaptureVideoOrientation)orientation controller: (ViewController *)controller {
    self = [self init];
    if (self) {
        self.orientation = orientation;
        
        [self loadFaceClassifier: C_face_cascade_name];
        [self loadEyesClassifier: C_eyes_cascade_name];
        self.controller = controller;
        self.faceDetected = [[FeatureDetectionTime alloc] initWith: FeatureFaceDetected ];
        self.faceDetected.delegate = self;
        [self.faceDetected setThreshold: false orange:1000 red:3000 darkred: 4000];
        
        self.eyesDetected = [[FeatureDetectionTime alloc] initWith: FeatureEyesDetected ];
        self.eyesDetected.delegate = self;
        [self.eyesDetected setThreshold: false orange: 2000 red: 3000 darkred: 5000];
        
        self.twoEyesDetected = [[FeatureDetectionTime alloc] initWith: Feature2EyesDetected ];
        self.twoEyesDetected.delegate = self;
        [self.eyesDetected setThreshold: false orange: 3000 red: 5000 darkred: 7000];
        return self;
    }
    return nil;
}




- (void)feature:(FeatureDetection)feature changedState:(State *)state {
    printf("%s : %s was ACTIVE since %i (changed now)\n",
           [(FeatureAlertColor_toString[ [state color] ]) UTF8String],
           [(FeatureDetection_toString[feature]) UTF8String],
           (int)[state elapsedTime]);
}



-(void)loadFaceClassifier: (NSString *) face_cascade_name {
    // Load the cascades
    NSURL *resourceURL = [[NSBundle mainBundle] URLForResource: face_cascade_name withExtension: @"xml"];
    printf("load face cascade classifier from %s.\n", [[resourceURL path] UTF8String]);
    if( !resourceURL || !face_cascade.load( [[resourceURL path] UTF8String] ) ){ printf("--(!)Error loading face cascade, please change face_cascade_name in source code.\n");
    }
}

-(void)loadEyesClassifier: (NSString *) eyes_cascade_name {
    // Load the cascades
    NSURL *resourceURL_eyes = [[NSBundle mainBundle] URLForResource: eyes_cascade_name withExtension: @"xml"];
    printf("load eyes cascade classifier from %s.\n", [[resourceURL_eyes path] UTF8String]);
    if( !resourceURL_eyes || !eyes_cascade.load( [[resourceURL_eyes path] UTF8String] ) ){ printf("--(!)Error loading eyes cascade, please change face_cascade_name in source code.\n");
    }
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void) faceDetected: (BOOL)detected {
    if (detected) {
        [self.faceDetected featureDetected];
    } else {
        [self.faceDetected featureNotDetected];
    }
}
- (void) eyesDetected: (BOOL)detected {
    if (detected) {
        [self.eyesDetected featureDetected];
    } else {
        [self.eyesDetected featureNotDetected];
    }
}
- (void) twoEyesDetected: (BOOL)detected {
    if (detected) {
        [self.twoEyesDetected featureDetected];
    } else {
        [self.twoEyesDetected featureNotDetected];
    }
}

#ifdef __cplusplus

- (void)detectFace:(cv::Mat&)image; {
    std::vector<cv::Rect> faces;
    //cv::Mat frame_gray;
    
    std::vector<cv::Mat> rgbChannels(3);
    cv::split(image, rgbChannels);
    cv::Mat frame_gray = rgbChannels[2];

//    [self goodFeaturesToTrack: image gray: frame_gray ];
    
    //cvtColor( frame, frame_gray, CV_BGR2GRAY );
    //equalizeHist( frame_gray, frame_gray );
    //cv::pow(frame_gray, CV_64F, frame_gray);
    //-- Detect faces
    cv::Size minSize = cv::Size(30, 30);
    cv::Size maxSize = cv::Size(150, 150);
    
    face_cascade.detectMultiScale( frame_gray, faces, 1.1, 3, 0|CV_HAAR_SCALE_IMAGE , minSize );
    
    if (faces.size() > 0) {
        for( int i = 0; i < faces.size(); i++ )
        {
            cv::Rect face = faces[i];
            rectangle(image, face, 1234);
        
            cv::Rect minRect(
                             face.x + face.width/2 - minSize.width / 2,
                             face.y + face.height/2 - minSize.height / 2,
                             minSize.width, minSize.height);
            cv::Rect maxRect(
                             MAX(face.x + face.width/2 - maxSize.width / 2, 0),
                             MAX(face.y + face.height/2 - maxSize.height / 2, 0),
                             maxSize.width, maxSize.height);

//          rectangle(image, minRect, 1234);

            [self faceDetected: true];
//            [self detectEyes: image gray: frame_gray face: face ];
        }
    } else {
        [self faceDetected: false];
//        [self eyesDetected: false];
//        [self twoEyesDetected: false];
    }

}

- (void)goodFeaturesToTrack: (cv::Mat&)image gray: (cv::Mat&)frame_gray {
    std::vector< cv::Point2f > corners;
    
    // maxCorners – The maximum number of corners to return. If there are more corners
    // than that will be found, the strongest of them will be returned
    int maxCorners = 10;
    
    // qualityLevel – Characterizes the minimal accepted quality of image corners;
    // the value of the parameter is multiplied by the by the best corner quality
    // measure (which is the min eigenvalue, see cornerMinEigenVal() ,
    // or the Harris function response, see cornerHarris() ).
    // The corners, which quality measure is less than the product, will be rejected.
    // For example, if the best corner has the quality measure = 1500,
    // and the qualityLevel=0.01 , then all the corners which quality measure is
    // less than 15 will be rejected.
    double qualityLevel = 0.01;
    
    // minDistance – The minimum possible Euclidean distance between the returned corners
    double minDistance = 20.;
    
    // mask – The optional region of interest. If the image is not empty (then it
    // needs to have the type CV_8UC1 and the same size as image ), it will specify
    // the region in which the corners are detected
    cv::Mat mask;
    
    // blockSize – Size of the averaging block for computing derivative covariation
    // matrix over each pixel neighborhood, see cornerEigenValsAndVecs()
    int blockSize = 3;
    
    // useHarrisDetector – Indicates, whether to use operator or cornerMinEigenVal()
    bool useHarrisDetector = true;
    
    // k – Free parameter of Harris detector
    double k = 0.04;
    
    cv::goodFeaturesToTrack( frame_gray, corners, maxCorners, qualityLevel, minDistance, mask, blockSize, useHarrisDetector, k );
    
    for( size_t i = 0; i < corners.size(); i++ )
    {
        cv::circle( image, corners[i], 10, cv::Scalar( 255. ));
    }
}

- (void)detectEyes:(cv::Mat&)image gray: (cv::Mat&)frame_gray face: (cv::Rect)face; {

    int eye_region_top = face.height * 0.2;
    int eye_region_bottom = face.height * 0.5;
    cv::Rect eyeRegion(
                    face.x, face.y+eye_region_top,
                    face.width, eye_region_bottom-eye_region_top);
    
    cv::Mat faceROI = frame_gray( eyeRegion );
    std::vector<cv::Rect> eyes;
    
    cv::Size minSize = cv::Size(20, 20);

    eyes_cascade.detectMultiScale( faceROI, eyes, 1.1, 2, 0 | CV_HAAR_SCALE_IMAGE, minSize );

    if (eyes.size() > 0) {
        for( size_t j = 0; j < eyes.size(); j++ ) {
            cv::Rect eye = eyes[j];
            cv::Point center( eyeRegion.x + eye.x + eye.width*0.5, eyeRegion.y + eye.y + eye.height*0.5 );
            //int radius = cvRound( (eye.width + eye.height)*0.25 );
            //circle( image, center, radius, cv::Scalar( 255, 0, 0 ), 4, 8, 0 );
            int radius = 5;
            circle( image, center, radius, cv::Scalar( 255, 0, 0 ));
            cv::Rect minRect(
                         eyeRegion.x + eye.x + eye.width/2 - minSize.width / 2,
                         eyeRegion.y + eye.y + eye.height/2 - minSize.height / 2,
                         minSize.width, minSize.height);
            rectangle(image, minRect, 1234);
            rectangle(image, eyeRegion, 100);
        }
        [self eyesDetected: true];
        if (eyes.size() == 2) {
            [self twoEyesDetected: true];
        } else {
            [self twoEyesDetected: false];
        }
    } else {
        [self eyesDetected: false];
        [self twoEyesDetected: false];
    }
    
}





// delegate method for processing image frames
- (void)processImage:(cv::Mat&)image; {
    [self detectFace: image];
}


#endif


@end
