//
//  Section.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 06.03.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Term.h"

@class Seminar;

@interface Section : Term

@property (nonatomic, retain) NSSet *seminars;
@end

@interface Section (CoreDataGeneratedAccessors)

- (void)addSeminarsObject:(Seminar *)value;
- (void)removeSeminarsObject:(Seminar *)value;
- (void)addSeminars:(NSSet *)values;
- (void)removeSeminars:(NSSet *)values;

@end
