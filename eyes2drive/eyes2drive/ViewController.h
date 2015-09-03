//
//  ViewController.h
//  eyes2drive
//
//  Created by Lorenz Hänggi on 07/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

#import <opencv2/videoio/cap_ios.h>
#include <opencv2/objdetect/objdetect.hpp>


@interface ViewController : UIViewController<MKMapViewDelegate,  CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UISlider *minSizeSlider;
@property (weak, nonatomic) IBOutlet UILabel *minSizeLabel;

@property (weak, nonatomic) IBOutlet UISlider *maxSizeSlider;
@property (weak, nonatomic) IBOutlet UILabel *maxSizeLabel;

@property (weak, nonatomic) IBOutlet UIStepper *minNeighboursStepper;
@property (weak, nonatomic) IBOutlet UILabel *neighboursLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *optionsSegment;
@property (weak, nonatomic) IBOutlet UILabel *optionsLabel;

@property (weak, nonatomic) IBOutlet UISwitch *eyesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *noseSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *debugSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *leftEyeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightEyeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;

@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic, strong) CLLocationManager *locationManager;

- (void) zoomVideoCamera: (float) zoomLevel;


@end

