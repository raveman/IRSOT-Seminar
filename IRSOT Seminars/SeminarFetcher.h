//
//  SeminarFetcher.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 01.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SEMINAR_URL @"http://devedu.ruseminar.ru/api/nonauth/"
#define SEMINAR_TAXONOMY_URL @"taxonomy_vocabulary"
#define SEMINAR_TERM_URL @"taxonomy_term"
#define SEMINAR_LIST_URL @"seminars"
#define SEMINAR_TYPE @"seminar_type"
#define SEMINAR_SECTION @"seminar_section"

#define SEMINAR_NAME @"node_title"
#define SEMINAR_LECTOR @"lector"
#define SEMINAR_DATE_START @"date_start.value"
#define SEMINAR_DATE_END @"date_end.value"
#define SEMINAR_ONLINE @"online"
#define SEMINAR_RUSEMINAR_ID @"ruseminar_id"

#define SEMINAR_DATE_FORMAT @"yyyy-MM-dd HH:mm:ss"

@interface SeminarFetcher : NSObject

+ (NSDictionary *)sectionsAndTypes;

+ (NSArray *)seminars;
+ (NSArray *)lectors;


@end
