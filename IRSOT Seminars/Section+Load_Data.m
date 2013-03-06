//
//  Section+Load_Data.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 06.03.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#import "Section+Load_Data.h"

@implementation Section (Load_Data)

+ (Section *)sectionWithTerm:(NSDictionary *)term inManagedObjectContext:(NSManagedObjectContext *)context
{
    Section *section = nil;
    
    // check whether we have already a new section in our database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Section"];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %@", [term objectForKey:@"tid"]];
    // soring our fetch
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        section = [NSEntityDescription insertNewObjectForEntityForName:@"Section" inManagedObjectContext:context];
        section.id = [NSNumber numberWithInteger:[[term objectForKey:@"tid"] integerValue]];
        section.name = [term objectForKey:@"name"];
        section.machine_name = [term objectForKey:@"machine_name"];
        section.vid = [NSNumber numberWithInteger:[[term objectForKey:@"vid"] integerValue]];
    } else {
        section = [matches lastObject];
    }
    
    return section;
}

+ (Section *)sectionWithId:(NSInteger)sectionId inManagedObjectContext:(NSManagedObjectContext *)context
{
    Section *section = nil;
    // check whether we have already a new section in our database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Section"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %d", sectionId];
    // sorting our fetch
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if ([matches count] == 0) {
        // TODO: handle error
        // why we have no section ?
    } else {
        section = [matches lastObject];
    }
    
    return section;
}
@end
