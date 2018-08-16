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
@property (nonatomic, strong) NSMutableArray *selectArray;

+ (YQAlbumManager *)sharedManager;
+ (void)requestAuthorization:(void(^)(PHAuthorizationStatus status))handler;

- (void)getCamerRollAlbumWithComplete:(void(^)(YQAlbumModel *model))complete;
- (void)getAllAlbumsWithCompletion:(void (^) (NSArray *allAlbumsArray))completion;
- (NSArray *)getAssetWithFetchResult:(PHFetchResult *)fetchResult;
- (void)getPhotoWithAsset:(PHAsset *)asset photoSize:(CGSize)photoSize complete:(void(^)(UIImage *image))complete;
- (void)startCaching:(NSArray *)assetArray targetSize:(CGSize)targetSize options:(nullable PHImageRequestOptions *)options;
- (void)stopCachingImagesForAllAssets;

- (void)addObject:(YQAssetModel *)assetModel;
- (void)deleteObject:(YQAssetModel *)assetModel;


@end
