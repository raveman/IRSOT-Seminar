//
//  ISCalendarViewController.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 21.08.12.
//  Copyright (c) 2012 IRSOT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface ISCalendarViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
