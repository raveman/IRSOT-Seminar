//
//  AllEvents+Load_Data.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 25.02.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#import "SeminarFetcher.h"
#import "AllEvents+Load_Data.h"

@implementation AllEvents (Load_Data)
+ (AllEvents *)eventWithTerm:(NSDictionary *)term inManagedObjectContext:(NSManagedObjectContext *)context
{
    AllEvents *event = nil;
    
    // check whether we have already a new section in our database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AllEvents"];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %@", [term objectForKey:SEMINAR_TERM_ID]];
    // soring our fetch
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"AllEvents" inManagedObjectContext:context];
        event.id = [NSNumber numberWithInteger:[[term objectForKey:SEMINAR_TERM_ID] integerValue]];
        event.name = [term objectForKey:SEMINAR_TERM_NAME];
    } else {
        event = [matches lastObject];
    }
    
    return event;
}

@end
