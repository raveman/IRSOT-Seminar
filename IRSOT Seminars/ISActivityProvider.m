//
//  ISActivityProvider.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 02/10/14.
//  Copyright (c) 2014 IRSOT. All rights reserved.
//

#import "ISActivityProvider.h"
#import "SeminarFetcher.h"
#import "Helper.h"
#import "ISWebviewViewController.h"

@implementation ISActivityProvider

- (id) activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if ( [activityType isEqualToString:UIActivityTypePostToFacebook]) {
        return [NSString stringWithFormat:@"%@ «%@»", NSLocalizedString(@"Seminar", @"Seminar"), self.seminar.name];
    }

    if ( [activityType isEqualToString:UIActivityTypePostToTwitter]) {
        return [NSString stringWithFormat:@"%@ @irsot: «%@»", NSLocalizedString(@"Seminar", @"Seminar"), self.seminar.name];
    }
    
    if ( [activityType isEqualToString:UIActivityTypeMail]) {
        return [self message];
    }

    if ( [activityType isEqualToString:UIActivityTypeMessage]) {
        return [self message];
    }

    return nil;
}

- (NSString *)message
{
    NSString *message = self.seminar.name;
    if ([self.seminar.date_start isEqualToDate: self.seminar.date_end]) {
        message = [NSString stringWithFormat:@"%@ дата проведения: %@", message, [Helper stringFromDate:self.seminar.date_start]];
    } else {
        message = [NSString stringWithFormat:@"%@ дата проведения: с %@ по %@", message, [Helper stringFromDate:self.seminar.date_start], [Helper stringFromDate:self.seminar.date_end]];
    }
    return message;
}

@end

