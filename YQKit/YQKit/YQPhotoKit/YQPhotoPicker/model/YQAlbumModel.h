//
//  YQAlbumModel.h
//  YQKit
//
//  Created by world on 2018/8/14.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@class PHAsset, PHFetchResult;
/**
 *  相册model
 */
@interface YQAlbumModel : NSObject

/**
 *  相册名字
 */
@property (nonatomic, strong) NSString *albumName;
/**
 *  相册包含多少图片
 */
@property (nonatomic, assign) NSInteger albumContainPhotoCount;
/**
 *  相册实体操作对象 PHFetchResult<PHAsset>
 */
@property (nonatomic, strong) PHFetchResult *albumResult;

+ (YQAlbumModel *)modelWithResult:(PHFetchResult *)result name:(NSString *)name;

@end






typedef NS_ENUM (NSInteger, YQAssetMediaType) {
    YQAssetMediaTypeImage = 1,  // 照片
    YQAssetMediaTypeLivePhoto,  // LivePhoto
    YQAssetMediaTypeVideo,  // 视频
};
/**
 *  单个图片管理对象
 */
@interface YQAssetModel : NSObject

/**
 *  图片对象 PHAsset
 */
@property (nonatomic, strong) PHAsset *asset;

/**
 *  用来保存下载好的原图
 */
@property (nonatomic, strong) UIImage *originalImage;


/**
 *  用来保存下载好的高清大图
 */
@property (nonatomic, strong) UIImage *highImage;

/**
 *  用来保存裁剪好的图
 */
@property (nonatomic, strong) UIImage *thumbImage;

/**
 *  文件类型
 */
@property (nonatomic, assign) YQAssetMediaType type;
/**
 *  视频文件时，视频文件的时长
 */
@property (nonatomic, copy) NSString *timeLength;

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) PHLivePhoto *livePhoto API_AVAILABLE(ios(9.1));

+ (YQAssetModel *)modelWithAsset:(PHAsset *)asset;

@end
