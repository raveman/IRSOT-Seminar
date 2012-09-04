//
//  ISSeminarViewController.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 04.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//
// TODO: переделать все UILabel в UITextView, чтобы у пользователя была возможность копи-паста

#import "ISAppDelegate.h"

#import "ISSeminarViewController.h"
#import "ISWebviewViewController.h"
#import "ISLectorViewController.h"

#import "Helper.h"
#import "Sections.h"
#import "Type.h"
#import "Lector.h"
#import "Seminar+Load_Data.h"

#import "SHK.h"
#import "SHKItem.h"
#import "SHKFacebook.h"
#import "SHKTwitter.h"
#import "SHKEvernote.h"
#import "SHKMail.h"
#import "SHKVkontakte.h"

#define ADD_BOOKMARK @"Добавить закладку"
#define VIEW_ON_WEB @"Посмотреть полную версию"

@interface ISSeminarViewController () <UIActionSheetDelegate, UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *attendSeminarButton;
@property (weak, nonatomic) IBOutlet UITextView *seminarName;
@property (weak, nonatomic) IBOutlet UILabel *seminarDate;
@property (weak, nonatomic) IBOutlet UILabel *sectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lectorsLabel;
@property (weak, nonatomic) IBOutlet UILabel *programLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIWebView *programWebView;
@property (weak, nonatomic) IBOutlet UITableView *lectorTableView;

@property (weak, nonatomic) UIActionSheet *actionSheet;

@property (strong, nonatomic) NSArray *lectors;

@end

@implementation ISSeminarViewController

@synthesize attendSeminarButton = _attendSeminarButton;
@synthesize seminarName = _seminarName;
@synthesize seminarDate = _seminarDate;
@synthesize sectionLabel = _sectionLabel;
@synthesize typeLabel = _typeLabel;
@synthesize lectorsLabel = _lectorsLabel;
@synthesize programLabel = _programLabel;
@synthesize scrollView = _scrollView;
@synthesize programWebView = _programWebView;
@synthesize lectorTableView = _lectorTableView;
@synthesize actionSheet = _actionSheet;

@synthesize seminar = _seminar;
@synthesize seminarID = _seminarID;

@synthesize lectors = _lectors;

