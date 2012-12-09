//
//  ISAppDelegate.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 01.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

// TODO: do something when model changed!!!!

#import "ISAppDelegate.h"

//#import "LocalyticsSession.h"

#import "ISMainPageViewController.h"
#import "ISBookmarksTableViewController.h"
#import "ISLectorListTableViewController.h"

#import "SeminarFetcher.h"

#import "SHKConfiguration.h"
#import "ISSHKConfigurator.h"

@implementation ISAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize kvStore = _kvStore;

#pragma mark - shared delegate
+ (ISAppDelegate *)sharedDelegate
{
    return (ISAppDelegate *) [UIApplication sharedApplication].delegate;
}

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

//    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.28 green:0.66 blue:0.79 alpha:1.0]];
//        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.94 green:0.51 blue:0.21 alpha:1.0]];
//    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.28 green:0.66 blue:0.79 alpha:1.0]];
    
//    [[LocalyticsSession sharedLocalyticsSession] startSession:@"[[LocalyticsSession sharedLocalyticsSession] startSession:@"APP KEY FROM STEP 2"];"];
    
    // orange IRSOT toolbar color
    //    [[UINavigationBar appearance] setTintColor: [UIColor colorWithRed:1 green:0.51 blue:0 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor: [UIColor colorWithRed:8/255.0 green:86/255.0 blue:126/255.0 alpha:1.0]];
//    [[UINavigationBar appearance] setTintColor: [UIColor colorWithRed:8/255.0 green:111/255.0 blue:152/255.0 alpha:1.0]];
    

    self.kvStore = [NSUbiquitousKeyValueStore defaultStore];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBookmarks:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:self.kvStore];
    [self.kvStore synchronize];
    
    DefaultSHKConfigurator *configurator = [[ISSHKConfigurator alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

//    [[LocalyticsSession sharedLocalyticsSession] close];
//    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    [[LocalyticsSession sharedLocalyticsSession] close];
//    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    [[LocalyticsSession sharedLocalyticsSession] resume];
//    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [[LocalyticsSession sharedLocalyticsSession] resume];
//    [[LocalyticsSession sharedLocalyticsSession] upload];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
//    [[LocalyticsSession sharedLocalyticsSession] close];
//    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    [self saveContext];
    [self.kvStore synchronize];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"IRSOT_Seminars" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"IRSOT_Seminars.sqlite"];
    

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */

//        If you encounter schema incompatibility errors during development, you can reduce their frequency by:
//        * Simply deleting the existing store:
//        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)lectorCacheDirectory
{
    NSURL *path = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:LECTOR_PICS_DIR isDirectory:YES];
    // need to create cache directory for lector's pics
    BOOL cachePicsDirExists = [[NSFileManager defaultManager] fileExistsAtPath:[path path]];
    
    if (!cachePicsDirExists) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtURL:path withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) NSLog(@"Error creating directory: %@", [error.userInfo objectForKey:NSUnderlyingErrorKey]);
    }
    
    return path;
}

#pragma mark - cache CSS files
- (NSURL *)bkCSS
{
    NSURL *bkCSSPath = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[RUSEMINAR_BK_CSS lastPathComponent]];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[bkCSSPath path]];
    if (!exists) {
        dispatch_queue_t fetchQ = dispatch_queue_create("Seminar fetcher", NULL);
        dispatch_async(fetchQ, ^{
            NSData *data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: RUSEMINAR_BK_CSS]];
            [data writeToURL:bkCSSPath atomically:YES];
        });
        dispatch_release(fetchQ);
    }
    return bkCSSPath;
}

- (NSURL *)seminarCSS
{
    NSURL *seminarCSSPath = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[RUSEMINAR_SEMINAR_CSS lastPathComponent]];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[seminarCSSPath path]];
    if (!exists) {
        dispatch_queue_t fetchQ = dispatch_queue_create("Seminar fetcher", NULL);
        dispatch_async(fetchQ, ^{

            NSData *data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: RUSEMINAR_SEMINAR_CSS]];
            [data writeToURL:seminarCSSPath atomically:YES];
        });
        dispatch_release(fetchQ);
    }
    return seminarCSSPath;
}

#pragma mark - updateBookmarks
- (void)updateBookmarks:(NSNotification *)notification
{
//    NSDictionary *userInfo = [notification userInfo];
//    NSNumber *reasonForChange = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
//    int reason = [reasonForChange integerValue];
//    if ((reason == NSUbiquitousKeyValueStoreServerChange) || (reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
//        NSArray *changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
//        
//    }
}

@end
