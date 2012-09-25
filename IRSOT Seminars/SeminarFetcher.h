//
//  SeminarFetcher.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 01.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RUSEMINAR_BK_CSS @"http://www.ruseminar.ru/assets/css/bizclass.css"
#define RUSEMINAR_SEMINAR_CSS @"http://www.ruseminar.ru/assets/css/seminar.css"

#define SEMINAR_SITE @"devedu.ruseminar.ru"
#define SEMINAR_URL @"http://mobile.ruseminar.ru/api/nonauth"
#define UPDATE_NODE @"node/100"
#define SEMINAR_TAXONOMY_URL @"taxonomy_vocabulary"
#define SEMINAR_TERM_URL @"taxonomy_term"
#define SEMINAR_LIST_URL @"seminars"
#define SEMINAR_TYPE @"seminar_type"
#define SEMINAR_SECTION @"seminar_section"

#define SEMINAR_NAME @"node_title"
#define SEMINAR_LECTOR @"lectors"
#define SEMINAR_DATE_START @"date_start.value"
#define SEMINAR_DATE_END @"date_end.value2"
#define SEMINAR_ONLINE @"online"
#define SEMINAR_RUSEMINAR_ID @"ruseminar_id"
#define SEMINAR_RUSEMINAR_URL @"ruseminar_url"
#define SEMINAR_PROGRAM @"program"
#define SEMINAR_COST_FULL @"cost_full"
#define SEMINAR_COST_DISCOUNT @"cost_discount"

#define LECTOR_LIST_URL @"lectors"
#define LECTOR_NAME @"lector_name"
#define LECTOR_BIO @"bio"
#define LECTOR_ID @"nid"
#define LECTOR_RUSEMINAR_ID @"ruseminar_id"
#define LECTOR_PHOTO_URL @"photo_url"

#define SEMINAR_DATE_FORMAT @"yyyy-MM-dd HH:mm:ss"
#define SEMINAR_DATE_FORMAT_DATE @"dd"
#define SEMINAR_DATE_FORMAT_DATE_MONTH @"MMMM YYYY"

// extern NSString *const kReachabilityChangedNotification;

// NSString *const kSeminarDataChangedNotification = @"kSeminarDataChangedNotification";

@interface SeminarFetcher : NSObject

+ (NSDictionary *)sectionsAndTypes;

+ (NSArray *)seminars;
+ (NSArray *)lectors;

+ (NSInteger)checkUpdates;


@end
