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
#import "Helper.h"
#import "Sections.h"
#import "Type.h"
#import "Lector.h"
#import "Seminar+Load_Data.h"

#define ADD_BOOKMARK @"Добавить закладку"


@interface ISSeminarViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *attendSeminarButton;
@property (weak, nonatomic) IBOutlet UITextView *seminarName;
@property (weak, nonatomic) IBOutlet UILabel *seminarDate;
@property (weak, nonatomic) IBOutlet UILabel *sectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lectorsLabel;
@property (weak, nonatomic) IBOutlet UITextView *programTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) UIActionSheet *actionSheet;

@end

@implementation ISSeminarViewController

@synthesize attendSeminarButton = _attendSeminarButton;
@synthesize seminarName = _seminarName;
@synthesize seminarDate = _seminarDate;
@synthesize sectionLabel = _sectionLabel;
@synthesize typeLabel = _typeLabel;
@synthesize lectorsLabel = _lectorsLabel;
@synthesize programTextView = _programTextView;
@synthesize scrollView = _scrollView;
@synthesize actionSheet = _actionSheet;

@synthesize seminar = _seminar;
@synthesize seminarID = _seminarID;

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
    self.typeLabel.frame = rect;
    
    // получаем общую высоту текущего заголовка: заголовок + тип и секция семинара
    height = rect.origin.y + rect.size.height;
    
    // опускаем лекторов на текущее смещение
    rect = [Helper resizeLabel:self.lectorsLabel withSize:currentSize];
    rect.origin.y = height + 10;
    self.lectorsLabel.frame = rect;
    
    height = rect.origin.y + rect.size.height;
    // осталось опустить описание семинара
    rect = self.programTextView.frame;
    rect.origin.y = height + 10;
    CGRect programRect = [Helper resizeTextView:self.programTextView withSize: currentSize];
    rect.size.width = programRect.size.width;
    self.programTextView.frame = rect;
    
    CGSize size = rect.size;
    size.height += height + 20;
    
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
        self.programTextView.hidden = YES;
        
    } else {
        self.title = self.seminar.name;
        
        if ([[self.seminar.name substringToIndex:1] isEqualToString:@"«"]) {
                self.seminarName.text = [NSString stringWithFormat:@"%@»", self.seminar.name];
        } else {
            self.seminarName.text = [NSString stringWithFormat:@"«%@»", self.seminar.name];
        }
        
        self.seminarDate.text = [self.seminar stringWithSeminarDates];
        self.sectionLabel.text = self.seminar.section.name;
        self.typeLabel.text = self.seminar.type.name;
        self.lectorsLabel.text  = [self.seminar stringWithLectorNames];

    }
}

- (void)viewDidUnload
{
    [self setSectionLabel:nil];
    [self setTypeLabel:nil];
    [self setLectorsLabel:nil];
    [self setProgramTextView:nil];

    [self setScrollView:nil];
    [self setSeminarDate:nil];
    [self setSeminarName:nil];
    [self setAttendSeminarButton:nil];
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
    [super viewWillAppear:animated];
    [self recalculateElementsBounds];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    [self recalculateElementsBounds];
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Bill Webview"]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.ruseminar.ru/bill?id=%@", self.seminar.ruseminarID]];
        
        ISWebviewViewController *dvc = (ISWebviewViewController *)segue.destinationViewController;
        [dvc setUrl:url];
        [dvc setWebviewTitle:@"Принять участие"];
    }
}

- (IBAction)share:(UIBarButtonItem *)sender {
    if (self.actionSheet) {
        // do nothing
    } else {
        NSString *addBookmarkButton = NSLocalizedString(ADD_BOOKMARK, @"Add seminar bookmark button title");
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Закладки" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:addBookmarkButton, nil];
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

@end
