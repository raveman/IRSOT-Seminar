//
//  Sections+Load_Data.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 03.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "Sections.h"

@interface Sections (Load_Data)

+ (Sections *)sectionWithTerm:(NSDictionary *)term inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Sections *)sectionWithId:(NSInteger)sectionId inManagedObjectContext:(NSManagedObjectContext *)context;

- (UIColor *)sectionColor;

@end
