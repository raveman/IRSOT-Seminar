//
//  ISSeminarViewController.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 04.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "ISSeminarViewController.h"
#import "Sections.h"
#import "Type.h"
#import "Lector.h"


@interface ISSeminarViewController ()

@property (weak, nonatomic) IBOutlet UILabel *seminarNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lectorsLabel;
@property (weak, nonatomic) IBOutlet UITextView *programTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ISSeminarViewController
@synthesize seminarNameLabel = _seminarNameLabel;
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
    
    //adjust the label the the new height.
    CGRect newFrame = self.seminarNameLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    
    return newFrame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.title = self.seminar.name;

    
    if ([[self.seminar.name substringToIndex:1] isEqualToString:@"«"]) {
            self.seminarNameLabel.text = [NSString stringWithFormat:@"%@»", self.seminar.name];
    } else {
        self.seminarNameLabel.text = [NSString stringWithFormat:@"«%@»", self.seminar.name];
    }
    
    // получаем размеры заголовка
    CGRect headerRect = [self resizeLabel:self.seminarNameLabel];

    // опускаем тип и раздел семинаров на высоту заголовка
    self.sectionLabel.text = self.seminar.section.name;
    CGRect rect = self.sectionLabel.frame;
    rect.origin.y = headerRect.size.height + 32;
    self.sectionLabel.frame = rect;
    
    self.typeLabel.text = self.seminar.type.name;
    rect = self.typeLabel.frame;
    rect.origin.y = headerRect.size.height + 32;
    self.typeLabel.frame = rect;
    
    // получаем общую высоту текущего заголовка: заголовок + тип и секция семинара
//    headerRect.size.height = headerRect.size.height + rect.size.height;
    int height = rect.origin.y + rect.size.height;
    
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
    [self setSeminarNameLabel:nil];
    [self setSectionLabel:nil];
    [self setTypeLabel:nil];
    [self setLectorsLabel:nil];
    [self setProgramTextView:nil];

    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
