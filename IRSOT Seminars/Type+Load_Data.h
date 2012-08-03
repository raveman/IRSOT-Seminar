//
//  Type+Load_Data.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 03.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "Type.h"

@interface Type (Load_Data)

+ (Type *)typeWithTerm:(NSDictionary *)term inManagedObjectContext:(NSManagedObjectContext *)context;

@end
