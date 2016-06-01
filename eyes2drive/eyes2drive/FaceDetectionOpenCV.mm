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


//do NOT change haar-classifier, these are the best right now
NSString * const C_face_cascade_name = @"haarcascade_frontalface_alt";

NSString * const C_eyes_cascade_name = @"haarcascade_eye";

//NSString * const C_right_eyes_cascade_name = @"haarcascade_righteye_2splits";
NSString * const C_right_eyes_cascade_name = @"haarcascade_mcs_righteye";

//NSString * const C_left_eyes_cascade_name = @"haarcascade_lefteye_2splits";
NSString * const C_left_eyes_cascade_name = @"haarcascade_mcs_lefteye";

NSString * const C_eyes_opened_cascade_name = @"haarcascade_eye_tree_eyeglasses";

NSString * const C_nose_cascade_name = @"haarcascade_mcs_nose";

NSString * const C_mouth_cascade_name = @"haarcascade_mcs_mouth";

cv::CascadeClassifier face_cascade;
cv::CascadeClassifier eyes_cascade;
cv::CascadeClassifier left_eyes_cascade;
cv::CascadeClassifier right_eyes_cascade;
cv::CascadeClassifier eyes_opened_cascade;
cv::CascadeClassifier nose_cascade;
cv::CascadeClassifier mouth_cascade;

CFTimeInterval ORANGE_Threshold = 500;
CFTimeInterval RED_Threshold = 1500;
CFTimeInterval DARKRED_Threshold = 3000;



- (id) initWith: (AVCaptureVideoOrientation)orientation controller: (ViewController *)controller {
    self = [self init];
    if (self) {
        self.orientation = orientation;
        
        [self loadClassifier: face_cascade named: C_face_cascade_name title: @"face"];
        [self loadClassifier: eyes_cascade named: C_eyes_cascade_name title: @"eyes"];
        [self loadClassifier: left_eyes_cascade named: C_left_eyes_cascade_name title: @"left eyes"];
        [self loadClassifier: right_eyes_cascade named: C_right_eyes_cascade_name title: @"right eyes"];
        [self loadClassifier: eyes_opened_cascade named: C_eyes_opened_cascade_name title: @"eyes opened"];
        [self loadClassifier: nose_cascade named: C_nose_cascade_name title: @"nose"];
        [self loadClassifier: mouth_cascade named: C_mouth_cascade_name title: @"mouth"];
        
        self.controller = controller;
        [self clearEvents];
        
        self.trip = [[FeatureDetectionTime alloc] initWith: FeatureTrip ];
        self.trip.delegate = self;
        [self.trip setThreshold: false orange:1 red:0 darkred: 0];
        [[self.trip state] push: FeatureAlertRed]; //initialize with detecte -> start means not-detected, stop means detected

        self.faceDetected = [[FeatureDetectionTime alloc] initWith: FeatureFaceDetected ];
        self.faceDetected.delegate = self;
        [self.faceDetected setThreshold: false orange:ORANGE_Threshold red:RED_Threshold darkred: DARKRED_Threshold];
        
        self.eyesDetected = [[FeatureDetectionTime alloc] initWith: FeatureEyesDetected ];
        self.eyesDetected.delegate = self;
        [self.eyesDetected setThreshold: false orange: ORANGE_Threshold red: RED_Threshold darkred: DARKRED_Threshold];
        
        self.twoEyesDetected = [[FeatureDetectionTime alloc] initWith: Feature2EyesDetected ];
        self.twoEyesDetected.delegate = self;
        [self.twoEyesDetected setThreshold: false orange: ORANGE_Threshold red: RED_Threshold darkred: DARKRED_Threshold];

        
        
        self.peripheral = [[BTLEPeripheral alloc] initWith: self];
        [self.peripheral startBluetooth];
        
        return self;
    }
    return nil;
}

- (void)clearEvents {
    self.events = @{
                [NSNumber numberWithInt: FeatureFaceDetected] : [[NSMutableArray alloc] init],
                [NSNumber numberWithInt: FeatureEyesDetected] : [[NSMutableArray alloc] init],
                [NSNumber numberWithInt: Feature2EyesDetected] : [[NSMutableArray alloc] init],
                [NSNumber numberWithInt: FeatureTrip] : [[NSMutableArray alloc] init]
                };
    self.eventsToSend = [[NSMutableArray alloc] init];

}


