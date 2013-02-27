//
//  ISInfoTableViewController.m
//  RuSeminar
//
//  Created by Bob Ershov on 09.07.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "ISInfoTableViewController.h"
#import "ISWebviewViewController.h"
#import "ISInfoDictionary.h"
#import "Helper.h"
#import "ADVTheme.h"

@interface ISInfoTableViewController ()
@property (nonatomic, strong) NSArray *infoLinks;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ISInfoTableViewController

@synthesize infoLinks = _infoLinks;
@synthesize tableView = _tableView;

#pragma mark - variable instantiation

- (NSArray *) infoLinks
{
    if (_infoLinks == nil) {
        _infoLinks = [ISInfoDictionary infoArray];
    }
    return _infoLinks;
}

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Participation terms", @"Info page title");

//    self.tableView.backgroundColor = [UIColor clearColor];
//    self.tableView.opaque = NO;
//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[theme viewBackground]];
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    [self.view setBackgroundColor:[theme backgroundColor]];
    
    [ADVThemeManager customizeTableView:self.tableView];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger sections = [self.infoLinks count] / 2;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger count = 0;
    
    id arr1 = [self.infoLinks objectAtIndex:section*2];
    if ([arr1 isKindOfClass:[NSArray class]] ) {
        id arr2 = [arr1 objectAtIndex:0];
        if ([arr1 isKindOfClass:[NSArray class]]) {
            count = [arr2 count];
        }
    }
    
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSInteger s = section * 2 + 1;
    NSString *title = [self.infoLinks objectAtIndex:s];
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Info Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...

    NSString *key = [[[self.infoLinks objectAtIndex:indexPath.section*2] objectAtIndex:1] objectAtIndex:indexPath.row];

    UIImage *accessoryImage = [UIImage imageNamed:@"accessoryArrow"];
    cell.accessoryView = [[UIImageView alloc] initWithImage:accessoryImage];
    cell.textLabel.font = [Helper cellMainFont];
    
    cell.textLabel.font = [Helper cellMainFont];
    cell.selectionStyle = [Helper cellSelectionStyle];

    cell.textLabel.text = key;
    
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, SECTION_HEADER_HEIGHT)];
    [headerView setBackgroundColor:[UIColor clearColor]];

    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    [headerView addSubview:[theme sectionLabelInTableView:tableView forSection:section andMargin:0]];
    
    return headerView;
}

#pragma mark - Table view delegate

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Web View"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSURL *url = [NSURL URLWithString:[[[self.infoLinks objectAtIndex:indexPath.section*2] objectAtIndex:0] objectAtIndex:indexPath.row]];
        ISWebviewViewController *dvc = (ISWebviewViewController *)segue.destinationViewController;
        [dvc setUrl:url];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [dvc setTitle:cell.textLabel.text];
    }
}

@end
