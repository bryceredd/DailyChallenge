//
//  RFDayViewController.m
//  DailyChallenge
//
//  Created by Bryce Redd on 4/22/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "RFDayViewController.h"
#import "RFChallengeService.h"

@interface RFDayViewController ()

@end

@implementation RFDayViewController

@synthesize table, challenge;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [self setTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITableView Datasource
 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}
 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* identifier = @"";
    switch (indexPath.row) {
      case 0:
        identifier = @"quoteCell";
        break;
      case 1:
        identifier = @"creditCell";
        break;
      case 2: 
        identifier = @"spaceCell";
        break;
      case 3:
        identifier = @"goalCell";
        break;
      default:
        break;
    } 
 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if([cell respondsToSelector:@selector(setChallenge:)]) 
        [(id)cell setChallenge:(id)self.challenge];
    
 
    return cell;
}
 
#pragma mark - UITableView Delegate methods
 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
