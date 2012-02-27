//
//  PFTableViewCell.m
//  GLKitSampler
//
//  Created by Jim Hillhouse on 2/26/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import "PFTableViewCell.h"

@implementation PFTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