- (void) recalculateElementsBounds
{
    // получаем размеры заголовка

    CGSize currentSize = self.view.frame.size;
    [Helper resizeRectButton:self.attendSeminarButton withSize:currentSize];
    CGRect headerRect = [Helper resizeTextView:self.seminarName withSize: currentSize];
    
    // опускаем дату проведения семинара
    CGRect rect = self.seminarDate.frame;
    rect.origin.y = headerRect.origin.y + headerRect.size.height;
    self.seminarDate.frame = rect;
    int height = rect.origin.y + rect.size.height;
    
    // опускаем тип и раздел семинаров на высоту предыдущих двух
    rect = self.sectionLabel.frame;
    rect.origin.y = height + rect.size.height - 20;
    self.sectionLabel.frame = rect;
    
    rect = self.typeLabel.frame;
    //    rect.origin.y = headerRect.origin.y + headerRect.size.height + 20;
    rect.origin.y = height + rect.size.height - 20;
    rect.origin.x = currentSize.width - rect.size.width - 20;
    self.typeLabel.frame = rect;
    
    // получаем общую высоту текущего заголовка: заголовок + тип и секция семинара
    height = rect.origin.y + rect.size.height;
    
    // опускаем лекторов на текущее смещение
//    rect = [Helper resizeLabel:self.lectorsLabel withSize:currentSize];
//    rect.origin.y = height + 10;
//    self.lectorsLabel.frame = rect;
//    
//    height = rect.origin.y + rect.size.height;
    
    // опускаем лабел программа

    rect = self.programLabel.frame;
    rect.origin.y = height + rect.size.height;
    self.programLabel.frame = rect;

    height = rect.origin.y + rect.size.height;

    // осталось опустить описание семинара
//    rect = self.programTextView.frame;
//    rect.origin.y = height + 10;
//    CGRect programRect = [Helper resizeTextView:self.programTextView withSize: currentSize];
//    rect.size.width = programRect.size.width;
//    self.programTextView.frame = rect;
    
    rect = self.programWebView.frame;
    rect.origin.y = height;
    rect.size.width = currentSize.width;
//    CGRect programRect = [Helper resizeTextView:self.programTextView withSize: currentSize];
//    rect.size.width = programRect.size.width;
    self.programWebView.frame = rect;
    CGSize size = rect.size;

    // берем высоту вебвью и приплюсовываем размер хедера
    size.height += height;
    
    int tableHeight = self.lectorTableView.rowHeight * [self.seminar.lectors count];
    CGRect tableFrame = self.lectorTableView.frame;
    tableFrame.size.width = currentSize.width;

    tableFrame.origin.y = size.height;
    tableFrame.size.height += tableHeight;
    self.lectorTableView.frame = tableFrame;

    size.height += tableHeight + 80;
    
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentSize = size;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.managedObjectContext = [[ISAppDelegate sharedDelegate] managedObjectContext];
    
    // we have an ID, which we have to find, not seminar itself.
    if (self.seminarID) {
        self.seminar = [self findSeminarWithID:self.seminarID];
    }
    
    if (!self.seminar) {
        // we have no any seminar, may be it was deleted from main catalog.
        // we shoud write error
        self.seminarName.text = @"Такого семинара нет в каталоге!";
        self.seminarName.textColor = [UIColor redColor];

        self.seminarDate.hidden = YES;
        self.sectionLabel.hidden = YES;
        self.typeLabel.hidden = YES;
        self.lectorsLabel.hidden = YES;
        self.programWebView.hidden = YES;
        self.lectorTableView.hidden = YES;
        self.programLabel.hidden = YES;
        self.attendSeminarButton.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
    } else {
        self.title = self.seminar.name;
        
        if ([[self.seminar.name substringToIndex:1] isEqualToString:@"«"]) {
                self.seminarName.text = [NSString stringWithFormat:@"%@»", self.seminar.name];
        } else {
            self.seminarName.text = [NSString stringWithFormat:@"«%@»", self.seminar.name];
        }
        
        UIImage *whiteButton = [UIImage imageNamed:@"whiteButton.png"];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            whiteButton = [whiteButton resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        } else {
            whiteButton = [whiteButton resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
        }
        [self.attendSeminarButton setBackgroundImage:whiteButton forState:UIControlStateNormal];
        
        if ([self.seminar.lectors count]) {
            NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
            self.lectors = [[self.seminar.lectors allObjects] sortedArrayUsingDescriptors:sortDescriptors];
        }
        
        self.seminarDate.text = [self.seminar stringWithSeminarDates];
        self.sectionLabel.text = self.seminar.section.name;
        self.typeLabel.text = self.seminar.type.name;
        self.lectorsLabel.text  = [self.seminar stringWithLectorNames];
        [self.programWebView loadHTMLString:[self makeHTMLPageFromString:self.seminar.program] baseURL:[NSURL URLWithString:@"http://www.ruseminar.ru"]];
        self.programWebView.userInteractionEnabled = NO;
        self.programWebView.scrollView.scrollEnabled = NO;
        self.programWebView.scalesPageToFit = YES;
        self.programWebView.delegate = self;
        self.lectorTableView.dataSource = self;
        self.lectorTableView.delegate = self;
    }
}

- (void)viewDidUnload
{
    [self setSectionLabel:nil];
    [self setTypeLabel:nil];
    [self setLectorsLabel:nil];

    [self setScrollView:nil];
    [self setSeminarDate:nil];
    [self setSeminarName:nil];
    [self setAttendSeminarButton:nil];
    [self setProgramWebView:nil];
    [self setProgramLabel:nil];
    [self setLectorTableView:nil];
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

- (void) viewWillAppear:(BOOL)animated
{
    [self recalculateElementsBounds];
    NSIndexPath *indexPath = [self.lectorTableView indexPathForSelectedRow];
    if (indexPath != nil) {
        [self.lectorTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    [super viewWillAppear:animated];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    [self.programWebView loadHTMLString:[self makeHTMLPageFromString:self.seminar.program] baseURL:[NSURL URLWithString:@"http://www.ruseminar.ru"]];
//    [self.programWebView reload];
//    [self recalculateElementsBounds];
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Bill Webview"]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.ruseminar.ru/bill?id=%@", self.seminar.ruseminarID]];
        
        ISWebviewViewController *dvc = (ISWebviewViewController *)segue.destinationViewController;
        [dvc setUrl:url];
        [dvc setWebviewTitle:@"Принять участие"];
    } else if ([segue.identifier isEqualToString:@"View On Web"]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", self.seminar.ruseminar_url]];
        
        ISWebviewViewController *dvc = (ISWebviewViewController *)segue.destinationViewController;
        [dvc setUrl:url];
        [dvc setWebviewTitle:self.seminar.name];
    } else if ([segue.identifier isEqualToString:@"Lector View"]) {
        ISLectorViewController *dvc = (ISLectorViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.lectorTableView indexPathForSelectedRow];
        Lector *lector = [self.lectors objectAtIndex:indexPath.row];
        [dvc setLector:lector];
    }
}

#pragma mark - Button Actions

- (IBAction)share:(UIBarButtonItem *)sender {
    if (self.actionSheet) {
        // do nothing
    } else {
        NSString *addBookmarkButton = NSLocalizedString(ADD_BOOKMARK, @"Add seminar bookmark button title");
        NSString *viewOnWebButton = NSLocalizedString(VIEW_ON_WEB, @"Add seminar bookmark button title");
        NSString *evernoteButton = NSLocalizedString(@"Сохранить в Evernote", @"Share on Evernote");
        NSString *twitterButton = NSLocalizedString(@"Отправить в Twitter", @"Share on twitter");
        NSString *facebookButton = NSLocalizedString(@"Отправить в Facebook", @"Share on Facebook");
        NSString *emailButton = NSLocalizedString(@"Отправить по почте", @"Share via E-Mail");
        NSString *vkontakteButton = NSLocalizedString(@"Отправить в Вконтакте", @"Share on Vkontakte");
//        NSString *odnoklassnikiButton = NSLocalizedString(@"Отправить в Одноклассники", @"Share on Odnoklassniki");
        
        UIActionSheet *actionSheet = nil;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Закладки" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:addBookmarkButton, viewOnWebButton, emailButton, evernoteButton, twitterButton, facebookButton, nil];
        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Закладки" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:addBookmarkButton, viewOnWebButton, emailButton, evernoteButton, twitterButton, facebookButton, vkontakteButton, nil];
        }
        
        [actionSheet showFromBarButtonItem:sender animated:YES];
        self.actionSheet = actionSheet;
    }
}

