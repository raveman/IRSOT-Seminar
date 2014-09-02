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
#define RUSEMINAR_MY_CSS @"http://www.ruseminar.ru/assets/css/my.css"

#define RUSEMINAR_SITE @"http://www.ruseminar.ru"

#define SEMINAR_SITE @"devedu.ruseminar.ru"
#define SEMINAR_URL @"http://mobile.ruseminar.ru"
#define UPDATE_NODE @"lastupdate"

// #define SEMINAR_TAXONOMY_URL @"taxonomy_vocabulary"

#define SEMINAR_TAXONOMY_URL @"taxonomy_term?parameters[vid]"
#define SEMINAR_TERM_URL @"taxonomy_term"

#define SEMINAR_TYPE_LIST @"seminar_types.json"
#define SEMINAR_SECTION_LIST @"seminar_sections.json"
#define SEMINAR_ALL @"allseminarstype.json"

#define SEMINAR_TERM_ID @"id"
#define SEMINAR_TERM_NAME @"name"
#define SEMINAR_TERM_VID @"vid" // TERM type: 0 - type, 1 - section

// unused, only for drupal version
#define SEMINAR_TYPE_VID 2
#define SEMINAR_SECTION_VID 3
#define SEMINAR_ALL_VID 6

#define SEMINAR_LIST_URL @"seminars.json"
#define SEMINAR_NAME @"title"
#define SEMINAR_TYPE @"seminar_type_id"
#define SEMINAR_SECTION @"seminar_section_id"
#define SEMINAR_LECTOR @"lectors"
#define SEMINAR_DATE_START @"date_start"
#define SEMINAR_DATE_END @"date_end"
#define SEMINAR_ONLINE @"online"
#define SEMINAR_RUSEMINAR_ID @"ruseminar_id"
#define SEMINAR_RUSEMINAR_URL @"url"
#define SEMINAR_PROGRAM @"program"
#define SEMINAR_COST_FULL @"price1"
#define SEMINAR_COST_DISCOUNT @"price2"

#define LECTOR_LIST_URL @"lectors.json"
#define LECTOR_NAME @"name"
#define LECTOR_FIRST_NAME @"first_name"
#define LECTOR_FATHER_NAME @"father_name"
#define LECTOR_LAST_NAME @"last_name"
#define LECTOR_BIO @"bio"
#define LECTOR_ID @"id" // old unused, whe need only ruseminar_id
#define LECTOR_RUSEMINAR_ID @"id"
#define LECTOR_PHOTO_URL @"photo_url"

#define SEMINAR_PROGRAMS_LIST_URL @"seminar_programs.json"
#define SEMINAR_PROGRAM_ID @"ruseminar_id"
#define SEMINAR_PROGRAM_PROGRAM @"program"

#define SEMINAR_DATE_FORMAT @"yyyy-MM-dd"
#define SEMINAR_DATE_FORMAT_DATE @"dd"
#define SEMINAR_DATE_FORMAT_DATE_MONTH @"MMMM"
#define SEMINAR_DATE_FORMAT_DATE_MONTH_YEAR @"MMMM YYYY"

// extern NSString *const kReachabilityChangedNotification;

// NSString *const kSeminarDataChangedNotification = @"kSeminarDataChangedNotification";

@interface SeminarFetcher : NSObject

+ (NSDictionary *)sectionsAndTypes;

+ (NSArray *)seminars;
+ (NSArray *)seminarPrograms;
+ (NSArray *)lectors;

+ (NSInteger)checkUpdates;


@end
