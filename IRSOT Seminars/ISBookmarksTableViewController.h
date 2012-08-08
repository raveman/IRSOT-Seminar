//
//  ISBookmarksTableViewController.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 04.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISBookmarksTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
