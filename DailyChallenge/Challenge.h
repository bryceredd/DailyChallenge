//
//  Challenge.h
//  DailyChallenge
//
//  Created by Bryce Redd on 4/29/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChallengeTask;

@interface Challenge : NSObject
@property (nonatomic) NSString * challenge;
@property (nonatomic) NSDate * date;
@property (nonatomic) NSString * imageCredit;
@property (nonatomic) NSString * imagePath;
@property (nonatomic) NSString * quote;
@property (nonatomic) NSString * quoteCredit;
@property (nonatomic) NSOrderedSet * tasks;

- (NSURL*) imageUrl;

@end
