//
//  Helper.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 08.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

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
//    newFrame.size.width = expectedLabelSize.width - HORIZONTAL_MARGIN;
    newFrame.size.width = maximumLabelSize.width;
    label.frame = newFrame;
    
    return newFrame;
}

+ (CGRect) resizeTextView:(UITextView *)textView withSize:(CGSize)size
{
    CGRect newFrame = textView.frame;
    newFrame.size.width = size.width - HORIZONTAL_MARGIN;
    textView.frame = newFrame;
    
    CGRect frame = textView.frame;
    frame.size.height = textView.contentSize.height;
    textView.frame = frame;
    
    return frame;
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

+ (UIFont *) cellDetailFont
{
    return [UIFont fontWithName:@"HelveticaNeue" size:14.0];
}

+ (UITableViewCellSelectionStyle) cellSelectionStyle
{
    return UITableViewCellSelectionStyleBlue;
}

@end
