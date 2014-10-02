//
//  ISActivityProvider.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 02/10/14.
//  Copyright (c) 2014 IRSOT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Seminar.h"

static NSString * const ISActivityViewOnWeb = @"ru.irsot.activity.ViewOnWeb";
static NSString * const ISActivityViewAdditional = @"ru.irsot.activity.ViewAdditional";

@interface ISActivityProvider : UIActivityItemProvider <UIActivityItemSource>

@property (nonatomic, strong) Seminar *seminar;

@end