- (void)sendEvent:(FeatureDetection)feature changedState:(State *)state {
    NSString * stateEvent = [state toSendEventString];
    if (self.started) {
        printf("send event now %s.\n", [stateEvent UTF8String]);
        [self.eventsToSend addObject: stateEvent];
    } else {
        //printf("send event suppressed becaused stopped now %s.\n", [stateEvent UTF8String]);
    }
}


- (NSData *)dataToSend {
    if ([self.eventsToSend count] > 0) {
        NSString * statusData = self.eventsToSend[0];
        [self.eventsToSend removeObjectAtIndex:0];
        return [statusData dataUsingEncoding:NSUTF8StringEncoding];
    }
    return nil;
}



- (void)feature:(FeatureDetection)feature changedState:(State *)state {
    NSMutableArray * elements = self.events[ [NSNumber numberWithInt: feature ] ];
    [elements addObject: state];
    
    [self sendEvent:(FeatureDetection)feature changedState:(State *)state];
    
    printf("%s %s since %.0f [ms]\n",
           [(FeatureAlertColor_toString[ [state color] ]) UTF8String],
           [(FeatureDetection_toString[feature]) UTF8String],
           [state elapsedTime]);
}

-(void)loadClassifier: (cv::CascadeClassifier&) cascade named: (NSString *) cascade_name title: (NSString *) title {
    // Load the cascades
    NSURL *resourceURL_eyes = [[NSBundle mainBundle] URLForResource: cascade_name withExtension: @"xml"];
    //printf("load %s cascade classifier from %s.\n", [title UTF8String], [[resourceURL_eyes path] UTF8String]);
    if( !resourceURL_eyes || !cascade.load( [[resourceURL_eyes path] UTF8String] ) ){ printf("--(!)Error loading %s cascade, please change face_cascade_name in source code.\n", [title UTF8String]);
    }
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void) faceDetected: (BOOL)detected {
    [self.faceDetected featureDetected: detected];
}
- (void) eyesDetected: (BOOL)detected {
    [self.eyesDetected featureDetected: detected];
}
- (void) twoEyesDetected: (BOOL)detected {
    [self.twoEyesDetected featureDetected: detected];
}

- (void)startTrip {
    self.started = true;
   // [self clearEvents];
    [self.trip featureDetected: true];
    [[self.trip state] push: FeatureAlertGreen];
    [self.trip triggerChangedEvent];
    
    
}
- (void)stopTrip {
    [[self.trip state] push: FeatureAlertRed];
    [self.trip triggerChangedEvent];
    self.started = false;
}

- (BOOL)isStarted {
    return self.started;
}


- (State *) getLastState: (FeatureDetection) feature {
    NSMutableArray * states =  [self getAllStates: feature];
    if ([states count] > 0 ) {
        return [states lastObject];
    }
    return nil;
}
- (NSMutableArray *) getAllStates: (FeatureDetection) feature {
    NSMutableArray * states =  [self.events[ [NSNumber numberWithInt: feature] ] copy];
    return states;
}
- (NSMutableArray *) getNofStates: (FeatureDetection)  feature {
    NSMutableArray * states =  [self getAllStates: feature];
    NSMutableArray * colorStates = [[NSMutableArray alloc] init];
    [colorStates addObject: [NSNumber numberWithInt: 0]];
    [colorStates addObject: [NSNumber numberWithInt: 0]];
    [colorStates addObject: [NSNumber numberWithInt: 0]];
    [colorStates addObject: [NSNumber numberWithInt: 0]];
    for (State * state in states) {
        NSNumber * nof = colorStates[state.color];
        colorStates[state.color] = [NSNumber numberWithInt: (nof.intValue + 1)];
    }
    return colorStates;
}


- (FeatureAlertColor)getLastColor: (FeatureDetection)  feature {
    State * currentState = [self getLastState: feature];
    if (currentState) { return [currentState color]; }
    return FeatureAlertGreen;
}


- (int) haarClassifierOption {
    return [[self.controller.optionsLabel text] intValue];
}
- (int) haarClassifierMinNeighbours {
    return (int)self.controller.minNeighboursStepper.value;
}

- (cv::Size)getMinSize {
    return cv::Size(
                    self.controller.minSizeSlider.value , self.controller.minSizeSlider.value);
}
- (cv::Size)getMaxSize {
    return cv::Size(
                    self.controller.maxSizeSlider.value , self.controller.maxSizeSlider.value);
}

- (int) radius {
    return 2;
}

