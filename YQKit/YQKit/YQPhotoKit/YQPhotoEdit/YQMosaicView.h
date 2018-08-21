//
//  YQMosaicView.h
//  YQKit
//
//  Created by world on 2018/8/20.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YQMosaicView : UIView
@property (nonatomic, strong) UIImage *mosaicImage;

- (void)didFinishHandleWithCompletionBlock:(void (^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;

@end
