//
//  PFAppDelegate.m
//  GLKitSampler
//
//  Created by Jim Hillhouse on 2/22/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import "PFAppDelegate.h"

#import "PFMasterViewController.h"
#import <QuartzCore/QuartzCore.h>




@implementation PFAppDelegate



@synthesize window = _window;

@synthesize managedObjectContext        = __managedObjectContext;
@synthesize managedObjectModel          = __managedObjectModel;
@synthesize persistentStoreCoordinator  = __persistentStoreCoordinator;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //
    // Override point for customization after application launch.
    //

    // 
    // Set the background image for the iPhone table view
    //
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        UIImageView *windowBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Star_Nursery"]];
        [self.window setContentMode:UIViewContentModeScaleAspectFill];
        [self.window addSubview:windowBackgroundImageView];
        
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        PFMasterViewController *controller = (PFMasterViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    }

    //
    // Set the background color for the iPad split view
    //
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
    {
        UISplitViewController *splitViewController      = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController    = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController  = [splitViewController.viewControllers objectAtIndex:0];
        PFMasterViewController *controller                  = (PFMasterViewController *)masterNavigationController.topViewController;
        controller.managedObjectContext                     = self.managedObjectContext;

        splitViewController.delegate                    = (id)navigationController.topViewController;
        navigationController.navigationBar.tintColor    = [UIColor blackColor];
        navigationController.navigationBar.alpha        = 0.7;
        navigationController.navigationBar.translucent  = YES;
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}




- (void)saveContext
{
    NSLog(@"AppDelegate -saveContext");
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) 
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) 
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}



#pragma mark - Core Data Stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    NSLog(@"AppDelegate -managedObjectContext");
    if (__managedObjectContext != nil) 
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) 
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}



// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    NSLog(@"AppDelegate -managedObjectModel");
    if (__managedObjectModel != nil) 
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GLKitSampler_CoreData_Model" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}



// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSLog(@"AppDelegate -persistentStoreCoordinator");
    if (__persistentStoreCoordinator != nil) 
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GLKitSampler_CoreData_Model.sqlite"];
    
    
#define MISSION_COPY_STORE_FROM_BUNDLE
    
#ifdef MISSION_COPY_STORE_FROM_BUNDLE
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) 
    {
        NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"GLKitSampler_CoreData_Model" ofType:@"sqlite"];
        
        NSError *anyError = nil;
        BOOL success = [[NSFileManager defaultManager] copyItemAtPath:dataPath toPath:[storeURL path] error:&anyError];
        
        if ( !success ) 
        {
            NSLog(@"Error copying file: %@", anyError);
        }
    }
#endif
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) 
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         */
         

        //
        // Deleting the existing store.
        //
        // NOTE: Comment-out on shipping code!!!
        //
        //[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];

        //
        // Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
        // Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and
        // Data Migration Programming Guide" for details.
        //
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}



#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



@end
