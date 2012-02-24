//
//  PFDetailViewController.h
//  GLKitSampler
//
//  Created by Jim Hillhouse on 2/22/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GLKit/GLKit.h>

@interface PFDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic)   id detailItem;
@property (strong, nonatomic)   IBOutlet UIView *overviewView;
@property (weak, nonatomic)     IBOutlet UILabel *overviewLabel;
@property (strong, nonatomic)   IBOutlet UITextView *textOverviewTextView;

@end
