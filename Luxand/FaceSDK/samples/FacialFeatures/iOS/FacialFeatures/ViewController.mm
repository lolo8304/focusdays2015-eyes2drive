//
//  ViewController.m
//  FacialFeatures
//
//  Copyright (c) 2013 Luxand, Inc. All rights reserved.
//

#import "ViewController.h"
#include "LuxandFaceSDK.h"

@interface ViewController ()

@end

@implementation ViewController

//for Xcode 4.2 support (not needed in Xcode 4.4+)
@synthesize label=_label;
@synthesize imageview=_imageview;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLabel:nil];
    [self setImageview:nil];
    [super viewDidUnload];
}

- (IBAction)loadButton:(id)sender {
    imagepicker = [[UIImagePickerController alloc] init];
    imagepicker.delegate = self;
    imagepicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        popOverController = [[UIPopoverController alloc] initWithContentViewController:imagepicker];
        [popOverController presentPopoverFromRect:CGRectMake(0, 0, imagepicker.view.frame.size.width, imagepicker.view.frame.size.height) inView:self.view permittedArrowDirections:NO animated:NO];        
    } else {
        [self.view addSubview:imagepicker.view];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    // Picked image
    UIImage * img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Load image to FaceSDK
    NSData * jpegbuf = UIImageJPEGRepresentation(img, 0.9f);
    unsigned int len = jpegbuf.length;
    unsigned char * ptr = (unsigned char *)jpegbuf.bytes;
    NSLog(@"image buffer len %d, ptr %p\n", len, ptr);
    HImage fsdk_img;
    int res = FSDK_LoadImageFromJpegBuffer(&fsdk_img, ptr, len);
    if (res != FSDKE_OK) {
        NSString * str = [[NSString alloc] initWithFormat: @"error loading image to FaceSDK: %d\n", res];
        self.label.text = str;
        NSLog(@"error loading image to FaceSDK: %d\n", res);
        return;
    }
    
    // Detect face
    BOOL have_face = NO;
    TFacePosition facepos;
    res = FSDK_DetectFace(fsdk_img, &facepos);
    if (res == FSDKE_OK) {
        have_face = YES;
        NSLog(@"face: %d %d %d %f", facepos.xc, facepos.yc, facepos.w, facepos.angle);
    } else {
        NSLog(@"no face detected, result = %d", res);
    }
    
    // Detect features
    BOOL have_features = NO;
    FSDK_Features features;
    if (have_face) {
        res = FSDK_DetectFacialFeaturesInRegion(fsdk_img, &facepos, &features);
        if (res == FSDKE_OK) {
            have_features = YES;
            NSLog(@"eyes: %d %d, %d %d\n", features[0].x, features[0].y, features[1].x, features[1].y);
        }
    }
    
    // Unload image from FaceSDK
    FSDK_FreeImage(fsdk_img);
    
    // Draw face and features
    if (have_face) {
        UIGraphicsBeginImageContext(img.size);
        [img drawAtPoint:CGPointZero];
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ctx, 2.0f);
        [[UIColor blueColor] setStroke];
        CGRect facerect = CGRectMake(facepos.xc - facepos.w/2.0f, facepos.yc - facepos.w/2.0f, facepos.w, facepos.w);
        CGContextStrokeRect(ctx, facerect);
        if (have_features) {
            for (int i=0; i<FSDK_FACIAL_FEATURE_COUNT; ++i) {
                CGRect feature = CGRectMake(features[i].x - 1.0f, features[i].y - 1.0f, 3.0f, 3.0f);
                CGContextAddEllipseInRect(ctx, feature);
            }
            CGContextStrokePath(ctx);
        }
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Show image
    self.imageview.contentMode = UIViewContentModeScaleAspectFit;
    self.imageview.image = img;
    self.imageview.hidden = NO;
    
    // Remove image picker
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [popOverController dismissPopoverAnimated:NO];
        popOverController = NULL;
    } else {
        [imagepicker.view removeFromSuperview];
    }
    imagepicker = NULL;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [popOverController dismissPopoverAnimated:NO];
        popOverController = NULL;
    } else {
        [imagepicker.view removeFromSuperview];
    }
    imagepicker = NULL;
}


@end
