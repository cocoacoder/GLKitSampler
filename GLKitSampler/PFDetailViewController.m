//
//  PFDetailViewController.m
//  GLKitSampler
//
//  Created by Jim Hillhouse on 2/22/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import "PFDetailViewController.h"

#import "PFGLKitSample1ViewController.h"

#import <QuartzCore/QuartzCore.h>




@interface PFDetailViewController ()


@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSString *overviewString;

- (void)configureView;
- (void)dimOverviewView;
- (void)undimOverviewView;
- (IBAction)glViewTransition:(id)sender;

@end




@implementation PFDetailViewController



@synthesize detailItem              = _detailItem;
@synthesize overviewView            = _overviewView;
@synthesize textOverviewTextView    = _textOverviewView;
@synthesize overviewLabel           = _overviewLabel;
@synthesize masterPopoverController = _masterPopoverController;

@synthesize overviewString          = _overviewString;
    
    
    
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
    {
        [self.overviewView.layer setCornerRadius:15.0];
    }
    else 
    {
        [self.overviewView.layer setCornerRadius:10.0];
    }
    

    if ([[self.detailItem description] isEqualToString:@"Line"]) 
    {
        NSLog(@"Line");
        
        self.overviewString = @"This GLKit example shows how to create a simple line using two points and GL_LINE_LOOP in the glDrawArrays call.";
        [self undimOverviewView];
    }
    else 
    {
        [self dimOverviewView];
    }
    
    self.textOverviewTextView.text = self.overviewString;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
     
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Star_Nursery"]];
        
}



- (void)viewDidUnload
{
    [self setOverviewLabel:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    self.overviewView = nil;
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



#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"GLKViewSegue"]) 
    {
        PFGLKitSample1ViewController *glkSample1ViewController = [segue destinationViewController];        
        glkSample1ViewController = [segue destinationViewController];
        self.detailItem = nil;
    }
}



- (void)glViewTransition:(id)sender
{
    
    if ([[self.detailItem description] isEqualToString:@"Line"]) 
    {
        [self performSegueWithIdentifier:@"GLKViewSegue" sender:sender];
    }
}



#pragma mark - Dimming and Undimming Methods

- (void)dimOverviewView
{
    [UIView animateWithDuration:0.75 animations:^{
        self.overviewView.alpha = 0.0;
    }
                     completion:^(BOOL finished){
                         NSLog(@"contentView has been dimmed");
                     }];
}



- (void)undimOverviewView
{
    [UIView animateWithDuration:0.75 animations:^{
        self.overviewView.alpha = 1.0;
    }
                     completion:^(BOOL finished){
                         NSLog(@"contentView has been undimmed");
                     }];
}



# pragma mark - Method for handling rotation.

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
