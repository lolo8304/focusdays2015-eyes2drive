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
#import <opencv2/videoio/cap_ios.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (nonatomic, retain) CvVideoCamera* videoCamera;

- (IBAction)actionStart:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
