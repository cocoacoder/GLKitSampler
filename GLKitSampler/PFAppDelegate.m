//
//  PFAppDelegate.m
//  GLKitSampler
//
//  Created by Jim Hillhouse on 2/22/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import "PFAppDelegate.h"

#import <QuartzCore/QuartzCore.h>

@implementation PFAppDelegate

@synthesize window = _window;

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
    }

    //
    // Set the background color for the iPad split view
    //
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
    {
        UISplitViewController *splitViewController      = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController    = [splitViewController.viewControllers lastObject];
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

@end
