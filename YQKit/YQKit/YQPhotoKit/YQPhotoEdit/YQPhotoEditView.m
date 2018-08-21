//
//  YQPhotoEditView.m
//  YQKit
//
//  Created by world on 2018/8/21.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoEditView.h"
#import "YQMosaicView.h"

@interface YQPhotoEditView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) YQMosaicView *mosaicView;
@property (nonatomic, strong) UIView *backView;
@end

@implementation YQPhotoEditView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initScrollView];
    }
    return self;
}

- (void)initScrollView
{
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 2;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    self.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
    [self addSubview:self.scrollView];
    
    self.backView = [[UIView alloc]initWithFrame:self.bounds];
    [self.scrollView addSubview:self.backView];
    
    self.mosaicView = [[YQMosaicView alloc]init];
    [self.backView addSubview:self.mosaicView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.backView;
}

#pragma mark - config
- (void)configWithImage:(UIImage *)image
{
    CGFloat height = image.size.height / image.size.width * self.bounds.size.width;
    self.mosaicView.frame = CGRectMake(0, (self.bounds.size.height - height) / 2, self.bounds.size.width, height);
    self.mosaicView.mosaicImage = image;
}



- (void)didFinishHandleWithCompletionBlock:(void (^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock
{
    [self.mosaicView didFinishHandleWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo) {
        if (completionBlock) {
            completionBlock(image,error,userInfo);
        }
    }];
}


@end
