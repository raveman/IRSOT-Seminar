//
//  Helper.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 08.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HORIZONTAL_MARGIN 40

@interface Helper : NSObject
+ (CGRect) resizeLabel:(UILabel *)label withSize:(CGSize)size;
+ (CGRect) resizeTextView:(UITextView *)textView withSize:(CGSize)size;
+ (CGRect) resizeRectButton:(UIButton *)button withSize:(CGSize)size;
@end
