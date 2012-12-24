//
//  ISInfoTableViewController.m
//  RuSeminar
//
//  Created by Bob Ershov on 09.07.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "ISInfoTableViewController.h"
#import "ISWebviewViewController.h"
#import "Helper.h"

@interface ISInfoTableViewController ()
@property (nonatomic, strong) NSDictionary *infoLinks;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ISInfoTableViewController

@synthesize infoLinks = _infoLinks;

@synthesize tableView;

#pragma mark - variable instantiation

- (NSDictionary *) infoLinks
{
    if (_infoLinks == nil) {
        
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *plistPath = [bundle pathForResource:@"Info Links" ofType:@"plist"];
        _infoLinks = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
    
    return _infoLinks;
}


// helper methods
- (NSDictionary *) getDictionaryFor: (NSDictionary *)dictionary atIndex: (NSInteger)index
{
    int i = 0;
    NSDictionary *resultDictionary = [NSDictionary dictionary];
    
    for (id key in dictionary) {
        if (i == index) {
            resultDictionary = [dictionary objectForKey:key];
        }
        i++;
    }
    
    return resultDictionary;
}

- (NSString *) getKeyForDictionary: (NSDictionary *) dictionary atIndex: (NSInteger) index
{
    int i = 0;
    NSString *key = [[NSString alloc] init];
    for (id k in dictionary) {
        if (i == index) {
            key = k;
        }
        i++;
    }
    return key;
}

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    self.navigationItem.title = NSLocalizedString(@"Условия участия", @"Info page title");

    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"light-hash-background.png"]];
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
    return [self.infoLinks count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self getDictionaryFor:self.infoLinks atIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self getKeyForDictionary:self.infoLinks atIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Info Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *sectionDictionary = [self getDictionaryFor:self.infoLinks atIndex:indexPath.section];
    NSString *key = [self getKeyForDictionary:sectionDictionary atIndex:indexPath.row];

    cell.textLabel.font = [Helper cellMainFont];
    cell.detailTextLabel.font = [Helper cellDetailFont];
    cell.selectionStyle = [Helper cellSelectionStyle];

    cell.textLabel.text = key;
    cell.detailTextLabel.text = [sectionDictionary objectForKey:key];
    
    return cell;
}

#pragma mark - Table view delegate

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Web View"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *dictionary = [self getDictionaryFor:self.infoLinks atIndex:indexPath.section];
        NSURL *url = [NSURL URLWithString:[dictionary objectForKey:[self getKeyForDictionary:dictionary atIndex:indexPath.row]]];
        ISWebviewViewController *dvc = (ISWebviewViewController *)segue.destinationViewController;
        [dvc setUrl:url];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [dvc setTitle:cell.textLabel.text];
    }
}

@end
