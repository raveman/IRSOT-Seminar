//
//  ISSeminarViewController.h
//  IRSOT Seminars
//
//  Created by Bob Ershov on 04.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Seminar+Load_Data.h"

@interface ISSeminarViewController : UIViewController
@property (nonatomic, strong) Seminar *seminar;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
