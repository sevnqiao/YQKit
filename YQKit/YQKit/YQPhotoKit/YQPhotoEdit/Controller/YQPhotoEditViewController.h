//
//  YQPhotoEditViewController.h
//  YQKit
//
//  Created by world on 2018/8/20.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YQPhotoEditViewController : UIViewController
- (void)configWithImage:(id)targetImage complete:(void (^)(UIImage *image, NSError *error, NSDictionary *userInfo))complete;
@end
