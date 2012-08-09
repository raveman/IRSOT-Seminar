//
//  ISNewsWebviewControllerViewController.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 09.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "ISNewsWebviewControllerViewController.h"

@interface ISNewsWebviewControllerViewController ()

@end

@implementation ISNewsWebviewControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
