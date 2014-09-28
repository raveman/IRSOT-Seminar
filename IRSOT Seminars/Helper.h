//
//  Helper.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 08.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HORIZONTAL_MARGIN 40
#define SECTION_HEADER_HEIGHT 10

extern NSString * const NSUbiquitousKeyValueStoreDidChangeLocallyNotification;

@interface Helper : NSObject
+ (CGRect) resizeLabel:(UILabel *)label withSize:(CGSize)size;
+ (CGRect) resizeTextView:(UITextView *)textView withSize:(CGSize)size andMargin:(NSUInteger)margin;
+ (CGRect) resizeRectButton:(UIButton *)button withSize:(CGSize)size;

// + (void)makeButtonShiny:(UIButton*)button withBackgroundColor:(UIColor*)backgroundColor;

+ (UIFont *) cellMainFont; // returns font for all cells in project
+ (UIFont *) cellDetailFont; // returns font for all cells in project
+ (UITableViewCellSelectionStyle) cellSelectionStyle;
+ (UIFont *)labelFont;

+ (NSString *)platformString;

+ (UIColor *)tintColor;

//+ (void)fixSegmentedControlForiOS7:(UISegmentedControl *)segmentedControl;
//+ (void)fixBarButtonItemForiOS7:(UIBarButtonItem *)barButtonItem;

@end
