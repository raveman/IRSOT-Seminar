//
//  ISSettingsViewController.m
//  Seminar.Ru
//
//  Created by Bob Ershov on 01.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//
// TODO: add error checking: no network, broken data transfer, etc...

#import <QuartzCore/QuartzCore.h>

#import "SVProgressHUD/SVProgressHUD.h"
#import "ReachabilityARC.h"
#import "NVUIGradientButton.h"

#import "ISAppDelegate.h"
#import "ISSettingsViewController.h"
#import "ISMainPageViewController.h"
#import "SeminarFetcher.h"
#import "Helper.h"

#import "Type+Load_Data.h"
#import "Sections+Load_Data.h"
#import "Seminar+Load_Data.h"
#import "Lector+Load_Data.h"

const NSInteger settingsSortSection = 0;
const NSInteger settingsUpdateSection = 1;
const NSInteger settingsSections = 2;

@interface ISSettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSString *updateDateLabel;
@property (strong, nonatomic) NSString *errorText;

@property (strong, nonatomic) UISwitch *sortSwitch;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;



@property (strong, nonatomic) ReachabilityARC * reach;

- (void) loadData;
- (void) deleteData;

@end    

@implementation ISSettingsViewController
@synthesize updateDateLabel = _updateDateLabel;
@synthesize sortSwitch = _sortSwitch;
@synthesize errorText = _errorText;

@synthesize versionLabel;
@synthesize delegate = _delegate;

@synthesize emptyStore = _emptyStore;
@synthesize changedTime = _changedTime;
@synthesize reach = _reach;

- (UISwitch *) sortSwitch
{
    if (!_sortSwitch) {
        _sortSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_sortSwitch addTarget:self action:@selector(updateSwitchAtIndexPath) forControlEvents:UIControlEventTouchUpInside];
    }

    return _sortSwitch;
}

- (NSString *)errorText
{
    
    if (!_errorText) {
        _errorText = NSLocalizedString(@"No internet access", @"No network access");
    }
    return _errorText;
}


- (ReachabilityARC *)reach
{
    if (_reach == nil) _reach = [ReachabilityARC reachabilityWithHostname:SEMINAR_SITE];
    
    return _reach;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.sortSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:SORT_KEY] boolValue];
    
    NSString *versionLabelText = NSLocalizedString(@"Версия", @"Version label");
    self.versionLabel.text = [NSString stringWithFormat:@"%@: %@", versionLabelText, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
      
    // checking network availability and enabling or disabling update button.
    
    ISSettingsViewController __block *weakSelf = self;
    self.reach.reachableBlock = ^(ReachabilityARC * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:settingsUpdateSection];
            UITableViewCell *refreshCell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
            refreshCell.selectionStyle = UITableViewCellSelectionStyleBlue;
            refreshCell.textLabel.enabled = YES;
            refreshCell.userInteractionEnabled = YES;
        });
    };
    
    self.reach.unreachableBlock = ^(ReachabilityARC * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:weakSelf.errorText];

            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:settingsUpdateSection];
            UITableViewCell *refreshCell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
            refreshCell.selectionStyle = UITableViewCellSelectionStyleNone;
            refreshCell.textLabel.enabled = NO;
            refreshCell.userInteractionEnabled = NO;
        });
    };
    
}

- (void)viewDidUnload
{
    [self setUpdateDateLabel:nil];
    [self setSortSwitch:nil];
    [self setReach:nil];
    [self setVersionLabel:nil];
    [self setCloseButton:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.reach startNotifier];
    self.updateDateLabel = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Date updated", @"Date catalog updated") ,[[NSUserDefaults standardUserDefaults] objectForKey:UPDATE_DATE_KEY]];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.reach stopNotifier];
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

#pragma mark - UI interactions

// done button pressed
- (IBAction)done:(UIBarButtonItem *)sender
{
    [[self presentingViewController] dismissModalViewControllerAnimated:YES];
}

#pragma mark - Loading staff from website

- (void) loadCSSFiles {
    
    NSError *error = nil;
    // Deleting CSS cache data
    
    NSArray *cssFilesArray = [[ISAppDelegate sharedDelegate] ruseminarCSSFilesURLs];
    for (NSDictionary *cssFileDict in cssFilesArray) {
        NSURL *localURL = [cssFileDict objectForKey:@"localURL"];
        NSURL *remoteURL = [NSURL URLWithString:[cssFileDict objectForKey:@"remoteURL"]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[localURL path]];
        if (fileExists) {
            [[NSFileManager defaultManager] removeItemAtURL:localURL error:&error];
        }
        dispatch_queue_t fetchQ = dispatch_queue_create("Seminar fetcher", NULL);
        dispatch_async(fetchQ, ^{
            
            NSData *data = [[NSData alloc] initWithContentsOfURL: remoteURL];
            [data writeToURL:localURL atomically:YES];
        });
        dispatch_release(fetchQ);
    }
}

- (void) loadData
{

    [self deleteData];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Обновляю каталог", @"Loading catalog data from the web")];

    dispatch_queue_t fetchQ = dispatch_queue_create("Seminar fetcher", NULL);
    dispatch_async(fetchQ, ^{
    
        // downloading section and types
    
        [self.managedObjectContext performBlockAndWait:^{
            
            // disabling "close" button
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.closeButton.enabled = NO;
            });
            
            NSDictionary  *sectionsAndTypes = [SeminarFetcher sectionsAndTypes];
    
            NSArray *sections = [sectionsAndTypes valueForKey:@"sections"];
            NSArray *types = [sectionsAndTypes valueForKey:@"types"];
            
            for (NSDictionary *section in sections) {
                [Sections sectionWithTerm:section inManagedObjectContext:self.managedObjectContext];
//                NSLog(@"Section: %@", [section objectForKey:@"name"]);
            }
            
            for (NSDictionary *type in types) {
                [Type typeWithTerm:type inManagedObjectContext:self.managedObjectContext];
//                NSLog(@"Type: %@", [type objectForKey:@"name"]);
            }

            [SVProgressHUD showWithStatus:@"Обновляю лекторов"];
            
            NSArray *lectors = [SeminarFetcher lectors];
            for (NSDictionary *lectorInfo in lectors) {
                [Lector lectorWithDictionary:lectorInfo inManagedObjectContext:self.managedObjectContext];
            }

            [SVProgressHUD showWithStatus:@"Обновляю каталог"];
    
            NSArray *seminars = [SeminarFetcher seminars];
    
            for (NSDictionary *seminarInfo in seminars) {
                [Seminar seminarWithDictionary:seminarInfo lectors:lectors inManagedObjectContext:self.managedObjectContext];
            }

            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Could'not save: %@", [error localizedDescription]);
                
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Ошибка загрузки %@", [error localizedDescription]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.closeButton.enabled = YES;
                });
                
            } else {
                [self.delegate settingsViewController:self didUpdatedStore:YES];
//                [self.delegate performSelector:@selector(reloadData)];
                
                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
                //                NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatFromTemplate:@"HH:MM dd.mm.yyyy" options:nil locale:nil];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                
                [dateFormatter setLocale:locale];
                NSDate *dateChanged = [NSDate date];
                NSString *dateUpdated = [dateFormatter stringFromDate:dateChanged];
                self.changedTime = [dateChanged timeIntervalSince1970];

                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:dateUpdated forKey:UPDATE_DATE_KEY];
                
                [defaults setInteger:self.changedTime forKey:CATALOG_CHANGED_KEY];
                [defaults synchronize];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Каталог обновлен!", @"Catalog loaded successfully")];
                    
                    self.updateDateLabel = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Date updated", @"Date catalog updated") ,dateUpdated];
                    self.closeButton.enabled = YES;
                    [self.tableView reloadData];
                });
            }
        }]; // end managedObjectContext performBlock
    }); // end dispatch_async(fetchQ) block
    dispatch_release(fetchQ);
}

