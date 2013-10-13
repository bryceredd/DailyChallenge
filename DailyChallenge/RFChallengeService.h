//
//  RFChallengeService.h
//  DailyChallenge
//
//  Created by Bryce Redd on 4/22/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Challenge.h"

@interface RFChallengeService : NSObject
- (void) fetchNewChallenges:(void(^)(NSArray*))callback;
@end
