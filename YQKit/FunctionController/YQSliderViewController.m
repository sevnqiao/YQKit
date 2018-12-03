//
//  YQSliderViewController.m
//  YQKit
//
//  Created by world on 2018/11/27.
//  Copyright © 2018 xyq. All rights reserved.
//

#import "YQSliderViewController.h"
#import "YQSliderView.h"

@interface YQSliderViewController ()<UIScrollViewDelegate, YQSliderViewDelegate>
@property (nonatomic, strong) YQSliderView *slider;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation YQSliderViewController{
    BOOL isTap;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    YQSliderView *slider = [[YQSliderView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    slider.sliderAlignment = YQSliderViewAlignmentNatural;
    slider.delegate = self;
    [self.view addSubview:slider];
    self.slider = slider;
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height - 60)];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * 4, self.view.bounds.size.height - 60);
    
    for (int i = 0; i < 4; i++) {
        UIView *view = [[UIView alloc]init];
        view.frame = CGRectMake(i * scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height);
        view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
        [scrollView addSubview:view];
    }
    
}

#pragma mark - YQSliderViewDelegate
- (NSArray *)dataSourceInSliderView:(YQSliderView *)sliderView {
    return @[@"生活", @"工作", @"环游世界", @"睡觉觉"];
}

- (void)sliderView:(YQSliderView *)sliderView selectAtIndex:(NSInteger)index {
    isTap = YES;
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * index, 0) animated:YES];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!isTap) {
        CGFloat progress = scrollView.contentOffset.x / scrollView.bounds.size.width;
        [self.slider updateIndicationViewWithProgress:progress];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    isTap = NO;
}

@end
