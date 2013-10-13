//
//  RFDayViewController.m
//  DailyChallenge
//
//  Created by Bryce Redd on 4/22/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "RFDayCell.h"
#import "RFMacros.h"
#import "RFChallengeService.h"
#import "UIImageView+AFNetworking.h"

#import "RFQuoteCell.h"
#import "RFChallengeCell.h"
#import "RFChallengeItemCell.h"

@interface RFDayCell()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* imageLeadingContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* imageWidthContraint;
@end

@implementation RFDayCell

/*- (void) awakeFromNib {
    for (UIView* view in @[self.quote, self.quoteCredit, self.challengeLabel]) {
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowRadius = 3.f;
        view.layer.shadowOffset = CGSizeZero;
        view.layer.shadowOpacity = 1.f;
        view.layer.rasterizationScale = [UIScreen mainScreen].scale;
        view.layer.shouldRasterize = YES;
    }
}*/

- (void) setChallenge:(Challenge *)data {
    _challenge = data;
    
    [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:self.challenge.imageUrl] placeholderImage:nil success:^(NSURLRequest* request, NSHTTPURLResponse* response, UIImage* image) {
        
        if (!image.size.width || !image.size.height)
            return;
        
        float ratio = image.size.width / image.size.height;
        float width = self.frame.size.height * ratio;
        float x = (self.frame.size.width - width) / 2.f;
        
        self.imageWidthContraint.constant = width;
        self.imageLeadingContraint.constant = x;
        
        [self updateConstraintsIfNeeded];
        
    } failure:nil];
    
    [self.tableView reloadData];
}

- (void) nudgeImage:(float)pixels {
    if(!self.imageView.image.size.width || !self.imageView.image.size.height)
        return;
    
    float ratio = self.imageView.image.size.width / self.imageView.image.size.height;
    float width = self.frame.size.height * ratio;
    float x = (self.frame.size.width - width) / 2.f;
    
    setFrameX(self.imageView, x + pixels);
}


#pragma table

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    //UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[self identifierForIndexPath:indexPath]];
    
    
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    return [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(!self.challenge) return 0;
    
    return 2 + self.challenge.tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if(indexPath.row == 0) {
        RFQuoteCell* cell = [tableView dequeueReusableCellWithIdentifier:@"RFQuoteCell"];
        cell.challenge = self.challenge;
        return cell;
    }
    
    if(indexPath.row == 1) {
        RFChallengeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"RFChallengeCell"];
        cell.challenge = self.challenge;
        return cell;
    }
    
    RFChallengeItemCell* cell = [tableView dequeueReusableCellWithIdentifier:@"RFChallengeItemCell"];
    cell.task = self.challenge.tasks[indexPath.row - 2];
    return cell;
}

- (NSString*) identifierForIndexPath:(NSIndexPath*)indexPath {
    if(indexPath.row == 0) {
        return @"RFQuoteCell";
    }
    
    if(indexPath.row == 1) {
        return @"RFChallengeCell";
    }
    
    return @"RFChallengeItemCell";
}


@end
