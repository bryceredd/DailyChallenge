//
//  Challenge.m
//  DailyChallenge
//
//  Created by Bryce Redd on 4/29/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "Challenge.h"
#import "ChallengeTask.h"
#import "NSManagedObject+JSON.h"
#import "JSONKit.h"

@implementation Challenge

@dynamic challenge;
@dynamic date;
@dynamic imageCredit;
@dynamic imageUrl;
@dynamic quote;
@dynamic quoteCredit;
@dynamic tasks;

- (NSComparisonResult) compare:(Challenge*)challenge {
    return [self.date compare:challenge.date];
}

@end
