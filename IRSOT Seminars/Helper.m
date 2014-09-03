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
    
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    newFrame.size.width = expectedLabelSize.width - HORIZONTAL_MARGIN;
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
    
    CGFloat fixedWidth = textView.frame.size.width; // - margin;
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

//- (UIImage *)addBorderToImage:(UIImage *)image
//{
//    CGImageRef cgimage = [image CGImage];
//    float width = CGImageGetWidth(cgimage);
//    float height = CGImageGetHeight(cgimage);
//    
//    // create temp buf
//    void *data = malloc(width * height * 4);
//    
//    // draw image to buf
//    CGContextRef ctx = CGBitmapContextCreate(data, width, height, 8, width * 4, CGImageGetColorSpace(image.CGImage), kCGImageAlphaPremultipliedLast);
//    
//    
//    return newImage;
//}

+ (void)makeButtonShiny:(UIButton*)button withBackgroundColor:(UIColor*)backgroundColor
{
    // Get the button layer and give it rounded corners with a semi-transparant button
    CALayer *layer = button.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor colorWithWhite:0.4f alpha:0.2f].CGColor;
    
    // Create a shiny layer that goes on top of the button
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    CGRect buttonSize = button.layer.bounds;
    shineLayer.frame = buttonSize;
    // Set the gradient colors
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         nil];
    // Set the relative positions of the gradien stops
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.3f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    
    // Add the layer to the button
    [button.layer addSublayer:shineLayer];
    
    [button setBackgroundColor:backgroundColor];
}

+ (UIFont *) cellMainFont
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0];
    return font;
}

+ (UIFont *) labelFont
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    return font;
}

+ (UIFont *) cellDetailFont
{
    return [UIFont fontWithName:@"HelveticaNeue" size:14.0];
}

+ (UITableViewCellSelectionStyle) cellSelectionStyle
{
    return UITableViewCellSelectionStyleBlue;
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

+ (UIColor *)tintColor {
    return [UIColor colorWithRed:228 / 255.0 green:245 / 255.0 blue:253 / 255.0 alpha:1.0];
}

+ (void)fixSegmentedControlForiOS7:(UISegmentedControl *)segmentedControl;
{
    NSInteger deviceVersion = [[UIDevice currentDevice] systemVersion].integerValue;
    if(deviceVersion < 7) // If this is not an iOS 7 device, we do not need to perform these customizations.
        return;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont boldSystemFontOfSize:12], UITextAttributeFont,
                                [UIColor whiteColor], UITextAttributeTextColor,
                                nil];
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    
    [segmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.tintColor = [Helper tintColor];
    //    self.seminarTypeSwitch.tintColor = [UIColor colorWithRed:105 / 255.0 green:201 / 255.0 blue:229 / 255.0 alpha:1.0];
    //    self.seminarTypeSwitch.tintColor = [UIColor colorWithRed:28/255.0 green:173/255.0 blue:215/255.0 alpha:1.0];
    //    self.seminarTypeSwitch.tintColor = [UIColor whiteColor];
}

+ (void)fixBarButtonItemForiOS7:(UIBarButtonItem *)barButtonItem
{
    NSInteger deviceVersion = [[UIDevice currentDevice] systemVersion].integerValue;
    if(deviceVersion < 7) // If this is not an iOS 7 device, we do not need to perform these customizations.
        return;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont boldSystemFontOfSize:12], UITextAttributeFont,
                                [UIColor whiteColor], UITextAttributeTextColor,
                                nil];
    [barButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    
    [barButtonItem setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    
    barButtonItem.tintColor = [Helper tintColor];
}




@end
