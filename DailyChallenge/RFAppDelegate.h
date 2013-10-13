//
//  RFAppDelegate.h
//  DummyProj
//
//  Created by Bryce Redd on 4/25/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class RFRootViewController;

@interface RFAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) IBOutlet RFRootViewController* controller;
@end
