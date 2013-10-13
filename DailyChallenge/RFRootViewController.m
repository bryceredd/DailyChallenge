//
//  RFRootViewController.m
//  DailyChallenge
//
//  Created by Bryce Redd on 4/19/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "RFRootViewController.h"
#import "RFDayCell.h"
#import "RFChallengeService.h"
#import "RFMacros.h"

@interface RFRootViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) NSArray* challenges;
@end

@implementation RFRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[RFChallengeService new] fetchNewChallenges:^(NSArray* array) {
        self.challenges = array;
    }];
    
    UICollectionViewFlowLayout* layout = (id)[self.collectionView collectionViewLayout];
    layout.minimumInteritemSpacing = 0.f;
    layout.minimumLineSpacing = 0.f;
}

- (void) setChallenges:(NSArray *)array {
    _challenges = array;
    [self.collectionView reloadData];
}


#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.challenges.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RFDayCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"RFDayCell" forIndexPath:indexPath];
    cell.challenge = self.challenges[indexPath.row];
    return cell;
}


#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.bounds.size;
}

- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scroll {
    float pixelsToNudge = 100;
    
    for (RFDayCell* cell in [self.collectionView visibleCells]) {
        float distFromContentOffset = scroll.contentOffset.x - cell.frame.origin.x;
        float percentOnScreen = distFromContentOffset / self.collectionView.frame.size.width;
        [cell nudgeImage:percentOnScreen*pixelsToNudge];
    }
}

@end
