//
//  RFCreditCell.h
//  DailyChallenge
//
//  Created by Bryce Redd on 4/29/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Challenge.h"

@interface RFCreditCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel* credit;
@property(nonatomic, strong) Challenge* challenge;

@end
