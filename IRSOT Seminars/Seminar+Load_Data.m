//
//  Seminar+Load_Data.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 03.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//
#import "SeminarFetcher.h"

#import "Seminar+Load_Data.h"
#import "Sections+Load_Data.h"
#import "Type+Load_Data.h"
#import "Lector+Load_Data.h"

@implementation Seminar (Load_Data)

+ (Seminar *)seminarWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Seminar *seminar = nil;
    
    // check whether we have already a new seminar in our database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Seminar"];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %@", [dictionary objectForKey:@"nid"]];
    // soring our fetch
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        seminar = [NSEntityDescription insertNewObjectForEntityForName:@"Seminar" inManagedObjectContext:context];
        seminar.id = [NSNumber numberWithInteger:[[dictionary objectForKey:@"nid"] integerValue]];
        seminar.name = [dictionary objectForKey:SEMINAR_NAME];
        
        NSString *dateStartStr = [dictionary valueForKeyPath:SEMINAR_DATE_START];
        NSString *dateEndStr = [dictionary valueForKeyPath:SEMINAR_DATE_END];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:SEMINAR_DATE_FORMAT];
        NSDate *dateStart = [[NSDate alloc] init];
        dateStart = [dateFormatter dateFromString:dateStartStr];
        NSDate *dateEnd = [[NSDate alloc] init];
        dateEnd = [dateFormatter dateFromString:dateEndStr];
        seminar.date_start = dateStart;
        seminar.date_end = dateEnd;
        
        seminar.ruseminarID = [NSNumber numberWithInteger:[[dictionary objectForKey:SEMINAR_RUSEMINAR_ID] integerValue]];
        seminar.online = [NSNumber numberWithInteger:[[[dictionary objectForKey:SEMINAR_ONLINE] objectForKey:@"value"] integerValue]];

        NSInteger sectionId = [[[dictionary objectForKey:SEMINAR_SECTION] objectForKey:@"tid"] integerValue];
        Sections *section = [Sections sectionWithId:sectionId inManagedObjectContext:context];
        seminar.section = section;

        NSInteger typeId = [[[dictionary objectForKey:SEMINAR_TYPE] objectForKey:@"tid"] integerValue];
        Type *type = [Type typeWithId:typeId inManagedObjectContext:context];
        seminar.type = type;
        
        NSArray *lectorNames = [[dictionary objectForKey:SEMINAR_LECTOR] componentsSeparatedByString:@","];
        NSMutableSet *lectors = [NSMutableSet set];
        for (NSString *lectorName in lectorNames) {
            Lector *lector = [Lector lectorWithName:lectorName inManagedObjectContext:context];
            [lectors addObject:lector];
        }
        seminar.lectors = lectors;
    } else {
        seminar = [matches lastObject];
    }
    return seminar;
}

- (NSString *)stringWithLectorNames
{
    NSString *lectors = nil;
    for (Lector *lector in self.lectors) {
        if (!lectors) lectors = [NSString stringWithFormat:@"%@", lector.name];
        else lectors = [NSString stringWithFormat:@"%@, %@", lectors, lector.name];
    }
    return lectors;
}

@end
