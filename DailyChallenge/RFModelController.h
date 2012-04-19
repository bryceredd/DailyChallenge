//
//  RFModelController.h
//  DailyChallenge
//
//  Created by Bryce Redd on 4/19/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RFDataViewController;

@interface RFModelController : NSObject <UIPageViewControllerDataSource>

- (RFDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(RFDataViewController *)viewController;

@end
