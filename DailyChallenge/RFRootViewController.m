//
//  RFRootViewController.m
//  DailyChallenge
//
//  Created by Bryce Redd on 4/19/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "RFRootViewController.h"
#import "RFDayViewController.h"
#import "RFChallengeService.h"


@interface RFRootViewController ()
@property(nonatomic, strong) RFDayViewController *leftViewController;
@property(nonatomic, strong) RFDayViewController *rightViewController;
@property(nonatomic, strong) RFDayViewController *middleViewController;
@property(nonatomic, strong) NSArray *controllers;

- (void)resetScrollViewController;

- (float) dayWidth;

@end

@implementation RFRootViewController

@synthesize scrollView;
@synthesize leftViewController, rightViewController, middleViewController;
@synthesize controllers;
@synthesize managedObjectContext;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[RFChallengeService new] fetchNewChallenges:^(NSArray* challenges) {
        NSLog(@"challenges!: %@", challenges);
    }];

    self.leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RFDayViewController"];
    self.rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RFDayViewController"];
    self.middleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RFDayViewController"];

    self.controllers = [NSArray arrayWithObjects:self.leftViewController, self.rightViewController, self.middleViewController, nil];

    [self.controllers enumerateObjectsUsingBlock:^(UIViewController *controller, NSUInteger index, BOOL *stop) {
        [self.scrollView addSubview:controller.view];
        setFrameY(controller.view, 0);
    }];

    [self.scrollView setContentSize:CGSizeMake([self dayWidth] * 3, 0)];

    self.leftViewController.table.backgroundColor = RGB(255, 0, 0);
    self.rightViewController.table.backgroundColor = RGB(255, 255, 0);
    self.middleViewController.table.backgroundColor = RGB(0, 255, 255);

    [self resetScrollViewController];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ipad? YES : interfaceOrientation == UIInterfaceOrientationPortrait;
}


#pragma mark scroll methods

- (CATransform3D) transformForPercent:(float)percent {
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -800;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI/2 * percent, 0.0f, 1.0f, 0.0f);
    return rotationAndPerspectiveTransform;
}

- (void)scrollViewDidScroll:(UIScrollView *)scroll {
    float midPercent = (float)(self.scrollView.contentOffset.x - [self dayWidth]) / [self dayWidth];
    float leftPercent = midPercent - 1;
    float rightPercent = midPercent + 1;

    self.leftViewController.view.layer.transform = [self transformForPercent:leftPercent];
    self.middleViewController.view.layer.transform = [self transformForPercent:midPercent];
    self.rightViewController.view.layer.transform = [self transformForPercent:rightPercent];

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    // find which view controller is now the middle
    // we need to do this to prevent our view controllers from
    // being deallocd!
    RFDayViewController *mid = self.middleViewController;
    RFDayViewController *right = self.rightViewController;
    RFDayViewController *left = self.leftViewController;

    if (self.scrollView.contentOffset.x < [self dayWidth]) {
        self.leftViewController = right;
        self.middleViewController = left;
        self.rightViewController = mid;
    }

    if (self.scrollView.contentOffset.x > [self dayWidth]) {
        self.leftViewController = mid;
        self.middleViewController = right;
        self.rightViewController = left;
    }

    [self resetScrollViewController];
}


#pragma mark ui methods

- (void)resetScrollViewController {
    [self.controllers enumerateObjectsUsingBlock:^(UIViewController *controller, NSUInteger index, BOOL *stop) {
        controller.view.layer.transform = [self transformForPercent:0];
    }];
    
    
    setFrameX(self.leftViewController.view, 0);
    setFrameX(self.middleViewController.view, [self dayWidth]);
    setFrameX(self.rightViewController.view, [self dayWidth] * 2);
    
    [self.view bringSubviewToFront:self.middleViewController.view];

    [self.scrollView setContentOffset:CGPointMake([self dayWidth], 0) animated:NO];
}


#pragma mark helper methods

- (RFDayViewController *)first:(BOOL(^)(RFDayViewController *))block {
    for (RFDayViewController *controller in [NSArray arrayWithObjects:self.leftViewController, self.rightViewController, self.middleViewController, nil]) {
        if (block(controller)) return controller;
    }
    return nil;
}

- (float) dayWidth {
    return CGRectGetWidth(self.view.frame);
}

@end
