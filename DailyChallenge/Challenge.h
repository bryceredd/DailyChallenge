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

@interface Challenge : NSManagedObject

@property (nonatomic, retain) NSString * challenge;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * imageCredit;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * quote;
@property (nonatomic, retain) NSString * quoteCredit;
@property (nonatomic, retain) NSSet *tasks;

@end

@interface Challenge (CoreDataGeneratedAccessors)

- (void)addTasksObject:(ChallengeTask *)value;
- (void)removeTasksObject:(ChallengeTask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

@end
