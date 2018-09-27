//
//  YQAlbumManager.h
//  YQKit
//
//  Created by world on 2018/8/14.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@class YQAlbumModel,YQAssetModel;

@interface YQAlbumManager : NSObject
@property (nonatomic, strong, readonly) NSMutableArray *selectArray;
@property (nonatomic, assign) BOOL isOriginal;

+ (YQAlbumManager *)sharedManager;
+ (void)requestAuthorization:(void(^)(PHAuthorizationStatus status))handler;

- (void)getCamerRollAlbumWithComplete:(void(^)(YQAlbumModel *model))complete;
- (void)getAllAlbumsWithCompletion:(void (^) (NSArray *allAlbumsArray))completion;
- (void)getPhotoWithAsset:(PHAsset *)asset photoSize:(CGSize)photoSize isSynchronous:(BOOL)isSynchronous complete:(void(^)(UIImage *image))complete;
- (void)getLivePhotoWithAsset:(PHAsset *)asset photoSize:(CGSize)photoSize complete:(void(^)(PHLivePhoto *livePhoto))complete API_AVAILABLE(ios(9.1));
- (void)getVideoWithAsset:(PHAsset *)asset complete:(void(^)(AVPlayerItem *playerItem))complete;
- (NSArray *)getAssetWithFetchResult:(PHFetchResult *)fetchResult;

- (void)startCaching:(NSArray *)assetArray targetSize:(CGSize)targetSize options:(nullable PHImageRequestOptions *)options;
- (void)stopCaching:(NSArray *)assetArray targetSize:(CGSize)targetSize options:(nullable PHImageRequestOptions *)options;
- (void)stopCachingImagesForAllAssets;

- (void)removeAllObjects;
- (void)addObject:(YQAssetModel *)assetModel;
- (void)deleteObject:(YQAssetModel *)assetModel;
- (BOOL)isContainObject:(NSString *)localIdentifier;

- (void)save:(UIImage *)image complete:(void(^)(YQAssetModel *assetModel))complete;
@end
