//
//  RFDayViewController.h
//  DailyChallenge
//
//  Created by Bryce Redd on 4/22/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Challenge.h"

@interface RFDayViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) Challenge* challenge;
@end
