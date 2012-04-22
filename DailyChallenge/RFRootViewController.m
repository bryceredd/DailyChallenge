//
//  RFRootViewController.m
//  DailyChallenge
//
//  Created by Bryce Redd on 4/19/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "RFRootViewController.h"
#import "RFDayViewController.h"


@interface RFRootViewController ()
@property(nonatomic, strong) RFDayViewController *leftViewController;
@property(nonatomic, strong) RFDayViewController *rightViewController;
@property(nonatomic, strong) RFDayViewController *middleViewController;

- (void)resetScrollViewController;

@end

@implementation RFRootViewController

@synthesize scrollView;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RFDayViewController"];
    self.rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RFDayViewController"];
    self.middleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RFDayViewController"];

    [self.scrollView addSubview:self.leftViewController];
    [self.scrollView addSubview:self.rightViewController];
    [self.scrollView addSubview:self.middleViewController];

    setFrameY(self.leftViewController.view, 0);
    setFrameY(self.rightViewController.view, 0);
    setFrameY(self.middleViewController.view, 0);

    [self resetScrollViewController];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ipad? YES : interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void) scrollView

#pragma mark ui methods

- (void)resetScrollViewController {
    setFrameX(self.leftViewController.view, -CGRectGetMaxX(self.leftViewController.view.frame));
    setFrameX(self.rightViewController.view, CGRectGetMaxX(self.rightViewController.view.frame));
    setFrameX(self.middleViewController.view, 0);
}


@end
