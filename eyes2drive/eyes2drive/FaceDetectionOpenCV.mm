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
        self.faceDetected = [[FeatureDetectionTime alloc] initWith: FeatureFaceDetected ];
        self.faceDetected.delegate = self;
        [self.faceDetected setThreshold: false orange:1000 red:3000 darkred: 5000];
        
        self.eyesDetected = [[FeatureDetectionTime alloc] initWith: FeatureEyesDetected ];
        self.eyesDetected.delegate = self;
        [self.eyesDetected setThreshold: false orange: 2000 red: 3000 darkred: 5000];
        
        self.twoEyesDetected = [[FeatureDetectionTime alloc] initWith: Feature2EyesDetected ];
        self.twoEyesDetected.delegate = self;
        [self.twoEyesDetected setThreshold: false orange: 3000 red: 5000 darkred: 7000];
        
        self.events = [[NSDictionary alloc] init];
        self.events = @{
                        [NSNumber numberWithInt: FeatureFaceDetected] : [[NSMutableArray alloc] init],
                        [NSNumber numberWithInt: FeatureEyesDetected] : [[NSMutableArray alloc] init],
                        [NSNumber numberWithInt: Feature2EyesDetected] : [[NSMutableArray alloc] init]
                       };
        return self;
    }
    return nil;
}


- (void)feature:(FeatureDetection)feature changedState:(State *)state {
    NSMutableArray * elements = self.events[ [NSNumber numberWithInt: feature ] ];
    [elements addObject: state];
    
    printf("%s %s since %.0f [ms]\n",
           [(FeatureAlertColor_toString[ [state color] ]) UTF8String],
           [(FeatureDetection_toString[feature]) UTF8String],
           [state elapsedTime]);
}

-(void)loadClassifier: (cv::CascadeClassifier&) cascade named: (NSString *) cascade_name title: (NSString *) title {
    // Load the cascades
    NSURL *resourceURL_eyes = [[NSBundle mainBundle] URLForResource: cascade_name withExtension: @"xml"];
    printf("load %s cascade classifier from %s.\n", [title UTF8String], [[resourceURL_eyes path] UTF8String]);
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
    self.tripStartTime = [FeatureDetectionTime now];
    self.tripStopTime = 0;
}
- (void)stopTrip {
    self.tripStopTime = [FeatureDetectionTime now];
}
- (CFTimeInterval)tripElapsedTime {
    if (self.tripStartTime == 0) { return 0; }
    if (self.tripStopTime == 0) {
        return [FeatureDetectionTime now] - self.tripStartTime;
    } else {
        return self.tripStopTime - self.tripStartTime;
    }
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

#ifdef __cplusplus

- (void)detectFace:(cv::Mat&)image; {
    std::vector<cv::Rect> faces;
    
    std::vector<cv::Mat> rgbChannels(3);
    cv::split(image, rgbChannels);
    cv::Mat frame_gray = rgbChannels[2];

    if (false) {
        [self goodFeaturesToTrack: image gray: frame_gray ];
    }

    cv::Size minSize = cv::Size(50, 50);
    cv::Size maxSize = cv::Size(200,200);
    
    face_cascade.detectMultiScale( frame_gray, faces, 1.1, MAX([self haarClassifierMinNeighbours], 1), [self haarClassifierOption], minSize );;
    
    BOOL debug =[self.controller.debugSwitch isOn] && ![self.controller.eyesSwitch isOn] && ![self.controller.noseSwitch isOn];
    
    if (faces.size() > 0) {
        for( int i = 0; i < faces.size(); i++ )
        {
            cv::Rect face = faces[i];
            rectangle(image, face, cvScalar(0,0, 255), 1);

            if (debug) {
                cv::Rect minRect(
                             MAX(face.x + face.width/2 - minSize.width / 2, 0),
                             MAX(face.y + face.height/2 - minSize.height / 2, 0),
                             minSize.width, minSize.height);
                cv::Rect maxRect(
                             MAX(face.x + face.width/2 - maxSize.width / 2, 0),
                             MAX(face.y + face.height/2 - maxSize.height / 2, 0),
                             maxSize.width, maxSize.height);

                rectangle(image, minRect, cvScalar(255,255,255));
                rectangle(image, maxRect, cvScalar(255,255,255));
            }
            
            UIImage* eyesImage = [self MatToUIImage: frame_gray(face).clone() ];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.controller.faceImageView setImage: eyesImage];
            });


            [self faceDetected: true];
            if ([self.controller.eyesSwitch isOn]) {
                [self detectEyes: image gray: frame_gray face: face ];
            }
            if ([self.controller.noseSwitch isOn]) {
                [self detectNose: image gray: frame_gray face: face ];
            }
        }
    } else {
        [self faceDetected: false];
    }

}


