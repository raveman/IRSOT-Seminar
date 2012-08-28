//
//  Lector.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 28.08.12.
//  Copyright (c) 2012 IRSOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Seminar;

@interface Lector : NSManagedObject

@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSNumber * ruseminarID;
@property (nonatomic, retain) NSString * fatherName;
@property (nonatomic, retain) NSSet *seminars;
@end

@interface Lector (CoreDataGeneratedAccessors)

- (void)addSeminarsObject:(Seminar *)value;
- (void)removeSeminarsObject:(Seminar *)value;
- (void)addSeminars:(NSSet *)values;
- (void)removeSeminars:(NSSet *)values;

@end