#ifdef __cplusplus

- (BOOL) globalDebugOn {
    return [self.controller.debugSwitch isOn];
}

- (BOOL) faceDebugOn {
    return [self globalDebugOn] && ![self noseDebugOn] && ![self eyesDebugOn];
}
- (BOOL) noseDebugOn {
    return [self globalDebugOn] && [self.controller.noseSwitch isOn];
}
- (BOOL) eyesDebugOn {
    return [self globalDebugOn] && [self.controller.eyesSwitch isOn];
}



- (cv::Rect)getBiggestRect: (std::vector<cv::Rect>) facesRect {
    if (facesRect.size() == 1) {
        return facesRect[0];
    } else if (facesRect.size() > 1) {
        int area = facesRect[0].width * facesRect[0].height;
        int biggestIndex = 0;
        for (int i=1; i < facesRect.size(); i++) {
            int newArea = facesRect[i].width * facesRect[i].height;
            if (newArea > area) {
                biggestIndex = i;
            }
        }
        return facesRect[biggestIndex];
    }
    return cv::Rect(0,0,0,0);
}

- (void)detectFace:(cv::Mat&)imageMat; {
    std::vector<cv::Rect> facesRect;

    cv::Mat imageGrayMat;
    if (self.controller.videoCamera.grayscaleMode) {
        imageGrayMat = imageMat.clone();
    } else {
        std::vector<cv::Mat> rgbChannels(3);
        cv::split(imageMat, rgbChannels);
        imageGrayMat = rgbChannels[2];
    }

    cv::Size minSize = cv::Size(50, 50);
    cv::Size maxSize = cv::Size(200,200);
    
    face_cascade.detectMultiScale( imageGrayMat, facesRect, 1.1, MAX([self haarClassifierMinNeighbours], 1), [self haarClassifierOption], minSize );;
    
    if (facesRect.size() > 0) {
        cv::Rect faceRect = [self getBiggestRect: facesRect];

        if ([self faceDebugOn]) {
            rectangle(imageMat, faceRect, cvScalar(0,0, 255), 1);
            cv::Rect minRect(
                         MAX(faceRect.x + faceRect.width/2 - minSize.width / 2, 0),
                         MAX(faceRect.y + faceRect.height/2 - minSize.height / 2, 0),
                         minSize.width, minSize.height);
            cv::Rect maxRect(
                         MAX(faceRect.x + faceRect.width/2 - maxSize.width / 2, 0),
                         MAX(faceRect.y + faceRect.height/2 - maxSize.height / 2, 0),
                         maxSize.width, maxSize.height);

            rectangle(imageMat, minRect, cvScalar(255,255,255));
            rectangle(imageMat, maxRect, cvScalar(255,255,255));
        }
        
        //[self goodFeaturesToTrack: image gray: frame_gray region: face ];
        cv::Mat faceImageMat = imageGrayMat(faceRect).clone();
        [self faceDetected: true];
        if ([self.controller.eyesSwitch isOn]) {
            [self detectEyes: imageMat gray: imageGrayMat faceImage: faceImageMat face: faceRect ];
        }
        if ([self.controller.noseSwitch isOn]) {
            [self detectNose: imageMat gray: imageGrayMat faceImage: faceImageMat face: faceRect ];
        }
        /*
        if ([self eyesDebugOn]) {
            UIImage* faceImageUI = [self MatToUIImage: faceImageMat ];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.controller.faceImageView setImage: faceImageUI];
            });
        }
         */
    } else {
        [self faceDetected: false];
    }

}


// new tricks: https://sites.google.com/site/learningopencv1/eye-dimensions
// new trick with 3 haar-classifiers: https://github.com/affromero/OpenCV-Projects/tree/master/VisionProject
// wow: https://www.youtube.com/watch?v=J0SlmOuNW8A&feature=iv&src_vid=NCtYdUEMotg&annotation_id=annotation_63398
//     and his paper: http://www.tomheyman.be/wp-content/uploads/2012/01/Paper_POCA_GazeEstimation_HeymanTom.pdf