// new tricks: https://sites.google.com/site/learningopencv1/eye-dimensions
// new trick with 3 haar-classifiers: https://github.com/affromero/OpenCV-Projects/tree/master/VisionProject
// wow: https://www.youtube.com/watch?v=J0SlmOuNW8A&feature=iv&src_vid=NCtYdUEMotg&annotation_id=annotation_63398
//     and his paper: http://www.tomheyman.be/wp-content/uploads/2012/01/Paper_POCA_GazeEstimation_HeymanTom.pdf

- (void)detectEyes:(cv::Mat&)image gray: (cv::Mat&)imageGray face: (cv::Rect)face; {

    int eye_region_top = face.height * 0.2;
    int eye_region_bottom = face.height * 0.6;
    cv::Rect eyeRegion(
                    face.x, face.y+eye_region_top,
                    face.width, eye_region_bottom-eye_region_top);
    
    cv::Mat eyesROI = imageGray( eyeRegion );
    std::vector<cv::Rect> eyes;
    std::vector<cv::Rect> leftEyes;
    std::vector<cv::Rect> rightEyes;
    
    cv::Size minSize = cv::Size(
                                self.controller.minSizeSlider.value , self.controller.minSizeSlider.value);
    cv::Size maxSize = cv::Size(
                                self.controller.maxSizeSlider.value , self.controller.maxSizeSlider.value);
//    eyes_cascade.detectMultiScale( eyesROI, eyes, 1.2, MAX([self haarClassifierMinNeighbours], 1), [self haarClassifierOption], minSize );
    right_eyes_cascade.detectMultiScale( eyesROI, rightEyes, 1.2, MAX([self haarClassifierMinNeighbours], 1), [self haarClassifierOption], minSize );
    left_eyes_cascade.detectMultiScale( eyesROI, leftEyes, 1.2, MAX([self haarClassifierMinNeighbours], 1), [self haarClassifierOption], minSize );

    if ([self.controller.debugSwitch isOn]) {
        rectangle(image, eyeRegion, cv::Scalar(255,255,255));
    }
    
    //[self showEyes: eyes region: eyeRegion image: image gray: imageGray minSize: minSize maxSize: maxSize];
    [self showEyes: rightEyes region: eyeRegion image: image gray: imageGray minSize: minSize maxSize: maxSize];
    [self showEyes: leftEyes region: eyeRegion image: image gray: imageGray minSize: minSize maxSize: maxSize];

}

