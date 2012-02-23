//
//  PFViewController.h
//  OpenGL Game
//
//  Created by Jim Hillhouse on 2/1/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GLKit/GLKit.h>



@interface PFGLKitSample1ViewController : GLKViewController


@property (weak, nonatomic) IBOutlet UITextField *pitchLabel;
@property (weak, nonatomic) IBOutlet UITextField *rollLabel;


- (IBAction)resetReferenceFrame:(id)sender;

@end
