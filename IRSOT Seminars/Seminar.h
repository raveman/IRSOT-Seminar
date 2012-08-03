//
//  Seminar.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 03.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lector, Sections, Type;

@interface Seminar : NSManagedObject

@property (nonatomic, retain) NSDate * date_end;
@property (nonatomic, retain) NSDate * date_start;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * online;
@property (nonatomic, retain) NSNumber * ruseminarID;
@property (nonatomic, retain) NSSet *lectors;
@property (nonatomic, retain) Sections *section;
@property (nonatomic, retain) Type *type;
@end

@interface Seminar (CoreDataGeneratedAccessors)

- (void)addLectorsObject:(Lector *)value;
- (void)removeLectorsObject:(Lector *)value;
- (void)addLectors:(NSSet *)values;
- (void)removeLectors:(NSSet *)values;

@end
