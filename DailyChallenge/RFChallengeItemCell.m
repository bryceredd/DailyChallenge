//
//  RFChallengeItemCell.m
//  DailyChallenge
//
//  Created by Bryce Redd on 10/12/13.
//  Copyright (c) 2013 Itv. All rights reserved.
//

#import "RFChallengeItemCell.h"

@interface RFChallengeItemCell ()

@property (weak, nonatomic) IBOutlet UILabel *taskLabel;
@property (weak, nonatomic) IBOutlet UISwitch *taskSwitch;

@end

@implementation RFChallengeItemCell

- (IBAction)toggleChallenge:(id)sender {
}

- (void)setTask:(ChallengeTask *)task {
    _task = task;
}

@end
