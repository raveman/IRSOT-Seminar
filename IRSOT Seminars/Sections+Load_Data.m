//
//  Sections+Load_Data.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 03.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "Sections+Load_Data.h"

@implementation Sections (Load_Data)

+ (Sections *)sectionWithTerm:(NSDictionary *)term inManagedObjectContext:(NSManagedObjectContext *)context
{
    Sections *section = nil;
    
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

+ (Sections *)sectionWithId:(NSInteger)sectionId inManagedObjectContext:(NSManagedObjectContext *)context
{
    Sections *section = nil;
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

- (UIColor *)sectionColor
{
 
    NSInteger sectionID = [self.id integerValue];
    UIColor *color = nil;
    
    switch (sectionID) {
        case 6: // бух-учет
            color = [UIColor colorWithRed:62/255.0 green:157/255.0 blue:30/255.0 alpha:1.0];
            break;
        case 7: // финансы
            color = [UIColor colorWithRed:52/255.0 green:168/255.0 blue:210/255.0 alpha:1.0];
            break;
        case 10: // управление
            color = [UIColor colorWithRed:243/255.0 green:91/255.0 blue:30/255.0 alpha:1.0];
            break;
        case 8: // право
            color = [UIColor colorWithRed:199/255.0 green:179/255.0 blue:38/255.0 alpha:1.0];
            break;
        case 9: // кадры
            color = [UIColor colorWithRed:201/255.0 green:66/255.0 blue:137/255.0 alpha:1.0];
            break;
        default:
            break;
    }
    
    
    return color;
}

@end
