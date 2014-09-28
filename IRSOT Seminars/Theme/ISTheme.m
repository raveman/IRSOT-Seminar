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
    return [ISTheme labelColor];
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
    return [ISTheme labelColor];
}

+ (UIColor *)navigationBarTitleColor
{
    return [UIColor whiteColor];
}


+ (UIColor *)baseTintColor
{
    return [UIColor colorWithRed:28/255.0 green:173/255.0 blue:215/255.0 alpha:1.0];
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


#pragma mark - Labels styling
+ (UIColor *)labelColor
{
    return [UIColor colorWithRed:18/255.0 green:122/255.0 blue:187/255.0 alpha:1.0];
    
}

+ (UIFont *) labelFont
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    return font;
}

#pragma mark - Table Fonts and Styling

+ (UIFont *)sectionLabelFont
{
    return [UIFont fontWithDescriptor:[UIFontDescriptor fontDescriptorWithFontAttributes:@{@"NSCTFontUIUsageAttribute" : UIFontTextStyleBody, @"NSFontNameAttribute" : @"HelveticaNeue-Medium"}] size:15.0];
    
}

+ (UIFont *) cellMainFont
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0];
    return font;
}

+ (UIFont *) cellDetailFont
{
    return [UIFont fontWithName:@"HelveticaNeue" size:14.0];
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

+ (UIImage *)tableBackground
{
    //    UIImage *image = [UIImage imageNamed:@"background"];
    //    image = [image resizableImageWithCapInsets:UIEdgeInsetsZero];
    //    return image;
    CIColor *color = [CIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1.0];
    UIImage *image = [UIImage imageWithCIImage: [CIImage imageWithColor:color]];
    return image;
}

+ (UITableViewCellSelectionStyle) cellSelectionStyle
{
    return UITableViewCellSelectionStyleBlue;
}

@end
