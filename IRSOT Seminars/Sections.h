//
//  Sections.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 18.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Term.h"

@class Seminar;

@interface Sections : Term

@property (nonatomic, retain) NSSet *seminars;
@end

@interface Sections (CoreDataGeneratedAccessors)

- (void)addSeminarsObject:(Seminar *)value;
- (void)removeSeminarsObject:(Seminar *)value;
- (void)addSeminars:(NSSet *)values;
- (void)removeSeminars:(NSSet *)values;

@end
