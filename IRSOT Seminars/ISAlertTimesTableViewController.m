//
//  ISAlertTimesTableViewController.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 18.02.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#import "ISAlertTimesTableViewController.h"


const int timeInMinutes[] = {0, 5, 15, 30, 60, 120, 1440, 2880};

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
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"None", @"None");
            break;

        case 1:
            cell.textLabel.text = NSLocalizedString(@"At time of event", @"At time of event");
            break;
            
        case 2:
            cell.textLabel.text = NSLocalizedString(@"5 minutes before", @"5 minutes before");
            break;

        case 3:
            cell.textLabel.text = NSLocalizedString(@"15 minutes before", @"15 minutes before");
            break;

        case 4:
            cell.textLabel.text = NSLocalizedString(@"30 minutes before", @"30 minutes beforet");
            break;
        case 5:
            cell.textLabel.text = NSLocalizedString(@"1 hour before", @"1 hour before");
            break;

        case 6:
            cell.textLabel.text = NSLocalizedString(@"2 hours before", @"2 hours before");
            break;

        case 7:
            cell.textLabel.text = NSLocalizedString(@"1 day before", @"1 day before");
            break;

        case 8:
            cell.textLabel.text = NSLocalizedString(@"2 days before", @"1 days before");
            break;

        default:
            break;
    }
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
