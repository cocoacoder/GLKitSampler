//
//  PFMasterViewController.m
//  GLKitSampler
//
//  Created by Jim Hillhouse on 2/22/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import "PFMasterViewController.h"

#import "PFTableViewCell.h"
#import "PFDetailViewController.h"

#import <QuartzCore/QuartzCore.h>



static BOOL glkitSampleData = YES; // Toggle this after including data





@interface PFMasterViewController () 
{
}

- (void)addGLKitSampleWithName:(NSString *)name type:(NSString *)type summary:(NSString *)summary order:(NSInteger)order;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end




@implementation PFMasterViewController



@synthesize detailViewController        = _detailViewController;

@synthesize fetchedResultsController    = __fetchedResultsController;
@synthesize managedObjectContext        = __managedObjectContext;

@synthesize titleLabel                  = _titleLabel;
@synthesize summaryLabel                = _summaryLabel;
@synthesize cellBackgroundView          = _cellBackgroundView;



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
//    self.navigationController.navigationBar.alpha       = 0.75;
//    self.navigationController.navigationBar.translucent = YES;
    

    //
    // Using Core Data to manage the GLKitSampler choices
    //
    if ( !glkitSampleData ) 
    {
        [self addGLKitSampleWithName:@"Draw A Line" type:@"Line" summary:@"Draw a simple line using GL_LINE_STRIP" order:1];
        [self addGLKitSampleWithName:@"Draw A Square" type:@"Square" summary:@"Draw a square using GL_LINE_LOOP" order:2];
        [self addGLKitSampleWithName:@"Draw A Cube" type:@"Cube" summary:@"Draw a cube using GL_TRIANGLE_STRIP" order:3];
        [self addGLKitSampleWithName:@"Texture A Cube" type:@"TexturedCube" summary:@"Put a little texture on your cube." order:4];
        [self addGLKitSampleWithName:@"A Textured Sphere" type:@"TexturedSphere" summary:@"Draw a sphere using GL_TRIANGLE_STRIP and put a texture on it." order:5];
        [self addGLKitSampleWithName:@"Import a Model" type:@"ISS" summary:@"Import a model from Blender as a header file, using Jeff Lamarche's Python script." order:6];
        
        NSLog(@"Managed objects created, database populated, and now setting BOOL to TRUE");
        
        glkitSampleData = TRUE;
    }
}



- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setSummaryLabel:nil];
    [self setCellBackgroundView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } 
    else 
    {
        return ( (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
    }
}



#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    return 1;
    NSLog(@"Number of sections: %d", [[self.fetchedResultsController sections] count]);
    return [[self.fetchedResultsController sections] count];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    return [self.controllers count];
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSLog(@"Number of rows: %d", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
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


/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    //
    // This alternating colors of table view cells is a pretty cool effect, but not particularly useful here.
    //
    if (indexPath.row == 0 || indexPath.row%2 == 0) 
    {
        UIColor *altCellColor = [UIColor colorWithWhite:0.7 alpha:0.25];
        cell.backgroundColor = altCellColor;
    }
}
*/



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"MasterView -tableView: cellForRowAtIndexPath:");
    
    PFTableViewCell *glkitSamplerCell = [tableView dequeueReusableCellWithIdentifier:@"GLKitSamplerCell"];
    
    if (glkitSamplerCell == nil) 
    {
        // Nothing to do here for now...
    }
    
    [self configureCell:glkitSamplerCell atIndexPath:indexPath];
    
    return glkitSamplerCell;
}



- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"MasterView -tableView: didSelectRowAtIndexPath:");
    
    //
    // This is used for the iPad
    //
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
    {        
        NSManagedObject *managedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        self.detailViewController.detailItem = [[managedObject valueForKey:@"type"] description];
        self.detailViewController.managedObject = managedObject;

        NSLog(@"Just touched an index row with type: %@", [[managedObject valueForKey:@"type"] description]);
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) 
    {
        NSLog(@"MasterView -prepareForSegue:");
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

        NSManagedObject *managedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:[[managedObject valueForKey:@"type"] description]];
        [[segue destinationViewController] setManagedObject:managedObject];
        
        NSLog(@"Just touched an index row with type: %@", [[managedObject valueForKey:@"type"] description]);
    }
}



#pragma mark - Core Data Method for Adding Data to the Managed Object

- (void)addGLKitSampleWithName:(NSString *)name type:(NSString *)type summary:(NSString *)summary order:(NSInteger)order
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newGLKitSample = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    NSLog(@"Entity Name: %@", [entity name]);
    
    [newGLKitSample setValue:name forKey:@"name"];
    [newGLKitSample setValue:summary forKey:@"summary"];
    [newGLKitSample setValue:type forKey:@"type"];
    
    NSNumber *orderNumber = [NSNumber numberWithInt:order];
    [newGLKitSample setValue:orderNumber forKey:@"order"];
    
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    if ( !success ) 
    {
        NSLog(@"Error = %@", error);
    }
}



- (void)configureCell:(PFTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSLog(@"sampler cell name: %@", [object valueForKey:@"name"]);
    
    cell.titleLabel.text     = [object valueForKey:@"name"];
    cell.summaryLabel.text   = [object valueForKey:@"summary"];
}




#pragma mark - Core Data Fetched Results Controller Methods

- (NSFetchedResultsController *)fetchedResultsController
{
    NSLog(@"MasterView -fetchedResultsController");
    
    if (__fetchedResultsController != nil) 
    {
        NSLog(@"fetchedResultsController already exists");
        return __fetchedResultsController;
    }
    
    NSLog(@"fetchedResultsController does not exist, creating one.");
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GLKitSample" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
   
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    



- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"MasterView -controllerWillChangeContent:");
    [self.tableView beginUpdates];
}



- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) 
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}



- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"fetchedResultsController delegate method -didChangeObject:...");
    
    UITableView *tableView = self.tableView;
    
    switch(type) 
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}



- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */



@end    
