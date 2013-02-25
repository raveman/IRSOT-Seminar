//
//  AllEvents+Load_Data.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 25.02.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#import "AllEvents.h"

@interface AllEvents (Load_Data)

+ (AllEvents *)eventWithTerm:(NSDictionary *)term inManagedObjectContext:(NSManagedObjectContext *)context;

@end
