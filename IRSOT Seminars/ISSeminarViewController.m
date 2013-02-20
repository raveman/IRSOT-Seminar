//
//  ISSeminarViewController.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 04.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//
// TODO: переделать все UILabel в UITextView, чтобы у пользователя была возможность копи-паста

#import <EventKit/EventKit.h>

#import "ISAppDelegate.h"

#import "ISSeminarViewController.h"
#import "ISWebviewViewController.h"
#import "ISLectorViewController.h"
#import "ISSettingsViewController.h"

#import "Helper.h"
#import "Sections.h"
#import "Type.h"
#import "Lector.h"
#import "Seminar+Load_Data.h"
#import "Sections+Load_Data.h"
#import "Type+Load_Data.h"
#import "ISAlertTimes.h"

#import "SHK.h"
#import "SHKItem.h"
#import "SHKFacebook.h"
#import "SHKTwitter.h"
#import "SHKEvernote.h"
#import "SHKMail.h"
#import "SHKVkontakte.h"

//#define ADD_BOOKMARK @"Добавить закладку"
//#define VIEW_ON_WEB @"Посмотреть полную версию"

const NSUInteger sectionHeaderHeight = 30;

#define ADD_BOOKMARK NSLocalizedString(@"Add bookmark", @"Add bookmark")
#define VIEW_ON_WEB NSLocalizedString(@"View on web site", @"View on web site")


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

@property (strong, nonatomic) NSString *html;

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

@synthesize html = _html;

- (NSString *) html
{
    if (!_html) {
        _html = [self makeHTMLPageFromString:self.seminar.program];
    }
    
    return _html;
}

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
    height = rect.origin.y + rect.size.height - 10;
    
    // опускаем лекторов на текущее смещение
//    rect = [Helper resizeLabel:self.lectorsLabel withSize:currentSize];
//    rect.origin.y = height + 10;
//    self.lectorsLabel.frame = rect;
//    
//    height = rect.origin.y + rect.size.height;
    

//    rect = self.programTextView.frame;
//    rect.origin.y = height + 10;
//    CGRect programRect = [Helper resizeTextView:self.programTextView withSize: currentSize];
//    rect.size.width = programRect.size.width;
//    self.programTextView.frame = rect;

    CGSize size = rect.size;
    size.height = height + 10;
    
    int tableHeight = self.lectorTableView.rowHeight * [self.seminar.lectors count];
    tableHeight = tableHeight + sectionHeaderHeight + 25;
    CGRect tableFrame = self.lectorTableView.frame;
    tableFrame.size.width = currentSize.width;

    tableFrame.origin.y = size.height;
    tableFrame.size.height = tableHeight;
    self.lectorTableView.frame = tableFrame;

    size.height += tableHeight;// + 40;

    // опускаем лабел программа
    
    rect = self.programLabel.frame;
    rect.origin.y = size.height + rect.size.height;
    self.programLabel.frame = rect;
    
    height = rect.origin.y + rect.size.height;

    size.height = height;
    // осталось опустить описание семинара

    rect = self.programWebView.frame;
    rect.origin.y = size.height;
    rect.size.width = currentSize.width;
    self.programWebView.frame = rect;
    
    // берем высоту вебвью и приплюсовываем размер хедера
    size.height += rect.size.height;
    
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentSize = size;
}

