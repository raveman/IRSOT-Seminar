//
//  ISTheme.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 27/09/14.
//  Copyright (c) 2014 IRSOT. All rights reserved.
//

#import "ISTheme.h"

@implementation ISTheme


+ (UIColor *)mainColor
{
    return [ISTheme baseTintColor];
}

+ (UIColor *)secondColor
{
    return [UIColor colorWithRed:0.49f green:0.49f blue:0.49f alpha:1.00f];
}

+ (UIColor *)backgroundColor
{
    return [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1.0];
}

+ (UIColor *)navigationBarBackgroundColor
{
    return [ISTheme accentTintColor];
}

+ (UIColor *)navigationBarTitleColor
{
    return [UIColor whiteColor];
}


+ (UIColor *)baseTintColor
{
    return [UIColor colorWithRed:28/255.0 green:173/255.0 blue:215/255.0 alpha:1.0];
}

+ (UIColor *)accentTintColor
{
    return [UIColor colorWithRed:18/255.0 green:122/255.0 blue:187/255.0 alpha:1.0];

}

+ (UIColor *)barButtonItemColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)selectedTabbarItemTintColor
{
   return [UIColor colorWithRed:18/255.0 green:122/255.0 blue:187/255.0 alpha:1.0];
}

+ (UIColor *)switchThumbColor
{
    return [UIColor colorWithRed:0.87f green:0.87f blue:0.89f alpha:1.00f];
}

+ (UIColor *)switchOnColor
{
    return [UIColor colorWithRed:18/255.0 green:122/255.0 blue:187/255.0 alpha:1.0];

}

- (UIColor *)switchTintColor
{
    return [ISTheme baseTintColor];
}

+ (CGSize)shadowOffset
{
   return CGSizeMake(0.0, 1.0);
}

+ (UIImage *)tableBackground
{
    //    UIImage *image = [UIImage imageNamed:@"background"];
    //    image = [image resizableImageWithCapInsets:UIEdgeInsetsZero];
    //    return image;
    CIColor *color = [CIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1.0];
    UIImage *image = [UIImage imageWithCIImage: [CIImage imageWithColor:color]];
    return image;
}

+ (UIFont *)sectionLabelFont
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    return font;
}

+ (UIColor *)sectionLabelColor
{
        return [UIColor colorWithRed:18/255.0 green:122/255.0 blue:187/255.0 alpha:1.0];
}

+ (UILabel *)sectionLabelInTableView: (UITableView *)tableView forSection:(NSUInteger)section andMargin:(NSUInteger)margin
{
    CGRect frame = CGRectZero;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (margin == 0) {
            margin = 60;
        }
        frame = CGRectMake(margin, 10, tableView.frame.size.width - 60, 18);
    } else {
        if (margin == 0) {
            margin = 20;
        }
        frame = CGRectMake(margin, 10, tableView.frame.size.width - 18, 18);
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    
    label.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    label.textColor = [self sectionLabelColor];
    label.font = [self sectionLabelFont];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0,1);
    
    label.backgroundColor = [UIColor clearColor];
    return label;
}

+ (UIImage *)viewBackground
{
    UIImage *image = [UIImage imageNamed:@"background"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsZero];
    return image;
}

@end