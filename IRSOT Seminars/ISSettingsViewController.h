//
//  ISSettingsViewController.h
//  Seminar.Ru
//
//  Created by Bob Ershov on 01.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SORT_KEY @"SeminarList.Sort"
#define UPDATE_DATE_KEY @"UpdateDate"

@class ISSettingsViewController;

@protocol ISSettingsViewControllerDelegate <NSObject>

- (void) settingsViewController:(ISSettingsViewController *)sender didDeletedStore: (BOOL) deleted;
- (void) settingsViewController:(ISSettingsViewController *)sender didUpdatedStore: (BOOL) updated;

@end


@interface ISSettingsViewController : UIViewController
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) BOOL emptyStore;

@property (nonatomic, weak) id <ISSettingsViewControllerDelegate> delegate;
 
@end
