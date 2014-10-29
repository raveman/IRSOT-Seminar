//
//  ISSettingsViewController.m
//  Seminar.Ru
//
//  Created by Bob Ershov on 01.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//
// TODO: add error checking: no network, broken data transfer, etc...

#import <EventKit/EventKit.h>

#import "SVProgressHUD/SVProgressHUD.h"
#import "ReachabilityARC.h"

#import "ISAppDelegate.h"
#import "ISSettingsViewController.h"
#import "ISMainPageViewController.h"
#import "SeminarFetcher.h"
#import "Helper.h"
#import "ISAlertTimesTableViewController.h"
#import "ISAlertTimes.h"

#import "ISTheme.h"

#import "Type+Load_Data.h"
#import "Section+Load_Data.h"
#import "Seminar+Load_Data.h"
#import "AllEvents+Load_Data.h"
#import "Lector+Load_Data.h"
#import "Info+Load_data.h"

const NSInteger settingsUpdateSection = 0;
const NSInteger settingsSortSection = 1;
const NSInteger settingsCalendarAlertSection = 2;
const NSInteger settingsSections = 3;

@interface ISSettingsViewController () <UITableViewDataSource, UITableViewDelegate, ISAlertTimesTableViewControllerDelegate>
@property (strong, nonatomic) NSString *updateDateLabel;
@property (strong, nonatomic) NSString *errorText;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@property (strong, nonatomic) ReachabilityARC * reach;

@property (nonatomic) BOOL isUpdating;

- (void) loadData;
- (void) deleteData;

@end    

@implementation ISSettingsViewController

@synthesize managedObjectContext = _managedObjectContext;

@synthesize updateDateLabel = _updateDateLabel;
@synthesize errorText = _errorText;

@synthesize versionLabel;
@synthesize delegate = _delegate;

@synthesize emptyStore = _emptyStore;
@synthesize changedTime = _changedTime;
@synthesize reach = _reach;
@synthesize isUpdating = _isUpdating;


#pragma mark - Properties initialization

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

#pragma mark - Helper methods
- (void) checkCalendarAccess
{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        // iOS 6 and later
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
            }
        }];
    } else {
    }
}

#pragma mark - UIViewContoller methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Settings", @"Settings page title");
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    NSString *versionLabelText = NSLocalizedString(@"Version", @"Version label");
    self.versionLabel.text = [NSString stringWithFormat:@"%@: %@", versionLabelText, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
      
    // checking network availability and enabling or disabling update button.
    
    ISSettingsViewController __block *weakSelf = self;
    self.reach.reachableBlock = ^(ReachabilityARC * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:settingsUpdateSection];
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

            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:settingsUpdateSection];
            UITableViewCell *refreshCell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
            refreshCell.selectionStyle = UITableViewCellSelectionStyleNone;
            refreshCell.textLabel.enabled = NO;
            refreshCell.userInteractionEnabled = NO;
        });
    };
 
    [self checkCalendarAccess];
    self.isUpdating = NO;
    if (self.doUpdate) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:settingsUpdateSection];
        UITableViewCell *refreshCell = [self.tableView cellForRowAtIndexPath:indexPath];
        refreshCell.selectionStyle = UITableViewCellSelectionStyleNone;
        refreshCell.textLabel.enabled = NO;
        refreshCell.userInteractionEnabled = NO;
        
        [self loadData];

        refreshCell.selectionStyle = UITableViewCellSelectionStyleBlue;
        refreshCell.textLabel.enabled = YES;
        refreshCell.userInteractionEnabled = YES;
    }
}

- (void)viewDidUnload
{
    [self setUpdateDateLabel:nil];
    [self setReach:nil];
    [self setVersionLabel:nil];
    [self setCloseButton:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated
{
    NSString *saveUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:UPDATE_DATE_KEY];
    if (saveUpdateDate == nil) {
        saveUpdateDate = @"";
    }
    self.updateDateLabel = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Last update", @"Last catalog update") ,saveUpdateDate];
    [self.reach startNotifier];
    [super viewWillAppear:animated];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Alert"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if ((indexPath.section == settingsCalendarAlertSection) || (indexPath.row == 1)) {
            ISAlertTimesTableViewController *dvc = (ISAlertTimesTableViewController *)[segue destinationViewController];
            dvc.timeRow = [ISAlertTimes savedAlertTimeOption];
            dvc.delegate = self;
        }
    }
}

#pragma mark - UI interactions

// done button pressed
- (IBAction)done:(UIBarButtonItem *)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
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
//        dispatch_release(fetchQ);
    }
}

