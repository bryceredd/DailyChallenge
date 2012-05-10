//
//  RFDayViewController.h
//  DailyChallenge
//
//  Created by Bryce Redd on 4/22/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Challenge.h"
#import "ImageViewCenteredFit.h"

@interface RFDayViewController : UIViewController

@property (nonatomic, strong) Challenge* challenge;

@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) IBOutlet UILabel *quote;
@property (weak, nonatomic) IBOutlet UILabel *quoteCredit;
@property (weak, nonatomic) IBOutlet UIView *challengeView;
@property (weak, nonatomic) IBOutlet UILabel *challengeLabel;
@property (weak, nonatomic) IBOutlet ImageViewCenteredFit *imageView;


@end
