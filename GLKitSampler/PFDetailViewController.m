//
//  PFDetailViewController.m
//  GLKitSampler
//
//  Created by Jim Hillhouse on 2/22/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import "PFDetailViewController.h"

#import "PFGLKitSample1ViewController.h"




@interface PFDetailViewController ()


@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;

@end




@implementation PFDetailViewController



@synthesize detailItem              = _detailItem;
@synthesize contentView             = _contentView;
@synthesize masterPopoverController = _masterPopoverController;



#pragma mark - Segue Method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"GLKViewSegue"]) 
    {
        PFGLKitSample1ViewController *glkSample1ViewController = [segue destinationViewController];        
        glkSample1ViewController = [segue destinationViewController];
        self.detailItem = nil;
    }
}
    
    
    
#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    NSLog(@"Set Detail Item");
    if (_detailItem != newDetailItem) 
    {
        _detailItem = newDetailItem;
        
        // Update the view.
        
        //
        // Update for the iPad here. That's because the iPad loads in the detail, or second, view
        // at start-up whereas the iPhone does not.
        //
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
        {
            [self configureView];
        }
    }

    if (self.masterPopoverController != nil) 
    {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}



- (void)configureView
{
    if ([[self.detailItem description] isEqualToString:@"Line"]) 
    {
        NSLog(@"Line");
        
        
        //
        // There are two ways to push the new view using the segue on StoryBoard.
        //
        // This way...
        [self performSegueWithIdentifier:@"GLKViewSegue" sender:self.contentView];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
     
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Star_Nursery"]];
    
    [UIView animateWithDuration:0.75 animations:^{
        self.contentView.alpha = 1.0;
    }
                     completion:^(BOOL finished){
                         NSLog(@"contentView has been undimmed");
                     }];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    self.contentView = nil;
}



- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"-viewDidAppear");
    
    [super viewDidAppear:animated];
    
    
    //
    // Since the iPhone doesn't load the detail, or second, view at start-up, the view needs to be
    // configured now.
    //
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        [self configureView];
    }
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } 
    else 
    {
        return YES;
    }
}



#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}



- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
