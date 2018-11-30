//
//  YQSliderView.h
//  YQKit
//
//  Created by world on 2018/11/27.
//  Copyright © 2018 xyq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YQSliderViewAlignment) {
    YQSliderViewAlignmentJustified,
    YQSliderViewAlignmentNatural
};

@interface YQSliderView : UIView

@property (nonatomic, assign) YQSliderViewAlignment sliderAlignment;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectColor;
@property (nonatomic, assign) UIColor *indicationViewColor;
@property (nonatomic, assign) NSInteger indicationViewHeight;
@property (nonatomic, assign) CGFloat itemSpace;

- (void)updateIndicationViewWithProgress:(CGFloat)progress;
- (void)configSliderViewWithDataArray:(NSArray *)dataArray;

@end


@interface YQSliderLabel : UILabel

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UIColor *fillColor;

@end
