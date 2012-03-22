//
//  PFGLKViewController.h
//  GLKitSampler
//
//  Created by Jim Hillhouse on 3/12/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface PFGLKViewController : GLKViewController


@property (weak, nonatomic) IBOutlet UITextField *pitchLabel;
@property (weak, nonatomic) IBOutlet UITextField *rollLabel;


- (IBAction)resetReferenceFrame:(id)sender;

- (void)prepareViewController;

@end
