//
//  ISSeminarViewController.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 04.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//
// TODO: переделать все UILabel в UITextView, чтобы у пользователя была возможность копи-паста

#import "ISSeminarViewController.h"
#import "ISWebviewViewController.h"
#import "Sections.h"
#import "Type.h"
#import "Lector.h"

@interface ISSeminarViewController ()

@property (weak, nonatomic) IBOutlet UITextView *seminarName;
@property (weak, nonatomic) IBOutlet UILabel *seminarDate;
@property (weak, nonatomic) IBOutlet UILabel *sectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lectorsLabel;
@property (weak, nonatomic) IBOutlet UITextView *programTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ISSeminarViewController

@synthesize seminarName = _seminarName;
@synthesize seminarDate = _seminarDate;
@synthesize sectionLabel = _sectionLabel;
@synthesize typeLabel = _typeLabel;
@synthesize lectorsLabel = _lectorsLabel;
@synthesize programTextView = _programTextView;
@synthesize scrollView = _scrollView;

@synthesize seminar = _seminar;

- (CGRect) resizeLabel:(UILabel *)label
{
    CGSize maximumLabelSize = CGSizeMake(320,300);
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    
    return newFrame;
}

- (CGRect) resizeTextView:(UITextView *)textView
{
    CGRect frame = textView.frame;
    frame.size.height = textView.contentSize.height;
    textView.frame = frame;
    
    return frame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.seminar.name;
    
    if ([[self.seminar.name substringToIndex:1] isEqualToString:@"«"]) {
            self.seminarName.text = [NSString stringWithFormat:@"%@»", self.seminar.name];
    } else {
        self.seminarName.text = [NSString stringWithFormat:@"«%@»", self.seminar.name];
    }
    
    // получаем размеры заголовка
     CGRect headerRect = [self resizeTextView:self.seminarName];
    
    // опускаем дату проведения семинара
    self.seminarDate.text = [self.seminar stringWithSeminarDates];
    CGRect rect = self.seminarDate.frame;
    rect.origin.y = headerRect.origin.y + headerRect.size.height;
    self.seminarDate.frame = rect;
    int height = rect.origin.y + rect.size.height;
    
    // опускаем тип и раздел семинаров на высоту предыдущих двух
    self.sectionLabel.text = self.seminar.section.name;
    rect = self.sectionLabel.frame;
//    headerRect.origin.y = self.seminarNameLabel.frame.origin.y + headerRect.size.height;
//    headerRect.origin.y = headerRect.size.height;
//    rect.origin.y = headerRect.origin.y + headerRect.size.height + 20;
    rect.origin.y = height + rect.size.height;
    self.sectionLabel.frame = rect;
    
    self.typeLabel.text = self.seminar.type.name;
    rect = self.typeLabel.frame;
//    rect.origin.y = headerRect.origin.y + headerRect.size.height + 20;
    rect.origin.y = height + rect.size.height;
    self.typeLabel.frame = rect;
    
    // получаем общую высоту текущего заголовка: заголовок + тип и секция семинара
    height = rect.origin.y + rect.size.height;
    
    // опускаем лекторов на текущее смещение
    self.lectorsLabel.text  = [self.seminar stringWithLectorNames];
    rect = [self resizeLabel:self.lectorsLabel];
    rect.origin.y = height + 10;
    self.lectorsLabel.frame = rect;
    
    height = rect.origin.y + rect.size.height;
    // осталось опустить описание семинара
    rect = self.programTextView.frame;
    rect.origin.y = height + 10;
    self.programTextView.frame = rect;
    
    CGSize size = rect.size;
    size.height += height + 20;
    
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentSize = size;
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Bill Webview"]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.ruseminar.ru/bill?id=%@", self.seminar.ruseminarID]];
        
        ISWebviewViewController *dvc = (ISWebviewViewController *)segue.destinationViewController;
        [dvc setUrl:url];
        [dvc setWebviewTitle:@"Принять участие"];
    }
}

@end
