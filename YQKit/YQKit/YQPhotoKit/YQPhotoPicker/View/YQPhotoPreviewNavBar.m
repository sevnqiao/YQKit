//
//  YQPhotoPreviewNavBar.m
//  YQKit
//
//  Created by world on 2018/8/14.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoPreviewNavBar.h"

@interface YQPhotoPreviewNavBar()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, copy) void (^handleBack)(void);
@property (nonatomic, copy) void (^handleNext)(void);
@end

@implementation YQPhotoPreviewNavBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
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
    
    UIButton *nextButton = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width-90, self.bounds.size.height-35, 80, 26)];
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setBackgroundColor:[UIColor colorWithRed:18/255.0 green:139/255.0 blue:214/255.0 alpha:1]];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:14];
    nextButton.layer.cornerRadius = 13;
    nextButton.layer.masksToBounds = YES;
    [self addSubview:nextButton];
    self.nextButton = nextButton;
}

- (void)back {
    if (self.handleBack) {
        self.handleBack();
    }
}

- (void)next {
    if (self.handleNext) {
        self.handleNext();
    }
}

- (void)handleWithBackHandle:(void (^)(void))backHandle nextHandle:(void (^)(void))nextHandle
{
    self.handleBack = backHandle;
    self.handleNext = nextHandle;
}

- (void)configTitleLabelWithTitle:(NSString *)title selectCount:(NSInteger)selectCount{
    self.titleLabel.text = title;
    [self.nextButton setTitle:[NSString stringWithFormat:@"下一步(%@)",@(selectCount)] forState:UIControlStateNormal];
}
@end
