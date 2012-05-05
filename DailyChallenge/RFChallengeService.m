//
//  RFChallengeService.m
//  DailyChallenge
//
//  Created by Bryce Redd on 4/22/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "RFChallengeService.h"
#import "NSManagedObject+JSON.h"
#import "DDHTTPRequest.h"
#import "RFCoreDataModel.h"

@implementation RFChallengeService

- (void) fetchNewChallenges:(void(^)(NSArray*))callback {

    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/challenges", CHALLENGE_API]];
    DDHTTPRequest* request = [DDHTTPRequest getRequestForURL:url];
    
    [request sendAsyncWithCallback:^(DDHTTPRequest* request) {
        callback([Challenge objectWithJSON:[request responseStringValueUTF8Encoding] inContext:[RFCoreDataModel managedObjectContext]]);
    }];
}

@end
