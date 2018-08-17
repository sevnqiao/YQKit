//
//  YQPhotoAlbumDetailViewController.m
//  YQKit
//
//  Created by world on 2018/8/14.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoAlbumDetailViewController.h"
#import "YQPhotoAlbumPreviewViewController.h"
#import "YQAlbumModel.h"
#import "YQAlbumManager.h"
#import "YQPhotoCollectionCell.h"
#import "YQPhotoAlbumDetailToolView.h"

#define KSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define KSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define KISIPHONEX (CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size))
#define KNAVBAR_HEIGHT (KISIPHONEX?96:64)

@interface YQPhotoAlbumDetailViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) YQPhotoAlbumDetailToolView *bottomView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@end

@implementation YQPhotoAlbumDetailViewController {
    CGRect previousPreheatRect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initNavBarView];
    [self initCollectionView];
    [self initBottomView];
    [self initData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.collectionView reloadData];
}

#pragma mark - init view
- (void)initNavBarView {
    self.navigationItem.title = self.albumModel.albumName;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finish)];
}
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)finish {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [[YQAlbumManager sharedManager].selectArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YQAssetModel *assetModel = obj;
        CGSize size = CGSizeMake(KSCREEN_WIDTH, KSCREEN_HEIGHT-KNAVBAR_HEIGHT);
        if ([YQAlbumManager sharedManager].isOriginal) {
            size = CGSizeZero;
        }
        [[YQAlbumManager sharedManager] getPhotoWithAsset:assetModel.asset photoSize:size isSynchronous:YES complete:^(UIImage *image) {
            if ([YQAlbumManager sharedManager].isOriginal) {
                assetModel.originalImage = image;
            } else {
                assetModel.highImage = image;
            }
        }];
    }];
}

- (void)initCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    layout.minimumLineSpacing = 2;
    layout.minimumInteritemSpacing = 2;
    CGFloat width = (self.view.bounds.size.width-8)/3;
    layout.itemSize = CGSizeMake(width, width);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGHT-KNAVBAR_HEIGHT-44) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    [collectionView registerNib:[UINib nibWithNibName:@"YQPhotoCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"YQPhotoCollectionCellIdentifier"];
}

- (void)initBottomView
{
    self.bottomView = [[YQPhotoAlbumDetailToolView alloc] initWithFrame:CGRectMake(0, KSCREEN_HEIGHT-KNAVBAR_HEIGHT-44, KSCREEN_WIDTH, 44)];
    [self.view addSubview:self.bottomView];
    
    __weak typeof(self) weakSelf = self;
    [self.bottomView handleWithPreviewHandle:^{
        if ([YQAlbumManager sharedManager].selectArray.count > 0) {
            [weakSelf jumpToPreviewControllerWithDataSource:[YQAlbumManager sharedManager].selectArray currentIndex:0 isPreview:YES];
        }
    } originalHandle:^(BOOL isOriginal) {
        [YQAlbumManager sharedManager].isOriginal = isOriginal;
    }];
}

#pragma mark - init data
- (void)initData
{
    self.dataSourceArray = [NSMutableArray array];
    [self.dataSourceArray addObjectsFromArray:[[YQAlbumManager sharedManager] getAssetWithFetchResult:self.albumModel.albumResult]];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YQPhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YQPhotoCollectionCellIdentifier" forIndexPath:indexPath];
    YQAssetModel *assetModel = self.dataSourceArray[indexPath.row];
    CGSize itemSize = ((UICollectionViewFlowLayout *)collectionView.collectionViewLayout).itemSize;
    [cell configCellWithAssetModel:assetModel targetSize:itemSize localIdentifier:assetModel.asset.localIdentifier];
    cell.selectHandle = ^{
        [self selectWithIndexPath:indexPath];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self jumpToPreviewControllerWithDataSource:self.dataSourceArray currentIndex:indexPath.row isPreview:NO];
}

- (void)selectWithIndexPath:(NSIndexPath *)indexPath
{
    YQAssetModel *model = self.dataSourceArray[indexPath.row];
    if (model.isSelected) {
        model.selected = NO;
        [[YQAlbumManager sharedManager] deleteObject:model];
    } else {
        model.selected = YES;
        [[YQAlbumManager sharedManager] addObject:model];
    }
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    CGSize size = CGSizeMake(KSCREEN_WIDTH, KSCREEN_HEIGHT-KNAVBAR_HEIGHT);
    if ([YQAlbumManager sharedManager].isOriginal) {
        size = CGSizeZero;
    }
    [[YQAlbumManager sharedManager] getPhotoWithAsset:model.asset photoSize:size isSynchronous:YES complete:^(UIImage *image) {
        if ([YQAlbumManager sharedManager].isOriginal) {
            model.originalImage = image;
        } else {
            model.highImage = image;
        }
        model.dataLength = [self calulateImageFileSize:image];
        
        [self caculateTotalSize];
    }];
}

- (void)jumpToPreviewControllerWithDataSource:(NSArray *)dataSource currentIndex:(NSInteger)currentIndex isPreview:(BOOL)isPreview
{
    YQPhotoAlbumPreviewViewController *previewController = [[YQPhotoAlbumPreviewViewController alloc]init];
    previewController.isPreview = isPreview;
    previewController.defautIndex = currentIndex;
    previewController.dataSourceArray = dataSource;
    [self.navigationController pushViewController:previewController animated:YES];
}

- (void)caculateTotalSize
{
    if ([YQAlbumManager sharedManager].isOriginal) {
        CGFloat totalSize = [[YQAlbumManager sharedManager] caculateTotalSize];
        NSArray *typeArray = @[@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB",@"ZB",@"YB"];
        NSInteger index = 0;
        while (totalSize > 1024) {
            totalSize /= 1024.0;
            index ++;
        }
        [self.bottomView configSizeTitle:[NSString stringWithFormat:@"%.1f %@", totalSize, typeArray[index]]];
    }
}

#pragma mark - updateCachedAssets

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCachedAssets];
}

