//
//  Lector+Load_Data.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 03.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "Lector.h"

@interface Lector (Load_Data)

+ (Lector *)lectorWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Lector *)lectorWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Lector *)lectorWithID:(NSInteger)lectorID inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSString *)lectorNameInitial;
- (NSString *)fullName;

@end
