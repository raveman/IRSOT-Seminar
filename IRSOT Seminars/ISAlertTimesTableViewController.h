//
//  ISAlertTimesTableViewController.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 18.02.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef enum {
//    tNow = 0,
//    t5Minutes = 5,
//    t15Minutes = 15,
//    t30Minutes = 30,
//    t1Hour = 60,
//    t2Hours = 120,
//    t1Day = 1440,
//    t2Days = 2880
//} times;

@class ISAlertTimesTableViewController;

@protocol ISAlertTimesTableViewControllerDelegate <NSObject>

- (void) alertTimesViewContoller:(ISAlertTimesTableViewController *)sender didSelectedTime: (NSInteger) time;

@end

@interface ISAlertTimesTableViewController : UITableViewController

@property (nonatomic) NSInteger timeRow;

@property (nonatomic, weak) id <ISAlertTimesTableViewControllerDelegate> delegate;

@end
