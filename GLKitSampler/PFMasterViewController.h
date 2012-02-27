//
//  PFMasterViewController.h
//  GLKitSampler
//
//  Created by Jim Hillhouse on 2/22/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>



@class PFDetailViewController;

@interface PFMasterViewController : UITableViewController  <NSFetchedResultsControllerDelegate>


@property (strong, nonatomic) PFDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
