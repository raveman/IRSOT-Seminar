//
//  Lector+Load_Data.m
//  IRSOT Lectors
//
//  Created by Bob Ershov on 03.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "Lector+Load_Data.h"
#import "SeminarFetcher.h"

@implementation Lector (Load_Data)

+ (Lector *)lectorWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    Lector *lector = nil;
    
    // check whether we have already a new Lector in our database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Lector"];
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    // soring our fetch
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
        // some shit happens but we return last object anyway
        lector = [matches lastObject];

    } else if ([matches count] == 0) {
        lector = [NSEntityDescription insertNewObjectForEntityForName:@"Lector" inManagedObjectContext:context];
        lector.name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        lector.name = [name stringByTrimmingCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]];
    } else {
        lector = [matches lastObject];
    }
    
    return lector;
}

+ (Lector *)lectorWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Lector *lector = nil;
    
    NSInteger nid = [[dictionary objectForKey:LECTOR_ID] integerValue];

    // check whether we have already a new Lector in our database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Lector"];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %d", nid];
    
    // soring our fetch
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
        // some shit happens but we return last object anyway
        lector = [matches lastObject];
        
    } else if ([matches count] == 0) {
        lector = [NSEntityDescription insertNewObjectForEntityForName:@"Lector" inManagedObjectContext:context];
        lector.id = [NSNumber numberWithInteger:nid];
        NSString *str = [[[dictionary objectForKey:LECTOR_NAME] objectForKey:@"value"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // strip excessive whitespaces from string
        str = [str stringByReplacingOccurrencesOfString:@" +" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, str.length)];
        
        NSArray *lectorNames = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        lector.lastName = [lectorNames objectAtIndex:2];
        lector.firstName = [lectorNames objectAtIndex:0];
        lector.fatherName = [lectorNames objectAtIndex:1];

        lector.name = [NSString stringWithFormat:@"%@ %@. %@.",lector.lastName, [lector.firstName substringToIndex:1], [lector.fatherName substringToIndex:1]];
        
        NSString *strRuseminarID = [[[dictionary objectForKey:LECTOR_RUSEMINAR_ID] objectForKey:@"value" ]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        lector.ruseminarID = [numberFormatter numberFromString:strRuseminarID];
//        lector.ruseminarID = [[dictionary objectForKey:LECTOR_RUSEMINAR_ID] objectForKey:@"value"] ;

        
        lector.bio = [[dictionary objectForKey:LECTOR_BIO] objectForKey:@"value"];
        NSDictionary *urlInfo = [dictionary objectForKey:LECTOR_PHOTO_URL];
        if ([urlInfo count]) {
            lector.photo = [urlInfo objectForKey:@"url"];
        }
//         = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    } else {
        lector = [matches lastObject];
    }
    
    return lector;
}

+ (Lector *)lectorWithID:(NSInteger)lectorID inManagedObjectContext:(NSManagedObjectContext *)context
{
    Lector *lector = nil;
    
    
    // check whether we have already a new Lector in our database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Lector"];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %d", lectorID];
    
    // soring our fetch
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
        // some shit happens but we return last object anyway
    } else {
        lector = [matches lastObject];
    }

    return lector;
}

- (NSString *) lectorNameInitial {
    [self willAccessValueForKey:@"lectorNameInitial"];

//    NSString *initial = [self.name substringWithRange:[self.name rangeOfComposedCharacterSequenceAtIndex:1]];
    NSString *initial = [NSString string];
    if ([self.lastName length]) initial = [NSString localizedStringWithFormat:@"%@", [[self.lastName substringToIndex:1] uppercaseString]];

    [self didAccessValueForKey:@"lectorNameInitial"];
    return initial;
}

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@ %@", self.lastName, self.firstName, self.fatherName];
}

@end
