//
//  RFDayViewController.h
//  DailyChallenge
//
//  Created by Bryce Redd on 4/22/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Challenge.h"

@interface RFDayCell : UICollectionViewCell <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) Challenge* challenge;

- (void) nudgeImage:(float)pixels;
@end
