//
//  ISLectorListTableViewController.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 08.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//
// TODO: fix index titles
#import "SVProgressHUD/SVProgressHUD.h"

#import "ISAppDelegate.h"
#import "ISLectorListTableViewController.h"
#import "ISLectorViewController.h"

#import "Lector+Load_Data.h"

#define CACHE_NAME @"lectors.cache"

@interface ISLectorListTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ISLectorListTableViewController
@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.managedObjectContext = [[ISAppDelegate sharedDelegate] managedObjectContext];
    self.title = NSLocalizedString(@"Лекторы", @"Lector List View Title");

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(seminarDataChanged:) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:nil];
}

- (void)viewDidUnload
{

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Lector View"]) {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        Lector *lector = [self.fetchedResultsController objectAtIndexPath:indexPath];
        ISLectorViewController *dvc = (ISLectorViewController *) segue.destinationViewController;
        [dvc setLector:lector];
    }
}

#pragma mark - Notification handlers
- (void) seminarDataChanged:(NSNotification *)notification
{
    //    notification.name;
    //    notification.object;
    //    notification.userInfo;
    
    if ([notification.userInfo objectForKey:NSRemovedPersistentStoresKey]) {
        self.fetchedResultsController = nil;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    NSInteger count = 
//    
//    if (!count) count = 1;
    
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    if ([[self.fetchedResultsController fetchedObjects] count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        count = [sectionInfo numberOfObjects];
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Lector Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    if ([[self.fetchedResultsController fetchedObjects] count]) {
        Lector *lector = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.textLabel.text = lector.name;
        } else {
            cell.textLabel.text = [lector fullName];
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Семинаров: %d", [lector.seminars count] ];
    }
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSArray *sectionIndexTitleLetters = [self.fetchedResultsController sectionIndexTitles];
    return sectionIndexTitleLetters;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger newIndex = [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];

    return newIndex;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Lector" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject: sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"lectorNameInitial" cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // TODO: handle error!
        NSString *errorMessage = [NSString stringWithFormat:@"Unresolved error %@, %@", error, [error userInfo]];
        [SVProgressHUD showErrorWithStatus:errorMessage];
	    NSLog(@"%@", errorMessage);
        
//	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{

    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
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
//    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView endUpdates];
//}

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName
{
    return sectionName;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"name"] description];
}


@end
