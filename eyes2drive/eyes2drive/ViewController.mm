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
#import "NWPusher.h"



#import <opencv2/videoio/cap_ios.h>
#include <opencv2/objdetect/objdetect.hpp>

@interface ViewController ()
    @property (weak, nonatomic) IBOutlet UIImageView *imageView;
    @property (weak, nonatomic) IBOutlet UIButton *button;

    @property (weak, nonatomic) IBOutlet UIImageView *faceAlertView;
@property (weak, nonatomic) IBOutlet UILabel *nofEvents;
@property (weak, nonatomic) IBOutlet UILabel *nofGreenEvents;
@property (weak, nonatomic) IBOutlet UILabel *nofOrangeEvents;
@property (weak, nonatomic) IBOutlet UILabel *nofRedEvents;
@property (weak, nonatomic) IBOutlet UILabel *nofDarkRedEvents;

    @property (weak, nonatomic) IBOutlet UISegmentedControl *faceAlertControl;

    @property (nonatomic, strong) CvVideoCamera* videoCamera;
    @property (nonatomic, strong) FaceDetectionOpenCV* faceDetection;

    @property (nonatomic, strong) NSThread *thread;

- (IBAction)valueChangedNeighbours:(UIStepper *)sender;
- (IBAction)valueChangedOptions:(UISegmentedControl *)sender;
- (IBAction)valueChangedMinSize:(UISlider *)sender;
- (IBAction)valueChangedMaxSize:(UISlider *)sender;

- (IBAction)actionStart:(id)sender;
- (IBAction)actionStop:(id)sender;
- (IBAction)actionSetControl: (id)sender;
@end


@implementation ViewController

NSString * coloredImageName = @"none";
NSArray * soundFiles;

CFURLRef soundFileURLRef;
SystemSoundID	soundFileObject;

NSMutableDictionary * sounds = [[NSMutableDictionary alloc] init];


- (IBAction)valueChangedNeighbours:(UIStepper *)sender {
    self.neighboursLabel.text = [NSString stringWithFormat:@"%1.0lf", sender.value];
}
- (IBAction)valueChangedOptions:(UISegmentedControl *)sender {
    self.optionsLabel.text = [sender titleForSegmentAtIndex: sender.selectedSegmentIndex];
}
- (IBAction)valueChangedMinSize:(UISlider *)sender; {
    self.minSizeLabel.text = [NSString stringWithFormat:@"%3.0lf", sender.value];
}
- (IBAction)valueChangedMaxSize:(UISlider *)sender {
    self.maxSizeLabel.text = [NSString stringWithFormat:@"%3.0lf", sender.value];
}



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
        [self.faceAlertControl setSelectedSegmentIndex: (int)color];
        [self playSound: color];
        if ([self.notificationSwitch isOn]) {
//          [self createLocalNotification: color];
            [self createPushNotification: color];
        }
    }
}

- (NSString *) getLocalNotificationAlertCategory: (FeatureAlertColor) color {
    if (color == FeatureAlertOrange) {
        return @"orangeAlertWarning";
    } else if (color == FeatureAlertRed) {
        return nil;
    } else if (color == FeatureAlertDarkRed) {
        return @"redAlertWarning";
    }
    return nil;
}
- (NSString *) getNotificationAlertText: (FeatureAlertColor) color {
    if (color == FeatureAlertOrange) {
        return @"ORANGE - Watch out ... keep eyes on the street";
    } else if (color == FeatureAlertRed) {
        return nil;
    } else if (color == FeatureAlertDarkRed) {
        return @"DARK RED - Watch the street - you're distracted. Make a pause ...";
    }
    return nil;
}

- (void) createLocalNotification: (FeatureAlertColor) color {
    NSString * text = [self getNotificationAlertText: color];
    if (text) {
    
        // Schedule the notification
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = text;
        localNotification.alertAction = @"whatch out";
        localNotification.alertTitle = text;
        localNotification.category = [self getLocalNotificationAlertCategory: color];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
    
        [[UIApplication sharedApplication] presentLocalNotificationNow: localNotification];
    }
}


/* https://blog.serverdensity.com/how-to-build-an-apple-push-notification-provider-server-tutorial/ 
    tutorial in objective-c
    http://stackoverflow.com/questions/15140557/how-to-receive-data-from-apns-feedback-server-in-objective-c
    + code https://github.com/noodlewerk/NWPusher
 
 */
