//
//  YQPhotoEditView.h
//  YQKit
//
//  Created by world on 2018/8/21.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YQPhotoEditView : UIView
- (void)configWithImage:(UIImage *)image;
- (void)didFinishHandleWithCompletionBlock:(void (^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;
- (void)clear;
- (void)back;
@end
