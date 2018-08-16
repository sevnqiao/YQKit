//
//  YQAlbumManager.m
//  YQKit
//
//  Created by world on 2018/8/14.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQAlbumManager.h"
#import "YQAlbumModel.h"


static YQAlbumManager *myManager = nil;

@interface YQAlbumManager ()
@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;
@end

@implementation YQAlbumManager

+ (YQAlbumManager *)sharedManager
{
    @synchronized (self)
    {
        static dispatch_once_t pred;
        dispatch_once (&pred, ^{
            myManager = [[self alloc] init];
        });
    }
    return myManager;
}

- (PHCachingImageManager *)cachingImageManager
{
    if (!_cachingImageManager) {
        _cachingImageManager = [[PHCachingImageManager alloc]init];
        _cachingImageManager.allowsCachingHighQualityImages = YES;
    }
    return _cachingImageManager;
}

- (NSMutableArray *)selectArray
{
    if (!_selectArray) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}

+ (void)requestAuthorization:(void(^)(PHAuthorizationStatus status))handler
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        handler(status);
    }];
}

#pragma mark - requesr album
- (void)getCamerRollAlbumWithComplete:(void(^)(YQAlbumModel *model))complete
{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    option.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES] ];
    
    PHFetchResult *smartAlbumsFetchResult = [PHAssetCollection
                                             fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                             subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                             options:nil];
    
    [smartAlbumsFetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAssetCollection *assetCollection = (PHAssetCollection *)obj;
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
        YQAlbumModel *model = [YQAlbumModel modelWithResult:fetchResult name:assetCollection.localizedTitle];
        complete(model);
        *stop = YES;
    }];
}

- (void)getAllAlbumsWithCompletion:(void (^) (NSArray *allAlbumsArray))completion
{
    NSMutableArray *albumArr = [NSMutableArray array];
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    
    /**
     *  PHAssetMediaType 多媒体类型
     */
    option.predicate =
    [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    option.sortDescriptors =
    @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES] ];
    
    /**
     *  显示的相册类型
     */
    PHAssetCollectionSubtype smartAlbumSubtype =
    PHAssetCollectionSubtypeSmartAlbumUserLibrary |
    PHAssetCollectionSubtypeSmartAlbumRecentlyAdded |
    PHAssetCollectionSubtypeSmartAlbumVideos;
    

        /**
         *  ios9后新增屏幕截图,自定义相册类型
         */
        smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary |
        PHAssetCollectionSubtypeSmartAlbumRecentlyAdded |
        PHAssetCollectionSubtypeSmartAlbumScreenshots |
        PHAssetCollectionSubtypeSmartAlbumSelfPortraits |
        PHAssetCollectionSubtypeSmartAlbumVideos;
    
    
    /**
     *  相机胶卷,屏幕快照,最近添加,个人收藏
     */
    PHFetchResult *smartAlbumsFetchResult =
    [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                             subtype:smartAlbumSubtype
                                             options:nil];
    for (PHAssetCollection *collection in smartAlbumsFetchResult)
    {
        PHFetchResult *fetchResult =
        [PHAsset fetchAssetsInAssetCollection:collection options:option];
        
        /**
         *  图片数为0的相册不显示
         */
        if (fetchResult.count < 1)
            continue;
        
        /**
         *  最近删除的相册不显示
         */
        if ([collection.localizedTitle containsString:@"Deleted"] ||
            [collection.localizedTitle isEqualToString:@"最近删除"])
            continue;
        
        /**
         *  相机胶卷的相册放在第一个显示
         */
        if ([collection.localizedTitle isEqualToString:@"Camera Roll"] ||
            [collection.localizedTitle isEqualToString:@"相机胶卷"] ||
            [collection.localizedTitle isEqualToString:@"All Photos"] ||
            [collection.localizedTitle isEqualToString:@"所有照片"] )
        {
            [albumArr
             insertObject:[YQAlbumModel modelWithResult:fetchResult name:collection.localizedTitle]
             atIndex:0];
        }
        else
        {
            [albumArr
             addObject:[YQAlbumModel modelWithResult:fetchResult name:collection.localizedTitle]];
        }
    }
    
    /**
     *  其它一些应用创建的相册
     */
    PHFetchResult *albumsFetchResult = [PHAssetCollection
                                        fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                        subtype:PHAssetCollectionSubtypeAlbumRegular |
                                        PHAssetCollectionSubtypeAlbumSyncedAlbum
                                        options:nil];
    for (PHAssetCollection *collection in albumsFetchResult)
    {
        PHFetchResult *fetchResult =
        [PHAsset fetchAssetsInAssetCollection:collection options:option];
        if (fetchResult.count < 1)
            continue;
        if ([collection.localizedTitle isEqualToString:@"My Photo Stream"] ||
            [collection.localizedTitle isEqualToString:@"我的照片流"])
        {
            [albumArr
             insertObject:[YQAlbumModel modelWithResult:fetchResult name:collection.localizedTitle]
             atIndex:1];
        }
        else
        {
            [albumArr
             addObject:[YQAlbumModel modelWithResult:fetchResult name:collection.localizedTitle]];
        }
    }
    if (completion && albumArr.count > 0)
    {
        completion (albumArr);
    }
    
}


