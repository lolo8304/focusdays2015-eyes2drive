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
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <DropboxSDK/DropboxSDK.h>

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


@property (nonatomic, strong) FaceDetectionOpenCV* faceDetection;

@property (weak, nonatomic) IBOutlet UISwitch *showMapSwitch;

@property (nonatomic, strong) DBRestClient *dropboxClient;

- (IBAction)showMapChanged:(id)sender;
    @property (nonatomic, strong) NSThread *thread;

- (IBAction)valueChangedNeighbours:(UIStepper *)sender;
- (IBAction)valueChangedOptions:(UISegmentedControl *)sender;
- (IBAction)valueChangedMinSize:(UISlider *)sender;
- (IBAction)valueChangedMaxSize:(UISlider *)sender;

- (IBAction)actionStart:(id)sender;
- (IBAction)actionStop:(id)sender;
- (IBAction)actionSetControl: (id)sender;
- (IBAction)toggleTrip:(id)sender;
@end


@implementation ViewController

NSString * coloredImageName = @"none";
NSArray * soundFiles;

CFURLRef soundFileURLRefGreen;
SystemSoundID	soundFileObjectGreen;
CFURLRef soundFileURLRefOther;
SystemSoundID	soundFileObjectOther;

BOOL recordEyes = false;
NSString* recordEyesSessionName;

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


- (NSString*)getSessionFolderName {
    NSDateFormatter *formatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    return  [formatter stringFromDate:[NSDate date]];
}


