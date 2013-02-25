//
//  Seminar.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 25.02.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AllEvents, Lector, Sections, Type;

@interface Seminar : NSManagedObject

@property (nonatomic, retain) NSNumber * cost_discount;
@property (nonatomic, retain) NSNumber * cost_full;
@property (nonatomic, retain) NSDate * date_end;
@property (nonatomic, retain) NSDate * date_start;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * online;
@property (nonatomic, retain) NSString * program;
@property (nonatomic, retain) NSString * ruseminar_url;
@property (nonatomic, retain) NSNumber * ruseminarID;
@property (nonatomic, retain) NSSet *lectors;
@property (nonatomic, retain) Sections *section;
@property (nonatomic, retain) Type *type;
@property (nonatomic, retain) NSSet *allevents;
@end

@interface Seminar (CoreDataGeneratedAccessors)

- (void)addLectorsObject:(Lector *)value;
- (void)removeLectorsObject:(Lector *)value;
- (void)addLectors:(NSSet *)values;
- (void)removeLectors:(NSSet *)values;

- (void)addAlleventsObject:(AllEvents *)value;
- (void)removeAlleventsObject:(AllEvents *)value;
- (void)addAllevents:(NSSet *)values;
- (void)removeAllevents:(NSSet *)values;

@end