- (NSArray *)getAssetWithFetchResult:(PHFetchResult *)fetchResult
{
    NSMutableArray *assetArray = [NSMutableArray array];
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = obj;
        YQAssetModel *model = [YQAssetModel modelWithAsset:asset];
        [assetArray addObject:model];
    }];
    return assetArray;
}

#pragma mark - cachingImageManager
- (void)startCaching:(NSArray *)assetArray targetSize:(CGSize)targetSize options:(nullable PHImageRequestOptions *)options
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize photoSize = CGSizeMake(targetSize.width * scale, targetSize.height * scale);
    if (CGSizeEqualToSize(photoSize, CGSizeZero)) {
        photoSize = PHImageManagerMaximumSize;
    }
    [self.cachingImageManager startCachingImagesForAssets:assetArray targetSize:photoSize contentMode:PHImageContentModeAspectFit options:options];
}

- (void)stopCaching:(NSArray *)assetArray targetSize:(CGSize)targetSize options:(nullable PHImageRequestOptions *)options
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize photoSize = CGSizeMake(targetSize.width * scale, targetSize.height * scale);
    if (CGSizeEqualToSize(photoSize, CGSizeZero)) {
        photoSize = PHImageManagerMaximumSize;
    }
    [self.cachingImageManager stopCachingImagesForAssets:assetArray targetSize:photoSize contentMode:PHImageContentModeAspectFit options:options];
}

- (void)stopCachingImagesForAllAssets
{
    [self.cachingImageManager stopCachingImagesForAllAssets];
}

#pragma mark - requestImage
- (void)getPhotoWithAsset:(PHAsset *)asset photoSize:(CGSize)photoSize complete:(void(^)(UIImage *image))complete
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(photoSize.width * scale, photoSize.height * scale);
    if (CGSizeEqualToSize(targetSize, CGSizeZero)) {
        targetSize = PHImageManagerMaximumSize;
    }
    [self.cachingImageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
         BOOL downloadFinined =
         ![[info objectForKey:PHImageCancelledKey] boolValue] &&
         ![info objectForKey:PHImageErrorKey];
         if (downloadFinined && result && complete)
         {
             complete(result);
         }
     }];
}

#pragma mark - select array operation
- (void)addObject:(YQAssetModel *)assetModel
{
    assetModel.selected = YES;
    [self.selectArray addObject:assetModel];
    [self startCaching:@[assetModel.asset] targetSize:CGSizeZero options:nil];
}

- (void)deleteObject:(YQAssetModel *)assetModel
{
    assetModel.selected = NO;
    [self.selectArray removeObject:assetModel];
    [self stopCaching:@[assetModel.asset] targetSize:CGSizeZero options:nil];
}

@end
