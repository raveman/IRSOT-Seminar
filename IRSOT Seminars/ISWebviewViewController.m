//
//  ISWebviewViewController.m
//  RuSeminar
//
//  Created by Bob Ershov on 09.07.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "ISWebviewViewController.h"

@interface ISWebviewViewController ()
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation ISWebviewViewController
//@synthesize scrollview;
@synthesize webview;

@synthesize url = _url;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.webview.scalesPageToFit = YES;
    [self.webview loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setWebview:nil];
//    [self setScrollview:nil];
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
