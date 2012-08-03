//
//  Type+Load_Data.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 03.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "Type+Load_Data.h"

@implementation Type (Load_Data)

+ (Type *)typeWithTerm:(NSDictionary *)term inManagedObjectContext:(NSManagedObjectContext *)context
{
    Type *type = nil;
    
    // check whether we have already a new section in our database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Type"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@", [term objectForKey:@"tid"]];
    // soring our fetch
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        type = [NSEntityDescription insertNewObjectForEntityForName:@"Type" inManagedObjectContext:context];
        type.id = [term valueForKey:@"id"];
        type.name = [term valueForKey:@"name"];
        type.machine_name = [term valueForKey:@"machine_name"];
        
    } else {
        type = [matches lastObject];
    }
    
    return type;
}

@end
