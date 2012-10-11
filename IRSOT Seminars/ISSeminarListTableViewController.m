//
//  ISSeminarListTableViewController.m
//  Seminar.Ru
//
//  Created by Bob Ershov on 28.07.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "ISAppDelegate.h"
#import "ISSeminarListTableViewController.h"
#import "ISSeminarViewController.h"

#import "Seminar+Load_Data.h"
#import "Type+Load_Data.h"
#import "Lector.h"
#import "ISSettingsViewController.h"

//#define CACHE_NAME_SEMINAR @"Seminar List"
//#define CACHE_NAME_BK @"BK List"
#define CACHE_NAME_SEMINAR nil
#define CACHE_NAME_BK nil

@interface ISSeminarListTableViewController () <UISearchBarDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *seminarTypeSwitch;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic) NSInteger currentSeminarType;
@property (nonatomic) BOOL searchIsActive;

@property (nonatomic) BOOL sortByDate;

@end

@implementation ISSeminarListTableViewController
@synthesize seminarTypeSwitch = _seminarTypeSwitch;
@synthesize searchBar = _searchBar;
@synthesize searchResults = _searchResults;
@synthesize currentSeminarType = _currentSeminarType;

@synthesize section = _section;
@synthesize type = _type;

@synthesize fetchedResultsController = _fetchedResultsController;

@synthesize searchIsActive = _searchIsActive;
@synthesize sortByDate = _sortByDate;

- (NSInteger)currentSeminarType
{
    _currentSeminarType = [self.seminarTypeSwitch selectedSegmentIndex];
    if (self.section) {
        if (_currentSeminarType) _currentSeminarType = SEMINAR_TYPE_BK;
        else _currentSeminarType = SEMINAR_TYPE_SEMINAR;
    } else {
        _currentSeminarType = [self.type.id integerValue];
    }

    return _currentSeminarType;
}

- (BOOL) sortByDate
{
    if (!_sortByDate) _sortByDate = [[[NSUserDefaults standardUserDefaults] objectForKey:SORT_KEY] boolValue];
    
    return _sortByDate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.managedObjectContext = [[ISAppDelegate sharedDelegate] managedObjectContext];
    
    self.searchDisplayController.searchBar.delegate = self;
    self.searchDisplayController.searchBar.backgroundColor = [UIColor clearColor];
    
    // if we have no arrived section we need to hide seminar type switch
    // and set currentSeminarType
    self.title = self.section.name;
    
    if (!self.section) {
//         self.seminarTypeSwitch.hidden = YES;
        [self.seminarTypeSwitch removeAllSegments];
        [self.seminarTypeSwitch insertSegmentWithTitle:self.type.name atIndex:0 animated:YES];
        self.seminarTypeSwitch.momentary = YES;
        self.title = self.type.name;
    }
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
// don't need to delete caches, we do not support them now
//    [NSFetchedResultsController deleteCacheWithName:CACHE_NAME_SEMINAR];
//    [NSFetchedResultsController deleteCacheWithName:CACHE_NAME_BK];
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
    if ([segue.identifier isEqualToString:@"Seminar View"]) {
        NSIndexPath *indexPath = nil;
        if ([sender isKindOfClass:[NSIndexPath class]]) {
            indexPath = sender;
        } else {
            indexPath = [self.tableView indexPathForCell:sender];
        }
        Seminar *seminar = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [segue.destinationViewController setSeminar:seminar];
        [segue.destinationViewController setManagedObjectContext:self.managedObjectContext];
    }
}

#pragma mark - UISegmentedControl
- (IBAction)seminarTypeChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
//            self.currentFetchedResultsController = self.seminarFetchedResultsController;
            self.fetchedResultsController = nil;
            [self.tableView reloadData];
            break;
        case 1:
            self.fetchedResultsController = nil;
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
    NSInteger count = [[self.fetchedResultsController sections] count];
    if (!count) count = 1;
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    NSString *title = [NSString string];
    if (!self.searchIsActive) {
        NSArray *sections = [self.fetchedResultsController sections];
        if ([sections count]) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
            NSArray *objects = [sectionInfo objects];
            Seminar *seminar = nil;
            if ([objects count]) seminar = [objects objectAtIndex:section];
            title = seminar.section.name;
        }
    }
    return  title;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (!self.searchIsActive) {
        if (!self.section) {
            NSMutableArray *sectionIndexTitleLetters = [NSMutableArray array];
            NSArray *sections = [self.fetchedResultsController sections];
            int count = [sections count];
            if (count) {
                for (int i=0; i < count; i++) {
                    id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:i];
                    NSArray *objects = [sectionInfo objects];
                    Seminar *seminar = nil;
                    if ([objects count]) seminar = [objects objectAtIndex:i];
                    [sectionIndexTitleLetters addObject: [seminar.section.name substringToIndex:1]];
                }
            }
            return sectionIndexTitleLetters;
        }
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 1;
    
    if ([[self.fetchedResultsController fetchedObjects] count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        count = [sectionInfo numberOfObjects];
    } else {
        if (self.searchIsActive) count = 0;
    }
    
    return count;
}

