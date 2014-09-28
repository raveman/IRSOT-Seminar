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
#import "Section+Load_Data.h"
#import "AllEvents.h"

#import "Helper.h"
#import "ISTheme.h"

#define CACHE_NAME @"Master"

static const NSUInteger ALL_TYPES_SECTION = 0;
static const NSUInteger SECTIONS_SECTION = 1;
static const NSUInteger TYPES_SECTION = 2;

@interface ISMainPageViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, ISSettingsViewControllerDelegate>
{
    BOOL checkUpdates;
    NSUInteger count;
}

@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;

@property (nonatomic, strong) UITableViewCell *currentSelectedCell;
@property (nonatomic) NSInteger changedTime;
@property (nonatomic) NSUInteger emptyCount;
@property (nonatomic, strong) NSArray *filteredTypeItems;

@end

@implementation ISMainPageViewController
@synthesize noDataLabel = _noDataLabel;
@synthesize seminarCategoriesTableView = _seminarCategoriesTableView;

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;

@synthesize currentSelectedCell = _currentSelectedCell;
@synthesize changedTime = _changedTime;
@synthesize emptyCount = _emptyCount;
@synthesize filteredTypeItems = _filteredTypeItems;

#pragma mark - Class methods 

- (void) filterEpmtySections
{
   if ([self.fetchedResultsController.sections count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:TYPES_SECTION];
        NSArray *items = sectionInfo.objects;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"seminars.@count > 0", @"Type"];
        NSArray *filteredItems = [items filteredArrayUsingPredicate:predicate];
        
        self.emptyCount = [items count] - [filteredItems count];
        self.filteredTypeItems = filteredItems;
    }
}

#pragma mark - UIViewController lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.managedObjectContext = [[ISAppDelegate sharedDelegate] managedObjectContext];
    
    // setting categories list tableview datasource and delegate
    self.seminarCategoriesTableView.dataSource = self;
    self.seminarCategoriesTableView.delegate = self;

    self.navigationItem.title =  NSLocalizedString(@"IRSOT Seminars", @"Main Page Title");
    
    self.noDataLabel.shadowColor = [UIColor grayColor];
    self.noDataLabel.shadowOffset = CGSizeMake(0,-1);
    self.noDataLabel.font = [UIFont boldSystemFontOfSize:28.0];
    self.noDataLabel.textColor = [UIColor whiteColor];
    self.noDataLabel.text = NSLocalizedString(@"No data", @"Main Page Categories list no data");
    
    UIBarButtonItem *setupButton = self.navigationItem.rightBarButtonItem;
    setupButton.image = [UIImage imageNamed:@"gear-iPhone"];
    setupButton.title = @" ";
    setupButton.tintColor = [ISTheme barButtonItemColor];
    
