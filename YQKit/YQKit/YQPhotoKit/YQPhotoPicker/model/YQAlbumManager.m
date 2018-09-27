//
//  YQAlbumManager.m
//  YQKit
//
//  Created by world on 2018/8/14.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQAlbumManager.h"
#import "YQAlbumModel.h"

#define KSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define KSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define KISIPHONEX (CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size))
#define KNAVBAR_HEIGHT (KISIPHONEX?96:64)

static YQAlbumManager *myManager = nil;

@interface YQAlbumManager ()
@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;
@property (nonatomic, strong) NSMutableDictionary *selectDictionary;
@property (nonatomic, strong) NSMutableArray *selectArray;
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

- (NSMutableDictionary *)selectDictionary
{
    if (!_selectDictionary) {
        _selectDictionary = [NSMutableDictionary dictionary];
    }
    return _selectDictionary;
}

+ (void)requestAuthorization:(void(^)(PHAuthorizationStatus status))handler
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        handler(status);
    }];
}

#pragma mark - 相册查询

/**
 * 查询相机胶卷
 *
 * @param complete 返回相机胶卷的相册model
 */
- (void)getCamerRollAlbumWithComplete:(void(^)(YQAlbumModel *model))complete
{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *smartAlbumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    [smartAlbumsFetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAssetCollection *assetCollection = (PHAssetCollection *)obj;
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
        YQAlbumModel *model = [YQAlbumModel modelWithResult:fetchResult name:assetCollection.localizedTitle];
        complete(model);
        *stop = YES;
    }];
}

/**
 * 查询所有的相册
 *
 * @param completion 返回相机胶卷的相册model数组
 */
- (void)getAllAlbumsWithCompletion:(void (^) (NSArray *allAlbumsArray))completion
{
    NSMutableArray *albumArr = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
//    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    option.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO] ];

    PHAssetCollectionSubtype subtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded | PHAssetCollectionSubtypeSmartAlbumVideos;
    if (@available(iOS 9.0, *)) {
        subtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded | PHAssetCollectionSubtypeSmartAlbumScreenshots | PHAssetCollectionSubtypeSmartAlbumSelfPortraits | PHAssetCollectionSubtypeSmartAlbumVideos;
    }
 
    PHFetchResult *smartAlbumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:subtype options:nil];
    for (PHAssetCollection *collection in smartAlbumsFetchResult)
    {
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        if (fetchResult.count < 1) {
            continue;
        }
        [albumArr addObject:[YQAlbumModel modelWithResult:fetchResult name:collection.localizedTitle]];
    }

    // 其它一些应用创建的相册
    PHFetchResult *albumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular | PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    for (PHAssetCollection *collection in albumsFetchResult)
    {
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        if (fetchResult.count < 1) {
            continue;
        }
        [albumArr addObject:[YQAlbumModel modelWithResult:fetchResult name:collection.localizedTitle]];
    }
    if (completion && albumArr.count > 0)
    {
        completion (albumArr);
    }
}


/**
 * 获取相册里的所有相片的model
 *
 * @param fetchResult 相册的 fetchResult
 * @return 相片数组
 */
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

#pragma mark - 缓存manager
/**
 * 开始缓存指定区域内的图片资源
 *
 * @param assetArray 需要缓存的相片资源
 * @param targetSize 缓存的相片的size
 * @param options setting
 */
- (void)startCaching:(NSArray *)assetArray targetSize:(CGSize)targetSize options:(nullable PHImageRequestOptions *)options
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize photoSize = CGSizeMake(targetSize.width * scale, targetSize.height * scale);
    if (CGSizeEqualToSize(photoSize, CGSizeZero)) {
        photoSize = PHImageManagerMaximumSize;
    }
    [self.cachingImageManager startCachingImagesForAssets:assetArray targetSize:photoSize contentMode:PHImageContentModeAspectFit options:options];
}

/**
 * 停止缓存指定区域内的图片资源
 *
 * @param assetArray 需要停止缓存的相片资源
 * @param targetSize 缓存的相片的size
 * @param options setting
 */
- (void)stopCaching:(NSArray *)assetArray targetSize:(CGSize)targetSize options:(nullable PHImageRequestOptions *)options
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize photoSize = CGSizeMake(targetSize.width * scale, targetSize.height * scale);
    if (CGSizeEqualToSize(photoSize, CGSizeZero)) {
        photoSize = PHImageManagerMaximumSize;
    }
    [self.cachingImageManager stopCachingImagesForAssets:assetArray targetSize:photoSize contentMode:PHImageContentModeAspectFit options:options];
}

