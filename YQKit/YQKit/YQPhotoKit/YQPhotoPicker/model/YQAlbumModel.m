//
//  YQAlbumModel.m
//  YQKit
//
//  Created by world on 2018/8/14.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQAlbumModel.h"
#import <Photos/Photos.h>

@implementation YQAlbumModel

+ (YQAlbumModel *)modelWithResult:(PHFetchResult *)result name:(NSString *)name
{
    YQAlbumModel *model = [[YQAlbumModel alloc] init];
    model.albumResult    = result;
    model.albumName      = name;
    model.albumContainPhotoCount = result.count;
    return model;
}


@end


@implementation YQAssetModel

+ (YQAssetModel *)modelWithAsset:(PHAsset *)asset
{
    YQAssetModel *assetModel = [YQAssetModel new];
    assetModel.asset = asset;
    switch (asset.mediaType) {
        case PHAssetMediaTypeUnknown:
        {
            assetModel.type = YQAssetMediaTypeImage;
        }
            break;
        case PHAssetMediaTypeImage:
        {
            assetModel.type = YQAssetMediaTypeImage;
            if (@available(iOS 9.1, *)) {
                if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                    assetModel.type = YQAssetMediaTypeLivePhoto;
                }
            }
        }
            break;
        case PHAssetMediaTypeVideo:
        case PHAssetMediaTypeAudio:
        {
            assetModel.type = YQAssetMediaTypeVideo;
            NSString *timeLength = [NSString stringWithFormat:@"%0.0f", asset.duration];
            assetModel.timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
        }
            break;
    }
    return assetModel;
}

+ (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration
{
    NSString *newTime = nil;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd", duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd", duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd", min, sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd", min, sec];
        }
    }
    return newTime;
}
@end