- (void) loadData
{
    if (!self.isUpdating) {
        self.isUpdating = YES;
        
        [self deleteData];
        
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Updating catalog", @"Loading catalog data from the web")];

        dispatch_queue_t fetchQ = dispatch_queue_create("Seminar fetcher", NULL);
        dispatch_async(fetchQ, ^{
        
            // downloading section and types
        
            [self.managedObjectContext performBlockAndWait:^{
                
                // disabling "close" button
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.closeButton.enabled = NO;
                });
                
                NSArray *infoPages = [SeminarFetcher infoPages];
                for (NSDictionary *infoPage in infoPages) {
                    [Info infoWithDictionary:infoPage inManagedObjectContext:self.managedObjectContext];
                }
                
                NSDictionary  *sectionsAndTypes = [SeminarFetcher sectionsAndTypes];
        
                NSArray *sections = [sectionsAndTypes valueForKey:@"sections"];
                NSArray *types = [sectionsAndTypes valueForKey:@"types"];
                NSArray *allEvents = [sectionsAndTypes valueForKey:@"all"];
                for (NSDictionary *event in allEvents) {
                    [AllEvents eventWithTerm:event inManagedObjectContext:self.managedObjectContext];
                }
                
                for (NSDictionary *section in sections) {
                    [Section sectionWithTerm:section inManagedObjectContext:self.managedObjectContext];
//                    NSLog(@"Section: %@", [section objectForKey:@"name"]);
                }
                
                for (NSDictionary *type in types) {
                    [Type typeWithTerm:type inManagedObjectContext:self.managedObjectContext];
//                    NSLog(@"Type: %@", [type objectForKey:@"name"]);
                }
                
                [SVProgressHUD showWithStatus:NSLocalizedString(@"Updating lectors", @"Updating lectors message")];
                
                NSArray *lectors = [SeminarFetcher lectors];
                for (NSDictionary *lectorInfo in lectors) {
//                    NSLog(@"Lector info: %@", [lectorInfo description]);
                    [Lector lectorWithDictionary:lectorInfo inManagedObjectContext:self.managedObjectContext];
                }

                [SVProgressHUD showWithStatus:NSLocalizedString(@"Updating catalog", @"Updating catalog message")];
        
                NSArray *seminars = [SeminarFetcher seminars];
        
                for (NSDictionary *seminarInfo in seminars) {
                    [Seminar seminarWithDictionary:seminarInfo lectors:lectors inManagedObjectContext:self.managedObjectContext];
                }

                NSError *error = nil;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Could'not save: %@", [error localizedDescription]);
                    
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Load error", @"Load error message"),[error localizedDescription]]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.closeButton.enabled = YES;
                        self.isUpdating = NO;
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
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Catalog successfully updated!", @"Catalog loaded successfully")];
                        
                        self.updateDateLabel = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Last update", @"Last catalog update") ,dateUpdated];
                        self.closeButton.enabled = YES;
                        [self.tableView reloadData];
                        self.isUpdating = NO;
                    });
                }
            }]; // end managedObjectContext performBlock
        }); // end dispatch_async(fetchQ) block
//        dispatch_release(fetchQ);
    }
}

