//
//  RFRootViewController.h
//  DailyChallenge
//
//  Created by Bryce Redd on 4/19/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

@interface RFRootViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@end
