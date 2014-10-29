//
//  ISInfoTableViewController.m
//  RuSeminar
//
//  Created by Bob Ershov on 09.07.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "ISInfoTableViewController.h"
#import "ISWebviewViewController.h"
#import "ISInfoDictionary.h"
#import "Helper.h"
#import "ISTheme.h"
#import "ISAppDelegate.h"
#import "SVProgressHUD/SVProgressHUD.h"
#import "Info.h"

#define CACHE_NAME @"info.cache"

@interface ISInfoTableViewController ()

@property (nonatomic) NSInteger count;
@property (nonatomic, strong) NSArray *infoLinks;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ISInfoTableViewController

@synthesize count = _count;
@synthesize infoLinks = _infoLinks;
@synthesize tableView = _tableView;
@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - Instance variables
- (NSInteger) count {
    if (_count == 0) {
        _count = [[self.fetchedResultsController fetchedObjects] count];
    }
    return _count;
}

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Important", @"Important Title");
    self.navigationItem.title = NSLocalizedString(@"Important", @"Important Title");
    
    self.navigationItem.leftBarButtonItem.tintColor = [ISTheme barButtonItemColor];
    
    self.managedObjectContext = [[ISAppDelegate sharedDelegate] managedObjectContext];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(seminarDataChanged:) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(seminarDataChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    if (self.count) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        count = [sectionInfo numberOfObjects];
    }
    
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = [NSString string];

    if (self.count) {
        title = [[self.fetchedResultsController sectionIndexTitles] objectAtIndex:section];
        title = [title substringFromIndex:2];
        title = NSLocalizedString(title, nil);
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Info Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...

//    NSString *key = [[[self.infoLinks objectAtIndex:indexPath.section*2] objectAtIndex:1] objectAtIndex:indexPath.row];
    

    UIImage *accessoryImage = [UIImage imageNamed:@"accessoryArrow"];
    cell.accessoryView = [[UIImageView alloc] initWithImage:accessoryImage];
    cell.textLabel.font = [ISTheme cellMainFont];
    
    cell.textLabel.font = [ISTheme cellMainFont];
    cell.selectionStyle = [ISTheme cellSelectionStyle];
    
    NSString *key = [NSString string];
    if (self.count) {
        Info *infoPage = [self.fetchedResultsController objectAtIndexPath:indexPath];
        key = NSLocalizedString(infoPage.title_rus, infoPage.title_eng);
    }

    cell.textLabel.text = key;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title;
    if (section == [[self.fetchedResultsController sectionIndexTitles] count] - 1 ) {
        title = NSLocalizedString(@"Телефоны: +7 (495) 933-02-17, +7 (495) 974-24-53\nФакс: +7 (495) 933-0215\nE-mail: seminar@ruseminar.ru",@"Info telephones");
    }
    return title;

}

#pragma mark - Table view delegate

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Web View"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Info *infoPage = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSURL *url = [NSURL URLWithString:infoPage.page_url];
        ISWebviewViewController *dvc = (ISWebviewViewController *)segue.destinationViewController;
        [dvc setUrl:url];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [dvc setWebviewTitle:cell.textLabel.text];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.textColor = [ISTheme labelColor];
        tableViewHeaderFooterView.textLabel.font = [ISTheme sectionLabelFont];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Info" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor1, sortDescriptor2];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"category" cacheName:CACHE_NAME];
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
    
    self.count = [[self.fetchedResultsController fetchedObjects] count];
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
        default:
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


#pragma mark - Notification handlers

- (void) seminarDataChanged:(NSNotification *)notification
{
    //    notification.name;
    //    notification.object;
    //    notification.userInfo;
    
    if ([notification.userInfo objectForKey:NSRemovedPersistentStoresKey]) {
        self.fetchedResultsController = nil;
    }
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
//    [self.tableView reloadData];
    //    [self.view performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    //    [self.view setNeedsDisplay];
}


@end
