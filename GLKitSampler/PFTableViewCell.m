//
//  PFTableViewCell.m
//  GLKitSampler
//
//  Created by Jim Hillhouse on 2/26/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import "PFTableViewCell.h"

#import <QuartzCore/QuartzCore.h>




@implementation PFTableViewCell


@synthesize cellBackgroundView  = _cellBackgroundView;
@synthesize titleLabel          = _titleLabel;
@synthesize summaryLabel        = _summaryLabel;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        // Initialization code
    }
    NSLog(@"calling custom table view cell code");
    return self;
}



-(void)awakeFromNib
{
    self.cellBackgroundView.layer.cornerRadius  = 5.0;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
