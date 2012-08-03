//
//  ISSeminarListTableViewController.m
//  Seminar.Ru
//
//  Created by Bob Ershov on 28.07.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#define CACHE_NAME_SEMINAR @"Seminar List"
#define CACHE_NAME_BK @"BK List"

#import "ISSeminarListTableViewController.h"
#import "ISSeminarViewController.h"

#import "Seminar+Load_Data.h"
#import "Type+Load_Data.h"
#import "Lector.h"

@interface ISSeminarListTableViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *seminarTypeSwitch;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation ISSeminarListTableViewController
@synthesize seminarTypeSwitch = _seminarTypeSwitch;
@synthesize searchBar = _searchBar;
@synthesize section = _section;

@synthesize currentFetchedResultsController = _fetchedResultsController;
@synthesize seminarFetchedResultsController = _seminarFetchedResultsController;
@synthesize bkFetchedResultsController = _bkFetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentFetchedResultsController = self.seminarFetchedResultsController;
    
}

- (void)viewDidUnload
{
    [self setSeminarTypeSwitch:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [NSFetchedResultsController deleteCacheWithName:CACHE_NAME_SEMINAR];
    [NSFetchedResultsController deleteCacheWithName:CACHE_NAME_BK];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Seminar View"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Seminar *seminar = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [segue.destinationViewController setSeminar:seminar];
        [segue.destinationViewController setManagedObjectContext:self.managedObjectContext];
    }
}

#pragma mark - UISegmentedControl
- (IBAction)seminarTypeChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.currentFetchedResultsController = self.seminarFetchedResultsController;
            [self.tableView reloadData];
            break;
        case 1:
            self.currentFetchedResultsController = self.bkFetchedResultsController;
            [self.tableView reloadData];
            break;
        default:
            break;
    }    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
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
    static NSString *CellIdentifier = @"SeminarList cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if ([[self.fetchedResultsController fetchedObjects] count]) {
        Seminar *seminar = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = seminar.name;
        cell.detailTextLabel.text = [seminar stringWithLectorNames];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Seminar" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"section.id == %@", self.section.id];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.currentFetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.currentFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (NSFetchedResultsController *)seminarFetchedResultsController
{
    if (_seminarFetchedResultsController != nil) {
        return _seminarFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Seminar" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"section.id == %@ AND type.id == %d", self.section.id, SEMINAR_TYPE_SEMINAR];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:CACHE_NAME_SEMINAR];
    aFetchedResultsController.delegate = self;
    self.seminarFetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.seminarFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _seminarFetchedResultsController;
}
- (NSFetchedResultsController *)bkFetchedResultsController
{
    if (_bkFetchedResultsController != nil) {
        return _bkFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Seminar" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"section.id == %@ AND type.id == %d", self.section.id, SEMINAR_TYPE_BK];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:CACHE_NAME_BK];
    aFetchedResultsController.delegate = self;
    self.bkFetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.bkFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _bkFetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == self.currentFetchedResultsController) {
        [self.tableView beginUpdates];
    }
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
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"name"] description];
}


@end
