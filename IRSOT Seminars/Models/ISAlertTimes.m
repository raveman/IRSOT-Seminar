//
//  ISAlertTimes.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 18.02.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#import "ISAlertTimes.h"

@implementation ISAlertTimes

+ (NSArray *)alerTimesArray {
    NSArray *times = [NSArray arrayWithObjects:NSLocalizedString(@"None", @"None"),
                      NSLocalizedString(@"At time of event", @"At time of event"),
                      NSLocalizedString(@"5 minutes before", @"5 minutes before"),
                      NSLocalizedString(@"15 minutes before", @"15 minutes before"),
                      NSLocalizedString(@"30 minutes before", @"30 minutes beforet"),
                      NSLocalizedString(@"1 hour before", @"1 hour before"),
                      NSLocalizedString(@"2 hours before", @"2 hours before"),
                      NSLocalizedString(@"1 day before", @"1 day before"),
                      NSLocalizedString(@"2 days before", @"1 days before"), nil];
    
    
    return times;
}

+ (int *)times {
    static int timeInMinutes[9] = {-1, 0, 5, 15, 30, 60, 120, 1440, 2880};
    
    return timeInMinutes;
}

+ (NSInteger)savedAlertTimeOption
{
    NSInteger time = [[[NSUserDefaults standardUserDefaults] objectForKey:CALENDAR_ALERT_TIME] integerValue];
    return  time;
}

+ (void)saveAlertTimeOptionWithTimeSelection:(NSInteger)time
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *calendarAlertTime = [NSNumber numberWithInteger:time];
    
    [defaults setObject:calendarAlertTime forKey:CALENDAR_ALERT_TIME];
    [defaults synchronize];

}

@end
