//
//  ISLectorViewController.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 04.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//
#import <QuartzCore/CALayer.h>

#import "ISAppDelegate.h"
#import "ISLectorViewController.h"
#import "ISSeminarViewController.h"
#import "Seminar+Load_Data.h"
#import "Helper.h"

@interface ISLectorViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *lectorPhoto;
@property (weak, nonatomic) IBOutlet UITextView *lectorName;
@property (weak, nonatomic) IBOutlet UITextView *lectorBio;
@property (weak, nonatomic) IBOutlet UITableView *lectorSeminars;

@property (strong, nonatomic) NSArray *seminars;

@end

@implementation ISLectorViewController
@synthesize scrollView = _scrollView;
@synthesize lectorPhoto = _lectorPhoto;
@synthesize lectorName = _lectorName;
@synthesize lectorBio = _lectorBio;
@synthesize lectorSeminars = _lectorSeminars;

@synthesize seminars = _seminars;
@synthesize lector = _lector;

- (void) recalculateElementsBounds
{
    CGSize currentSize = self.view.frame.size;
    
    CGRect pictureFrame = self.lectorPhoto.frame;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        pictureFrame.size.width = 192;
        pictureFrame.size.height = 192;
        self.lectorPhoto.frame = pictureFrame;
    }
    
    CGSize size = currentSize;
    size.width = currentSize.width - pictureFrame.size.width;
    size.height = pictureFrame.size.height;
    
    CGRect titleFrame = self.lectorName.frame;
    titleFrame.origin.x = pictureFrame.origin.x * 2 + pictureFrame.size.width;
    self.lectorName.frame = titleFrame;
    titleFrame = [Helper resizeTextView:self.lectorName withSize:size];
    
    // header
    size = titleFrame.size;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGRect bioFrame = self.lectorBio.frame;
        bioFrame.origin.x = titleFrame.origin.x;
        bioFrame.origin.y = titleFrame.origin.y + titleFrame.size.height;
        self.lectorBio.frame = bioFrame;
        size.height = pictureFrame.size.height;
    } else {
        size.height = pictureFrame.size.height;
        size.width = currentSize.width;
    }
    
    // bio
    CGRect rect = [Helper resizeTextView:self.lectorBio withSize:size];
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) size.height += rect.size.height + 10;
        else size.height = pictureFrame.origin.y + pictureFrame.size.height;
    
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


- (void)loadLectorPhoto
{
    NSURL __block *cachedImage = [[ISAppDelegate sharedDelegate] lectorCacheDirectory];
    
    NSString *imageName = [self.lector.photo lastPathComponent];
    
    cachedImage = [cachedImage URLByAppendingPathComponent:imageName];
    UIImage *image = [UIImage imageWithContentsOfFile:[cachedImage path]];

    if (image) {
        self.lectorPhoto.image = image;
    } else {
        dispatch_queue_t fetchQ = dispatch_queue_create("Lector Photo fetcher", NULL);
        dispatch_async(fetchQ, ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.lector.photo]];
            if ( data == nil ) return;
            
            // saving downladed image to cache
            UIImage *image = [UIImage imageWithData: data];
            NSError *error = nil;
            BOOL success = [UIImagePNGRepresentation(image) writeToURL:cachedImage options:NSDataWritingAtomic error:&error];
            if (!success) NSLog(@"Save image error: %@ %@", error.localizedFailureReason, [error.userInfo objectForKey:NSUnderlyingErrorKey]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lectorPhoto.layer.borderColor = [UIColor whiteColor].CGColor;
                self.lectorPhoto.layer.borderWidth = 1.0;
                self.lectorPhoto.image = image;
            });
        });
        
        dispatch_release(fetchQ);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// view additional setups
    self.lectorSeminars.dataSource = self;
    self.lectorSeminars.delegate = self;
    
    self.title = [self.lector fullName];

    self.lectorName.text = [self.lector fullName];
    self.lectorBio.text = self.lector.bio;
    if ([self.lector.seminars count]) {
        NSArray *lectorSeminars = [self.lector.seminars allObjects];
        NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        lectorSeminars = [lectorSeminars sortedArrayUsingDescriptors:sortDescriptors];
        self.seminars = lectorSeminars;
    }
    
    self.lectorPhoto.layer.masksToBounds = YES;
    
    self.lectorPhoto.layer.shadowColor = [UIColor grayColor].CGColor;
    self.lectorPhoto.layer.shadowOffset = CGSizeMake(0, 1);
    self.lectorPhoto.layer.shadowOpacity = 1;
    self.lectorPhoto.layer.shadowRadius = 1.0;
    self.lectorPhoto.clipsToBounds = NO;
    
    if ([self.lector.photo length]) [self loadLectorPhoto];
}

- (void)viewDidUnload
{
    [self setLectorName:nil];
    [self setLectorBio:nil];
    [self setLectorSeminars:nil];
    [self setScrollView:nil];
    [self setLectorPhoto:nil];
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
        Seminar *seminar = [self.seminars objectAtIndex:indexPath.row];
        ISSeminarViewController *dvc = (ISSeminarViewController *)segue.destinationViewController;
        [dvc setSeminar:seminar];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.seminars count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Lector Seminar Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue Medium" size:15.0];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:13.0];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

    if ([self.seminars count]) {
        Seminar *seminar = [self.seminars objectAtIndex:indexPath.row];
        cell.textLabel.text = seminar.name;
        cell.detailTextLabel.text = [seminar stringWithSeminarDates];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.seminars count]) {
        return NSLocalizedString(@"Семинары:", @"Lector Seminar Table Title");
    } else {
        return @"";
    }
}

#pragma mark - UITableViewDelegate

@end
