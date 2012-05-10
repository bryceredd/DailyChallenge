//
//  RFRootViewController.m
//  DailyChallenge
//
//  Created by Bryce Redd on 4/19/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "RFRootViewController.h"
#import "RFDayViewController.h"
#import "RFChallengeService.h"
#import "RFMacros.h"

@interface RFRootViewController ()
@property(nonatomic, strong) RFDayViewController *leftViewController;
@property(nonatomic, strong) RFDayViewController *rightViewController;
@property(nonatomic, strong) RFDayViewController *middleViewController;
@property(nonatomic, strong) NSArray* challenges;
@property(nonatomic, strong) NSArray *controllers;

- (void)resetScrollViewController;

- (float) dayWidth;

@end

@implementation RFRootViewController

@synthesize scrollView;
@synthesize challenges;
@synthesize leftViewController, rightViewController, middleViewController;
@synthesize controllers;
@synthesize managedObjectContext;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[RFChallengeService new] fetchNewChallenges:^(NSArray* array) {
        self.challenges = array;
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

    [self resetScrollViewController];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ipad? YES : interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void) setChallenges:(NSArray *)array {
    challenges = array;
    
    // refresh only the view controllers which need it
    if(!self.leftViewController.challenge && challenges.count > 0)
        self.leftViewController.challenge = [challenges objectAtIndex:0];
    if(!self.middleViewController.challenge && challenges.count > 1)
        self.middleViewController.challenge = [challenges objectAtIndex:1];
    if(!self.rightViewController.challenge && challenges.count > 2)
        self.rightViewController.challenge = [challenges objectAtIndex:2];
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
    
    midPercent = fabsf(midPercent);

    float leftPercent = 1 - midPercent;
    float rightPercent = 1 - midPercent;

    self.leftViewController.view.layer.transform = [self transformForPercent:leftPercent];
    self.middleViewController.view.layer.transform = [self transformForPercent:midPercent];
    self.rightViewController.view.layer.transform = [self transformForPercent:rightPercent];

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    BOOL hasAnotherChallenge = [self.challenges indexOfObject:self.rightViewController.challenge] < [self.challenges count] - 1;
    BOOL hasPreviousChallenge = [self.challenges indexOfObject:self.leftViewController.challenge] > 0;

    // find which view controller is now the middle
    // we need to do this to prevent our view controllers from
    // being deallocd!
    
    BOOL didScrollToPrevious = self.scrollView.contentOffset.x < [self dayWidth];
    BOOL didScrollToNext = self.scrollView.contentOffset.x > [self dayWidth];
    
    RFDayViewController *mid = self.middleViewController;
    RFDayViewController *right = self.rightViewController;
    RFDayViewController *left = self.leftViewController;

    if (didScrollToNext && hasAnotherChallenge) {
        self.leftViewController = right;
        self.middleViewController = left;
        self.rightViewController = mid;
        
        self.rightViewController.challenge = [self.challenges objectAtIndex:[self.challenges indexOfObject:self.middleViewController.challenge] + 1];
        
        [self resetScrollViewController];
    }

    if (didScrollToPrevious && hasPreviousChallenge) {
        self.leftViewController = mid;
        self.middleViewController = right;
        self.rightViewController = left;
        
        self.rightViewController.challenge = [self.challenges objectAtIndex:[self.challenges indexOfObject:self.middleViewController.challenge] - 1];
        
        [self resetScrollViewController];
    }

    
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
