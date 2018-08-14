//
//  YQPhotoBrowseViewController.m
//  YQKit
//
//  Created by world on 2018/8/13.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoBrowseViewController.h"
#import "YQPhotoNavBarView.h"
#import "YQPhotoItemCell.h"

#define KMARGIN 20
#define KISIphoneX (CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size))

@interface YQPhotoBrowseViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) YQPhotoNavBarView *navBarView;
@end

@implementation YQPhotoBrowseViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initCollectionView];
    [self initNavView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
    [self.navBarView configTitleLabelWithTitle:[NSString stringWithFormat:@"%@ / %@", @(self.currentIndex + 1), @(self.dataSourceArray.count)]];
}

- (void)initNavView
{
    self.navBarView = [[YQPhotoNavBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, KISIphoneX?96:64)];
    [self.view addSubview:self.navBarView];
    
    __weak typeof(self) weakSelf = self;
    self.navBarView.handleBack = ^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
}

- (void)initCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, KMARGIN/2, 0, KMARGIN/2);
    layout.itemSize = self.view.bounds.size;
    layout.minimumLineSpacing = KMARGIN;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-KMARGIN/2, 0, self.view.frame.size.width + KMARGIN, self.view.frame.size.height) collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.pagingEnabled = YES;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [collectionView registerClass:[YQPhotoItemCell class] forCellWithReuseIdentifier:@"YQPhotoItemCellIdentifier"];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YQPhotoItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YQPhotoItemCellIdentifier" forIndexPath:indexPath];
    [cell configImageViewWith:self.dataSourceArray[indexPath.row] tapHandle:^{
        [self showHideNavBarView];
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    YQPhotoItemCell *itemCell = (YQPhotoItemCell *)cell;
    [itemCell resetToDefault];
}

- (void)showHideNavBarView
{
    BOOL isShow = self.navBarView.frame.origin.y < 0;
    [[UIApplication sharedApplication] setStatusBarHidden:!isShow];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = self.navBarView.frame;
        rect.origin.y = isShow ? 0 :(-rect.size.height);
        self.navBarView.frame = rect;
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x + scrollView.bounds.size.width/2;
    NSInteger index = offsetX / scrollView.bounds.size.width;
    self.currentIndex = index;
    [self.navBarView configTitleLabelWithTitle:[NSString stringWithFormat:@"%@ / %@", @(index + 1), @(self.dataSourceArray.count)]];

}

@end
