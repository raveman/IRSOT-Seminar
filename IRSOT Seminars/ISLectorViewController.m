//
//  ISLectorViewController.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 04.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "ISLectorViewController.h"
#import "ISSeminarViewController.h"
#import "Seminar+Load_Data.h"
#import "Helper.h"

@interface ISLectorViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *lectorName;
@property (weak, nonatomic) IBOutlet UITextView *lectorBio;
@property (weak, nonatomic) IBOutlet UITableView *lectorSeminars;
@end

@implementation ISLectorViewController
@synthesize scrollView = _scrollView;
@synthesize lectorName = _lectorName;
@synthesize lectorBio = _lectorBio;
@synthesize lectorSeminars = _lectorSeminars;

@synthesize lector = _lector;

- (void) recalculateElementsBounds
{
    CGSize currentSize = self.view.frame.size;
    CGRect titleFrame = [Helper resizeTextView:self.lectorName withSize:currentSize];
    
    // header
    CGSize size = titleFrame.size;
    // bio
    CGRect rect = [Helper resizeTextView:self.lectorBio withSize:currentSize];
    size.height += rect.origin.y + rect.size.height - 40;
    
    // seminars
//    size.height += self.lectorSeminars.frame.size.height;
    int tableHeight = self.lectorSeminars.rowHeight * [self.lector.seminars count];
    //    CGRectGetMaxY([self.tableView rectForSection:[self.tableView numberOfSections] - 1])
    
    CGRect tableFrame = self.lectorSeminars.frame;
    tableFrame.origin.y = size.height;
    tableFrame.size.height += tableHeight;
    self.lectorSeminars.frame = tableFrame;
    
    size.height += tableHeight + 80;
//    size.height += tableFrame.size.height;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentSize = size;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// view additional setups
    self.lectorSeminars.dataSource = self;
    self.lectorSeminars.delegate = self;
    
    self.title = self.lector.name;
    self.lectorName.text = [NSString stringWithFormat:@"%@ %@ %@", self.lector.lastName, self.lector.firstName, self.lector.fatherName];
    self.lectorBio.text = self.lector.bio;
    if (![self.lector.seminars count]) {
        
    }
}

- (void)viewDidUnload
{
    [self setLectorName:nil];
    [self setLectorBio:nil];
    [self setLectorSeminars:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
 
    [self recalculateElementsBounds];
    NSIndexPath *indexPath = [self.lectorSeminars indexPathForSelectedRow];
    if (indexPath != nil) {
        [self.lectorSeminars deselectRowAtIndexPath:indexPath animated:YES];
    }
    [super viewWillAppear:animated];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [self recalculateElementsBounds];
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Lector Seminar View"]) {
        NSIndexPath *indexPath = self.lectorSeminars.indexPathForSelectedRow;
        Seminar *seminar = [[self.lector.seminars allObjects] objectAtIndex:indexPath.row];
        ISSeminarViewController *dvc = (ISSeminarViewController *)segue.destinationViewController;
        [dvc setSeminar:seminar];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.lector.seminars count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Lector Seminar Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if ([self.lector.seminars count]) {
        NSArray *seminars = [self.lector.seminars allObjects];
        Seminar *seminar = [seminars objectAtIndex:indexPath.row];
        cell.textLabel.text = seminar.name;
        cell.detailTextLabel.text = [seminar stringWithSeminarDates];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.lector.seminars count]) {
        return NSLocalizedString(@"Семинары:", @"Lector Seminar Table Title");
        
    } else {
        return @"";
    }
}

#pragma mark - UITableViewDelegate

@end
