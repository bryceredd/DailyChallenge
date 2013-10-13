//
//  Challenge.m
//  DailyChallenge
//
//  Created by Bryce Redd on 4/29/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "Challenge.h"
#import "ChallengeTask.h"
#import "JSONKit.h"

@implementation Challenge

- (NSURL*) imageUrl {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@", CHALLENGE_API, self.imagePath]];
}

- (NSComparisonResult) compare:(Challenge*)challenge {
    return [self.date compare:challenge.date];
}

@end
