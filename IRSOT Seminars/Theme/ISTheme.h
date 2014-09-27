//
//  ISTheme.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 27/09/14.
//  Copyright (c) 2014 IRSOT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISTheme : NSObject

+ (UIColor *)mainColor;
+ (UIColor *)secondColor;
+ (UIColor *)backgroundColor;
+ (UIColor *)baseTintColor;
+ (UIColor *)accentTintColor;
+ (UIColor *)selectedTabbarItemTintColor;
+ (UIColor *)switchThumbColor;
+ (UIColor *)switchOnColor;
+ (CGSize)shadowOffset;
+ (UIImage *)tableBackground;
+ (UIFont *)sectionLabelFont;
+ (UIColor *)sectionLabelColor;
+ (UILabel *)sectionLabelInTableView: (UITableView *)tableView forSection:(NSUInteger)section andMargin:(NSUInteger)margin;
+ (UIImage *)viewBackground;

@end
