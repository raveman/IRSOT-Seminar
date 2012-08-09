//
//  ISWebviewViewController.m
//  RuSeminar
//
//  Created by Bob Ershov on 09.07.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "SVProgressHUD/SVProgressHUD.h"
#import "ISWebviewViewController.h"

@interface ISWebviewViewController () <UIWebViewDelegate>
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UINavigationBar *modalNavigationBar;

@end

@implementation ISWebviewViewController
//@synthesize scrollview;
@synthesize webview;
@synthesize modalNavigationBar;

@synthesize url = _url;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.webview.scalesPageToFit = YES;
    [self.webview loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController) {
        self.modalNavigationBar.hidden = YES;

    } else {
        self.modalNavigationBar.topItem.title = self.webviewTitle;
        CGRect webviewFrame = self.webview.frame;
        webviewFrame.size.height -= self.modalNavigationBar.frame.size.height;
        webviewFrame.origin.y = self.modalNavigationBar.frame.size.height;
        self.webview.frame = webviewFrame;
    }
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setWebview:nil];
//    [self setScrollview:nil];
    [self setModalNavigationBar:nil];
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

- (IBAction)done:(UIBarButtonItem *)sender {
        [[self presentingViewController] dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate
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
    [SVProgressHUD showErrorWithStatus:@"Ошибка :-("];
    
}


@end
