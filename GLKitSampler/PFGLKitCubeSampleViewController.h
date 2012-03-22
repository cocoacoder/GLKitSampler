//
//  PFGLKitCubeSampleViewController.h
//  GLKitSampler
//
//  Created by Jim Hillhouse on 3/2/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import <GLKit/GLKit.h>



@interface PFGLKitCubeSampleViewController : GLKViewController


@property (weak, nonatomic) IBOutlet UITextField *pitchLabel;
@property (weak, nonatomic) IBOutlet UITextField *rollLabel;


- (IBAction)resetReferenceFrame:(id)sender;
- (void)prepareViewController;

@end
