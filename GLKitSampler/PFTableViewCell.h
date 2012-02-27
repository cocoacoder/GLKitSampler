//
//  PFTableViewCell.h
//  GLKitSampler
//
//  Created by Jim Hillhouse on 2/26/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface PFTableViewCell : UITableViewCell


@property (strong, nonatomic)   IBOutlet    UIView  *cellBackgroundView;
@property (strong, nonatomic)   IBOutlet    UILabel *titleLabel;
@property (strong, nonatomic)   IBOutlet    UILabel *summaryLabel;


@end