// удаляем все данные из приложения
- (void) deleteData
{

    [self loadCSSFiles];

    NSError *error = nil;
    
    NSPersistentStoreCoordinator *persistentCoordinator = [self.managedObjectContext persistentStoreCoordinator];
    // retrieve the store URL
    
    NSArray *stores = [persistentCoordinator persistentStores];
    if (!stores) {
        return;
    }
    
    NSArray *persistenStores = [persistentCoordinator persistentStores];
    if (persistenStores) {
        NSURL *storeURL = [persistentCoordinator URLForPersistentStore:[persistenStores lastObject]];
        
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
            self.updateDateLabel = NSLocalizedString(@"no information", @"No data about update");
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"" forKey:UPDATE_DATE_KEY];
            [defaults synchronize];
        }
        
        [self.managedObjectContext unlock];
        
        // need to remove Lector Pics cache
        [[NSFileManager defaultManager] removeItemAtURL:[[ISAppDelegate sharedDelegate] lectorCacheDirectory] error:&error];
        if (error) NSLog(@"Error creating directory: %@", [error.userInfo objectForKey:NSUnderlyingErrorKey]);
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Catalog deleted", @"Catalog deleted")];
        
        //notifying main page view controller about deleted data
        [self.delegate settingsViewController:self didDeletedStore:deleted];
    }


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

        case settingsCalendarAlertSection:
            rows = 2;
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
    static NSString *AlertCellIdentifier = @"Setup Alert Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    [switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
    switchView.onTintColor = [ISTheme switchOnColor];

    switch (indexPath.section) {
        // sorting switch
        case settingsSortSection:
            if (indexPath.row == 0) {
                switchView.on = [[[NSUserDefaults standardUserDefaults] objectForKey:SORT_KEY] boolValue];
                cell.textLabel.text = NSLocalizedString(@"Sort catalog by date or seminar name", @"Sort catalog by date");
                cell.accessoryView = switchView;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                switchView.tag = indexPath.section;
            }

            break;

        // catalog update setup
        case settingsCalendarAlertSection:
            switch (indexPath.row) {
                case 0:
                    switchView.on = [[[NSUserDefaults standardUserDefaults] objectForKey:CALENDAR_ALERT_KEY] boolValue];
                    cell.textLabel.text = NSLocalizedString(@"Use calendar alerts", @"Use calendar alerts");
                    cell.accessoryView = switchView;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    switchView.tag = indexPath.section;
                    break;
                    
                case 1:
                    cell = [tableView dequeueReusableCellWithIdentifier:AlertCellIdentifier];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AlertCellIdentifier];
                    }
                    
                    cell.textLabel.text = NSLocalizedString(@"Alert", @"Alert");
                    cell.detailTextLabel.text = [[ISAlertTimes alerTimesArray] objectAtIndex:[ISAlertTimes savedAlertTimeOption]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.enabled = [ISAlertTimes useCalendarAlerts];
                    cell.detailTextLabel.enabled = cell.textLabel.enabled;
                    break;

                default:
                    break;
            }
            break;
            
        // catalog update setup
        case settingsUpdateSection:
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Refresh catalog", @"Refresh catalog");
                cell.textLabel.textColor = [UIColor redColor];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                if (![self.reach isReachable]) {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.enabled = NO;
                    cell.userInteractionEnabled = NO;
                }
            }
            break;
            
        default:
            break;
    }
    cell.textLabel.font = [ISTheme cellMainFont];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = [NSString string];
    
    switch (section) {
        case settingsSortSection:
            title = NSLocalizedString(@"Sorting",@"Sorting section title");
            break;
            
        case settingsCalendarAlertSection:
            title = NSLocalizedString(@"Calendar",@"Calendar section title");
            break;
            
        case settingsUpdateSection:
            title = NSLocalizedString(@"Catalog",@"Catalog section title");
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
            
        case settingsCalendarAlertSection:
            title = NSLocalizedString(@"Use calendar alerts when adding events to calendar", @"Calendar alerts description");
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == settingsUpdateSection) {
        [self loadData];
    }
//    if ((indexPath.section == settingsCalendarAlertSection) && (indexPath.row == 1)) {
//        [self performSegueWithIdentifier:@"Alert" sender:indexPath];
//    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.textColor = [ISTheme labelColor];
        tableViewHeaderFooterView.textLabel.font = [ISTheme sectionLabelFont];
    }
}

#pragma mark - Settings actions
- (void)updateSwitch:(id)sender
{

//    UITableView *tableView;
//    UITableViewCell *cell;
    
    NSUInteger indexes[] = {[sender tag], 0};
    NSIndexPath *indexPath =[NSIndexPath indexPathWithIndexes:indexes length: 2];

    if (indexPath.section == settingsSortSection) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *sortByDate = [NSNumber numberWithBool:[sender isOn]];
        
        [defaults setObject:sortByDate forKey:SORT_KEY];
        [defaults synchronize];
    }
    
    if (indexPath.section == settingsCalendarAlertSection) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *useCalendarAlerts = [NSNumber numberWithBool:[sender isOn]];
        
        [defaults setObject:useCalendarAlerts forKey:CALENDAR_ALERT_KEY];
        [defaults synchronize];
        // now we need to enable/disable cell for alerts
        NSIndexPath *alertCellIndexPath = [NSIndexPath indexPathForRow:1 inSection:settingsCalendarAlertSection];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:alertCellIndexPath];
        cell.textLabel.enabled = [sender isOn];
        cell.detailTextLabel.enabled = cell.textLabel.enabled;
    }
}

#pragma mark - ISAlertTimesViewControllerDelegate

- (void) alertTimesViewContoller:(ISAlertTimesTableViewController *)sender didSelectedTime: (NSInteger) time
{
    [ISAlertTimes saveAlertTimeOptionWithTimeSelection:sender.timeRow];
    [self.tableView reloadData];
}

@end
