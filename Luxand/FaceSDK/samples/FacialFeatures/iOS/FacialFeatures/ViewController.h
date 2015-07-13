//
//  ViewController.h
//  FacialFeatures
//
//  Copyright (c) 2013 Luxand, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImagePickerController * imagepicker;
    UIPopoverController * popOverController; //iPad only    
}

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *label;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageview;

- (IBAction)loadButton:(id)sender;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

@end
