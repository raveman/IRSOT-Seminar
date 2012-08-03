//
//  ISSettingsViewController.m
//  Seminar.Ru
//
//  Created by Bob Ershov on 01.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "ISSettingsViewController.h"
#import "SeminarFetcher.h"

#import "Type.h"
#import "Sections.h"
#import "Lector.h"
#import "Seminar.h"

@interface ISSettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *updateDateLabel;

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

#pragma mark - Loading staff from website

- (void) loadData {
    dispatch_queue_t fetchQ = dispatch_queue_create("Seminar fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSDictionary *sectionsAndTypes = [SeminarFetcher sectionsAndTypes];
        
        [self.managedObjectContext performBlock:^{
            NSArray *sections = [sectionsAndTypes valueForKey:@"sections"];
            NSArray *types = [sectionsAndTypes valueForKey:@"types"];
            
            for (NSDictionary *section in sections) {
                Sections *newSection = [NSEntityDescription insertNewObjectForEntityForName:@"Sections" inManagedObjectContext:self.managedObjectContext];
                newSection.id = [newSection valueForKey:@"id"];
                newSection.name = [newSection valueForKey:@"name"];
                newSection.machine_name = [newSection valueForKey:@"machine_name"];
            }
            
            for (NSDictionary *type in types) {
                Type *newType = [NSEntityDescription insertNewObjectForEntityForName:@"Type" inManagedObjectContext:self.managedObjectContext];
                newType.id = [type valueForKey:@"id"];
                newType.name = [type valueForKey:@"name"];
                newType.machine_name = [type valueForKey:@"machine_name"];
            }
            
            
        }]; // end managedObjectContext performBlock
    }); // end dispatch_async(fetchQ) block
    
    dispatch_release(fetchQ);
    
}


@end
