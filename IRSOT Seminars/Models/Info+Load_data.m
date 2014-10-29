//
//  Info+Load_data.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 29/10/14.
//  Copyright (c) 2014 IRSOT. All rights reserved.
//

#import "Info+Load_data.h"
#import "SeminarFetcher.h"

@implementation Info (Load_data)

+ (Info *) infoWithDictionary:(NSDictionary *) dictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Info *info = nil;
    
    // check whether we have already a new section in our database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Info"];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %@", [dictionary objectForKey:SEMINAR_INFO_ID]];
    // soring our fetch
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        info = [NSEntityDescription insertNewObjectForEntityForName:@"Info" inManagedObjectContext:context];
        info.id = [NSNumber numberWithInteger:[[dictionary objectForKey:SEMINAR_INFO_ID] integerValue]];
        info.category = [dictionary objectForKey:SEMINAR_INFO_CATEGORY];
        info.page_url = [dictionary objectForKey:SEMINAR_INFO_URL];
        info.title_eng = [dictionary objectForKey:SEMINAR_INFO_TITLE_ENG];
        info.title_rus = [dictionary objectForKey:SEMINAR_INFO_TITLE_RUS];
    } else {
        info = [matches lastObject];
    }

    return info;
}


@end
