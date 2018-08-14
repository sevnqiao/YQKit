//
//  YQPhotoNavBarView.h
//  YQKit
//
//  Created by world on 2018/8/14.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YQPhotoNavBarView : UIView
@property (nonatomic, copy) void(^handleBack)(void);
- (void)configTitleLabelWithTitle:(NSString *)title;
@end
