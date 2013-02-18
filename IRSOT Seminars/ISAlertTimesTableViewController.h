//
//  ISAlertTimesTableViewController.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 18.02.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ISAlertTimesTableViewController;

@protocol ISAlertTimesTableViewControllerDelegate <NSObject>

- (void) alertTimesViewContoller:(ISAlertTimesTableViewController *)sender didSelectedTime: (NSInteger) time;

@end

@interface ISAlertTimesTableViewController : UITableViewController

@property (nonatomic) NSInteger timeRow;

@property (nonatomic, weak) id <ISAlertTimesTableViewControllerDelegate> delegate;

@end
