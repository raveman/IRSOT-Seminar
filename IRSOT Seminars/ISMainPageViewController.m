//
//  ISMainPageViewController.m
//  Seminar.Ru
//
//  Created by Bob Ershov on 28.07.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

// зеленыйц R: 73, G: 168, B: 201
// оранжевый R: 208, G: 126, B: 73
//
#import <QuartzCore/QuartzCore.h>

#import "ISAppDelegate.h"
#import "ISMainPageViewController.h"
#import "ISSeminarListTableViewController.h"
#import "ISSettingsViewController.h"

#import "SeminarFetcher.h"

#import "Type+Load_Data.h"
#import "Sections+Load_Data.h"

#import "Helper.h"
#import "ADVTheme.h"

#define CACHE_NAME @"Master"

const NSInteger allTypesSection = 0;

@interface ISMainPageViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, ISSettingsViewControllerDelegate> {
    BOOL checkUpdates;
    int count;
}

@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;
@property (nonatomic, strong) UIColor *selectedCellBGColor;
@property (nonatomic, strong) UIColor *notSelectedCellBGColor;

@property (nonatomic, strong) UITableViewCell *currentSelectedCell;
@property (nonatomic) NSInteger changedTime;

@end

@implementation ISMainPageViewController
@synthesize noDataLabel = _noDataLabel;
@synthesize seminarCategoriesTableView = _seminarCategoriesTableView;

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;

@synthesize currentSelectedCell = _currentSelectedCell;
@synthesize changedTime = _changedTime;


#pragma mark - UIViewController lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    
    self.managedObjectContext = [[ISAppDelegate sharedDelegate] managedObjectContext];
    
    // setting categories list tableview datasource and delegate
    self.seminarCategoriesTableView.dataSource = self;
    self.seminarCategoriesTableView.delegate = self;
    self.seminarCategoriesTableView.backgroundColor = [UIColor clearColor];
    self.seminarCategoriesTableView.opaque = NO;
    self.seminarCategoriesTableView.backgroundView = [[UIImageView alloc]initWithImage:[theme viewBackground]];
    
    self.title =  NSLocalizedString(@"Catalog", @"Main Page Title");
    
    self.noDataLabel.shadowColor = [UIColor grayColor];
    self.noDataLabel.shadowOffset = CGSizeMake(0,-1);
    self.noDataLabel.font = [UIFont boldSystemFontOfSize:28.0];
    self.noDataLabel.textColor = [UIColor whiteColor];
    self.noDataLabel.text = NSLocalizedString(@"No data", @"Main Page Categories list no data");
    
    UIBarButtonItem *setupButton = self.navigationItem.rightBarButtonItem;
    setupButton.image = [UIImage imageNamed:@"gear-iPhone"];
    setupButton.title = @"";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(seminarDataChanged:) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(seminarDataChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];

    count = [[self.fetchedResultsController fetchedObjects] count];
    if (!count) {
    } else {
        checkUpdates = YES;
        [self checkUpdates];
    }
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];  
    [self setSeminarCategoriesTableView:nil];
    [self setNoDataLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    count = [[self.fetchedResultsController fetchedObjects] count];
    if (!count) {
        // у нас нет еще никаких данных, надо бы их загрузить
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Catalog", @"Catalog") message:NSLocalizedString(@"No downloaded seminars", @"No downloaded data") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Download", @"Download"), nil];
        [alert show];
        checkUpdates = NO;
        self.noDataLabel.hidden = NO;
    } else {
        self.noDataLabel.hidden = YES;
        // deselecting previous selected row
        NSIndexPath *indexPath = [self.seminarCategoriesTableView indexPathForSelectedRow];
        if (indexPath != nil) {
            [self.seminarCategoriesTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
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
    if ([[segue identifier] isEqualToString:@"Seminar List For Section or Type"]) {
        NSIndexPath *indexPath = [self.seminarCategoriesTableView indexPathForSelectedRow];
        ISSeminarListTableViewController *dvc = [segue destinationViewController];
        if (indexPath.section == allTypesSection) {
            [dvc setManagedObjectContext:self.managedObjectContext];
        }
        if (indexPath.section == 1) {
            NSIndexPath *adjustedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
            Sections *section = [[self fetchedResultsController] objectAtIndexPath:adjustedIndexPath];
            [dvc setSection:section];
            [dvc setManagedObjectContext:self.managedObjectContext];
        } else if (indexPath.section == 2){
            NSIndexPath *adjustedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
            Type *type = [[self fetchedResultsController] objectAtIndexPath:adjustedIndexPath];
            [dvc setType:type];
            [dvc setManagedObjectContext:self.managedObjectContext];
        }
    }
    
    if ([[segue identifier] isEqualToString:@"Settings"]) {
        UINavigationController *dnc = (UINavigationController *)[segue destinationViewController];
        ISSettingsViewController *dvc = (ISSettingsViewController *) dnc.topViewController;
        if (![self.fetchedResultsController.fetchedObjects count]) {
            dvc.emptyStore = NO;
        } else {
            dvc.emptyStore = YES;
        }
        [dvc setManagedObjectContext:self.managedObjectContext];
        [dvc setDelegate:self];
        [dvc setChangedTime:self.changedTime];
    }
}

#pragma mark - UITableView dataSource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSInteger rowsInSection = 0;

    if (section == allTypesSection) {
        rowsInSection = 1;
    } else {
        // Return the number of rows in the section.
        
        if ([[self.fetchedResultsController fetchedObjects] count]) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section-1];
            rowsInSection = [sectionInfo numberOfObjects];
            self.noDataLabel.hidden = YES;
        } else {
            self.noDataLabel.hidden = NO;
            self.noDataLabel.text = NSLocalizedString(@"No data in catalog", @"Main Page Categories list no data");
        }
    }
    
    return rowsInSection;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.fetchedResultsController fetchedObjects]) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            Sections *section = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            self.detailViewController.section = section;
        }
        [self performSegueWithIdentifier:@"Seminar List For Section or Type" sender:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Education Types Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
//    if (cell == nil) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
    cell.selectionStyle = [Helper cellSelectionStyle];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [Helper cellMainFont];

    if (indexPath.section == allTypesSection) {
        cell.textLabel.text = NSLocalizedString(@"All event types", @"All event types");
    } else {
        if ([[self.fetchedResultsController fetchedObjects] count]) {
            NSIndexPath *adjustedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
            Sections *section = [self.fetchedResultsController objectAtIndexPath:adjustedIndexPath];
            NSString *sectionName = [[[section.name substringToIndex:1] uppercaseString] stringByAppendingString:[section.name substringFromIndex:1]];
            
            cell.textLabel.text = sectionName;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    NSString *title = [NSString string];
    switch (section) {
        case allTypesSection:
            title = @"";
            break;
        case 1:
            title = NSLocalizedString(@"Sections", @"Main Page Section Title");
            break;
        case 2:
            title = NSLocalizedString(@"Formats", @"Main Page Type Title");
            break;
        default:
            break;
    }
    
    return title;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    // Fetching "meta" entity Term, because we need in Sections and Types simultaneously.
    // Section and Type are derived from Term
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Term" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Sort keys: we have two: first - by vid, second by name.
    NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"vid" ascending:NO],
                                 [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"vid" cacheName:CACHE_NAME];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.seminarCategoriesTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.seminarCategoriesTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.seminarCategoriesTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.seminarCategoriesTableView;
    
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
    [self.seminarCategoriesTableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"name"] description];
}