- (void)showEyes: (std::vector<cv::Rect>&) eyes region: (cv::Rect&) eyeRegion image: (cv::Mat&)image gray: (cv::Mat&)frame_gray minSize: (cv::Size&) minSize maxSize: (cv::Size) maxSize{
    
    if (eyes.size() > 0) {
        for( size_t j = 0; j < eyes.size(); j++ ) {
            cv::Rect eye = eyes[j];
            cv::Point center( eyeRegion.x + eye.x + eye.width*0.5, eyeRegion.y + eye.y + eye.height*0.5 );

            // detect if eyes are too high and its propably eye-browse
            if (center.y > eyeRegion.y + eyeRegion.height / 4) {
                cv::Rect previewRect(
                                 MAX(center.x - 20, 0),
                                 MAX(center.y - 8, 0),
                                 40, 16);
                cv::Mat eyesROI = frame_gray( previewRect ).clone();
                /*
                 std::vector<cv::Rect> eyesOpened;
                 eyes_opened_cascade.detectMultiScale( eyesROI, eyesOpened, 1.1, MAX([self  haarClassifierMinNeighbours], 1), [self haarClassifierOption]);
                 if (eyesOpened.size() > 0) {
                 */
                int radius = 2;
                circle( image, center, radius, cv::Scalar( 255, 0, 0 ));
                
                if ([self.controller.debugSwitch isOn]) {
                    cv::Rect minRect(
                                     MAX(center.x - minSize.width / 2, 0),
                                     MAX(center.y - minSize.height / 2, 0),
                                     minSize.width, minSize.height);
                    cv::Rect maxRect(
                                     MAX(center.x - maxSize.width / 2, 0),
                                     MAX(center.y - maxSize.height / 2, 0),
                                     maxSize.width, maxSize.height);
                    cv::Rect eyeRect(
                                     MAX(center.x - eye.width / 2, 0),
                                     MAX(center.y - eye.height / 2, 0),
                                     eye.width, eye.height);
//                    rectangle(image, minRect, cv::Scalar(255,255,255));
//                    rectangle(image, maxRect, cv::Scalar(255,255,255));
                    rectangle(image, eyeRect, cv::Scalar(255,255,255));
                }
                
                cv::Mat destEyesROI = cv::Mat::zeros( eyesROI.size(), CV_8UC1 );
                [self threshold: eyesROI dest: destEyesROI];
                UIImage* eyesImage = [self MatToUIImage: destEyesROI];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (eye.x < eyeRegion.width/2) {
                        [self.controller.leftEyeImageView setImage: eyesImage];
                    } else {
                        [self.controller.rightEyeImageView setImage: eyesImage];
                    }
                });
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

- (void)threshold: (cv::Mat&) srcImage dest:(cv::Mat&) destImage {
    int option = [self haarClassifierOption];
    if (option == 1) {
        [self adaptiveThreshold: srcImage dest: destImage];
    } else if (option == 2) {
        [self otsuThreshold: srcImage dest: destImage];
    } else if (option == 4) {
        [self cannyEdgeDetect: srcImage dest: destImage];
    } else if (option == 8) {
        [self findContour: srcImage dest: destImage];
    }
}

// http://docs.opencv.org/master/d7/d4d/tutorial_py_thresholding.html
- (void)simpleThreshold: (cv::Mat&) srcImage dest:(cv::Mat&) destImage  {
    
    cv::equalizeHist(srcImage, destImage);
    // 2.55 because maxSize range is 0..100
    int threshold = self.controller.maxSizeSlider.value * 2.55;
    int threshold_type = [self haarClassifierMinNeighbours];
    cv::threshold( srcImage, destImage, threshold , 255, threshold_type );
}


// http://docs.opencv.org/master/d7/d4d/tutorial_py_thresholding.html
- (void)adaptiveThreshold: (cv::Mat&) srcImage dest:(cv::Mat&) destImage {
    [self gaussianBlur:srcImage dest:destImage size:5];
    /* must be ODD number */
    int threshold = (int)self.controller.minSizeSlider.value;
    if (threshold % 2 == 0) { threshold++; }
    threshold = 11;
    cv::adaptiveThreshold(srcImage, destImage, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C,
                          cv::THRESH_BINARY, threshold, 8);
}


// http://docs.opencv.org/master/d7/d4d/tutorial_py_thresholding.html
- (void)otsuThreshold: (cv::Mat&) srcImage dest:(cv::Mat&) destImage {
    //cv::equalizeHist(srcImage, destImage);
    [self gaussianBlur:srcImage dest:destImage size:5];
    int threshold = self.controller.maxSizeSlider.value * 2.55;
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
    int lowThreshold = self.controller.maxSizeSlider.value;

    [self blur: srcImage dest: destImage size: 3];
    cv::Canny( srcImage, destImage, lowThreshold , lowThreshold * ratio, kernel_size );
}


// http://docs.opencv.org/doc/tutorials/imgproc/imgtrans/canny_detector/canny_detector.html
- (void)findContour: (cv::Mat&) srcImage dest:(cv::Mat&) destImage {

    [self adaptiveThreshold: srcImage dest: srcImage];
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


- (void)detectNose:(cv::Mat&)image gray: (cv::Mat&)frame_gray face: (cv::Rect)face; {
    
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
    
    cv::Size minSize = cv::Size(
                                self.controller.minSizeSlider.value , self.controller.minSizeSlider.value);
    cv::Size maxSize = cv::Size(
                                self.controller.maxSizeSlider.value , self.controller.maxSizeSlider.value);

    nose_cascade.detectMultiScale( noseROI, noses, 1.2, MAX([self haarClassifierMinNeighbours], 1), [self haarClassifierOption], minSize );
    if ([self.controller.debugSwitch isOn]) {
        rectangle(image, noseRegion, CvScalar(255,255,255));
    }
    
    if (noses.size() > 0) {
        for( size_t j = 0; j < noses.size(); j++ ) {
            cv::Rect nose = noses[j];
            cv::Point center( noseRegion.x + nose.x + nose.width*0.5, noseRegion.y + nose.y + nose.height*0.5 );
            //int radius = cvRound( (eye.width + eye.height)*0.25 );
            //circle( image, center, radius, cv::Scalar( 255, 0, 0 ), 4, 8, 0 );
            int radius = 2;
            circle( image, center, radius, CvScalar( 0, 0, 255 ));
            if ([self.controller.debugSwitch isOn]) {
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



// delegate method for processing image frames
- (void)processImage:(cv::Mat&)image; {
    [self detectFace: image];
}


#endif


@end
