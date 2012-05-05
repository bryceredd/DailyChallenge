//
//  RFQuoteCell.m
//  DailyChallenge
//
//  Created by Bryce Redd on 4/29/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "RFQuoteCell.h"

@implementation RFQuoteCell

@synthesize quote;

+ (float) heightForQuote:(NSString*)quote {
    return 100.f;
}

@end
