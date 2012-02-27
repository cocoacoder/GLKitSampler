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
    //self.cellBackgroundView.layer.shadowColor   = [[UIColor colorWithWhite:1.0 alpha:0.75] CGColor];
    //self.cellBackgroundView.layer.shadowOffset  = CGSizeMake(3.0, 5.0);
    //self.cellBackgroundView.layer.shadowRadius  = 10.0;
    
    /*
    UIView *imgView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
    imgView.backgroundColor = [UIColor clearColor];
    
    // Rounded corners.
    imgView.layer.cornerRadius = 5;
    
    // A thin border.
    imgView.layer.borderColor = [UIColor redColor].CGColor;
    imgView.layer.borderWidth = 3.0;
    
    // Drop shadow.
    imgView.layer.shadowColor = [UIColor redColor].CGColor;
    imgView.layer.shadowOpacity = 1.0;
    imgView.layer.shadowRadius = 7.0;
    imgView.layer.shadowOffset = CGSizeMake(0, 4);
    
    [self.backgroundView addSubview:imgView];
    */
    
    /*
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(20.0, 20.0, 200.0, 40.0) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5.0, 5.0)];
    
    [[UIColor redColor] setFill];
    
    [path stroke];
    
    self.cellBackgroundView.layer.shadowPath = path.CGPath;
    */
    
    //UIBezierPath *roundedRectPath = [UIBezierPath bezierPath];
    
    /*
    // Set the starting point of the shape.
    [roundedRectPath moveToPoint:CGPointMake(5.0, 0.0)];
    
    // Draw the lines
    [roundedRectPath addLineToPoint:CGPointMake(315.0, 0.0)];
    [roundedRectPath addQuadCurveToPoint:CGPointMake(320.0, 5.0) controlPoint:CGPointMake(320.0, 0.0)];
    [roundedRectPath addLineToPoint:CGPointMake(320.0, 65.0)];
    [roundedRectPath addQuadCurveToPoint:CGPointMake(315.0, 70.0) controlPoint:CGPointMake(320.0, 70.0)];
    [roundedRectPath addLineToPoint:CGPointMake(5.0, 70.0)];
    [roundedRectPath addQuadCurveToPoint:CGPointMake(0.0, 65.0) controlPoint:CGPointMake(0.0, 70.0)];
    [roundedRectPath addLineToPoint:CGPointMake(0.0, 5.0)];
    [roundedRectPath addQuadCurveToPoint:CGPointMake(5.0, 0.0) controlPoint:CGPointMake(0.0, 0.0)];
    [roundedRectPath closePath];
    */
    /*
    [roundedRectPath moveToPoint:CGPointMake(5.0, 5.0)];
    [roundedRectPath addLineToPoint:CGPointMake(315.0, 5.0)];
    [roundedRectPath addLineToPoint:CGPointMake(315.0, 65.0)];
    [roundedRectPath addLineToPoint:CGPointMake(5.0, 65.0)];
    [roundedRectPath addLineToPoint:CGPointMake(5.0, 5.0)];
    [roundedRectPath closePath];
    */
    //self.cellBackgroundView.layer.shadowPath    = roundedRectPath.CGPath;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
