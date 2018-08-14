//
//  YQPhotoNavBarView.m
//  YQKit
//
//  Created by world on 2018/8/14.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoNavBarView.h"

@interface YQPhotoNavBarView()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation YQPhotoNavBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-44, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(44, self.bounds.size.height-44, self.bounds.size.width-88, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:25];
    titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

- (void)back {
    if (self.handleBack) {
        self.handleBack();
    }
}

- (void)configTitleLabelWithTitle:(NSString *)title {
    self.titleLabel.text = title;
}
@end
