//
//  RFChallengeService.m
//  DailyChallenge
//
//  Created by Bryce Redd on 4/22/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "RFChallengeService.h"
#import "NSManagedObject+JSON.h"
#import "RFCoreDataModel.h"
#import "AFNetworking.h"

@implementation RFChallengeService

- (void) fetchNewChallenges:(void(^)(NSArray*))callback {

    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/challenges", CHALLENGE_API]];
    AFJSONRequestOperation* operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:url] success:^(NSURLRequest* request, NSHTTPURLResponse* response, id json) { 
        
        NSArray* sorted = [[Challenge objectWithObject:json inContext:[RFCoreDataModel managedObjectContext]] sortedArrayUsingSelector:@selector(compare:)];
        
        // fetch the stored challenges from coredata, and mix them
        
        callback(sorted);
        
     } failure:nil];
     
     [operation start];
}

@end
