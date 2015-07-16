//
//  ViewController.h
//  eyes2drive
//
//  Created by Lorenz Hänggi on 07/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

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
@property (weak, nonatomic) IBOutlet UISwitch *goodFeaturesSwitch;



@end

