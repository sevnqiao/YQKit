//
//  YQPhotoAlbumDetailToolView.m
//  YQKit
//
//  Created by world on 2018/8/16.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoAlbumDetailToolView.h"

@interface YQPhotoAlbumDetailToolView ()
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UIButton *originalButton;

@property (nonatomic, copy) void (^handlePreview)(void);
@property (nonatomic, copy) void (^handleOriginal)(BOOL isOriginal);

@end

@implementation YQPhotoAlbumDetailToolView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    self.previewButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 40, self.bounds.size.height)];
    [self.previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [self.previewButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.previewButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.previewButton addTarget:self action:@selector(preview:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.previewButton];
    
    self.originalButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.previewButton.frame) + 10, 0, 200, self.bounds.size.height)];
    [self.originalButton setTitle:@"原图" forState:UIControlStateNormal];
    [self.originalButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.originalButton.titleLabel.font = [UIFont systemFontOfSize:13];
    self.originalButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.originalButton addTarget:self action:@selector(original:) forControlEvents:UIControlEventTouchUpInside];
    [self.originalButton setImage:[UIImage imageNamed:@"original_unselect"] forState:UIControlStateNormal];
    [self.originalButton setImage:[UIImage imageNamed:@"original_select"] forState:UIControlStateSelected];
    [self addSubview:self.originalButton];
}

- (void)preview:(UIButton *)sender
{
    if (self.handlePreview) {
        self.handlePreview();
    }
}

- (void)original:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    if (self.handleOriginal) {
        self.handleOriginal(sender.isSelected);
    }
}

- (void)handleWithPreviewHandle:(void (^)(void))previewHandle originalHandle:(void (^)(BOOL isOriginal))originalHandle
{
    self.handlePreview = previewHandle;
    self.handleOriginal = originalHandle;
}

- (void)configSizeTitle:(NSString *)sizeTitle
{
    [self.originalButton setTitle:[NSString stringWithFormat:@"原图（%@）",sizeTitle] forState:UIControlStateNormal];
}

@end
