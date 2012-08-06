//
//  ISSeminarListTableViewController.h
//  Seminar.Ru
//
//  Created by Bob Ershov on 28.07.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Sections.h"

@interface ISSeminarListTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) Sections *section;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