- (NSString *)truncateLectorNames:(NSString *)lectors
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([lectors length] > 35) {
            lectors = [lectors substringToIndex:35];
            lectors = [lectors stringByAppendingString:@"…"];
        }
    } else {
        if ([lectors length] > 100) {
            lectors = [lectors substringToIndex:100];
            lectors = [lectors stringByAppendingString:@"…"];
        }
    }
    
    return lectors;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SeminarList cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue Medium" size:15.0];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:13.0];
//    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (tableView == self.tableView) {
        // Configure the cell...
        if ([[self.fetchedResultsController fetchedObjects] count]) {
            Seminar *seminar = [self.fetchedResultsController objectAtIndexPath:indexPath];
            cell.textLabel.text = seminar.name;
            
            NSString *lectors = [seminar stringWithLectorNames];
            lectors = [self truncateLectorNames:lectors];
            
            cell.detailTextLabel.text =[NSString stringWithFormat:@"%@\n%@", lectors, [seminar stringWithSeminarDates]];
            cell.detailTextLabel.numberOfLines = 2;
            cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue Medium" size:15.0];
            cell.textLabel.text = NSLocalizedString(@"Нет мероприятий", @"No seminars");
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.text = @"";
        }
    } else {
        if ([[self.fetchedResultsController fetchedObjects] count]) {
            Seminar *seminar = [self.fetchedResultsController objectAtIndexPath:indexPath];
            cell.textLabel.text = seminar.name;
            
            NSString *lectors = [seminar stringWithLectorNames];
            lectors = [self truncateLectorNames:lectors];
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", lectors, [seminar stringWithSeminarDates]];
            cell.detailTextLabel.numberOfLines = 2;
            cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int numberOfRows = 3;

    return (40.0 + (numberOfRows - 1) * 15.0);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"Seminar View" sender:indexPath];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Seminar" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    if (self.section) {

        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"section.id == %d AND type.id == %d", [self.section.id integerValue], self.currentSeminarType];
    } else {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type.id == %d", self.currentSeminarType];
    }
    
//    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject: nameSortDescriptor];
    if (self.sortByDate) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date_start" ascending:YES];
        [sortDescriptors insertObject:sortDescriptor atIndex:0];
    }

    NSString *sectionNameKeyPath = [NSString string];
    if (self.section) {
        sectionNameKeyPath = nil;
    } else {
        NSSortDescriptor *sectionSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
        [sortDescriptors insertObject:sectionSortDescriptor atIndex:0];
        sectionNameKeyPath = @"section";
    }

    [fetchRequest setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // TODO: handle error!
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if ([self searchIsActive]) {
        [[[self searchDisplayController] searchResultsTableView] beginUpdates];
    }
    else  {
        if (controller == self.fetchedResultsController) {
            [self.tableView beginUpdates];
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([self searchIsActive]) {
        [[[self searchDisplayController] searchResultsTableView] endUpdates];
    }
    else  {
        [self.tableView endUpdates];
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

//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView endUpdates];
//}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"name"] description];
}

#pragma mark - Content filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSFetchRequest *aRequest = [[self fetchedResultsController] fetchRequest];

    if (self.section) {
        aRequest.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ AND section.id == %d AND type.id == %d", searchText, [self.section.id integerValue] , self.currentSeminarType];
    } else {
        aRequest.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ AND type.id == %d", searchText,  self.currentSeminarType];
    }
  
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [aRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - UISearch Delegates

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:nil];
    
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.fetchedResultsController = nil;
    [self fetchedResultsController];
    
    [self setSearchIsActive:NO];
    return;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [self setSearchIsActive:YES];
    return;
}

@end