- (void)updateCachedAssets {
    CGRect visibleRect = CGRectMake(0, self.collectionView.contentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    CGRect preheatRect = CGRectMake(0, visibleRect.origin.y - visibleRect.size.height *0.3, visibleRect.size.width, visibleRect.size.height * 0.3);

    [self computeDifferenceBetweenRect:previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
        NSMutableArray *removeAssetArray = [self getAssetArrayWithTargetRect:removedRect];
        [[YQAlbumManager sharedManager]stopCaching:removeAssetArray targetSize:((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize options:nil];
    } addedHandler:^(CGRect addedRect) {
        NSMutableArray *addAssetArray = [self getAssetArrayWithTargetRect:addedRect];
        [[YQAlbumManager sharedManager]startCaching:addAssetArray targetSize:((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize options:nil];
    }];
    
    previousPreheatRect = preheatRect;
}

- (NSMutableArray *)getAssetArrayWithTargetRect:(CGRect)targetRect
{
    NSMutableArray *assetArray = [NSMutableArray array];
    NSArray *layoutArray = [self.collectionView.collectionViewLayout layoutAttributesForElementsInRect:targetRect];
    [layoutArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UICollectionViewLayoutAttributes *attributes = obj;
        NSIndexPath *indexPath = attributes.indexPath;
        YQAssetModel *assetModel = self.dataSourceArray[indexPath.row];
        [assetArray addObject:assetModel.asset];
    }];
    return assetArray;
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}



#pragma mark - Description
- (void)dealloc {
    [[YQAlbumManager sharedManager] stopCachingImagesForAllAssets];
}

- (long)calulateImageFileSize:(UIImage *)image {
    NSData *data = UIImagePNGRepresentation(image);
    if (!data) {
        data = UIImageJPEGRepresentation(image, 0.5);
    }
    double dataLength = [data length];
    return dataLength;
}
@end
