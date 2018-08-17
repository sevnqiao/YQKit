//
//  YQPhotoPreviewNavBar.h
//  YQKit
//
//  Created by world on 2018/8/14.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YQPhotoPreviewNavBar : UIView
- (void)handleWithBackHandle:(void (^)(void))backHandle nextHandle:(void (^)(void))nextHandle;
- (void)configTitleLabelWithTitle:(NSString *)title selectCount:(NSInteger)selectCount;
@end