- (void) resizeWebview:(UIWebView *)webview
{
    CGRect oldBounds = webview.bounds;
    //in the document you can use your string ... ans set theheight
//    [webview stringByEvaluatingJavaScriptFromString:@"var e = document.createEvent('Events'); e.initEvent('orientationchange', true, false); document.dispatchEvent(e);"];
    
    CGFloat height = [[webview stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
//    NSLog(@"Height: %f", height);
    [webview setBounds:CGRectMake(oldBounds.origin.x, oldBounds.origin.y, oldBounds.size.width, height)];
    
//    [self recalculateElementsBounds];
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
        self.attendSeminarButton.hidden = YES;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
    } else {
        self.title = self.seminar.name;
        
        if ([[self.seminar.name substringToIndex:1] isEqualToString:@"«"]) {
                self.seminarName.text = [NSString stringWithFormat:@"%@»", self.seminar.name];
        } else {
            self.seminarName.text = [NSString stringWithFormat:@"«%@»", self.seminar.name];
        }
        
        UIImage *whiteButton = [UIImage imageNamed:@"whiteButton.png"];
        UIImage *whiteButtonHighlight = [UIImage imageNamed:@"whiteButtonHighlight.png"];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            whiteButton = [whiteButton resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
            whiteButtonHighlight = [whiteButtonHighlight resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        } else {
            whiteButton = [whiteButton resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
            whiteButtonHighlight = [whiteButtonHighlight resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
        }
        [self.attendSeminarButton setBackgroundImage:whiteButton forState:UIControlStateNormal];
        [self.attendSeminarButton setBackgroundImage:whiteButtonHighlight forState:UIControlStateHighlighted];
        
        if ([self.seminar.lectors count]) {
            NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
            self.lectors = [[self.seminar.lectors allObjects] sortedArrayUsingDescriptors:sortDescriptors];
        }
        
        self.seminarDate.text = [self.seminar stringWithSeminarDates];
        
        self.sectionLabel.text = [[[self.seminar.section.name substringToIndex:1] uppercaseString] stringByAppendingString:[self.seminar.section.name  substringFromIndex:1]];

        self.typeLabel.text = self.seminar.type.name;

        [self.programWebView loadHTMLString:self.html baseURL:[NSURL URLWithString:@"http://www.ruseminar.ru"]];
        self.programWebView.userInteractionEnabled = NO;
        self.programWebView.scrollView.scrollEnabled = NO;
        self.programWebView.scalesPageToFit = YES;
        self.programWebView.delegate = self;
        self.lectorTableView.dataSource = self;
        self.lectorTableView.delegate = self;
        
        self.scrollView.scrollsToTop = YES;
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

- (void) viewWillAppear:(BOOL)animated
{

//    [self recalculateElementsBounds];

    NSIndexPath *indexPath = [self.lectorTableView indexPathForSelectedRow];
    if (indexPath != nil) {
        [self.lectorTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.actionSheet dismissWithClickedButtonIndex:[self.actionSheet destructiveButtonIndex] animated:YES];
    
    [super viewWillDisappear:animated];
}

#pragma mark - View Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self recalculateElementsBounds];
//   [self.programWebView loadHTMLString:self.html baseURL:[NSURL URLWithString:@"http://www.ruseminar.ru"]];
    [self.programWebView stringByEvaluatingJavaScriptFromString:@"var e = document.createEvent('Events'); "
     @"e.initEvent('orientationchange', true, false);"
     @"document.dispatchEvent(e); "];

    [self.scrollView scrollRectToVisible:self.view.bounds animated:YES];

}

#pragma mark - View Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Bill Webview"]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.ruseminar.ru/bill?id=%@", self.seminar.ruseminarID]];
        
        ISWebviewViewController *dvc = (ISWebviewViewController *)segue.destinationViewController;
        [dvc setUrl:url];
        [dvc setWebviewTitle:NSLocalizedString(@"Attend seminar", @"Attend seminar")];
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
        NSString *addBookmarkButton = NSLocalizedString(@"Add bookmark", @"Add seminar bookmark button title");
        NSString *viewOnWebButton = NSLocalizedString(@"View on web site", @"Add seminar bookmark button title");
        NSString *addToCalendar = NSLocalizedString(@"Add to calendar", @"Add to calendar button title");

        
        NSString *twitterButton = NSLocalizedString(@"Share on Twitter", @"Share on twitter");
        NSString *facebookButton = NSLocalizedString(@"Share on Facebook", @"Share on Facebook");
        NSString *emailButton = NSLocalizedString(@"Email", @"Share via E-Mail");
        NSString *vkontakteButton = NSLocalizedString(@"Share on Vkontakte", @"Share on Vkontakte");
        
        UIActionSheet *actionSheet = nil;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Favorites", @"Bookmarks List View Title") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:addBookmarkButton, viewOnWebButton, addToCalendar, emailButton, twitterButton, facebookButton, vkontakteButton, nil];
        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Favorites", @"Bookmarks List View Title") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:addBookmarkButton, viewOnWebButton, addToCalendar, emailButton, twitterButton, facebookButton, vkontakteButton, nil];
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
                    break;
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
        // add to calendar
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        EKEvent *event = [EKEvent eventWithEventStore:eventStore];
        event.title = self.seminar.name;
        NSDate *startDate = self.seminar.date_start;
        NSTimeInterval morning = 9*60*60 + 30*60;
        startDate = [startDate dateByAddingTimeInterval:morning];
        event.startDate = startDate;

        NSDate *endDate = self.seminar.date_end;
        NSTimeInterval evening = 17*60*60 + 30*60;
        endDate = [endDate dateByAddingTimeInterval:evening];
        event.endDate = endDate;
        event.allDay = NO;
        
        if ([ISAlertTimes useCalendarAlerts]) {
            int time = [ISAlertTimes times][[ISAlertTimes savedAlertTimeOption]];
            if (time >= 0) {
                NSTimeInterval alarmOffSet = -1 * 60 * time; // 1 hour
                EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:alarmOffSet];
                [event addAlarm:alarm];
            }
        }

        [event setCalendar:[eventStore defaultCalendarForNewEvents]];

        NSError *error = nil;
        
        // checking for permissions to access calendar
        if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
            // iOS 6 and later
            [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                if (granted) {
                    [eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
                }
            }];
        } else {
            [eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
        }
        
        if (!error) {
            NSString *message = [NSString stringWithFormat:@"%@ «%@» %@", NSLocalizedString(@"Event", @"Calendar event start message"), self.seminar.name, NSLocalizedString(@"added", @"Calendar event end message") ];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Calendar", @"Calendar") message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    } else if (buttonIndex == 3) {
        //share to mail
        SHKItem *item = [SHKItem URL:[NSURL URLWithString:self.seminar.ruseminar_url] title:[NSString stringWithFormat:@"%@: «%@»", NSLocalizedString(@"IRSOT seminar",@"IRSOT Seminar"), self.seminar.name] contentType:SHKURLContentTypeWebpage];
        [SHKMail shareItem:item];
    } else if (buttonIndex == 4) {
        //share to twitter
        SHKItem *item = [SHKItem URL:[NSURL URLWithString:self.seminar.ruseminar_url] title:[NSString stringWithFormat:@"%@ @irsot: «%@»", NSLocalizedString(@"Seminar",@"Seminar"), self.seminar.name] contentType:SHKURLContentTypeWebpage];
        [SHKTwitter shareItem:item];
    } else if (buttonIndex == 5) {
        //share to facebook
        SHKItem *item = [SHKItem URL:[NSURL URLWithString:self.seminar.ruseminar_url] title:[NSString stringWithFormat:@"«%@»", self.seminar.name] contentType:SHKURLContentTypeWebpage];
        [SHKFacebook shareItem:item];
    }
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
       else if (buttonIndex == 6) {
            //share to vkontakte
            SHKItem *item = [SHKItem URL:[NSURL URLWithString:self.seminar.ruseminar_url] title:[NSString stringWithFormat:@"%@: «%@»", NSLocalizedString(@"IRSOT seminar",@"IRSOT Seminar"), self.seminar.name] contentType:SHKURLContentTypeWebpage];
            [SHKVkontakte shareItem:item];
    }
    
    //share to evernote
//    SHKItem *item = [SHKItem URL:[NSURL URLWithString:self.seminar.ruseminar_url] title:[NSString stringWithFormat:@"Семинар ИРСОТ: «%@»", self.seminar.name] contentType:SHKShareTypeURL];
//    [SHKEvernote shareItem:item];
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
    
    header = [NSString stringWithFormat:@"%@\n %@", header, @"<style type=\"text/css\"> \n"];
    
    header = [NSString stringWithFormat:@"%@\n %@", header,
    @"html {"
        "-webkit-text-size-adjust: none;"
    "}\n" ];
    
//    "body {font-family: \"helvetica neue\"; "];

//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        header = [NSString stringWithFormat:@"%@ font-size: %dpt; !important }\n", header, 16];
//    } else {
//        header = [NSString stringWithFormat:@"%@ font-size: %dpt; !important }\n", header, 16];
//    }
    header = [NSString stringWithFormat:@"%@ %@", header, @"ul {\n"
        "list-style-position: outside;\n"
        "list-style-type: square;\n"
        "padding-left: 15px;\n"
    "}\n"];

//    CGRect frame =  [[UIScreen mainScreen] bounds];
//    int width = 0;
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    if (deviceOrientation == UIDeviceOrientationPortrait || deviceOrientation == UIDeviceOrientationUnknown || deviceOrientation == UIDeviceOrientationPortraitUpsideDown ) width = frame.size.width - 10;
//        else width = frame.size.height - 10;

//    header = [NSString stringWithFormat:@"%@ #program_page { width: %dpx; font-size: 11pt; margin: 5px; } !important", header, width];
    header = [NSString stringWithFormat:@"%@ #program_page { font-size: 11pt; margin: 5px; } !important", header];

    header = [NSString stringWithFormat:@"%@ %@", header, @"</style> \n"];

//    NSString *seminarCSSData = [NSString stringWithContentsOfURL:[[ISAppDelegate sharedDelegate] seminarCSS] encoding:NSUTF8StringEncoding error:&error];
//    NSString *bkCSSData = [NSString stringWithContentsOfURL:[[ISAppDelegate sharedDelegate] bkCSS] encoding:NSUTF8StringEncoding error:&error];

    NSArray *cssDataArray = [[ISAppDelegate sharedDelegate] ruseminarCSSFilesData];
    header = [NSString stringWithFormat:@"%@\n <style type=\"text/css\">\n ", header];
    for (NSString *cssData in cssDataArray) {
        header = [NSString stringWithFormat:@"%@\n%@ ", header, cssData];
    }
    header = [NSString stringWithFormat:@"%@\n</style>", header];

//    header = [NSString stringWithFormat:@"%@\n <style type=\"text/css\">\n %@\n", header, seminarCSSData];
//    header = [NSString stringWithFormat:@"%@\n%@", header, bkCSSData];
    
    header = [NSString stringWithFormat:@"%@ %@", header, @"<meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=1.0;'>\n"
    "</head> \n<body>\n<div id=\"program_page\">\n<div class=\"cat_program\">\n"];

    // constructing seminar attending cost
    if (([self.seminar.type.id integerValue] != SEMINAR_TYPE_BK) && ([self.seminar.type.id integerValue] != SEMINAR_TYPE_COURSE)) {
        NSString *cost = [NSString stringWithFormat:@"<p>Регистрационный взнос составляет <strong>%@</strong> руб.<br>\nобеспечивает обед в ресторане отеля, кофе-паузы, раздаточные материалы</p>", self.seminar.cost_full];
        
        // constructing discounts
        NSString *cost_discount = [NSString string];
        if ([self.seminar.cost_discount integerValue] != 0) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"d MMMM"];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
            [dateFormatter setLocale:locale];
            NSDate *discount_date = [self.seminar.date_start dateByAddingTimeInterval:-864000]; // 10 days in seconds: 18*24*60*60
            
            cost_discount = [NSString stringWithFormat:@"<p>При оплате <span style=\"color: #d71632;\"><strong>до %@ </strong></span><br>\n СПЕЦИАЛЬНАЯ ЦЕНА %@ руб.</p>\n", [dateFormatter stringFromDate:discount_date], self.seminar.cost_discount];
        }
        html = [NSString stringWithFormat:@"%@\n <p></p><hr>%@ %@<hr>\n", html, cost, cost_discount];
    }
    
    NSString *footer = @"</div></div>\n</body>\n</html>";

    NSString *fullHTML = [NSString stringWithFormat:@"%@\n%@\n%@", header, html, footer];
    
    // delete all width 500px/600px
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"width:.[0-9]+px;" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSString *modifiedString = [regex stringByReplacingMatchesInString:fullHTML options:0 range:NSMakeRange(0, [fullHTML length]) withTemplate:@"width: 95%;"];

    return modifiedString;
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
    
   [webview sizeToFit];

    NSString *output = [webview stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"program_page\").offsetHeight;"];
//    NSString *output = [webview stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
//    NSLog(@"program_page height: %@", output);

//    CGRect frame = webview.frame;
    frame.size.height = [output integerValue];
    webview.frame = frame;
    
    [self resizeWebview:webview];
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
    
    cell.textLabel.font = [Helper cellMainFont];
    cell.detailTextLabel.font = [Helper cellDetailFont];
    cell.selectionStyle = [Helper cellSelectionStyle];
    
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
    NSInteger seminarType = [self.seminar.type.id integerValue];
    
    switch (seminarType) {
        case SEMINAR_TYPE_SEMINAR:
            if (count == 1) {
                title = NSLocalizedString(@"Seminar host:", @"Seminar Lector Table Title");
            } else {
                title = NSLocalizedString(@"Seminar hosts:", @"Seminar Lectors Table Title");
            }
            break;
        case SEMINAR_TYPE_BK:
            if (count == 1) {
                title = NSLocalizedString(@"Business-class host:", @"BK Lector Table Title");
            } else {
                title = NSLocalizedString(@"Business-class hosts:", @"BK Lectors Table Title");
            }
            break;
        case SEMINAR_TYPE_COURSE:
            if (count == 1) {
                title = NSLocalizedString(@"Course host:", @"Course Lector Table Title");
            } else {
                title = NSLocalizedString(@"Course hosts:", @"Course Lectors Table Title");
            }
            break;
        case SEMINAR_TYPE_CONFERENCE:
            if (count == 1) {
                title = NSLocalizedString(@"Conference host:", @"Conference Lector Table Title");
            } else {
                title = NSLocalizedString(@"Conference hosts:", @"Conference Lectors Table Title");
            }
            break;
        case SEMINAR_TYPE_MASTER_CLASS:
            if (count == 1) {
                title = NSLocalizedString(@"Master-class host:", @"Master class Lector Table Title");
            } else {
                title = NSLocalizedString(@"Master-class hosts:", @"Master class Lectors Table Title");
            }
            break;
        case SEMINAR_TYPE_THEMATIC_WEEK:
            title = NSLocalizedString(@"Lectors:", @"Thematic week Lectors Table Title");
            break;
        case SEMINAR_TYPE_NBU:
            title = NSLocalizedString(@"Lectors:", @"NBU Lectors Table Title");
            break;
        default:
            break;
    }
    
    return title;
}

#pragma mark - UITableViewDelegate
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, sectionHeaderHeight)];
    [headerView setBackgroundColor:[UIColor clearColor]];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 3, tableView.bounds.size.width - 18, 18)];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.textColor = [UIColor blackColor];
    label.font = [Helper labelFont];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    
    return headerView;
}


@end
