//
//  ISSettingsViewController.m
//  Seminar.Ru
//
//  Created by Bob Ershov on 01.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//
// TODO: add error checking: no network, broken data transfer, etc...

#import "SVProgressHUD/SVProgressHUD.h"

#import "ISSettingsViewController.h"
#import "ISMainPageViewController.h"
#import "SeminarFetcher.h"

#import "Type+Load_Data.h"
#import "Sections+Load_Data.h"
#import "Seminar+Load_Data.m"
#import "Lector+Load_Data.h"

@interface ISSettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *updateDateLabel;
@property (weak, nonatomic) IBOutlet UISwitch *sortSwitch;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

- (void) loadData;
- (void) deleteData;

@end

@implementation ISSettingsViewController
@synthesize updateDateLabel;
@synthesize sortSwitch;
@synthesize refreshButton;
@synthesize deleteButton;
@synthesize delegate = _delegate;

@synthesize emptyStore;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_texture.png"]];

    self.sortSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:SORT_KEY] boolValue];
    
    if (self.emptyStore) self.deleteButton.hidden = NO;
        else self.deleteButton.hidden = YES;
}

- (void)viewDidUnload
{
    [self setUpdateDateLabel:nil];
    [self setDeleteButton:nil];
    [self setRefreshButton:nil];
    [self setSortSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.updateDateLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:UPDATE_DATE_KEY];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

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

- (IBAction)sortSwitchPressed:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *sortByDate = [NSNumber numberWithBool:sender.on];
    
    [defaults setObject:sortByDate forKey:SORT_KEY];
    [defaults synchronize];
}

#pragma mark - Loading staff from website

- (void) loadData {

    [SVProgressHUD showWithStatus:NSLocalizedString(@"Загружаю семинары", @"Loading seminars data from the web")];
    BOOL __block updated = NO;
    dispatch_queue_t fetchQ = dispatch_queue_create("Seminar fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSDictionary *sectionsAndTypes = [SeminarFetcher sectionsAndTypes];
        
        [self.managedObjectContext performBlock:^{
            NSArray *sections = [sectionsAndTypes valueForKey:@"sections"];
            NSArray *types = [sectionsAndTypes valueForKey:@"types"];
            
            for (NSDictionary *section in sections) {
                [Sections sectionWithTerm:section inManagedObjectContext:self.managedObjectContext];
                NSLog(@"Section: %@", [section objectForKey:@"name"]);
            }
            
            for (NSDictionary *type in types) {
                [Type typeWithTerm:type inManagedObjectContext:self.managedObjectContext];
                NSLog(@"Type: %@", [type objectForKey:@"name"]);
            }

            NSArray *seminars = [SeminarFetcher seminars];
            for (NSDictionary *seminarInfo in seminars) {
                [Seminar seminarWithDictionary:seminarInfo inManagedObjectContext:self.managedObjectContext];
            }

            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Could'not save: %@", [error localizedDescription]);
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Ошибка загрузки", @"Seminars load error")];
            } else {

                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Семинары загружены!", @"Seminars loaded successfully")];
                self.deleteButton.hidden = NO;
                updated = YES;
                
                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
//                NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatFromTemplate:@"HH:MM dd.mm.yyyy" options:nil locale:nil];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                
                [dateFormatter setLocale:locale];
                NSString *dateUpdated = [dateFormatter stringFromDate:[NSDate date]];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

                self.updateDateLabel.text = dateUpdated;
                
                [defaults setObject:dateUpdated forKey:UPDATE_DATE_KEY];
                [defaults synchronize];
            }
            [self.delegate settingsViewController:self didUpdatedStore:updated];
        }]; // end managedObjectContext performBlock
    }); // end dispatch_async(fetchQ) block
    dispatch_release(fetchQ);

}

// удаляем все данные из приложения
- (void) deleteData
{
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
        [persistentCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];//recreates the persistent store
        deleted = YES;
        self.deleteButton.hidden = YES;
        self.updateDateLabel.text = @"";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"" forKey:UPDATE_DATE_KEY];
        [defaults synchronize];
    }
    
    [self.managedObjectContext unlock];

    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Семинары удалены", @"Seminars deleted")];
    
    //notifying main page view controller about deleted data
    [self.delegate settingsViewController:self didDeletedStore:deleted];
}


@end