- (void)detectEyes:(cv::Mat&)imageMat gray: (cv::Mat&)imageGrayMat faceImage:(cv::Mat&)faceImageMat face: (cv::Rect)faceRect; {

    std::vector<cv::Rect> leftEyesRect;
    std::vector<cv::Rect> rightEyesRect;
    
    cv::Size minSize = [self getMinSize];
    cv::Size maxSize = [self getMaxSize];
    right_eyes_cascade.detectMultiScale(
            faceImageMat, rightEyesRect, 1.2,
                MAX([self haarClassifierMinNeighbours], 1),
                [self haarClassifierOption], minSize );
    left_eyes_cascade.detectMultiScale(
            faceImageMat, leftEyesRect, 1.2,
                MAX([self haarClassifierMinNeighbours], 1),
                [self haarClassifierOption], minSize );
    
    //[self showEyes: eyes region: eyeRegion image: image gray: imageGray minSize: minSize maxSize: maxSize];
    [self showEyes: rightEyesRect region: faceRect image: imageMat gray: imageGrayMat faceImage:(cv::Mat&)faceImageMat  minSize: minSize maxSize: maxSize leftEye: false];
    [self showEyes: leftEyesRect region: faceRect image: imageMat gray: imageGrayMat faceImage:(cv::Mat&)faceImageMat minSize: minSize maxSize: maxSize leftEye: true];

}



- (cv::Rect)chooseEye: (std::vector<cv::Rect>) eyesRect face: (cv::Rect&) faceRect leftEye: (BOOL) isLeftEye {
    if (eyesRect.size() == 1) {
        return eyesRect[0];
    } else if (eyesRect.size() > 1) {
        for (int i=0; i < eyesRect.size(); i++) {
            cv::Rect eyeRect = eyesRect[i];
            if (eyeRect.y + eyeRect.height / 2 < faceRect.height / 2) {
                if (isLeftEye && eyeRect.x + eyeRect.width / 2 < faceRect.width / 2 ) {
                    return eyeRect;
                }
                if (!isLeftEye && eyeRect.x + eyeRect.width / 2 > faceRect.width / 2 ) {
                    return eyeRect;
                }
            }
        }
    }
    return cv::Rect(0,0,0,0);
}


- (void)showEyes: (std::vector<cv::Rect>&) eyesRect region: (cv::Rect&) faceRect image: (cv::Mat&)imageMat gray: (cv::Mat&)imageGrayMat faceImage:(cv::Mat&)faceImageMat minSize: (cv::Size&) minSize maxSize: (cv::Size) maxSize leftEye: (BOOL) isLeftEye {
    
    if (eyesRect.size() > 0) {
        cv::Rect eyeRect = [self chooseEye: eyesRect face: faceRect leftEye: isLeftEye];
        if (eyeRect.width > 0 && eyeRect.height > 0) {
            cv::Point center( faceRect.x + eyeRect.x + eyeRect.width*0.5, faceRect.y + eyeRect.y + eyeRect.height*0.5 );

            circle( imageMat, center, [self radius], cv::Scalar( 153, 255, 51 ), 1);
            cv::Point previewCenter( eyeRect.x + eyeRect.width*0.5, eyeRect.y + eyeRect.height*0.5 );
            cv::Point previewTop  ( previewCenter.x, previewCenter.y-10 );
            cv::Point previewDown ( previewCenter.x, previewCenter.y+10);
            cv::Point previewLeft ( previewCenter.x-10, previewCenter.y );
            cv::Point previewRight( previewCenter.x+10, previewCenter.y );
            cv::Rect previewRect(
                                    MAX(center.x - 30, 0),
                                    MAX(center.y - 15, 0),
                                    60 , 30);
            cv::Mat previewEyeSourceMat = imageGrayMat( previewRect ).clone();
            cv::Rect openedEyesRect = [self detectOpenEyes:eyeRect region:faceRect image: imageMat gray:imageGrayMat faceImage:faceImageMat previewEyeMat: previewEyeSourceMat leftEye: isLeftEye];
                    
            if ([self eyesDebugOn]) {
                line( faceImageMat, previewLeft, previewRight, cv::Scalar( 255, 255, 255 ), 1);
                line( faceImageMat, previewTop, previewDown, cv::Scalar( 255, 255, 255 ), 1);
                cv::Rect minRect(
                                    MAX(center.x - minSize.width / 2, 0),
                                    MAX(center.y - minSize.height / 2, 0),
                                    minSize.width, minSize.height);
                cv::Rect maxRect(
                                    MAX(center.x - maxSize.width / 2, 0),
                                    MAX(center.y - maxSize.height / 2, 0),
                                    maxSize.width, maxSize.height);
                cv::Rect centerEyeRect(
                                    MAX(center.x - eyeRect.width / 2, 0),
                                    MAX(center.y - eyeRect.height / 2, 0),
                                    eyeRect.width, eyeRect.height);
                rectangle(imageMat, centerEyeRect, cv::Scalar(255,255,255));
                    
                    
                //cv::Mat previewEyeDestMat = previewEyeSourceMat;
                cv::Mat previewEyeDestMat = cv::Mat::zeros( previewEyeSourceMat.size(), CV_8UC1 );
                [self threshold: previewEyeSourceMat dest: previewEyeDestMat];

                if (openedEyesRect.height != 0 && openedEyesRect.width != 0) {
                        //[self printMathPointsCVS: previewEyeDestMat];
                        cv::Rect openEyeImageRect (
                            previewRect.x + openedEyesRect.x,
                            previewRect.y + openedEyesRect.y,
                            openedEyesRect.width,
                            openedEyesRect.height
                            );
                        rectangle(imageMat, openEyeImageRect, cv::Scalar(255,255,255));

                }
                UIImage* previewEyeImageUI = [self MatToUIImage: previewEyeDestMat];
                if (eyeRect.x < faceRect.width/2) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.controller uploadLeftEyeImage: previewEyeImageUI];
                    });
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.controller uploadRightEyeImage: previewEyeImageUI];
                    });
                }
            }
        }
        /*
         [self eyesDetected: true];
         if (eyes.size() == 2) {
         [self twoEyesDetected: true];
         } else {
         [self twoEyesDetected: false];
         }
         */
    } else {
        /*
         [self eyesDetected: false];
         [self twoEyesDetected: false];
         */
    }
}


