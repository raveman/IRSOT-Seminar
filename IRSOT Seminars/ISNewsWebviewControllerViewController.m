//
//  ISNewsWebviewControllerViewController.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 09.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "SVProgressHUD/SVProgressHUD.h"
#import "ISNewsWebviewControllerViewController.h"
#import "Helper.h"
#import "ISTheme.h"

@interface ISNewsWebviewControllerViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (strong, nonatomic) UIBarButtonItem *refreshButton;

@end

@implementation ISNewsWebviewControllerViewController
@synthesize webview;
@synthesize backButton;
@synthesize forwardButton;
@synthesize refreshButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSURL *url;
    if (self.tabBarController.selectedIndex == 2) {
        self.title = NSLocalizedString(@"Video", @"Video Title");
        self.navigationItem.title = NSLocalizedString(@"Video", @"Video Title");
        url = [NSURL URLWithString:@"http://youtube.com/irsot"];
    } else if (self.tabBarController.selectedIndex == 3) {
        self.title = NSLocalizedString(@"News", @"News Title");
        self.navigationItem.title = NSLocalizedString(@"News", @"News Title");
        url = [NSURL URLWithString:@"http://twitter.com/irsot"];
    }
    
    self.webview.scalesPageToFit = YES;
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest: request];
    self.navigationItem.rightBarButtonItem.tintColor = [ISTheme barButtonItemColor];
    self.navigationItem.leftBarButtonItem.tintColor = [ISTheme barButtonItemColor];
    
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:  self.forwardButton, self.refreshButton, nil];
    
}

- (void)viewDidUnload
{
    [self setWebview:nil];

    [self setBackButton:nil];
    [self setForwardButton:nil];
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
#pragma mark - web buttons methods

- (IBAction)backButtonPressed:(UIBarButtonItem *)sender {
    [self.webview goBack];
}
- (IBAction)forwardButtonPressed:(UIBarButtonItem *)sender {
    [self.webview goForward];
}

- (void)refresh:(UIBarButtonItem *)sender {
    [self.webview reload];
}

#pragma mark - IUWebviewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
//    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (webview.canGoBack) self.backButton.enabled = YES;
        else self.backButton.enabled = NO;
    if (webview.canGoForward) self.forwardButton.enabled = YES;
        else self.forwardButton.enabled = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Load error", @"Load error")];
}

@end