- (IBAction)showMapChanged:(id)sender {
    if ([sender isOn]) {
        [self.mapView setHidden: false];
        if ([[DBSession sharedSession] isLinked] && [self.debugSwitch isOn]) {
            recordEyesSessionName = [self getSessionFolderName];
            [self.dropboxClient createFolder: recordEyesSessionName];
            recordEyes = true;
        }

    } else {
        [self.mapView setHidden: true];
        recordEyes = false;
    }
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
    if ([self.faceDetection isStarted]) {
        NSMutableString *imageName = [NSMutableString stringWithFormat:@"Alert-%@.png", FeatureAlertColor_toString[color]];
        if (![coloredImageName isEqualToString: imageName]) {
            coloredImageName = imageName;
            self.faceAlertView.image = [UIImage imageNamed: coloredImageName];
            [self.faceAlertControl setSelectedSegmentIndex: (int)color];
            [self playSound: color];
        }
    } else {
        coloredImageName = @"Image";
        self.faceAlertView.image = [UIImage imageNamed: coloredImageName];
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


- (void) playSound: (FeatureAlertColor) color {
    if (color == FeatureAlertGreen) {
        if (!soundFileURLRefGreen) {
            NSURL* sound = [self getURLSound: color];
            soundFileURLRefGreen = (CFURLRef)CFBridgingRetain(sound);
            AudioServicesCreateSystemSoundID (soundFileURLRefGreen, &soundFileObjectGreen);
        }
        AudioServicesPlaySystemSound (soundFileObjectGreen);
    } else {
        if (!soundFileURLRefOther) {
            NSURL* sound = [self getURLSound: color];
            soundFileURLRefOther = (CFURLRef)CFBridgingRetain(sound);
            AudioServicesCreateSystemSoundID (soundFileURLRefOther, &soundFileObjectOther);
        }
        AudioServicesPlaySystemSound (soundFileObjectOther);
    }
}


- (NSURL *)getURLSound: (FeatureAlertColor) color {
    if (color == FeatureAlertGreen) {
        return [[NSBundle mainBundle] URLForResource: @"tap"
                                                withExtension: @"aif"];
    } else {
        return [[NSBundle mainBundle] URLForResource: @"Sound-Red"
                                       withExtension: @"aiff"];
    }
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
        [NSMutableString stringWithFormat:@"%i events", (int)[states count]]];
    
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

- (IBAction)toggleTrip:(id)sender {
    if ([self.faceDetection isStarted]) {
        [self actionStop:sender];
    } else {
        [self actionStart:sender];
    }
}



- (IBAction)actionStart:(id)sender {
    [self.faceDetection startTrip ];
    [[self toggleTripButton] setTitle: @"Stop" forState: UIControlStateNormal];
    [self setFaceAlertImage: FeatureAlertGreen];
    
}

- (IBAction)actionStop:(id)sender {
    [self.faceDetection stopTrip ];
    [[self toggleTripButton] setTitle: @"Start" forState: UIControlStateNormal];
}


- (void)initStart {
    self.faceDetection = [ [FaceDetectionOpenCV alloc ] initWith: AVCaptureVideoOrientationPortrait controller: self];
    self.videoCamera.delegate = self.faceDetection;

    [self.videoCamera start];
    [self setFaceAlertImage: FeatureAlertGreen];
    if ([self.thread isExecuting]) {
        NSLog(@"Thread is already running");
    } else {
        NSLog(@"Starting thread");
        [self.thread start];
    }

}
- (void)exitStop {
    [self.videoCamera stop];
    NSLog(@"Stopping thread");
    [self.thread cancel];
    [self setFaceAlertImage: FeatureAlertGreen];
    [self.locationManager stopUpdatingLocation];
   // [self.locationManager stopUpdatingHeading];

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
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
    self.dropboxClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.dropboxClient.delegate = self;

    [self clearTempDirectory];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    
    self.faceDetection = [ [FaceDetectionOpenCV alloc ] initWith: AVCaptureVideoOrientationPortrait controller: self];
    self.videoCamera.delegate = self.faceDetection;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    //self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;

    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    //self.videoCamera.defaultAVCaptureVideoOrientation = self.currentVideoOrientation;
    printf("current video orientation = %li\n", (long)self.currentVideoOrientation);
    self.videoCamera.defaultFPS = 50;
    self.videoCamera.grayscaleMode = NO;
    //[self.videoCamera lockFocus];
    //[self.videoCamera lockExposure];
    //[self.videoCamera lockBalance];
    [self.videoCamera rotateVideo];
    
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
    
    /* map view initialisation */
    self.mapView.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    //[self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
   // [self.locationManager startUpdatingHeading];
    
    self.mapView.showsUserLocation = YES;
    [self.mapView setMapType:MKMapTypeHybrid];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    [self.mapView setRotateEnabled: YES];
    [self.mapView setUserInteractionEnabled: YES];
   // [self.mapView setUserTrackingMode: MKUserTrackingModeFollowWithHeading animated: YES];
    
    
}

- (void) zoomDevice {

    AVCaptureDevice* device;
    float zoomLevel = 2.0f;
    if ([device respondsToSelector:@selector(setVideoZoomFactor:)]
        && device.activeFormat.videoMaxZoomFactor >= zoomLevel) {
        // iOS 7.x with compatible hardware
        if ([device lockForConfiguration:nil]) {
            [device setVideoZoomFactor:zoomLevel];
            [device unlockForConfiguration];
        }
    }
}


- (void) zoomVideoCamera: (float) zoomLevel {
    
    AVCaptureDevice *device = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    if ([device respondsToSelector:@selector(setVideoZoomFactor:)]
        && device.activeFormat.videoMaxZoomFactor >= zoomLevel) {
        // iOS 7.x with compatible hardware
        if ([device lockForConfiguration:nil]) {
            [device setVideoZoomFactor:zoomLevel];
            [device unlockForConfiguration];
        }
    }}

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

- (void) clearTempDirectory {
        NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
        for (NSString *file in tmpDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
        }
}

- (void) writeImageToDropbox: (UIImage*) image named: (NSString*) name {
    if (!recordEyes) return;
    NSData *imageData = UIImagePNGRepresentation(image);
    
    
    NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    NSString* fileNameUUID = [NSString stringWithFormat: @"%@.jpg", [[NSUUID UUID] UUIDString] ];
    /*
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                          NSUserDomainMask,
                                                          YES) lastObject];
     */
    NSString* path = NSTemporaryDirectory();

    NSString* fileName = [path stringByAppendingPathComponent: fileNameUUID];
    
    [imageData writeToFile: fileName atomically:YES];
    [self.dropboxClient uploadFile: fileNameUUID toPath: [NSString stringWithFormat:@"/%@/%@", recordEyesSessionName, name] withParentRev: nil fromPath: fileName];
}

- (void)uploadLeftEyeImage: (UIImage*) image {
    [self.leftEyeImageView setImage: image];
    [self writeImageToDropbox: image named: @"leftEye"];
}
- (void)uploadRightEyeImage: (UIImage*) image {
    [self.rightEyeImageView setImage: image];
    [self writeImageToDropbox: image named: @"rightEye"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // We support only Portrait.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];

    [self initStart];

    /* important http://matthewfecher.com/app-developement/getting-gps-location-using-core-location-in-ios-8-vs-ios-7/ */
    
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    NSLog(@"%@", [self deviceLocation]);
    
    //View Area
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 0.005f;
    region.span.latitudeDelta = 0.005f;
    [self.mapView setRegion:region animated:YES];

    
}
- (void)viewWillDisappear:(BOOL)animated {
    [self exitStop];
    
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
   // [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
}

- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
}
@end