//    [Helper fixBarButtonItemForiOS7:setupButton];

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
        [self.seminarCategoriesTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

        self.noDataLabel.hidden = YES;
        // deselecting previous selected row;
//        NSIndexPath *indexPath = [self.seminarCategoriesTableView indexPathForSelectedRow];
//        if (indexPath != nil) {
//            [self.seminarCategoriesTableView deselectRowAtIndexPath:indexPath animated:YES];
//        }
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
        NSIndexPath *selectedIndexPath = [self.seminarCategoriesTableView indexPathForSelectedRow];
        ISSeminarListTableViewController *dvc = [segue destinationViewController];
        if (selectedIndexPath.section == ALL_TYPES_SECTION) {
            [dvc setManagedObjectContext:self.managedObjectContext];
        }
        if (selectedIndexPath.section == SECTIONS_SECTION) {
            Sections *section = [[self fetchedResultsController] objectAtIndexPath:selectedIndexPath];
            [dvc setSection:section];
            [dvc setManagedObjectContext:self.managedObjectContext];
        } else if (selectedIndexPath.section == TYPES_SECTION){
            Type *type = [self.filteredTypeItems objectAtIndex:selectedIndexPath.row];
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
    NSInteger sections = [[self.fetchedResultsController sections] count];

    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsInSection = 0;
    
    if ([[self.fetchedResultsController fetchedObjects] count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        rowsInSection = [sectionInfo numberOfObjects];
        if (section == TYPES_SECTION) {
            rowsInSection = rowsInSection - self.emptyCount;
        }
        self.noDataLabel.hidden = YES;
    } else {
        self.noDataLabel.hidden = NO;
        self.noDataLabel.text = NSLocalizedString(@"No data in catalog", @"Main Page Categories list no data");
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = [Helper cellSelectionStyle];
    UIImage *accessoryImage = [UIImage imageNamed:@"accessoryArrow"];
    cell.accessoryView = [[UIImageView alloc] initWithImage:accessoryImage];
    cell.textLabel.font = [Helper cellMainFont];
    
    if ([[self.fetchedResultsController fetchedObjects] count]) {
        id row;
        if (indexPath.section == TYPES_SECTION) {
            row = [self.filteredTypeItems objectAtIndex:indexPath.row];
        } else {
            row = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        
        NSUInteger seminarsCount = 0;
        NSString *sectionName;
        
        if ([row isKindOfClass:[Section class]]) {
            seminarsCount = [[(Section *)row seminars] count];
            sectionName = [(Section *)row name];
        } else if ([row isKindOfClass:[Type class]]) {
            seminarsCount = [[(Type *)row seminars] count];
            sectionName = [(Type *)row name];
        } else if ([row isKindOfClass:[AllEvents class]]) {
            seminarsCount = [[(AllEvents *)row seminars] count];
            sectionName = [(AllEvents *)row name];
        }
        
        sectionName = [[[sectionName substringToIndex:1] uppercaseString] stringByAppendingString:[sectionName substringFromIndex:1]];

        if (seminarsCount) {
            cell.textLabel.text = sectionName;
            if ([sectionName isEqualToString:@"Все мероприятия"]) {
                cell.imageView.image = [UIImage imageNamed:@"calendar"];
            } else if ([sectionName isEqualToString:@"Бухгалтерский учет"]) {
                cell.imageView.image = [UIImage imageNamed:@"accounting"];
            } else if ([sectionName isEqualToString:@"Кадры"]) {
                cell.imageView.image = [UIImage imageNamed:@"hr"];
            } else if ([sectionName isEqualToString:@"Право"]) {
                cell.imageView.image = [UIImage imageNamed:@"law"];
            } else if ([sectionName isEqualToString:@"Управление"]) {
                cell.imageView.image = [UIImage imageNamed:@"management"];
            } else if ([sectionName isEqualToString:@"Финансы"]) {
                cell.imageView.image = [UIImage imageNamed:@"finance"];
            } else if ([sectionName isEqualToString:@"Бизнес-класс"]) {
                cell.imageView.image = [UIImage imageNamed:@"business_class"];
            } else if ([sectionName isEqualToString:@"Семинар"]) {
                cell.imageView.image = [UIImage imageNamed:@"seminar"];
            } else if ([sectionName isEqualToString:@"Мастер-класс"]) {
                cell.imageView.image = [UIImage imageNamed:@"master_class"];
            } else if ([sectionName isEqualToString:@"Неделя бухучета"]) {
                cell.imageView.image = [UIImage imageNamed:@"nbu"];
            } else if ([sectionName isEqualToString:@"Курс"]) {
                cell.imageView.image = [UIImage imageNamed:@"course"];
            } else if ([sectionName isEqualToString:@"Тематическая неделя"]) {
                cell.imageView.image = [UIImage imageNamed:@"lecturer"];
            } else if ([sectionName isEqualToString:@"Конференция"]) {
                cell.imageView.image = [UIImage imageNamed:@"conference"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"seminar"];
            }
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = [NSString string];
    switch (section) {
        case 0:
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

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, SECTION_HEADER_HEIGHT)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    [headerView addSubview:[ISTheme sectionLabelInTableView:tableView forSection:section andMargin:0]];
    
    return headerView;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Term" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    fetchRequest.fetchBatchSize = 20;
    
    NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:SEMINAR_TERM_VID ascending:NO],
                                 [NSSortDescriptor sortDescriptorWithKey:SEMINAR_TERM_NAME ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:SEMINAR_TERM_VID cacheName:CACHE_NAME];
    aFetchedResultsController.delegate = self;
    _fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}

    [self filterEpmtySections];
    
    return _fetchedResultsController;
}

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.seminarCategoriesTableView beginUpdates];
//}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{

    switch(type) {
        case NSFetchedResultsChangeInsert:
//            [self.seminarCategoriesTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
//            [self.seminarCategoriesTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
//    UITableView *tableView = self.seminarCategoriesTableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.seminarCategoriesTableView endUpdates];
//}

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
        self.fetchedResultsController = nil;
//        [self.seminarCategoriesTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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

//    [self.seminarCategoriesTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
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
//        dispatch_release(checkQ);
    }
}

- (void) reloadData
{
    [self.seminarCategoriesTableView reloadData];
}

@end
