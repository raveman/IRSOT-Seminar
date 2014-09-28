//
//  ISWebviewViewController.m
//  RuSeminar
//
//  Created by Bob Ershov on 09.07.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "SVProgressHUD/SVProgressHUD.h"
#import "ISWebviewViewController.h"
#import "Helper.h"
#import "ISTheme.h"

@interface ISWebviewViewController () <UIWebViewDelegate, UIActionSheetDelegate>
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UINavigationBar *modalNavigationBar;
@property (weak, nonatomic) IBOutlet UIToolbar *modalWebToolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reloadButton;

@property (weak, nonatomic) UIActionSheet *actionSheet;

@end

@implementation ISWebviewViewController
//@synthesize scrollview;
@synthesize webview;
@synthesize modalNavigationBar;
@synthesize modalWebToolBar;
@synthesize backButton;
@synthesize forwardButton;
@synthesize reloadButton;
@synthesize actionButton;

@synthesize actionSheet = _actionSheet;

@synthesize url = _url;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    NSMutableArray *buttons = self.modalWebToolBar.items.mutableCopy;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacer.width = 10;
    [buttons insertObject:spacer atIndex:1];
    [buttons insertObject:spacer atIndex:3];
    [buttons insertObject:spacer atIndex:3];
    self.modalWebToolBar.items = buttons;
    
    self.backButton.title = @" ";
    self.forwardButton.title = @" ";
    self.actionButton.title = @" ";
    self.reloadButton.title = @" ";
    
    self.backButton.tintColor = [ISTheme navigationBarBackgroundColor];
    self.forwardButton.tintColor = [ISTheme navigationBarBackgroundColor];
    self.actionButton.tintColor = [ISTheme navigationBarBackgroundColor];
    self.reloadButton.tintColor = [ISTheme navigationBarBackgroundColor];
    
    if (self.navigationController) {
        self.modalNavigationBar.hidden = YES;
        self.modalWebToolBar.hidden = YES;

    } else {
        self.modalNavigationBar.topItem.title = self.webviewTitle;
        self.modalWebToolBar.hidden = NO;
        CGRect webviewFrame = self.webview.frame;
        webviewFrame.size.height -= self.modalNavigationBar.frame.size.height;
        webviewFrame.origin.y = self.modalNavigationBar.frame.size.height;
        self.webview.frame = webviewFrame;
        self.backButton.enabled = NO;
        self.forwardButton.enabled = NO;
        self.actionButton.enabled = NO;
        self.reloadButton.enabled = NO;
    }
    
	// Do any additional setup after loading the view.

    self.modalWebToolBar.barStyle = UIBarStyleDefault;
//    self.modalWebToolBar.barTintColor = [ISTheme navigationBarBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.webview.scalesPageToFit = YES;
    [self.webview loadRequest:[NSURLRequest requestWithURL:self.url]];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
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

- (IBAction)done:(UIBarButtonItem *)sender {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
    
    if (webview.canGoBack) self.backButton.enabled = YES;
        else self.backButton.enabled = NO;
    if (webview.canGoForward) self.forwardButton.enabled = YES;
        else self.forwardButton.enabled = NO;
    
    self.reloadButton.enabled = YES;
    self.actionButton.enabled = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
   
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [error localizedDescription]]];
    
}

#pragma mark - web buttons methods

- (IBAction)backButtonPressed:(UIBarButtonItem *)sender {
    [self.webview goBack];
}
- (IBAction)forwardButtonPressed:(UIBarButtonItem *)sender {
    [self.webview goForward];
}
- (IBAction)reloadButtonPressed:(UIBarButtonItem *)sender {
    [self.webview reload];
}

#pragma mark - Button Actions
- (IBAction)share:(UIBarButtonItem *)sender {
    if (self.actionSheet) {
        // do nothing
    } else {
        NSString *openInSafariButton = NSLocalizedString(@"Open in Safari", @"Open in Safari");
        
        UIActionSheet *actionSheet = nil;
        
        actionSheet = [[UIActionSheet alloc] initWithTitle:self.webview.request.URL.absoluteString delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:openInSafariButton,  nil];
        [actionSheet showFromBarButtonItem:sender animated:YES];
        self.actionSheet = actionSheet;
    }

}

#pragma mark - UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
    } else if (buttonIndex == 0) {
        //open in Safari
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.webview.request.URL.absoluteString]];
    }
}

@end
