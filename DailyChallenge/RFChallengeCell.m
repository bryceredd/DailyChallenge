//
//  RFChallengeCell.m
//  DailyChallenge
//
//  Created by Bryce Redd on 10/12/13.
//  Copyright (c) 2013 Itv. All rights reserved.
//

#import "RFChallengeCell.h"

@interface RFChallengeCell ()

@property (weak, nonatomic) IBOutlet UILabel *challengeLabel;

@end

@implementation RFChallengeCell

- (void)setChallenge:(Challenge *)challenge {
    _challenge = challenge;
    
    self.challengeLabel.text = self.challenge.challenge;
}

@end
