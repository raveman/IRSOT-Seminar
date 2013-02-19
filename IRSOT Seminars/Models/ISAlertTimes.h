//
//  ISAlertTimes.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 18.02.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#define CALENDAR_ALERT_KEY @"SeminarList.UseCalendarAlerts"
#define CALENDAR_ALERT_TIME @"SeminarList.CalendarAlertTime"

#import <Foundation/Foundation.h>

@interface ISAlertTimes : NSObject

+ (NSArray *)alerTimesArray; // alert times array
+ (int *)times;
+ (NSInteger)savedAlertTimeOption;
+ (void)saveAlertTimeOptionWithTimeSelection:(NSInteger)time;

@end
