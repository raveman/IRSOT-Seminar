//
//  Helper.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 08.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "Helper.h"

NSString * const NSUbiquitousKeyValueStoreDidChangeLocallyNotification = @"Seminar.Local.Change";

@implementation Helper

+ (CGRect) resizeLabel:(UILabel *)label withSize:(CGSize)size
{
    
    CGSize maximumLabelSize = size;
    
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    newFrame.size.width = expectedLabelSize.width - HORIZONTAL_MARGIN;
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


@end
