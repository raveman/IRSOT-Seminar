//
//  Section+Load_Data.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 06.03.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#import "Section.h"

@interface Section (Load_Data)

+ (Section *)sectionWithTerm:(NSDictionary *)term inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Section *)sectionWithId:(NSInteger)sectionId inManagedObjectContext:(NSManagedObjectContext *)context;

@end
