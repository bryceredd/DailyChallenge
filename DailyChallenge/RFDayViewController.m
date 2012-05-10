//
//  RFDayViewController.m
//  DailyChallenge
//
//  Created by Bryce Redd on 4/22/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "RFDayViewController.h"
#import "UIImageView+AFNetworking.h"
#import "RFChallengeService.h"

@interface RFDayViewController ()

@end

@implementation RFDayViewController
@synthesize quote;
@synthesize quoteCredit;
@synthesize challengeView;
@synthesize challengeLabel;
@synthesize imageView;
@synthesize scrollView, challenge;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setQuote:nil];
    [self setQuoteCredit:nil];
    [self setChallengeView:nil];
    [self setChallengeLabel:nil];
    [self setImageView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) setChallenge:(Challenge *)data {
    challenge = data;
    
    self.quote.text = self.challenge.quote;
    self.quoteCredit.text = self.challenge.quoteCredit;
    self.challengeLabel.text = self.challenge.challenge;
    [self.imageView setImageWithURL:[NSURL URLWithString:self.challenge.imageUrl]];
}

@end