- (cv::Rect)detectOpenEyes: (cv::Rect&) eyeRect region: (cv::Rect&) eyeRegionRect image: (cv::Mat&)imageMat gray: (cv::Mat&)imageGrayMat faceImage:(cv::Mat&)faceImageMat previewEyeMat: (cv::Mat&)previewEyeSourceMat leftEye: (BOOL) isLeftEye {
    
    if (isLeftEye) return cv::Rect(0,0,0,0);
    
    std::vector<cv::Rect> openEyesRect;
    
    cv::Size minSize = cv::Size(3, 3);
    cv::Size maxSize = cv::Size(100, 100);
    //cv::Mat eyeMat = eyesRegionMat( eyeRect ).clone();
    eyes_opened_cascade.detectMultiScale(
                                        previewEyeSourceMat, openEyesRect, 1.1,
                                         [self haarClassifierMinNeighbours],
                                         cv::CASCADE_FIND_BIGGEST_OBJECT | cv::CASCADE_SCALE_IMAGE
                                         //,[self getMinSize], [self getMaxSize]
                                         //, minSize, maxSize
                                         );
    
    if (openEyesRect.size() > 0) {
        cv::Rect eyeDetected;
        for (int i = 0; i < openEyesRect.size();i++) {
            eyeDetected = openEyesRect[i];
        
            eyeDetected.x = eyeRect.x + eyeDetected.x;
            eyeDetected.y = eyeRect.y + eyeDetected.y;
        
            cv::Rect eye_template(
                                  (int) eyeDetected.x -  eyeDetected.width/2,
                                  (int) eyeDetected.y -  eyeDetected.height/2,
                                  eyeDetected.width,  eyeDetected.height);
        
            printf("%d: %s EYES OPENED\n", i, (isLeftEye ? "LEFT" : "RIGHT"));
        }
        return eyeDetected;
    }
    printf("%s EYES ****CLOSED**** \n", (isLeftEye ? "LEFT" : "RIGHT"));
    return cv::Rect();

}


- (void)threshold: (cv::Mat&) srcImage dest:(cv::Mat&) destImage {
    int option = [self haarClassifierOption];
    if (option == 1) {
        [self equalizeHist: srcImage dest: destImage];
        //[self adaptiveGaussThreshold: srcImage dest: destImage];
    } else if (option == 2) {
        [self houghCirclesThreshold: srcImage dest: destImage];
        //[self adaptiveMeanThreshold: srcImage dest: destImage];
        //[self otsuThreshold: srcImage dest: destImage];
    } else if (option == 4) {
        //[self adaptiveGaussTriangleThreshold: srcImage dest: destImage];
        [self cannyEdgeDetect: srcImage dest: destImage];
    } else if (option == 8) {
        [self findContour: srcImage dest: destImage];
    }
}


