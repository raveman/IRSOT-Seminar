//
//  Seminar+Load_Data.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 03.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "Seminar.h"

#define BOOKMARKS_KEY @"Bookmark"

#define BOOKMARK_SEMINAR_NAME_KEY @"Seminar.Name"
#define BOOKMARK_SEMINAR_ID_KEY @"Seminar.ID"
#define BOOKMARK_SEMINAR_DATE_KEY @"Seminar.Date"

@interface Seminar (Load_Data)

+ (Seminar *)seminarWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Seminar *)seminarWithDictionary:(NSDictionary *)dictionary lectors:(NSArray *)lectors inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSString *)stringWithLectorNames;
- (NSString *)stringWithSeminarDates;
- (NSString *)stringWithSeminarMonth;

@end
