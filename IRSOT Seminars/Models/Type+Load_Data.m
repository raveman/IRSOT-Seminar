//
//  Type+Load_Data.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 03.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "SeminarFetcher.h"
#import "Type+Load_Data.h"

@implementation Type (Load_Data)

+ (Type *)typeWithTerm:(NSDictionary *)term inManagedObjectContext:(NSManagedObjectContext *)context
{
    Type *type = nil;
    
    // check whether we have already a new section in our database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Type"];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %@", [term objectForKey:SEMINAR_TERM_ID]];
    // soring our fetch
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:SEMINAR_TERM_NAME ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        type = [NSEntityDescription insertNewObjectForEntityForName:@"Type" inManagedObjectContext:context];
        type.id = [NSNumber numberWithInteger:[[term objectForKey:SEMINAR_TERM_ID] integerValue]];
        type.name = [term objectForKey:SEMINAR_TERM_NAME];
        type.vid = [NSNumber numberWithInt: SEMINAR_TYPE_VID];
    } else {
        type = [matches lastObject];
    }
    
    return type;
}

+ (Type *)typeWithId:(NSInteger)typeId inManagedObjectContext:(NSManagedObjectContext *)context
{
    Type *section = nil;
    // check whether we have already a new section in our database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Type"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %d", typeId];
    // soring our fetch
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
