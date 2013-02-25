//
//  Type+Load_Data.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 03.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "Type.h"

#define SEMINAR_TYPE_SEMINAR 1
#define SEMINAR_TYPE_BK 2
#define SEMINAR_TYPE_COURSE 3
#define SEMINAR_TYPE_CONFERENCE 4
#define SEMINAR_TYPE_MASTER_CLASS 21
#define SEMINAR_TYPE_NBU 17
#define SEMINAR_TYPE_THEMATIC_WEEK 18
#define SEMINAR_TYPE_ALL 24

//#define SEMINAR_TYPE_SEMINAR_BK 3
//#define SEMINAR_TYPE_OTHER 2


@interface Type (Load_Data)

+ (Type *)typeWithTerm:(NSDictionary *)term inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Type *)typeWithId:(NSInteger)typeId inManagedObjectContext:(NSManagedObjectContext *)context;

@end
