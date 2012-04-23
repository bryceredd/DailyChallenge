//
//  Challenge.h
//  DailyChallenge
//
//  Created by Bryce Redd on 4/22/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Challenge : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * quote;
@property (nonatomic, retain) NSString * quoteCredit;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * imageCredit;
@property (nonatomic, retain) NSString * challenge;
@property (nonatomic, retain) NSManagedObject *tasks;

@end
