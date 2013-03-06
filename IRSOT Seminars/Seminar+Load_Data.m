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
#import "AllEvents.h"

@implementation Seminar (Load_Data)

+ (Seminar *)seminarWithDictionary:(NSDictionary *)dictionary lectors:(NSArray *)lectors inManagedObjectContext:(NSManagedObjectContext *)context
{
    Seminar *seminar = nil;

    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AllEvents"];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    AllEvents *allEvents = nil;
    if (matches) {
        allEvents = [matches objectAtIndex:0];
    }
    
    // check whether we have already a new seminar in our database
    request = [NSFetchRequest fetchRequestWithEntityName:@"Seminar"];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %@", [dictionary objectForKey:@"nid"]];
    // soring our fetch
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    error = nil;
    matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        seminar = [NSEntityDescription insertNewObjectForEntityForName:@"Seminar" inManagedObjectContext:context];
        seminar.id = [NSNumber numberWithInteger:[[dictionary objectForKey:@"nid"] integerValue]];
        seminar.name = [dictionary objectForKey:SEMINAR_NAME];
        
        NSString *strRuseminarID = [[dictionary objectForKey:SEMINAR_RUSEMINAR_ID] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        seminar.ruseminarID = [numberFormatter numberFromString:strRuseminarID];
        
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
        
        NSDictionary *buf = [dictionary objectForKey:SEMINAR_ONLINE];
        if ([buf count] >0 ) {
            NSString *bufString = [buf objectForKey:@"value"];
//            if ([bufString length] > 0) {
                seminar.online = [NSNumber numberWithInteger:[bufString integerValue]];
//            } else {
//                seminar.online = [NSNumber numberWithInteger:0];
//            }
        }
        
        NSInteger sectionId = [[[dictionary objectForKey:SEMINAR_SECTION] objectForKey:@"tid"] integerValue];
        Sections *section = [Sections sectionWithId:sectionId inManagedObjectContext:context];
        seminar.section = section;
        
        NSInteger typeId = [[[dictionary objectForKey:SEMINAR_TYPE] objectForKey:@"tid"] integerValue];
        Type *type = [Type typeWithId:typeId inManagedObjectContext:context];
        seminar.type = type;
        
        NSArray *lectorNames = [dictionary objectForKey:SEMINAR_LECTOR];
        NSMutableSet *lectorsForSeminar = [NSMutableSet set];
        for (NSString *lectorName in lectorNames) {
            Lector *lector = [Lector lectorWithID:[lectorName integerValue] inManagedObjectContext:context];
            [lectorsForSeminar addObject:lector];
        }
        seminar.lectors = lectorsForSeminar;
        seminar.ruseminar_url = [[dictionary objectForKey:SEMINAR_RUSEMINAR_URL] objectForKey:@"url"];
        NSDictionary *program = [dictionary objectForKey:SEMINAR_PROGRAM];
        if ([program count]) seminar.program = [program objectForKey:@"value"];
        NSNumber *cost_full = [NSNumber numberWithInteger:[[[dictionary objectForKey:SEMINAR_COST_FULL] objectForKey:@"value"] integerValue]];
        NSNumber *cost_discount = [NSNumber numberWithInteger:[[[dictionary objectForKey:SEMINAR_COST_DISCOUNT] objectForKey:@"value"] integerValue]];
        seminar.cost_full = cost_full;
        seminar.cost_discount = cost_discount;
        [allEvents addSeminarsObject:seminar];
        
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

- (NSString *)stringWithSeminarDates
{
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
    
    NSDateFormatter *dateFormatterDate = [[NSDateFormatter alloc] init];
    [dateFormatterDate setDateFormat:SEMINAR_DATE_FORMAT_DATE];
    [dateFormatterDate setLocale:locale];
    NSDateFormatter *dateFormatterMonth = [[NSDateFormatter alloc] init];
    [dateFormatterMonth setLocale:locale];
    [dateFormatterMonth setDateFormat:SEMINAR_DATE_FORMAT_DATE_MONTH];
    NSDateFormatter *dateFormatterMonthYear = [[NSDateFormatter alloc] init];
    [dateFormatterMonthYear setLocale:locale];
    [dateFormatterMonthYear setDateFormat:SEMINAR_DATE_FORMAT_DATE_MONTH_YEAR];

    
    NSString *dateStr;
    
    if ([[dateFormatterDate stringFromDate:self.date_start] isEqualToString:[dateFormatterDate stringFromDate:self.date_end]]) {
        dateStr = [NSString stringWithFormat:@"%@ %@", [dateFormatterDate stringFromDate:self.date_start],  [dateFormatterMonthYear stringFromDate:self.date_start]];
    } else {
        NSUInteger monthS = [self integerFromSeminarMonthWithDate:self.date_start];
        NSUInteger monthE = [self integerFromSeminarMonthWithDate:self.date_end];
        if ( monthS == monthE) {
            dateStr = [NSString stringWithFormat:@"%@ – %@ %@", [dateFormatterDate stringFromDate:self.date_start], [dateFormatterDate stringFromDate:self.date_end], [dateFormatterMonthYear stringFromDate:self.date_end]];
        } else {
            dateStr = [NSString stringWithFormat:@"%@ %@ – %@ %@", [dateFormatterDate stringFromDate:self.date_start], [dateFormatterMonth stringFromDate:self.date_start], [dateFormatterDate stringFromDate:self.date_end], [dateFormatterMonthYear stringFromDate:self.date_end]];
        }
    }
    
    return dateStr;
}

- (NSString *)stringFromSeminarMonth
{
    [self willAccessValueForKey:@"stringFromSeminarMonth"];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:locale];
    [formatter setDateFormat:@"LLLL"];
    NSString *stringFromDate = [formatter stringFromDate:self.date_start];
    [self didAccessValueForKey:@"stringFromSeminarMonth"];

    return stringFromDate;
}

- (NSInteger)integerFromSeminarDay
{
    NSCalendar *cal = [[NSCalendar alloc] init];
    NSDateComponents *components = [cal components:0 fromDate:self.date_start];
    
    return [components day];
}

- (NSInteger)integerFromSeminarMonthWithDate: (NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSMonthCalendarUnit fromDate:date];
    
    return [components month];
}

- (NSInteger)integerFromSeminarYear
{
    NSCalendar *cal = [[NSCalendar alloc] init];
    NSDateComponents *components = [cal components:0 fromDate:self.date_start];
    
    return [components year];
}
@end
