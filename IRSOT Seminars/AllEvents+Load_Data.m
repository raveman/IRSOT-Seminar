//
//  AllEvents+Load_Data.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 25.02.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#import "AllEvents+Load_Data.h"

@implementation AllEvents (Load_Data)
+ (AllEvents *)eventWithTerm:(NSDictionary *)term inManagedObjectContext:(NSManagedObjectContext *)context
{
    AllEvents *event = nil;
    
    // check whether we have already a new section in our database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AllEvents"];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %@", [term objectForKey:@"tid"]];
    // soring our fetch
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"AllEvents" inManagedObjectContext:context];
        event.id = [NSNumber numberWithInteger:[[term objectForKey:@"tid"] integerValue]];
        event.name = [term objectForKey:@"name"];
        event.machine_name = [term objectForKey:@"machine_name"];
        event.vid = [NSNumber numberWithInteger:[[term objectForKey:@"vid"] integerValue]];
    } else {
        event = [matches lastObject];
    }
    
    return event;
}

@end