// удаляем все данные из приложения
- (void) deleteData
{

    [self loadCSSFiles];

    NSError *error = nil;
    
    NSPersistentStoreCoordinator *persistentCoordinator = [self.managedObjectContext persistentStoreCoordinator];
    // retrieve the store URL
    NSURL *storeURL = [persistentCoordinator URLForPersistentStore:[[persistentCoordinator persistentStores] lastObject]];
    
    // lock the current context
    [self.managedObjectContext lock];
    [self.managedObjectContext reset];//to drop pending changes
    
    BOOL deleted = NO;
    //delete the store from the current managedObjectContext
    if ([persistentCoordinator removePersistentStore:[[persistentCoordinator persistentStores] lastObject] error:&error])
    {
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        //recreate the store like in the  appDelegate method
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        if (![persistentCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {

            NSLog(@"Recreating store after deletion: unresolved error %@, %@", error, [error userInfo]);
            abort();
        }

        deleted = YES;
        self.updateDateLabel = NSLocalizedString(@"нет данных", @"No data about update");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"" forKey:UPDATE_DATE_KEY];
        [defaults synchronize];
    }
    
    [self.managedObjectContext unlock];
    
    // need to remove Lector Pics cache
    [[NSFileManager defaultManager] removeItemAtURL:[[ISAppDelegate sharedDelegate] lectorCacheDirectory] error:&error];
    if (error) NSLog(@"Error creating directory: %@", [error.userInfo objectForKey:NSUnderlyingErrorKey]);

    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Каталог удален", @"Seminars deleted")];
    
    //notifying main page view controller about deleted data
    [self.delegate settingsViewController:self didDeletedStore:deleted];
}


#pragma mark - UITableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return settingsSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section) {
        case settingsSortSection:
            rows = 1;
            break;

        case settingsUpdateSection:
            rows = 1;
            break;
            
        default:
            break;
    }
    
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Setup Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    switch (indexPath.section) {
        // sorting switch
        case settingsSortSection:
            
            cell.textLabel.text = NSLocalizedString(@"Sort catalog by date", @"Sort catalog by date");
            cell.accessoryView = self.sortSwitch;

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;

        // catalog update setup
        case settingsUpdateSection:
            cell.textLabel.text = NSLocalizedString(@"Refresh catalog", @"Refresh catalog");
            cell.textLabel.textAlignment = UITextAlignmentCenter;

            if (![self.reach isReachable]) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.enabled = NO;
                cell.userInteractionEnabled = NO;
            }
            
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = [NSString string];
    
    switch (section) {
        case settingsSortSection:
            break;
            
        case settingsUpdateSection:
            break;
            
        default:
            break;
    }
    
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title = [NSString string];
    
    switch (section) {
        case settingsSortSection:
            title = NSLocalizedString(@"Sort catalog by date", @"Sort description");
            break;
            
        case settingsUpdateSection:
            title = self.updateDateLabel;
            break;

        default:
            break;
    }
    
    return title;
}

#pragma mark - UITableView Delegate
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//        
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == settingsUpdateSection) {
        [self loadData];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)updateSwitchAtIndexPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *sortByDate = [NSNumber numberWithBool:self.sortSwitch.on];
    
    [defaults setObject:sortByDate forKey:SORT_KEY];
    [defaults synchronize];
}

@end
