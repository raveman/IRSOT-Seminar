//
//  ISAppDelegate.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 01.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LECTOR_PICS_DIR @"Lector Pics"

@interface ISAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSUbiquitousKeyValueStore *kvStore;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)lectorCacheDirectory;
//- (NSURL *)bkCSS;
- (NSURL *)bkCSSURL;
//- (NSURL *)seminarCSS;
- (NSURL *)seminarCSSURL;
//- (NSURL *)myCSS;
- (NSURL *)myCSSURL;

- (NSArray *)ruseminarCSSFilesURLs;
- (NSArray *)ruseminarCSSFilesData;

+ (ISAppDelegate *)sharedDelegate;

@end
