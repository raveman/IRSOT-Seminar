//
//  Lector+Load_Data.m
//  IRSOT Lectors
//
//  Created by Bob Ershov on 03.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "Lector+Load_Data.h"

@implementation Lector (Load_Data)

+ (Lector *)lectorWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    Lector *lector = nil;
    
    // check whether we have already a new Lector in our database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Lector"];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %@", name];
    // soring our fetch
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        lector = [NSEntityDescription insertNewObjectForEntityForName:@"Lector" inManagedObjectContext:context];
        lector.name = name;
    } else {
        lector = [matches lastObject];
    }
    
    return lector;
}
@end
