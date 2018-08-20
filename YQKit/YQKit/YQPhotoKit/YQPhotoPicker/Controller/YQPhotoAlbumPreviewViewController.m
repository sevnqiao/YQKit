//
//  YQPhotoAlbumPreviewViewController.m
//  YQKit
//
//  Created by world on 2018/8/13.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoAlbumPreviewViewController.h"
#import "YQPhotoPreviewNavBar.h"
#import "YQPhotoPreviewItemCell.h"
#import "YQAlbumModel.h"
#import "YQAlbumManager.h"
#import "YQPhotoAlbumDetailBottomView.h"

#define KMARGIN 20
#define KSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define KSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define KISIPHONEX (CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size))
#define KNAVBAR_HEIGHT (KISIPHONEX?96:64)

@interface YQPhotoAlbumPreviewViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) YQPhotoPreviewNavBar *navBarView;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) YQPhotoAlbumDetailBottomView *bottomView ;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation YQPhotoAlbumPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    [self initCollectionView];
    [self initNavView];
    [self initBottomPreview];
    [self.view addSubview:self.selectButton];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.defautIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
    NSString *title = nil;
    if (self.isPreview) {
        title = [NSString stringWithFormat:@"%@ / %@", @(self.defautIndex + 1), @(self.dataSourceArray.count)];
    }
    [self.navBarView configTitleLabelWithTitle:title selectCount:[YQAlbumManager sharedManager].selectArray.count];
    
    YQAssetModel *assetModel = self.dataSourceArray[self.defautIndex];
    self.selectButton.selected = [[YQAlbumManager sharedManager] isContainObject:assetModel.asset.localIdentifier];
}

- (void)initNavView
{
    self.navBarView = [[YQPhotoPreviewNavBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, KISIPHONEX?96:64)];
    [self.view addSubview:self.navBarView];
    
    __weak typeof(self) weakSelf = self;
    [self.navBarView handleWithBackHandle:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } nextHandle:^{
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)initCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, KMARGIN/2, 0, KMARGIN/2);
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    layout.minimumLineSpacing = KMARGIN;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-KMARGIN/2, 0, self.view.frame.size.width + KMARGIN, self.view.frame.size.height) collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.pagingEnabled = YES;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [collectionView registerClass:[YQPhotoPreviewItemCell class] forCellWithReuseIdentifier:@"YQPhotoPreviewItemCellIdentifier"];
    
    if (@available(iOS 11.0, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)initBottomPreview
{
    YQPhotoAlbumDetailBottomView *bottomView = [[YQPhotoAlbumDetailBottomView alloc]initWithFrame:CGRectMake(0, KSCREEN_HEIGHT-120, KSCREEN_WIDTH, 120)];
    [bottomView configBottomViewWithAssetArray:[YQAlbumManager sharedManager].selectArray];
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
    
    __weak typeof(self) weakSelf = self;
    bottomView.selectHandle = ^(NSString *localIdentifier) {
        NSIndexPath *indexPath = [weakSelf indexPathOfLocalIdentifier:localIdentifier];
        [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    };
}

- (NSIndexPath *)indexPathOfLocalIdentifier:(NSString *)localIdentifier
{
    __block NSIndexPath *indexPath = nil;
    [self.dataSourceArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YQAssetModel *assetModel = obj;
        if ([assetModel.asset.localIdentifier isEqualToString:localIdentifier]) {
            indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            *stop = YES;
        }
    }];
    return indexPath;
}

#pragma mark - getter / setter
- (UIButton *)selectButton
{
    if (!_selectButton) {
        _selectButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-40, 70, 40, 40)];
        [_selectButton setImage:[UIImage imageNamed:@"photo_select"] forState:UIControlStateSelected];
        [_selectButton setImage:[UIImage imageNamed:@"photo_unselect"] forState:UIControlStateNormal];
        [_selectButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (void)select:(UIButton *)sender
{
    YQAssetModel *assetModel = self.dataSourceArray[self.currentIndex];
    if (sender.isSelected) {
        [[YQAlbumManager sharedManager] deleteObject:assetModel];
    } else {
        [[YQAlbumManager sharedManager] addObject:assetModel];
    }
    sender.selected = !sender.isSelected;
    NSString *title = nil;
    if (self.isPreview) {
        title = [NSString stringWithFormat:@"%@ / %@", @(self.currentIndex + 1), @(self.dataSourceArray.count)];
    }
    [self.navBarView configTitleLabelWithTitle:title selectCount:[YQAlbumManager sharedManager].selectArray.count];
    [self.bottomView configBottomViewWithAssetArray:[YQAlbumManager sharedManager].selectArray];
    [self.bottomView selctItemWithLocalIdentifier:assetModel.asset.localIdentifier];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YQPhotoPreviewItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YQPhotoPreviewItemCellIdentifier" forIndexPath:indexPath];
    YQAssetModel *assetModel = self.dataSourceArray[indexPath.row];
    [cell configImageViewWith:assetModel localIdentifier:assetModel.asset.localIdentifier  tapHandle:^{
        [self showHideNavBarView];
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    YQPhotoPreviewItemCell *itemCell = (YQPhotoPreviewItemCell *)cell;
    [itemCell resetToDefault];
}

- (void)showHideNavBarView
{
    BOOL isShow = (self.navBarView.alpha == 0);
    [UIView animateWithDuration:0.25 animations:^{
        self.navBarView.alpha = isShow?1:0;
        self.selectButton.alpha = isShow?1:0;
        self.bottomView.alpha = isShow?([YQAlbumManager sharedManager].selectArray.count > 0 ? 1 : 0):0;
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x + scrollView.bounds.size.width/2;
    NSInteger index = offsetX / scrollView.bounds.size.width;
    [self updateCachedAssetsWithIndex:index];
    self.currentIndex = index;
    NSString *title = nil;
    if (self.isPreview) {
        title = [NSString stringWithFormat:@"%@ / %@", @(index + 1), @(self.dataSourceArray.count)];
    }
    [self.navBarView configTitleLabelWithTitle:title selectCount:[YQAlbumManager sharedManager].selectArray.count];
    
    YQAssetModel *assetModel = self.dataSourceArray[index];
    self.selectButton.selected = [[YQAlbumManager sharedManager] isContainObject:assetModel.asset.localIdentifier];
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat offsetX = (*targetContentOffset).x + scrollView.bounds.size.width/2;
    NSInteger index = offsetX / scrollView.bounds.size.width;
    YQAssetModel *assetModel = self.dataSourceArray[index];
    [self.bottomView selctItemWithLocalIdentifier:assetModel.asset.localIdentifier];
}

- (void)updateCachedAssetsWithIndex:(NSInteger)index
{
    if (index < self.dataSourceArray.count - 1) {
        YQAssetModel *preAssetModel = self.dataSourceArray[index + 1];
        [[YQAlbumManager sharedManager]startCaching:@[preAssetModel.asset] targetSize:CGSizeMake(KSCREEN_WIDTH, KSCREEN_HEIGHT-KNAVBAR_HEIGHT) options:nil];
    }
    if (index > 0) {
        YQAssetModel *preAssetModel = self.dataSourceArray[index - 1];
        [[YQAlbumManager sharedManager]startCaching:@[preAssetModel.asset] targetSize:CGSizeMake(KSCREEN_WIDTH, KSCREEN_HEIGHT-KNAVBAR_HEIGHT) options:nil];
    }
}


@end
