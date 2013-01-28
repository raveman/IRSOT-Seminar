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

@interface ISSettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *updateDateLabel;
@property (weak, nonatomic) IBOutlet UISwitch *sortSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *iCloudSwitch;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@property (strong, nonatomic) ReachabilityARC * reach;

- (void) loadData;
- (void) deleteData;

@end

@implementation ISSettingsViewController
@synthesize updateDateLabel;
@synthesize sortSwitch;
@synthesize iCloudSwitch;
@synthesize refreshButton;
@synthesize deleteButton;
@synthesize errorLabel;
@synthesize versionLabel;
@synthesize delegate = _delegate;

@synthesize emptyStore = _emptyStore;
@synthesize changedTime = _changedTime;
@synthesize reach = _reach;

- (ReachabilityARC *)reach
{
    if (_reach == nil) _reach = [ReachabilityARC reachabilityWithHostname:SEMINAR_SITE];
    
    return _reach;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_texture.png"]];

    UIImage *greenButtonImage = [UIImage imageNamed:@"greenButton.png"];
    UIImage *greenButtonHighlightImage = [UIImage imageNamed:@"greenButtonHighlight.png"];
    
    UIImage *redButtonImage = [UIImage imageNamed:@"orangeButton.png"];
    UIImage *redButtonHighlightImage = [UIImage imageNamed:@"orangeButtonHighlight.png"];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        greenButtonImage = [greenButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        redButtonImage = [redButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        greenButtonHighlightImage = [greenButtonHighlightImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        redButtonHighlightImage = [redButtonHighlightImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
    } else {
        greenButtonImage = [greenButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
        redButtonImage = [redButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
        greenButtonHighlightImage = [greenButtonHighlightImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
        redButtonHighlightImage = [redButtonHighlightImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
    }
    [self.refreshButton setBackgroundImage:greenButtonImage forState:UIControlStateNormal];
    [self.deleteButton setBackgroundImage:redButtonImage forState:UIControlStateNormal];
    [self.refreshButton setBackgroundImage:greenButtonHighlightImage forState:UIControlStateHighlighted];
    [self.deleteButton setBackgroundImage:redButtonHighlightImage forState:UIControlStateHighlighted];
    
    self.sortSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:SORT_KEY] boolValue];
//    self.iCloudSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:USE_ICLOUD_KEY] boolValue];
    
    self.closeButton.title = @"abracadabra";
    self.errorLabel.text = @"";
    NSString *versionLabelText = NSLocalizedString(@"Версия", @"Version label");
    self.versionLabel.text = [NSString stringWithFormat:@"%@: %@", versionLabelText, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    if (self.emptyStore) self.deleteButton.enabled = YES;
        else self.deleteButton.enabled = NO;
    
    // we need to force downloading of the catalog
    
    self.reach.reachableBlock = ^(ReachabilityARC * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            refreshButton.enabled = YES;
            errorLabel.text = @"";
        });
    };
    
    self.reach.unreachableBlock = ^(ReachabilityARC * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            refreshButton.enabled = NO;
            NSString *noInternetText = NSLocalizedString(@"Нет доступа к интернету", @"No network access");
            errorLabel.text = noInternetText;
            [SVProgressHUD showErrorWithStatus:noInternetText];
        });
    };
    
}

- (void)viewDidUnload
{
    [self setUpdateDateLabel:nil];
    [self setDeleteButton:nil];
    [self setRefreshButton:nil];
    [self setSortSwitch:nil];
    [self setErrorLabel:nil];
    [self setReach:nil];
    [self setICloudSwitch:nil];
    [self setVersionLabel:nil];
    [self setCloseButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.reach startNotifier];
    self.updateDateLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:UPDATE_DATE_KEY];
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

// load button pressed
- (IBAction)load:(UIButton *)sender
{
    [self loadData];
}

// delete button pressed
- (IBAction)delete:(UIButton *)sender
{
    [self deleteData];
}

- (IBAction)sortSwitchPressed:(UISwitch *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *sortByDate = [NSNumber numberWithBool:sender.on];
    
    [defaults setObject:sortByDate forKey:SORT_KEY];
    [defaults synchronize];
}

#pragma mark - Loading staff from website

- (void) loadCSSFiles {
    
    NSError *error = nil;
    // Deleting CSS cache data
    
    NSArray *cssFilesArray = [[ISAppDelegate sharedDelegate] ruseminarCSSFilesURLs];
    for (NSDictionary *cssFileDict in cssFilesArray ) {
        NSURL *localURL = [cssFileDict objectForKey:@"localURL"];
        NSURL *remoteURL = [NSURL URLWithString:[cssFileDict objectForKey:@"remoteURL"]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[localURL path]];
        if (fileExists) {
            [[NSFileManager defaultManager] removeItemAtURL:localURL error:&error];
        } else {
            dispatch_queue_t fetchQ = dispatch_queue_create("Seminar fetcher", NULL);
            dispatch_async(fetchQ, ^{
                
                NSData *data = [[NSData alloc] initWithContentsOfURL: remoteURL];
                [data writeToURL:localURL atomically:YES];
            });
            dispatch_release(fetchQ);
        }
    }
}

- (void) loadData {

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
                    
                    self.deleteButton.enabled = YES;
                    self.updateDateLabel.text = dateUpdated;
                    self.closeButton.enabled = YES;
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
        self.deleteButton.enabled = NO;
        self.updateDateLabel.text = NSLocalizedString(@"нет данных", @"No data about update");
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


@end
