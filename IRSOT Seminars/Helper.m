//
//  Helper.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 08.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//
#include <sys/types.h>
#include <sys/sysctl.h>

#import <QuartzCore/QuartzCore.h>
#import "Helper.h"

NSString * const NSUbiquitousKeyValueStoreDidChangeLocallyNotification = @"Seminar.Local.Change";

@implementation Helper

+ (CGRect) resizeLabel:(UILabel *)label withSize:(CGSize)size
{
    
    CGSize maximumLabelSize = size;
    maximumLabelSize.width -= HORIZONTAL_MARGIN;
    
//    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = label.lineBreakMode;
    
    NSDictionary *attributes = @{NSFontAttributeName:label.font, NSParagraphStyleAttributeName:paragraphStyle};

    CGRect expectedLabelRect = [label.text boundingRectWithSize:maximumLabelSize
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:attributes
                                                        context:nil];
    
    //adjust the label new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelRect.size.height;
    newFrame.size.width = expectedLabelRect.size.width - HORIZONTAL_MARGIN;
    newFrame.size.width = maximumLabelSize.width;
    label.frame = newFrame;
    
    return newFrame;
}

+ (CGRect) resizeTextView:(UITextView *)textView withSize:(CGSize)size andMargin:(NSUInteger)margin
{
    if (margin == -1) margin = HORIZONTAL_MARGIN;

//    CGRect newFrame = textView.frame;
//    newFrame.size.width = size.width - margin;
//    textView.frame = newFrame;
//    
//    CGRect frame = textView.frame;
//    frame.size.height = textView.contentSize.height;
//    textView.frame = frame;
    
    CGFloat fixedWidth = size.width - margin; // - margin;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    
    return newFrame;
}

+ (CGRect) resizeRectButton:(UIButton *)button withSize:(CGSize)size
{
    CGRect frame = button.frame;
    frame.size.width = size.width - HORIZONTAL_MARGIN;
    button.frame = frame;
    
    return frame;
}

+ (NSString *) platformString {
    // Gets a string with the device model
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    return platform;
}

+(void)setLocalizedItemsLabelsForTabBarController:(UITabBarController *)tabBarController
{
    [[tabBarController.tabBar.items objectAtIndex:0] setTitle:NSLocalizedString(@"Catalog", @"Catalog section title")];
    
    [[tabBarController.tabBar.items objectAtIndex:1] setTitle:NSLocalizedString(@"Lectors", @"Lector List View Title")];
    
    [[tabBarController.tabBar.items objectAtIndex:2] setTitle:NSLocalizedString(@"Video", @"Video Title")];
    
    [[tabBarController.tabBar.items objectAtIndex:3] setTitle:NSLocalizedString(@"News", @"News Title")];

    [[tabBarController.tabBar.items objectAtIndex:4] setTitle:NSLocalizedString(@"Important", @"Important Title")];

}

+ (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d.MM.y"];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
    [dateFormatter setLocale:locale];
    
    return [dateFormatter stringFromDate:date];
}


@end