#pragma mark - UIAlerViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"Settings" sender:self];
    }
    // в buttonIndex содержится номер кнопки
}

#pragma mark - ISSettingsViewControllerDelegate
- (void) settingsViewController:(ISSettingsViewController *)sender didDeletedStore:(BOOL)deleted
{
    if (deleted) {
        self.noDataLabel.hidden = NO;
        self.fetchedResultsController = nil;
        [self.seminarCategoriesTableView reloadData];
    }
}

- (void) settingsViewController:(ISSettingsViewController *)sender didUpdatedStore:(BOOL)updated
{
    if (updated) {
        [self.seminarCategoriesTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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

    [self.seminarCategoriesTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
//    [self.view performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
//    [self.view setNeedsDisplay];
}

#pragma mark - check for updates
- (void) checkUpdates
{
    if (checkUpdates) {
        dispatch_queue_t checkQ = dispatch_queue_create("Update Checker", NULL);
        dispatch_async(checkQ, ^{
            NSInteger changeTime = [SeminarFetcher checkUpdates];
            if (changeTime) {
                checkUpdates = NO;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSInteger savedChangeTime = [[defaults objectForKey:CATALOG_CHANGED_KEY] integerValue];
                if (savedChangeTime < changeTime) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.changedTime = changeTime;
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Catalog", @"Catalog") message:NSLocalizedString(@"There are catalog updates. Download ?", @"There are updates message")  delegate:self cancelButtonTitle:NSLocalizedString(@"Not now", @"Not now button") otherButtonTitles:NSLocalizedString(@"Download", @"Download button"), nil];
                        [alert show];
                    });
                }
            }
        });
        dispatch_release(checkQ);
    }
}

- (void) reloadData
{
    [self.seminarCategoriesTableView reloadData];
}

@end
