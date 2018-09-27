//
//  YQPhotoVideoView.h
//  YQKit
//
//  Created by world on 2018/8/29.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface YQPhotoVideoView : UIView
@property (nonatomic, strong) AVPlayerItem *playerItem;
- (void)resetToDefault;
@end
