//
//  YQPhotoAlbumDetailBottomView.h
//  YQKit
//
//  Created by world on 2018/8/17.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YQAssetModel;

@interface YQPhotoAlbumDetailBottomView : UIView
@property (nonatomic, copy) void(^selectHandle)(NSString *localIdentifier);
- (void)configBottomViewWithAssetArray:(NSArray *)assetArray;
- (void)selctItemWithLocalIdentifier:(NSString *)localIdentifier;
@end


@interface YQPhotoAlbumDetailBottomItemView : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, copy) NSString *localIdentifier;
- (void)configCellWithAssetModel:(YQAssetModel *)assetModel localIdentifier:(NSString *)localIdentifier select:(BOOL)select;
@end
