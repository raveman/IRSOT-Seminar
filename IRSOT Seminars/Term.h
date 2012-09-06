//
//  Term.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 06.09.12.
//  Copyright (c) 2012 IRSOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Term : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * machine_name;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * vid;

@end