- (void) createPushNotification: (FeatureAlertColor) color {

    
    NSString * text = [self getNotificationAlertText: color];
    if (text) {
        NSURL *url = [NSBundle.mainBundle URLForResource:@"apns-dev-cert.p12" withExtension: nil];
        NSData *pkcs12 = [NSData dataWithContentsOfURL:url];
        NSError *error = nil;
        NWPusher *pusher = [NWPusher connectWithPKCS12Data:pkcs12 password:@"pa$$wort" error:&error];
        if (pusher) {
            NSLog(@"Connected to APNs");
        } else {
            NSLog(@"Unable to connect: %@", error);
            return;
        }
    
    
        NSString * payload = [ NSString stringWithFormat: @"{\
        \"aps\" : { \"alert\" : \"%@\", \"badge\" : 1, \"sound\" : \"default\" }, \
        \"server\" : { \"serverId\" : 1, \"name\" : \"Server name\"} }", text ];

        NSString *token = @"b8a30a5fb0679e4f8d4a9ecc81075465543cf2af849cfb0313d97b02b880d207";
        BOOL pushed = [pusher pushPayload:payload token:token identifier:rand() error:&error];
        if (pushed) {
            NSLog(@"Pushed to APNs");
        } else {
            NSLog(@"Unable to push: %@", error);
        }
    
        sleep(1);
    
        NSUInteger identifier = 0;
        NSError *apnError = nil;
        BOOL read = [pusher readFailedIdentifier:&identifier apnError:&apnError error:&error];
        if (read && apnError) {
            NSLog(@"Notification with identifier %i rejected: %@", (int)identifier, apnError);
        } else if (read) {
            NSLog(@"Read and none failed");
        } else {
            NSLog(@"Unable to read failed: %@", error);
        }
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


- (IBAction)actionSetControl: (id)sender {
    FeatureAlertColor color = (FeatureAlertColor)[self.faceAlertControl selectedSegmentIndex];
    State * newState = [[State alloc] initWith: FeatureFaceDetected];
    [newState push: color at: 0 since: 0];
    [self.faceDetection feature: FeatureFaceDetected changedState: newState];
}


- (void) updateOutput:(NSNumber *)notUsed {
    FeatureAlertColor lastColor = [self.faceDetection getLastColor: FeatureFaceDetected];
    [self setFaceAlertImage: lastColor];
    NSMutableArray * states = [self.faceDetection getAllStates: FeatureFaceDetected];
    [self.nofEvents setText:
        [NSMutableString stringWithFormat:@"%ui events", (unsigned int)[states count]]];
    
    NSMutableArray * colorStates = [self.faceDetection getNofStates: FeatureFaceDetected];
    NSNumber * nof = colorStates[ (int)FeatureAlertGreen ];
    [self.nofGreenEvents setText:
        [NSMutableString stringWithFormat:@"%i Green", nof.intValue ]];

    nof = colorStates[ (int)FeatureAlertOrange ];
    [self.nofOrangeEvents setText:
     [NSMutableString stringWithFormat:@"%i Orange", nof.intValue ]];

    nof = colorStates[ (int)FeatureAlertRed ];
    [self.nofRedEvents setText:
     [NSMutableString stringWithFormat:@"%i Red", nof.intValue ]];

    nof = colorStates[ (int)FeatureAlertDarkRed ];
    [self.nofDarkRedEvents setText:
     [NSMutableString stringWithFormat:@"%i Dark Red", nof.intValue ]];

}



- (IBAction)actionStart:(id)sender {
    self.faceDetection = [ [FaceDetectionOpenCV alloc ] initWith: AVCaptureVideoOrientationPortrait controller: self];
    self.videoCamera.delegate = self.faceDetection;

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
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    
    self.faceDetection = [ [FaceDetectionOpenCV alloc ] initWith: AVCaptureVideoOrientationPortrait controller: self];
    self.videoCamera.delegate = self.faceDetection;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;

    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    //self.videoCamera.defaultAVCaptureVideoOrientation = self.currentVideoOrientation;
    printf("current video orientation = %li\n", (long)self.currentVideoOrientation);
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    [self valueChangedMaxSize: self.maxSizeSlider];
    [self valueChangedMinSize: self.minSizeSlider];
    
    // do not change, best option for all: 2
    [self.minNeighboursStepper setValue: 2.0];
    [self valueChangedNeighbours: self.minNeighboursStepper];

    /*
        CASCADE_DO_CANNY_PRUNING    = 1,    index = 0
        CASCADE_SCALE_IMAGE         = 2,    index = 1
        CASCADE_FIND_BIGGEST_OBJECT = 4,    index = 2
        CASCADE_DO_ROUGH_SEARCH     = 8     index = 3
     */
    // do not change, best option for all: CASCADE_SCALE_IMAGE
    [self.optionsSegment setSelectedSegmentIndex: 0];
    [self valueChangedOptions: self.optionsSegment];
    
    [self.eyesSwitch setOn: true];
    [self.noseSwitch setOn: true];
    [self.debugSwitch setOn: false];
    [self.notificationSwitch setOn: false];
    
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
        printf("current video orientation = %ui\n", (unsigned int)self.currentVideoOrientation);
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // We support only Portrait.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewDidAppear:(BOOL)animated {
    [self actionStart: nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self actionStop: nil];
}



#pragma mark - CBCentralManagerDelegate Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            break;
        case CBCentralManagerStatePoweredOff:
            break;
            
        case CBCentralManagerStateUnsupported: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dang."
                                                            message:@"Unfortunately this device can not talk to Bluetooth Smart (Low Energy) Devices"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            
            [alert show];
            break;
        }
            
            
        default:
            break;
    }
    
    
    
}




@end
