//
//  ISSettingsViewController.m
//  Seminar.Ru
//
//  Created by Bob Ershov on 01.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "SVProgressHUD/SVProgressHUD.h"

#import "ISSettingsViewController.h"
#import "ISMainPageViewController.h"
#import "SeminarFetcher.h"

#import "Type.h"
#import "Sections.h"
#import "Lector.h"
#import "Seminar.h"

#import "Type+Load_Data.h"
#import "Sections+Load_Data.h"

@interface ISSettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *updateDateLabel;

- (void) loadData;

@end

@implementation ISSettingsViewController
@synthesize updateDateLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setUpdateDateLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
- (IBAction)done:(UIBarButtonItem *)sender {

    [[self presentingViewController] dismissModalViewControllerAnimated:YES];

}

// load button pressed
- (IBAction)load:(UIButton *)sender {
    [self loadData];
}

// delete button pressed
- (IBAction)delete:(UIButton *)sender {
}

#pragma mark - Loading staff from website

- (void) loadData {
//    dispatch_queue_t fetchQ = dispatch_queue_create("Seminar fetcher", NULL);
//    dispatch_async(fetchQ, ^{
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Загружаю семинары", @"Loading seminars data from the web")];
        NSDictionary *sectionsAndTypes = [SeminarFetcher sectionsAndTypes];
        
//        [self.managedObjectContext performBlock:^{
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
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Семинары загружены!", @"Seminars loaded successfully")];
    
//        }]; // end managedObjectContext performBlock
        
//    }); // end dispatch_async(fetchQ) block
    
//    dispatch_release(fetchQ);
    
}


@end
