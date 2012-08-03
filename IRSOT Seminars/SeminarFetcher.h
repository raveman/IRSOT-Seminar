//
//  SeminarFetcher.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 01.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SeminarFetcher : NSObject

+ (NSDictionary *)sectionsAndTypes;

+ (NSArray *)seminars;
+ (NSArray *)lectors;


@end
