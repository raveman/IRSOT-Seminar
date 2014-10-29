//
//  Info+Load_data.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 29/10/14.
//  Copyright (c) 2014 IRSOT. All rights reserved.
//

#import "Info.h"

@interface Info (Load_data)

+ (Info *) infoWithDictionary:(NSDictionary *) dictionary inManagedObjectContext:(NSManagedObjectContext *)context;
@end
