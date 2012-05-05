//
//  RFCoreDataModel.m
//  DailyChallenge
//
//  Created by Bryce Redd on 4/25/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "RFCoreDataModel.h"
#import "RFAppDelegate.h"

@implementation RFCoreDataModel

+ (NSManagedObjectContext*) managedObjectContext {
    RFAppDelegate* delegate = (RFAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    return delegate.managedObjectContext;
}

@end
