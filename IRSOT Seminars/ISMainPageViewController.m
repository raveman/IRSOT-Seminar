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

#import "ISAppDelegate.h"
#import "ISMainPageViewController.h"
#import "ISSeminarListTableViewController.h"
#import "ISSettingsViewController.h"

#import "Sections.h"
#import "Type+Load_Data.h"

#define CACHE_NAME @"Master"

@interface ISMainPageViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, ISSettingsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;

@end

@implementation ISMainPageViewController
@synthesize noDataLabel = _noDataLabel;
@synthesize seminarCategoriesTableView = _seminarCategoriesTableView;

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - getters and setters

#pragma mark - UIViewController lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.managedObjectContext = [[ISAppDelegate sharedDelegate] managedObjectContext];
    
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.28 green:0.66 blue:0.79 alpha:1.0];
	
    // setting categories list tableview datasource and delegate
    self.seminarCategoriesTableView.dataSource = self;
    self.seminarCategoriesTableView.delegate = self;

    self.title = NSLocalizedString(@"Семинары ИРСОТ", @"Main Page Title");
    
    self.noDataLabel.shadowColor = [UIColor grayColor];
    self.noDataLabel.shadowOffset = CGSizeMake(1,-1);
    self.noDataLabel.font = [UIFont boldSystemFontOfSize:28.0];
    self.noDataLabel.textColor = [UIColor whiteColor];
    
    UIBarButtonItem *setupButton = self.navigationItem.rightBarButtonItem;
    setupButton.image = [UIImage imageNamed:@"gear-iPhone.png"];
    setupButton.title = @"";
    
    self.seminarCategoriesTableView.backgroundColor = [UIColor clearColor];
    self.seminarCategoriesTableView.opaque = NO;
    self.seminarCategoriesTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"light-hash-background.png"]];
}

- (void)viewDidUnload
{
   
    [self setSeminarCategoriesTableView:nil];
    [self setNoDataLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSInteger count = [[self.fetchedResultsController fetchedObjects] count];
    if (!count) {
        // у нас нет еще никаких данных, надо бы их загрузить
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Данные" message:@"У нас нет еще загруженных семинаров" delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Загрузить", nil];
        [alert show];
    } else {
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
        if (indexPath.section == 0) {
            Sections *section = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            [segue.destinationViewController setSection:section];
            [segue.destinationViewController setManagedObjectContext:self.managedObjectContext];
        } else {
            Type *type = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            [segue.destinationViewController setType:type];
            [segue.destinationViewController setManagedObjectContext:self.managedObjectContext];
        }
    }
    
    if ([[segue identifier] isEqualToString:@"Settings"]) {
        ISSettingsViewController *dvc = (ISSettingsViewController *)[segue destinationViewController];
        if (![self.fetchedResultsController.fetchedObjects count]) {
            dvc.emptyStore = NO;
        } else {
            dvc.emptyStore = YES;
        }
        [dvc setManagedObjectContext:self.managedObjectContext];
        [dvc setDelegate:self];
    }
}

#pragma mark - UITableView dataSource and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger count = 0;
    
    if ([[self.fetchedResultsController fetchedObjects] count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
       count = [sectionInfo numberOfObjects];
//        if (section == SEMINAR_TYPE_SEMINAR_BK) {
//            count = [sectionInfo numberOfObjects];
//        } else {
//            count = [sectionInfo numberOfObjects] - 2;
//        }
        
        self.noDataLabel.hidden = YES;
    } else {
        self.noDataLabel.hidden = NO;
        self.noDataLabel.text = NSLocalizedString(@"Нет данных", @"Main Page Categories list no data");
    }
        
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Education Types Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // Configure the cell...
    if ([[self.fetchedResultsController fetchedObjects] count]) {
        Sections *section = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSString *sectionName = [[[section.name substringToIndex:1] uppercaseString] stringByAppendingString:[section.name substringFromIndex:1]];
        
        cell.textLabel.text = sectionName;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self.fetchedResultsController fetchedObjects]) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            Sections *section = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            self.detailViewController.section = section;
        }
    }
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
        self.fetchedResultsController = nil;
        [self.seminarCategoriesTableView reloadData];
    }
}

- (void) settingsViewController:(ISSettingsViewController *)sender didUpdatedStore:(BOOL)updated
{
    if (updated) {
        [self.seminarCategoriesTableView reloadData];
    }
}

@end
