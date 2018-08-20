//
//  YQPhotoAlbumDetailBottomView.m
//  YQKit
//
//  Created by world on 2018/8/17.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoAlbumDetailBottomView.h"
#import "YQAlbumModel.h"
#import "YQAlbumManager.h"

@interface YQPhotoAlbumDetailBottomView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataSourceArray;
@property (nonatomic, copy) NSString *localIdentifier;
@end

@implementation YQPhotoAlbumDetailBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0];
        
        [self initEffectView];
        [self initCollectionView];
    }
    return self;
}

- (void)initEffectView
{
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithFrame:self.bounds];
    effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    [self addSubview:effectView];
    
    if (@available(iOS 10.0, *)) {
        UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.1 curve:UIViewAnimationCurveLinear animations:^{
            effectView.effect = nil;
        }];
        animator.fractionComplete = 0.3;
    }
}

- (void)initCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.itemSize = CGSizeMake(100, 100);
    layout.minimumLineSpacing = 10;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
    [collectionView registerClass:[YQPhotoAlbumDetailBottomItemView class] forCellWithReuseIdentifier:@"YQPhotoAlbumDetailBottomItemViewIdentifier"];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YQPhotoAlbumDetailBottomItemView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YQPhotoAlbumDetailBottomItemViewIdentifier" forIndexPath:indexPath];
    YQAssetModel *assetModel = self.dataSourceArray[indexPath.row];
    [cell configCellWithAssetModel:assetModel localIdentifier:assetModel.asset.localIdentifier select:[assetModel.asset.localIdentifier isEqualToString:self.localIdentifier]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YQAssetModel *assetModel = self.dataSourceArray[indexPath.row];
    if (self.selectHandle) {
        self.selectHandle(assetModel.asset.localIdentifier);
        [self selctItemWithLocalIdentifier:assetModel.asset.localIdentifier];
    }
}

#pragma mark - config
- (void)configBottomViewWithAssetArray:(NSArray *)assetArray
{
    self.alpha = (assetArray.count == 0) ? 0 : 1;
    self.dataSourceArray = assetArray;
    [self.collectionView reloadData];
}

- (void)selctItemWithLocalIdentifier:(NSString *)localIdentifier
{
    self.localIdentifier = localIdentifier;
    [self.collectionView scrollToItemAtIndexPath:[self indexOfLocalIdentifier:localIdentifier] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self.collectionView reloadData];
}

- (NSIndexPath *)indexOfLocalIdentifier:(NSString *)localIdentifier
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

@end

@implementation YQPhotoAlbumDetailBottomItemView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.imageView = ({
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.contentView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled = YES;
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        imageView;
    });
}

- (void)configCellWithAssetModel:(YQAssetModel *)assetModel localIdentifier:(NSString *)localIdentifier select:(BOOL)select
{
    self.localIdentifier = localIdentifier;
    if (assetModel.thumbImage) {
        self.imageView.image = assetModel.thumbImage;
    } else {
        [[YQAlbumManager sharedManager] getPhotoWithAsset:assetModel.asset photoSize:self.bounds.size isSynchronous:NO complete:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.localIdentifier isEqualToString:assetModel.asset.localIdentifier]) {
                    self.imageView.image = image;
                    assetModel.thumbImage = image;
                }
            });
        }];
    }
    
    self.imageView.layer.borderWidth = 2;
    if (select) {
        self.imageView.layer.borderColor = [UIColor colorWithRed:18/255.0 green:139/255.0 blue:214/255.0 alpha:1].CGColor;
    } else  {
        self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
