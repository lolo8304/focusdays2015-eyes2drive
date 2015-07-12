//
//  ViewController.m
//  eyes2drive
//
//  Created by Lorenz Hänggi on 07/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//
// helping documentation:
//  http://docs.opencv.org/doc/tutorials/ios/hello/hello.html#opencvioshelloworld
//  http://docs.opencv.org/doc/tutorials/ios/video_processing/video_processing.html#opencviosvideoprocessing
//  http://fyhao.com/2015/01/computer-and-it/tutorial/tutorial-on-setup-opencv-on-ios/
//  http://stackoverflow.com/questions/12797783/cap-ios-h-is-not-found
//  linker issues
//     http://stackoverflow.com/questions/7953168/symbols-not-found-for-architecture-armv6/10415850#10415850


#import "ViewController.h"
#import "FaceDetectionOpenCV.h"
#import "FeatureDetectionTime.h"
#import "AudioToolbox/AudioServices.h"

#import <opencv2/videoio/cap_ios.h>

@interface ViewController ()
    @property (weak, nonatomic) IBOutlet UIImageView *imageView;
    @property (weak, nonatomic) IBOutlet UIButton *button;

    @property (weak, nonatomic) IBOutlet UIImageView *faceAlertView;

    @property (weak, nonatomic) IBOutlet UISegmentedControl *UIAlertColor;

    @property (nonatomic, strong) CvVideoCamera* videoCamera;
    @property (nonatomic, strong) FaceDetectionOpenCV* faceDetection;

    @property (nonatomic, strong) NSThread *thread;

- (IBAction)actionStart:(id)sender;
- (IBAction)actionStop:(id)sender;

@end


@implementation ViewController

NSString * coloredImageName = @"none";
NSArray * soundFiles;

CFURLRef soundFileURLRef;
SystemSoundID	soundFileObject;

NSMutableDictionary * sounds = [[NSMutableDictionary alloc] init];


- (NSThread *) thread
{
    if (!_thread) {
        _thread = [[NSThread alloc]
                   initWithTarget:self
                   selector:@selector(longloop)
                   object:nil];
    }
    return _thread;
}

- (void)longloop
{
    while (true) {
        //change the text in the label on the main thread:
        [self performSelector:@selector(updateOutput:)
                     onThread:[NSThread mainThread]
                   withObject: 0
                waitUntilDone:NO];
        sleep(1);
        if ([self.thread isCancelled]) {
            //stop the thread:
            self.thread = nil;
            break;
        }
    }
}



- (void) setFaceAlertImage: (FeatureAlertColor) color {
    NSMutableString *imageName = [NSMutableString stringWithFormat:@"Alert-%@.png", FeatureAlertColor_toString[color]];
    if (![coloredImageName isEqualToString: imageName]) {
        coloredImageName = imageName;
        self.faceAlertView.image = [UIImage imageNamed: coloredImageName];
        [self playSound: color];
    }
}

- (void) playSound: (FeatureAlertColor) color {
    if (!soundFileURLRef) {
        NSURL* sound = [self getURLSound: FeatureAlertGreen];
        soundFileURLRef = (CFURLRef)CFBridgingRetain(sound);
        AudioServicesCreateSystemSoundID (soundFileURLRef, &soundFileObject);
    }
// * vibrate + sound
//    AudioServicesPlayAlertSound (soundFileObject);

// * sound only
    AudioServicesPlaySystemSound (soundFileObject);

// * vibrate only
//        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}


- (NSURL *)getURLSound: (FeatureAlertColor) color {
    return [[NSBundle mainBundle] URLForResource: @"tap"
                                                withExtension: @"aif"];
    
}


- (void) updateOutput:(NSNumber *)notUsed {
    FeatureAlertColor lastColor = [self.faceDetection getLastColor: FeatureFaceDetected];
    [self setFaceAlertImage: lastColor];
}



- (IBAction)actionStart:(id)sender {
    [self.faceDetection startTrip ];
    [self.videoCamera start];
    [self setFaceAlertImage: FeatureAlertGreen];
    if ([self.thread isExecuting]) {
        NSLog(@"Thread is already running");
    } else {
        NSLog(@"Starting thread");
        [self.thread start];
    }

}
- (IBAction)actionStop:(id)sender {
    [self.faceDetection stopTrip ];
    [self.videoCamera stop];
    NSLog(@"Stopping thread");
    [self.thread cancel];
    [self setFaceAlertImage: FeatureAlertGreen];

}

- (BOOL)isPortraitOrientation {
    return self.currentOrientation == UIInterfaceOrientationPortrait;
}
- (int)currentOrientation {
    return [UIDevice currentDevice].orientation ;
}
- (AVCaptureVideoOrientation)currentVideoOrientation {
    return (AVCaptureVideoOrientation)self.currentOrientation;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    
    self.faceDetection = [ [FaceDetectionOpenCV alloc ] initWith: AVCaptureVideoOrientationPortrait controller: self];
    self.videoCamera.delegate = self.faceDetection;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;

    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    printf("current video orientation = %i\n", self.currentVideoOrientation);
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    if (self.videoCamera) {
        self.videoCamera.defaultAVCaptureVideoOrientation = self.currentVideoOrientation;
        self.faceDetection.orientation = self.currentVideoOrientation;
        printf("current video orientation = %i\n", self.currentVideoOrientation);
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [self actionStart: nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self actionStop: nil];
}


@end