/**
 * 停止缓存所有的图片资源
 */
- (void)stopCachingImagesForAllAssets
{
    [self.cachingImageManager stopCachingImagesForAllAssets];
}

#pragma mark - 请求加载图片
/**
 * 获取一张LivePhoto
 *
 * @param asset 相片资源
 * @param photoSize 获取的大小
 * @param complete 回调
 */
- (void)getLivePhotoWithAsset:(PHAsset *)asset photoSize:(CGSize)photoSize complete:(void(^)(PHLivePhoto *livePhoto))complete API_AVAILABLE(ios(9.1))
{
    CGSize targetSize = [self getTargetSizeWith:photoSize];
    [self.cachingImageManager requestLivePhotoForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        if (downloadFinined && livePhoto && complete)
        {
            complete(livePhoto);
        }
    }];
}

/**
 * 获取一段视频资源
 *
 * @param asset 相片资源
 * @param complete 回调
 */
- (void)getVideoWithAsset:(PHAsset *)asset complete:(void(^)(AVPlayerItem *playerItem))complete
{
    [self.cachingImageManager requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        complete(playerItem);
    }];
}

/**
 * 获取一张图片
 *
 * @param asset 相片资源
 * @param photoSize 图片大小
 * @param isSynchronous 是否同步获取
 * @param complete 回调
 */
- (void)getPhotoWithAsset:(PHAsset *)asset photoSize:(CGSize)photoSize isSynchronous:(BOOL)isSynchronous complete:(void(^)(UIImage *image))complete
{
    CGSize targetSize = [self getTargetSizeWith:photoSize];
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = isSynchronous;
    
    [self.cachingImageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
         BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
         if (downloadFinined && result && complete)
         {
             complete(result);
         }
     }];
}

- (CGSize)getTargetSizeWith:(CGSize)photoSize
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(photoSize.width * scale, photoSize.height * scale);
    if (CGSizeEqualToSize(targetSize, CGSizeZero)) {
        targetSize = PHImageManagerMaximumSize;
    }
    return targetSize;
}

#pragma mark - select array operation
- (void)removeAllObjects
{
    [self.selectDictionary removeAllObjects];
    [self.selectArray removeAllObjects];
}

- (void)addObject:(YQAssetModel *)assetModel
{    
    if (![self isContainObject:assetModel.asset.localIdentifier]) {
        [self.selectArray addObject:assetModel];
    }
    [self.selectDictionary setValue:assetModel forKey:assetModel.asset.localIdentifier];
    
    CGSize size = CGSizeMake(KSCREEN_WIDTH, KSCREEN_HEIGHT-KNAVBAR_HEIGHT);
    if (self.isOriginal) {
        size = CGSizeZero;
    }
    [self startCaching:@[assetModel.asset] targetSize:size options:nil];
    

}

- (void)deleteObject:(YQAssetModel *)assetModel
{
    if ([self isContainObject:assetModel.asset.localIdentifier]) {
        [self.selectArray removeObject:[self deleteObjectWithLocalIdentifier:assetModel.asset.localIdentifier]];
    }
    [self.selectDictionary removeObjectForKey:assetModel.asset.localIdentifier];
    
    CGSize size = CGSizeMake(KSCREEN_WIDTH, KSCREEN_HEIGHT-KNAVBAR_HEIGHT);
    if (self.isOriginal) {
        size = CGSizeZero;
    }
    [self stopCaching:@[assetModel.asset] targetSize:size options:nil];
}

- (BOOL)isContainObject:(NSString *)localIdentifier
{
    return [self.selectDictionary.allKeys containsObject:localIdentifier];
}

- (YQAssetModel *)deleteObjectWithLocalIdentifier:(NSString *)localIdentifier
{
    __block YQAssetModel *targetAssetModel = nil;
    [self.selectArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YQAssetModel *assetModel = obj;
        if ([assetModel.asset.localIdentifier isEqualToString:localIdentifier]) {
            targetAssetModel = assetModel;
            *stop = YES;
        }
    }];
    return targetAssetModel;
}


#pragma mark - save
- (void)save:(UIImage *)image complete:(void(^)(YQAssetModel *assetModel))complete
{
    __block NSString *assetId = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        assetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
            YQAssetModel *assetModel = [YQAssetModel modelWithAsset:asset];
            complete(assetModel);
        });
    }];
}

@end
