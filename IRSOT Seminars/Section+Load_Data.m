//
//  Section+Load_Data.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 06.03.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#import "SeminarFetcher.h"
#import "Section+Load_Data.h"

@implementation Section (Load_Data)

+ (Section *)sectionWithTerm:(NSDictionary *)term inManagedObjectContext:(NSManagedObjectContext *)context
{
    Section *section = nil;
    
    // check whether we have already a new section in our database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Section"];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %@", [term objectForKey:SEMINAR_TERM_ID]];
    // soring our fetch
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:SEMINAR_TERM_NAME ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        section = [NSEntityDescription insertNewObjectForEntityForName:@"Section" inManagedObjectContext:context];
        section.id = [NSNumber numberWithInteger:[[term objectForKey:SEMINAR_TERM_ID] integerValue]];
        section.name = [term objectForKey:SEMINAR_TERM_NAME];
        section.vid = [NSNumber numberWithInt: 2];
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
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:SEMINAR_TERM_NAME ascending:YES];
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
