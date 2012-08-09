//
//  ISNewsWebviewControllerViewController.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 09.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "SVProgressHUD/SVProgressHUD.h"
#import "ISNewsWebviewControllerViewController.h"

@interface ISNewsWebviewControllerViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation ISNewsWebviewControllerViewController
@synthesize webview;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    self.title = NSLocalizedString(@"Новости ИРСОТ", @"News Webview Title");
    self.navigationItem.title = NSLocalizedString(@"Новости ИРСОТ", @"News Webview Title");
    
    NSURL *url = [NSURL URLWithString:@"http://twitter.com/irsot"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest: request];
}

- (void)viewDidUnload
{
    [self setWebview:nil];
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

#pragma mark - IUWebviewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:@"Ошибка загрузки :-("];
    
}

@end
