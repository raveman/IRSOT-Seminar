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
@end

@implementation ISSeminarViewController
@synthesize seminarNameLabel = _seminarNameLabel;
@synthesize sectionLabel = _sectionLabel;
@synthesize typeLabel = _typeLabel;
@synthesize lectorsLabel = _lectorsLabel;
@synthesize programTextView = _programTextView;

@synthesize seminar = _seminar;

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
    
    self.sectionLabel.text = self.seminar.section.name;
    self.typeLabel.text = self.seminar.type.name;
    self.lectorsLabel.text  = [self.seminar stringWithLectorNames];
}

- (void)viewDidUnload
{
    [self setSeminarNameLabel:nil];
    [self setSectionLabel:nil];
    [self setTypeLabel:nil];
    [self setLectorsLabel:nil];
    [self setProgramTextView:nil];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
