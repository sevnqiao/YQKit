//
//  YQAlbumModel.h
//  YQKit
//
//  Created by world on 2018/8/14.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
    YQAssetMediaTypeLiveImage,  // 图片是一种动图(ios9之后) LivePhoto，长按之后会进行播放
    YQAssetMediaTypeVideo,  // 视频
    YQAssetMediaTypeAudio,  // 语音
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
 *  用来保存下载好的高清大图
 */
@property (nonatomic, strong) UIImage *highImage;

/**
 *  用来保存裁剪好的图
 */
@property (nonatomic, strong) UIImage *thumbImage;

/**
 *  是否选中,YES选中;反之未选中 默认NO
 */
@property (nonatomic, assign, getter=isSelected) BOOL selected;
/**
 *  文件类型
 */
@property (nonatomic, assign) YQAssetMediaType type;
/**
 *  视频文件时，视频文件的时长
 */
@property (nonatomic, copy) NSString *timeLength;


+ (YQAssetModel *)modelWithAsset:(PHAsset *)asset;

@end
