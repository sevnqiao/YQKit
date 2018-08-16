//
//  YQPhotoCollectionCell.h
//  YQKit
//
//  Created by world on 2018/8/15.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YQAssetModel;

@interface YQPhotoCollectionCell : UICollectionViewCell
- (void)configCellWithAssetModel:(YQAssetModel *)assetModel targetSize:(CGSize)targetSize localIdentifier:(NSString *)localIdentifier;
@end
