//
//  PFMasterViewController.m
//  GLKitSampler
//
//  Created by Jim Hillhouse on 2/22/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import "PFMasterViewController.h"

#import "PFDetailViewController.h"




@interface PFMasterViewController () 
{
}

@end




@implementation PFMasterViewController



@synthesize detailViewController = _detailViewController;
@synthesize controllers = _controllers;



- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
    {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
//        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    //
    // Special Note: Please don't forget to put this in ever again...because doing so caused me to
    // waste the last 4 hours of my life!
    //
    self.detailViewController = (PFDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    
    //
    // Set-up some appearance (but not appearance proxy!) to make the UI look better
    //
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
    {
        //self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    }
    
    self.navigationController.navigationBar.tintColor   = [UIColor blackColor];
    self.navigationController.navigationBar.alpha       = 0.75;
    self.navigationController.navigationBar.translucent = YES;
    
    
    //
    // Set-up the controllers array
    //
    
    
    //
    // Set up the dictionaries for the two views
    //
    NSDictionary *scribblePressUIDictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                @"Draw A Line", @"Name", 
                                                @"Draw a simple line using GL_POINTS", @"Summary",
                                                @"Line", @"Type",
                                                nil];
    NSDictionary *scribblePressUIDictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                @"Draw A Square", @"Name", 
                                                @"Draw a square using GL_LINES", @"Summary", 
                                                @"Square", @"Type",
                                                nil];
    NSDictionary *scribblePressUIDictionary3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                @"Draw A Cube", @"Name",
                                                @"Draw a cube using GL_TRIANGLES", @"Summary",
                                                @"Cube", @"Type",
                                                nil];
    NSDictionary *scribblePressUIDictionary4 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                @"Textured Cube", @"Name", 
                                                @"Put a little texture on your cube.", @"Summary", 
                                                @"CubeTexture", @"Type",
                                                nil];
    
    NSArray *anArray = [[NSArray alloc] initWithObjects:
                        scribblePressUIDictionary1, 
                        scribblePressUIDictionary2,
                        scribblePressUIDictionary3,
                        scribblePressUIDictionary4,
                        nil];
    
    self.controllers = anArray;
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } 
    else 
    {
        return YES;
    }
}



#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.controllers count];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
    {
        return 80;
    }
    else 
    {
        return 75;
    }

}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *glkitSamplerCell = [tableView dequeueReusableCellWithIdentifier:@"GLKitSamplerCell"];

    // Configure the cell.
    NSUInteger row          = [indexPath row];
    NSDictionary *rowData   = [self.controllers objectAtIndex:row];
    
    glkitSamplerCell.textLabel.text         = [rowData objectForKey:@"Name"];
    glkitSamplerCell.detailTextLabel.text   = [rowData objectForKey:@"Summary"];
    
    
    return glkitSamplerCell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSUInteger row = [indexPath row];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
    {        
        NSDictionary *rowData = [self.controllers objectAtIndex:indexPath.row];
        [self.detailViewController setDetailItem:[rowData objectForKey:@"Type"]];
        NSLog(@"Just touched an index row with type: %@", [rowData objectForKey:@"Type"]);
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) 
    {
        NSLog(@"Segueing now...");
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *rowData = [self.controllers objectAtIndex:indexPath.row];
        [[segue destinationViewController] setDetailItem:[rowData objectForKey:@"Type"]];
    }
}

@end
