//
//  RFChallengeService.m
//  DailyChallenge
//
//  Created by Bryce Redd on 4/22/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "RFChallengeService.h"
#import "RFCoreDataModel.h"
#import "AFNetworking.h"
#import "NSObject+JTObjectMapping.h"

@implementation RFChallengeService

- (void) fetchNewChallenges:(void(^)(NSArray*))callback {

    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/challenges", CHALLENGE_API]];
    AFJSONRequestOperation* operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:url] success:^(NSURLRequest* request, NSHTTPURLResponse* response, id json) {
        
        NSArray* array = [Challenge objectFromJSONObject:json mapping:nil];
                          
        array = [array sortedArrayUsingSelector:@selector(compare:)];
        
        if(callback) callback(array);
        
     } failure:nil];
     
     [operation start];
}

@end
