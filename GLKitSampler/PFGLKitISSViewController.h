//
//  PFGLKitSphereViewController.h
//  GLKitSampler
//
//  Created by Jim Hillhouse on 3/15/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface PFGLKitISSViewController : GLKViewController


@property (weak, nonatomic) IBOutlet UITextField *pitchLabel;
@property (weak, nonatomic) IBOutlet UITextField *rollLabel;


- (IBAction)resetReferenceFrame:(id)sender;

// Gesture Recognizer Methods
- (IBAction)handleZoomFromGestureRecognizer:(UIPinchGestureRecognizer *)recognizer;

// Attitude Methods
- (IBAction)setTranslation:(id)sender;

@end
