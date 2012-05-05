//
//  RFGoalCell.h
//  DailyChallenge
//
//  Created by Bryce Redd on 4/29/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Challenge.h"

@interface RFGoalCell : UITableViewCell

@property(nonatomic, strong) Challenge* challenge;

+ (float) heightForGoal:(NSString*)goal;

@end
