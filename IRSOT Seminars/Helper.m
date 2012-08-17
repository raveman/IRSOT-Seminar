//
//  Helper.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 08.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+ (CGRect) resizeLabel:(UILabel *)label withSize: (CGSize)size
{
    
    CGSize maximumLabelSize = size;
    
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    
    return newFrame;
}

+ (CGRect) resizeTextView:(UITextView *)textView withSize: (CGSize)size
{
    CGRect newFrame = textView.frame;
    newFrame.size.width = size.width - HORIZONTAL_MARGIN;
    textView.frame = newFrame;
    
    CGRect frame = textView.frame;
    frame.size.height = textView.contentSize.height;
    textView.frame = frame;
    
    return frame;
}


@end