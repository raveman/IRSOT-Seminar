//
//  Info.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 29/10/14.
//  Copyright (c) 2014 IRSOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Info : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * page_url;
@property (nonatomic, retain) NSString * title_eng;
@property (nonatomic, retain) NSString * title_rus;
@property (nonatomic, retain) NSNumber * id;

@end