#pragma mark - UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
    } else if ([choice isEqualToString:ADD_BOOKMARK]) {
        NSUbiquitousKeyValueStore *bookmarksStore = [NSUbiquitousKeyValueStore defaultStore];
        NSMutableArray *bookmarksArray = [[bookmarksStore arrayForKey:BOOKMARKS_KEY] mutableCopy];
        BOOL found = NO;
        if (bookmarksArray == nil) {
            bookmarksArray = [NSMutableArray array];
        } else {
            for (NSDictionary *item in bookmarksArray) {
                if ([[item objectForKey:BOOKMARK_SEMINAR_ID_KEY] integerValue] == [self.seminar.id integerValue]) {
                    found = YES;
                }
            }
        } 
        if (!found) {
            NSDictionary *bookmark = [NSDictionary dictionaryWithObjectsAndKeys:self.seminar.name, BOOKMARK_SEMINAR_NAME_KEY, self.seminar.id, BOOKMARK_SEMINAR_ID_KEY, [self.seminar stringWithSeminarDates], BOOKMARK_SEMINAR_DATE_KEY , nil];
            [bookmarksArray addObject:bookmark];
            [bookmarksStore setObject:bookmarksArray forKey:BOOKMARKS_KEY];
            [[NSNotificationCenter defaultCenter] postNotificationName:NSUbiquitousKeyValueStoreDidChangeLocallyNotification object:bookmarksStore userInfo:bookmark];
        }
    } else if ([choice isEqualToString:VIEW_ON_WEB]) {
        [self performSegueWithIdentifier:@"View On Web" sender:self];
    } else if (buttonIndex == 2) {
        //share to mail
        SHKItem *item = [SHKItem URL:[NSURL URLWithString:self.seminar.ruseminar_url] title:[NSString stringWithFormat:@"Семинар ИРСОТ: «%@»", self.seminar.name] contentType:SHKShareTypeURL];
        [SHKMail shareItem:item];
    } else if (buttonIndex == 3) {
        //share to evernote
        SHKItem *item = [SHKItem URL:[NSURL URLWithString:self.seminar.ruseminar_url] title:[NSString stringWithFormat:@"Семинар ИРСОТ: «%@»", self.seminar.name] contentType:SHKShareTypeURL];
        [SHKEvernote shareItem:item];
    } else if (buttonIndex == 4) {
        //share to twitter
        SHKItem *item = [SHKItem URL:[NSURL URLWithString:self.seminar.ruseminar_url] title:[NSString stringWithFormat:@"Семинар @irsot: «%@»", self.seminar.name] contentType:SHKShareTypeURL];
        [SHKTwitter shareItem:item];
    } else if (buttonIndex == 5) {
        //share to facebook
        SHKItem *item = [SHKItem URL:[NSURL URLWithString:self.seminar.ruseminar_url] title:[NSString stringWithFormat:@"«%@»", self.seminar.name] contentType:SHKShareTypeURL];
        [SHKFacebook shareItem:item];
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (buttonIndex == 6) {
            //share to vkontakte
            SHKItem *item = [SHKItem URL:[NSURL URLWithString:self.seminar.ruseminar_url] title:[NSString stringWithFormat:@"Семинар ИРСОТ: «%@»", self.seminar.name] contentType:SHKShareTypeURL];
            [SHKVkontakte shareItem:item];
        }
    }
}

#pragma mark - Core Data Fetch

- (Seminar *)findSeminarWithID:(NSInteger)seminarID 
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Seminar"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    // no predicate because we want ALL the Photographers
    
    request.predicate = [NSPredicate predicateWithFormat:@"id == %d", seminarID];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    NSError *error = nil;
	if (![fetchedResultsController performFetch:&error]) {
        // TODO: handle error!
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return [[fetchedResultsController fetchedObjects] lastObject];
}

