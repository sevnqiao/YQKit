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
    assetModel.selected = NO;
    return assetModel;
}


@end
