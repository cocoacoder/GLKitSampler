//
//  PFGLKViewController.m
//  GLKitSampler
//
//  Created by Jim Hillhouse on 3/12/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import "PFGLKViewController.h"

#import <CoreMotion/CoreMotion.h>





@interface PFGLKViewController () <UIGestureRecognizerDelegate>
{
    CMMotionManager *_motionMgr;
}

@property (strong, nonatomic) CMAttitude *referenceFrame;

@end




@implementation PFGLKViewController



@synthesize pitchLabel  = _pitchLabel;
@synthesize rollLabel   = _rollLabel;

@synthesize referenceFrame = _referenceFrame;



#pragma mark - View Life

//- (id)init
//{
//    [self doesNotRecognizeSelector:_cmd];
//    return nil;
//}



#pragma mark - Reference Frame

- (IBAction)resetReferenceFrame:(id)sender
{
    [self doesNotRecognizeSelector:_cmd];
}



-(void)prepareViewController
{
    [self doesNotRecognizeSelector:_cmd];
}



@end
