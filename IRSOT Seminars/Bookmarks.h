//
//  Bookmarks.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 20.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Seminar;

@interface Bookmarks : NSManagedObject

@property (nonatomic, retain) NSSet *seminars;
@end

@interface Bookmarks (CoreDataGeneratedAccessors)

- (void)addSeminarsObject:(Seminar *)value;
- (void)removeSeminarsObject:(Seminar *)value;
- (void)addSeminars:(NSSet *)values;
- (void)removeSeminars:(NSSet *)values;

@end
