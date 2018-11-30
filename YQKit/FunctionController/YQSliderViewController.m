//
//  YQSliderViewController.m
//  YQKit
//
//  Created by world on 2018/11/27.
//  Copyright © 2018 xyq. All rights reserved.
//

#import "YQSliderViewController.h"
#import "YQSliderView.h"

@interface YQSliderViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) YQSliderView *slider;
@end

@implementation YQSliderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    YQSliderView *slider = [[YQSliderView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    slider.sliderAlignment = YQSliderViewAlignmentNatural;
    [slider configSliderViewWithDataArray:@[@"生活", @"工作", @"环游世界", @"睡觉觉"]];
    [self.view addSubview:slider];
    self.slider = slider;
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height - 60)];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * 4, self.view.bounds.size.height - 60);
    
    for (int i = 0; i < 4; i++) {
        UIView *view = [[UIView alloc]init];
        view.frame = CGRectMake(i * scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height);
        view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
        [scrollView addSubview:view];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat progress = scrollView.contentOffset.x / scrollView.bounds.size.width;
    [self.slider updateIndicationViewWithProgress:progress];
    
    
}

@end