// http://docs.opencv.org/master/d7/d4d/tutorial_py_thresholding.html
- (void)equalizeHist: (cv::Mat&) srcImage dest:(cv::Mat&) destImage  {
    
    cv::equalizeHist(srcImage, destImage);
    //cv::GaussianBlur(destImage, destImage, cv::Size(3, 3), 0, 0);

}


- (void)printMathPointsCVS: (cv::Mat&) srcImage {
    //    static int FACTOR[] = { 1,2,3,4,7,7,9,9,10,10,10,10,9,9,7,7,4,3,2,1 };
        static int FACTOR[] = { 10,10,10,10,10,10,10,10,10,10, 10,10,10,10,10,10,10,10,10,10 };
    
    if ([self eyesDebugOn]) {
        for( int x = 0; x < srcImage.cols; x++ ) {
            int totalScale = 0;
            int maxScale = srcImage.rows * 255;
            for( int y = 0; y < srcImage.rows; y++ ) {
                cv::Scalar intensity = srcImage.at<uchar>(y, x);
                int scale = 255-intensity.val[0];
                totalScale = totalScale + scale;
            }
            int factor = totalScale * 100 * FACTOR[x] / maxScale; // 0 - 1000
            cv::Point pt  ( x, 19-factor / 5 / 10); // 0..19
            line( srcImage, pt, pt, cv::Scalar( 255, 255, 255 ), 1);
            /*
            cv::Point pt2  ( 0, 19 );
            cv::Point pt3  ( 19, 0 );
            line( srcImage, pt2, pt3, cv::Scalar( 255, 255, 255 ), 1);
             */
        }
//        NSLog(@"%@", lineString); NSLog(@"\n");
    }
}



// http://docs.opencv.org/master/d7/d4d/tutorial_py_thresholding.html
- (void)simpleThreshold: (cv::Mat&) srcImage dest:(cv::Mat&) destImage  {
    
    cv::equalizeHist(srcImage, srcImage);
    // 2.55 because maxSize range is 0..100
    int threshold = [self getMaxSize].height * 2.55;
    int threshold_type = [self haarClassifierMinNeighbours];
    cv::threshold( srcImage, destImage, threshold , 255, threshold_type );
}


// http://docs.opencv.org/master/d7/d4d/tutorial_py_thresholding.html
- (void)adaptiveGaussThreshold: (cv::Mat&) srcImage dest:(cv::Mat&) destImage {
    [self gaussianBlur:srcImage dest:srcImage size:5];
    /* must be ODD number */
    int threshold = [self getMinSize].height;
    if (threshold % 2 == 0) { threshold++; }
//    threshold = MIN(21, threshold);
//    threshold = 11;
    cv::adaptiveThreshold(srcImage, destImage, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C,
                          cv::THRESH_BINARY, threshold, 8);
}

// http://docs.opencv.org/master/d7/d4d/tutorial_py_thresholding.html
- (void)adaptiveMeanThreshold: (cv::Mat&) srcImage dest:(cv::Mat&) destImage {
    [self gaussianBlur:srcImage dest:srcImage size:3];
    /* must be ODD number */
    int threshold = [self getMinSize].height;
    if (threshold % 2 == 0) { threshold++; }
    //    threshold = MIN(21, threshold);
    //    threshold = 11;
    cv::adaptiveThreshold(srcImage, destImage, 255, cv::ADAPTIVE_THRESH_MEAN_C,
                          cv::THRESH_TRIANGLE, threshold, 8);
}

//http://docs.opencv.org/2.4/doc/tutorials/imgproc/imgtrans/hough_circle/hough_circle.html-

/*
 @param method Detection method, see cv::HoughModes. Currently, the only implemented method is HOUGH_GRADIENT
 @param dp Inverse ratio of the accumulator resolution to the image resolution. For example, if
 dp=1 , the accumulator has the same resolution as the input image. If dp=2 , the accumulator has
 half as big width and height.
 @param minDist Minimum distance between the centers of the detected circles. If the parameter is
 too small, multiple neighbor circles may be falsely detected in addition to a true one. If it is
 too large, some circles may be missed.
 @param param1 First method-specific parameter. In case of CV_HOUGH_GRADIENT , it is the higher
 threshold of the two passed to the Canny edge detector (the lower one is twice smaller).
 @param param2 Second method-specific parameter. In case of CV_HOUGH_GRADIENT , it is the
 accumulator threshold for the circle centers at the detection stage. The smaller it is, the more
 false circles may be detected. Circles, corresponding to the larger accumulator values, will be
 returned first.
 @param minRadius Minimum circle radius.
 @param maxRadius Maximum circle radius.

 */

