//
//  YQPhotoAlbumDetailToolView.h
//  YQKit
//
//  Created by world on 2018/8/16.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YQPhotoAlbumDetailToolView : UIView
- (void)handleWithPreviewHandle:(void (^)(void))previewHandle originalHandle:(void (^)(BOOL isOriginal))originalHandle;
- (void)configSizeTitle:(NSString *)sizeTitle;
@end
