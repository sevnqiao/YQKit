//
//  YQPhotoAlbumDetailViewController.m
//  YQKit
//
//  Created by world on 2018/8/14.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoAlbumDetailViewController.h"
#import "YQAlbumModel.h"
#import "YQAlbumManager.h"
#import "YQPhotoCollectionCell.h"

@interface YQPhotoAlbumDetailViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@end

@implementation YQPhotoAlbumDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initNavBarView];
    [self initCollectionView];
    [self initData];
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
        [[YQAlbumManager sharedManager] getPhotoWithAsset:assetModel.asset photoSize:CGSizeZero complete:^(UIImage *image) {
            assetModel.highImage = image;
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
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.view addSubview:collectionView];
    [collectionView registerNib:[UINib nibWithNibName:@"YQPhotoCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"YQPhotoCollectionCellIdentifier"];
}

#pragma mark - init data
- (void)initData
{
    NSMutableArray *assetArray = [NSMutableArray array];
    [self.dataSourceArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [assetArray addObject:((YQAssetModel *)obj).asset];
    }];
    CGFloat width = (self.view.bounds.size.width-8)/3;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    [[YQAlbumManager sharedManager]startCaching:assetArray targetSize:CGSizeMake(width, width) options:nil];
    
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
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YQAssetModel *model = self.dataSourceArray[indexPath.row];
    if (model.isSelected) {
        [[YQAlbumManager sharedManager] deleteObject:model];
    } else {
        [[YQAlbumManager sharedManager] addObject:model];
    }
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - Description
- (void)dealloc {
    [[YQAlbumManager sharedManager] stopCachingImagesForAllAssets];
}
@end
