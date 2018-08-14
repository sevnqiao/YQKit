//
//  YQPhotoBrowseViewController.h
//  YQKit
//
//  Created by world on 2018/8/13.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YQPhotoBrowseViewController : UIViewController

/**
 * 数据源 （NSString, NSUrl, UIImage）
 */
@property (nonatomic, strong) NSArray *dataSourceArray;
@property (nonatomic, assign) NSInteger currentIndex;
@end
