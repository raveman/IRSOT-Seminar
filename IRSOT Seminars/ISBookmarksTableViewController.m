//
//  ISBookmarksTableViewController.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 04.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "ISBookmarksTableViewController.h"
#import "ISSeminarViewController.h"
#import "Helper.h"
#import "ADVTheme.h"
#import "Sections+Load_Data.h"

@interface ISBookmarksTableViewController ()

@property (nonatomic, strong) NSArray *bookmarks;
@property (nonatomic, strong) NSUbiquitousKeyValueStore *bookmarkStore;
@property (nonatomic) BOOL isBookmarksEditing;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end

@implementation ISBookmarksTableViewController

@synthesize bookmarks = _bookmarks;
@synthesize isBookmarksEditing = _isBookmarksEditing;
@synthesize bookmarkStore = _bookmarkStore;
@synthesize editButton = _editButton;

- (NSArray *)bookmarks
{
    if (!_bookmarks) {
        _bookmarks = (NSArray *)[self.bookmarkStore arrayForKey:BOOKMARKS_KEY];
    }
    return _bookmarks;
}

- (void)setBookmarks:(NSMutableArray *)bookmarks
{
    if (_bookmarks != bookmarks) {
        _bookmarks = bookmarks;
        [self.bookmarkStore setObject:_bookmarks forKey:BOOKMARKS_KEY];
//        [self.bookmarkStore synchronize];
    }
}

- (NSUbiquitousKeyValueStore *)bookmarkStore
{
    if (_bookmarkStore == nil) _bookmarkStore = [NSUbiquitousKeyValueStore defaultStore];
    return _bookmarkStore;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Favorites", @"Favorites List View Title");

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBookmarks:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:self.bookmarkStore];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBookmarks:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeLocallyNotification
                                               object:self.bookmarkStore];
    [self.bookmarkStore synchronize];
    self.isBookmarksEditing = NO;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setEditButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateBookmarks];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Seminar View"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ISSeminarViewController *dvc = (ISSeminarViewController *)segue.destinationViewController;
        NSInteger seminarID = [[[self.bookmarks objectAtIndex:indexPath.row] objectForKey:BOOKMARK_SEMINAR_ID_KEY] integerValue];
        [dvc setSeminarID:seminarID];
    }
}

#pragma mark - iCloud key value
- (void)updateBookmarks
{
//    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
//    NSMutableArray *bookmarks = (NSMutableArray *)[store arrayForKey:BOOKMARKS_KEY];
//    self.bookmarks = bookmarks;
    [self.tableView reloadData];
}

- (void)updateBookmarksWithKeyArray:(NSArray *)changedKeys
{
    
    for (NSString *key in changedKeys) {
        if ([key isEqualToString:BOOKMARKS_KEY]) {
            NSMutableArray *newBookmarks = (NSMutableArray *)[self.bookmarkStore arrayForKey:key];
            //    [newBookmarks addObjectsFromArray:bookmarks];
            self.bookmarks = newBookmarks;
        }
    }
    
    [self.tableView reloadData];
}

- (void)updateBookmarks:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    if ([notification.name isEqualToString:NSUbiquitousKeyValueStoreDidChangeLocallyNotification]) {
        NSMutableArray *newBookmarks = [self.bookmarks mutableCopy];
        BOOL found = NO;
        for (NSDictionary *item in newBookmarks) {
            if ([[item objectForKey:BOOKMARK_SEMINAR_ID_KEY] integerValue] == [[userInfo objectForKey:BOOKMARK_SEMINAR_ID_KEY] integerValue]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [newBookmarks addObject:userInfo];
            self.bookmarks = newBookmarks;
        }
        [self.tableView reloadData];
    } else {
        NSNumber *reasonForChange = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
        int reason = [reasonForChange integerValue];
        if ((reason == NSUbiquitousKeyValueStoreServerChange) || (reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
            NSArray *changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
            if ([changedKeys count]) {
                [self updateBookmarksWithKeyArray:changedKeys];
            }
        }
    }
}

#pragma mark - Buttons methods
- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    if (!self.isBookmarksEditing) {
        self.isBookmarksEditing = YES;
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonPressed:)];
//        [self.navigationItem setRightBarButtonItem:cancelButton animated:NO];
        self.navigationItem.rightBarButtonItem = cancelButton;
        
        [self.tableView setEditing:self.isBookmarksEditing animated:YES];
    } else {
        self.isBookmarksEditing = NO;
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)];
        [self.navigationItem setRightBarButtonItem:editButton animated:NO];
        [self.tableView setEditing:self.isBookmarksEditing animated:YES];
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
    return [self.bookmarks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Bookmark Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.font = [Helper cellMainFont];
    cell.detailTextLabel.font = [Helper cellDetailFont];
    cell.selectionStyle = [Helper cellSelectionStyle];

    NSDictionary *bookmark = [self.bookmarks objectAtIndex:indexPath.row];
    cell.textLabel.text = [bookmark objectForKey:BOOKMARK_SEMINAR_NAME_KEY];
    cell.detailTextLabel.text = [bookmark objectForKey:BOOKMARK_SEMINAR_DATE_KEY];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSMutableArray *newBookmarks = [self.bookmarks mutableCopy];
        [newBookmarks removeObjectAtIndex:indexPath.row];
        self.bookmarks = newBookmarks;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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

#pragma mark - NSFetchedResultsControllerDelegate


@end
