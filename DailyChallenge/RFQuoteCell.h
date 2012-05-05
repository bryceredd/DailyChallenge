//
//  RFQuoteCell.h
//  DailyChallenge
//
//  Created by Bryce Redd on 4/29/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Challenge.h"

@interface RFQuoteCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel* quote;
@property(nonatomic, strong) Challenge* challenge;

+ (float) heightForQuote:(NSString*)quote;

@end
