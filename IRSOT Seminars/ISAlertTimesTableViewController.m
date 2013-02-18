//
//  ISAlertTimesTableViewController.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 18.02.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#import "ISAlertTimesTableViewController.h"
#import "ISAlertTimes.h"

@interface ISAlertTimesTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ISAlertTimesTableViewController

@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Alert Time Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == self.timeRow) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [[ISAlertTimes alerTimesArray] objectAtIndex:indexPath.row];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *previousSelectedCellIndexPath = [NSIndexPath indexPathForRow:self.timeRow inSection:0];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:previousSelectedCellIndexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;

    cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    self.timeRow = indexPath.row;
    [self.delegate alertTimesViewContoller:self didSelectedTime:self.timeRow];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
