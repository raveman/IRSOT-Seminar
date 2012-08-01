//
//  ISMainPageViewController.m
//  Seminar.Ru
//
//  Created by Bob Ershov on 28.07.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

// зеленыйц R: 73, G: 168, B: 201
// оранжевый R: 208, G: 126, B: 73
//


#import "ISMainPageViewController.h"
#import "ISSeminarListTableViewController.h"

@interface ISMainPageViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *seminarCategoriesTableView;

@property (nonatomic, strong) NSArray *seminarSections;
@end

@implementation ISMainPageViewController

@synthesize seminarCategoriesTableView = _seminarCategoriesTableView;
@synthesize seminarSections = _seminarSections;


#pragma mark - getters and setters
- (NSArray *) seminarSections
{
    NSArray *seminarSections = [NSArray arrayWithObjects:@"Бухгалтерский учет", @"Финансы", @"Право", @"Управление", @"Кадры", nil];
    _seminarSections = seminarSections;
    
    return _seminarSections;
}

#pragma mark - UIViewController lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.28 green:0.66 blue:0.79 alpha:1.0];
	
    // setting categories list tableview datasource and delegate
    self.seminarCategoriesTableView.dataSource = self;
    self.seminarCategoriesTableView.delegate = self;
    
    self.title = NSLocalizedString(@"Семинары ИРСОТ", @"Main Page Title");
}

- (void)viewDidUnload
{
    [self setSeminarCategoriesTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Seminar List for Section"]) {
        NSIndexPath *indexPath = nil;
        if ([sender isKindOfClass:[NSIndexPath class]]) {
            indexPath = (NSIndexPath *) sender;
        } else if ([sender isKindOfClass:[UITableViewCell class]]) {
            indexPath = [self.seminarCategoriesTableView indexPathForCell:sender];
        } else if (!sender || (sender == self) || (sender == self.seminarCategoriesTableView)) {
            indexPath = [self.seminarCategoriesTableView indexPathForSelectedRow];
        }
        
        RSSeminarListViewController *seminarListVC = (RSSeminarListTableViewController *)segue.destinationViewController;
        [seminarListVC setSection:[NSNumber numberWithInt: indexPath.row]];
    };
}

#pragma mark - UITableView dataSource and delegate
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.seminarSections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Education Types Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [self.seminarSections objectAtIndex:indexPath.row];
    
    return cell;
}


@end
