//
//  ISCalendarViewController.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 21.08.12.
//  Copyright (c) 2012 IRSOT. All rights reserved.
//



#import "ISCalendarViewController.h"

@interface ISCalendarViewController ()

@end

@implementation ISCalendarViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;


- (void)viewDidLoad
{
    [super viewDidLoad];
//	[self.monthView selectDate:[NSDate month]];
}

- (void)viewDidUnload
{
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


@end
