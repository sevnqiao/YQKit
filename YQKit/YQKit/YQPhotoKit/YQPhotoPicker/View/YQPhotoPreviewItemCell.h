//
//  YQPhotoPreviewItemCell.h
//  YQKit
//
//  Created by world on 2018/8/16.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YQAssetModel;

@interface YQPhotoPreviewItemCell : UICollectionViewCell
- (void)configImageViewWith:(YQAssetModel *)assetModel localIdentifier:(NSString *)localIdentifier tapHandle:(void(^)(void))tapHandle;
- (void)resetToDefault;
@end
