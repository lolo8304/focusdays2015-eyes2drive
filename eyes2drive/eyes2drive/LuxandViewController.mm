//
//  LuxandViewController.mm
//  eyes2drive
//
//  Created by Lorenz Hänggi on 07/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

#import "LuxandViewController.h"

@interface LuxandViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *button;

- (IBAction)actionStart:(id)sender;
- (IBAction)actionStop:(id)sender;

@end


@implementation LuxandViewController

- (IBAction)actionStart:(id)sender {
}
- (IBAction)actionStop:(id)sender {
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