- (void)houghCirclesThreshold: (cv::Mat&) srcImage dest:(cv::Mat&) destImage {
    cv::GaussianBlur(srcImage, destImage, cv::Size(3, 3), 0, 0);
    std::vector<cv::Vec3f> circles;
    cv::HoughCircles(destImage, circles, CV_HOUGH_GRADIENT,
                     1, /*inv ratio btw accumlator and input image resolution ??? */
                     srcImage.rows/4, /* min distance centers */
                     30, /* higher treshold to canny edge, lower */
                     15 /* accumulator threshold for circle centers */);
    if (circles.size() > 0) {
        int centerX = srcImage.cols / 2;
        int centerY = srcImage.rows / 2;
        int centerXDiff = centerX / 8;
        int centerYDiff = centerY / 8;
        for( size_t j = 0; j < circles.size(); j++ ) {
            cv::Vec3f circle = circles[j];
            cv::Point center(cvRound(circle[0]), cvRound(circle[1]));
            if (abs(center.x - centerX) <= centerXDiff && abs(center.y - centerY) <= centerYDiff) {
                int radius = cvRound(circle[2]);
                if (
                    (center.x - radius < centerX) &&
                    (center.x + radius > centerX) &&
                    (center.y + radius > centerY) &&
                    (center.y - radius < centerY)
                    ) {
                    // circle center
                    //cv::circle( destImage, center, 1, cv::Scalar(0,255,0), 1, 8, 0 );
                    // circle outline
                    cv::circle( destImage, center, radius, cv::Scalar(0,0,255), 1, 8, 0 );
                }
            }
        }
    }
}



// http://docs.opencv.org/master/d7/d4d/tutorial_py_thresholding.html
- (void)otsuThreshold: (cv::Mat&) srcImage dest:(cv::Mat&) destImage {
    //cv::equalizeHist(srcImage, destImage);
    [self gaussianBlur:srcImage dest:srcImage size:5];
    int threshold = [self getMaxSize].height * 2.55;
    cv::threshold( srcImage, destImage, threshold , 255, cv::THRESH_OTSU | cv::THRESH_BINARY );
}

// http://docs.opencv.org/doc/tutorials/imgproc/imgtrans/canny_detector/canny_detector.html
- (void)blur: (cv::Mat&) srcImage dest:(cv::Mat&) destImage size: (int) size{
    cv::blur(srcImage, destImage, cv::Size(size, size));
}
// http://docs.opencv.org/master/d7/d4d/tutorial_py_thresholding.html
- (void)gaussianBlur: (cv::Mat&) srcImage dest:(cv::Mat&) destImage size: (int) size{
    cv::GaussianBlur(srcImage, destImage, cv::Size(size, size), 0, 0);
}

// http://docs.opencv.org/doc/tutorials/imgproc/imgtrans/canny_detector/canny_detector.html
- (void)cannyEdgeDetect: (cv::Mat&) srcImage dest:(cv::Mat&) destImage {
    
//    [self adaptiveThreshold: srcImage dest: destImage];
    
    int ratio = 3;
    int kernel_size = 3;
    // 2.55 because maxSize range is 0..100
    int lowThreshold = [self getMaxSize].height;

    cv::Mat blurredImage = cv::Mat::zeros( srcImage.size(), CV_8UC1 );
    [self blur: srcImage dest: blurredImage size: 3];
    cv::Canny( blurredImage, destImage, lowThreshold , lowThreshold * ratio, kernel_size );
}


