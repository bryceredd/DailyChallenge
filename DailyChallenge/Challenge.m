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

- (void) setValue:(id)value forKey:(NSString *)key {
    if([key isEqualToString:@"tasks"]) {
        value = [NSSet setWithArray:[ChallengeTask objectWithJSON:[value JSONString] inContext:self.managedObjectContext]];
    } 
    
    [super setValue:value forKey:key];
}


@end
