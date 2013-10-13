//
//  RFQuoteCell.m
//  DailyChallenge
//
//  Created by Bryce Redd on 10/12/13.
//  Copyright (c) 2013 Itv. All rights reserved.
//

#import "RFQuoteCell.h"

@interface RFQuoteCell()

@property (weak, nonatomic) IBOutlet UILabel *quoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditLabel;

@end

@implementation RFQuoteCell

- (void)setChallenge:(Challenge *)challenge {
    _challenge = challenge;
    
    self.quoteLabel.text = challenge.quote;
    self.creditLabel.text = challenge.quoteCredit;
}

@end