#pragma mark - UIWebViewDelegate

- (NSString *)makeHTMLPageFromString:(NSString *)html
{
    NSString *header = @"<!doctype html>\n<html>\n<head> \n";

    NSError *error = nil;
    NSString *seminarCSSData = [NSString stringWithContentsOfURL:[[ISAppDelegate sharedDelegate] seminarCSS] encoding:NSUTF8StringEncoding error:&error];
    NSString *bkCSSData = [NSString stringWithContentsOfURL:[[ISAppDelegate sharedDelegate] bkCSS] encoding:NSUTF8StringEncoding error:&error];
    
    header = [NSString stringWithFormat:@"%@\n <style type=\"text/css\">\n %@\n", header, seminarCSSData];
    header = [NSString stringWithFormat:@"%@\n%@", header, bkCSSData];
    header = [NSString stringWithFormat:@"%@\n</style>", header];
    
    header = [NSString stringWithFormat:@"%@\n %@", header, @"<style type=\"text/css\"> \n"
    "html {"
        "-webkit-text-size-adjust: none; "
    "}\n"
    "body {font-family: \"helvetica neue\"; font-size: 14; }\n"
    "ul {\n"
        "list-style-position: outside;\n"
        "list-style-type: square;\n"
        "padding-left: 15px;\n"
    "}\n"];
//    "ul {\n"
//        "width: 100% !important\n"
//    "}\n"
    
//    CGSize size = [[UIScreen mainScreen] bounds].size;
//    int width = 0;
//    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
//        width = size.width;
//    } else {
//        width = size.height;
//    }

    CGRect frame =  [[UIScreen mainScreen] bounds];
    int width = 0;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (deviceOrientation == UIDeviceOrientationPortrait || deviceOrientation == UIDeviceOrientationUnknown || deviceOrientation == UIDeviceOrientationPortraitUpsideDown ) width = frame.size.width - 10;
        else width = frame.size.height - 10;

    header = [NSString stringWithFormat:@"%@ #program_page { width: %dpx; font-size: small; margin: 5px; }", header, width];

    header = [NSString stringWithFormat:@"%@ %@", header, @"</style> \n"
    "<meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=1.0;'>\n"
    "</head> \n<body>\n<div id=\"program_page\">\n"];

    NSString *footer = @"</div>\n</body>\n</html>";

    NSString *fullHTML = [NSString stringWithFormat:@"%@\n%@\n%@", header, html, footer];
    
    // delete all width 500px/600px
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"width:.[0-9]+px;" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSString *modifiedString = [regex stringByReplacingMatchesInString:fullHTML options:0 range:NSMakeRange(0, [fullHTML length]) withTemplate:@"width: 95%;"];

    
    return modifiedString;
}

- (void) reloadHtml
{
    [self.programWebView stringByEvaluatingJavaScriptFromString:@"var e = document.createEvent('Events'); e.initEvent('orientationchange', true, false); document.dispatchEvent(e);"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webview
{
//    CGRect oldBounds = [webview bounds];
//    CGFloat height = [[webview stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
//    [webview setBounds:CGRectMake(oldBounds.origin.x, oldBounds.origin.y, oldBounds.size.width, height)];

    CGRect frame = webview.frame;
//    frame.size.height = 1;
//    frame.size.width = 1;
//    webview.frame = frame;
    CGSize fittingSize = [webview sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    frame.size.width = self.view.frame.size.width;
    webview.frame = frame;
    
//    [webview sizeToFit];
//    NSString *output = [webview stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"program_page\").offsetHeight;"];
//    NSString *output = [webview stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
//
//    NSLog(@"height: %@", output);

//    CGRect frame = webview.frame;
//    frame.size.height = [output integerValue];
//    webview.frame = frame;
        
    [self recalculateElementsBounds];

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.seminar.lectors count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Lector Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue Medium" size:15.0];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:13.0];
    
    if ([self.seminar.lectors count]) {
        Lector *lector = [self.lectors objectAtIndex:indexPath.row];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.textLabel.text = lector.name;
        } else {
            cell.textLabel.text = [lector fullName];
        }
//        cell.detailTextLabel.text = [lector stringWithSeminarDates];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSInteger count = [self.seminar.lectors count];
    NSString *title = [NSString string];
    
    switch (count) {
        case 0:
            title = @"";
            break;
        case 1:
            title = NSLocalizedString(@"Семинар проводит:", @"Seminar Lectors Table Title");
            break;
        default:
            title = NSLocalizedString(@"Семинар проводят:", @"Seminar Lectors Table Title");
            break;
    }
    return title;
}



#pragma mark - UITableViewDelegate

@end