// http://docs.opencv.org/doc/tutorials/imgproc/imgtrans/canny_detector/canny_detector.html
- (void)findContour: (cv::Mat&) srcImage dest:(cv::Mat&) destImage {

    [self adaptiveGaussThreshold: srcImage dest: srcImage];
//    [self blur: srcImage dest: srcImage size: 3];
    
    std::vector<std::vector<cv::Point>> contours;
    //    std::vector<cv::Vec4i> hierarchy;
    //    cv::blur(srcImage, destImage, cv::Size(kernel_size,kernel_size));
    cv::findContours(srcImage, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    
    cv::Scalar color = cv::Scalar( 255, 0, 0 );
    for( int i = 0; i< contours.size(); i++ ) {
        cv::drawContours( destImage, contours, i, color);
    }

}


- (void)detectNose:(cv::Mat&)image gray: (cv::Mat&)frame_gray faceImage:(cv::Mat&)faceImage face: (cv::Rect)face; {
    
    // nose is in middle 3 5th of head
    int nose_center_quarter_height = face.height / 5;
    // nose is in middle 2 quadrant of head
    int nose_center_quarter_width = face.width / 4;
    cv::Rect noseRegion(
                        face.x+nose_center_quarter_width,
                        face.y + nose_center_quarter_height,
                        2*nose_center_quarter_width,
                        3*nose_center_quarter_height);
    
    cv::Mat noseROI = frame_gray( noseRegion );
    std::vector<cv::Rect> noses;
    
    cv::Size minSize = [self getMinSize];
    cv::Size maxSize = [self getMaxSize];

    nose_cascade.detectMultiScale( noseROI, noses, 1.2, MAX([self haarClassifierMinNeighbours], 1), [self haarClassifierOption], minSize );
    if ([self noseDebugOn]) {
        //rectangle(image, noseRegion, CvScalar(255,255,255));
    }
    
    if (noses.size() > 0) {
        for( size_t j = 0; j < noses.size(); j++ ) {
            cv::Rect nose = noses[j];
            cv::Point center( noseRegion.x + nose.x + nose.width*0.5, noseRegion.y + nose.y + nose.height*0.5 );
            circle( image, center, [self radius], CvScalar( 153, 255, 51 ), 1);
            if ([self globalDebugOn]) {
                cv::Rect minRect(
                             noseRegion.x + nose.x + nose.width/2 - minSize.width / 2,
                             noseRegion.y + nose.y + nose.height/2 - minSize.height / 2,
                             minSize.width, minSize.height);
                cv::Rect maxRect(
                             noseRegion.x + nose.x + nose.width/2 - maxSize.width / 2,
                             noseRegion.y + nose.y + nose.height/2 - maxSize.height / 2,
                             maxSize.width, maxSize.height);
                rectangle(image, minRect, cv::Scalar(255,255,255));
            }

        }
        /*
         [self eyesDetected: true];
         if (eyes.size() == 2) {
         [self twoEyesDetected: true];
         } else {
         [self twoEyesDetected: false];
         }
         */
    } else {
        /*
         [self eyesDetected: false];
         [self twoEyesDetected: false];
         */
    }
    
}


- (UIImage *)MatToUIImage:(const cv::Mat&)cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                      // Width
                                        cvMat.rows,                      // Height
                                        8,                               // Bits per component
                                        8 * cvMat.elemSize(),            // Bits per pixel
                                        cvMat.step[0],                   // Bytes per row
                                        colorSpace,                      // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,
                                                                         // Bitmap info flags
                                        provider,                        // CGDataProviderRef
                                        NULL,                            // Decode
                                        false,                           // Should interpolate
                                        kCGRenderingIntentDefault);      // Intent
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

- (void)createMask: (cv::Mat&)frame_gray region: (cv::Rect&) region mask: (cv::Mat&) mask {
    int xOffset = region.x;
    int	yOffset = region.y;
    for (int y=yOffset; y<yOffset+region.height; y++){
        for (int x=xOffset; x<xOffset+region.width; x++){
            mask.at<int>(y, x) = 1;
        }
    }
}


- (void)goodFeaturesToTrack: (cv::Mat&)image gray: (cv::Mat&)frame_gray region: (cv::Rect&) region {
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
    cv::Mat mask = cv::Mat::zeros( frame_gray.size(), CV_8UC1 );
    [self createMask: frame_gray region: region mask: mask];
    
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
        cv::circle( image, corners[i], [self radius], cv::Scalar(153, 255, 51), 1);
        /* RGB: 51, 255, 153 */
        /* BGR: 153, 255, 51 */
        
    }
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (void) writeToTraceLog: (NSString *)content header: (NSArray *) header {
    content = [NSString stringWithFormat:@"%@\n",content];
    NSString *fileName = [[self applicationDocumentsDirectory].path
                          stringByAppendingPathComponent:@"tracelog.txt"];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if (fileHandle){
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    } else{
        [content writeToFile:fileName
                  atomically:NO
                    encoding:NSUTF8StringEncoding
                       error:nil];
    }

}

// delegate method for processing image frames
- (void)processImage:(cv::Mat&)image; {
        [self detectFace: image];
}


#endif


@end
