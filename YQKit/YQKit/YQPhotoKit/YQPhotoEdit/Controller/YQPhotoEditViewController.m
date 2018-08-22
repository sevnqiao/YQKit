//
//  YQPhotoEditViewController.m
//  YQKit
//
//  Created by world on 2018/8/20.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoEditViewController.h"
#import "YQPhotoEditView.h"
#import "SDWebImageManager.h"


@interface YQPhotoEditViewController ()
@property (nonatomic, strong) YQPhotoEditView *editView;
@property (nonatomic, copy) void (^completeHandle)(UIImage *image, NSError *error, NSDictionary *userInfo);
@end

@implementation YQPhotoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    YQPhotoEditView *editView = [[YQPhotoEditView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:editView];
    self.editView = editView;

    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10, self.view.bounds.size.height - 40, 50, 30)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"完成" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *rescind = [[UIButton alloc]initWithFrame:CGRectMake(150, self.view.bounds.size.height - 40, 50, 30)];
    rescind.backgroundColor = [UIColor redColor];
    [rescind setTitle:@"撤销" forState:UIControlStateNormal];
    [rescind setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rescind addTarget:self action:@selector(rescind:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rescind];
    
    UIButton *reset = [[UIButton alloc]initWithFrame:CGRectMake(250, self.view.bounds.size.height - 40, 50, 30)];
    reset.backgroundColor = [UIColor redColor];
    [reset setTitle:@"重置" forState:UIControlStateNormal];
    [reset setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [reset addTarget:self action:@selector(reset:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reset];
}

- (void)save:(UIButton *)sender
{
    [self.editView didFinishHandleWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo) {
        if (self.completeHandle) {
            self.completeHandle(image, error, userInfo);
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)rescind:(UIButton *)sender
{
    [self.editView back];
}

- (void)reset:(UIButton *)sender
{
    [self.editView clear];
}


#pragma mark - config
- (void)configWithImage:(id)targetImage complete:(void (^)(UIImage *image, NSError *error, NSDictionary *userInfo))complete
{
    self.completeHandle = complete;
    
    if ([targetImage isKindOfClass:[UIImage class]]) {
        [self.editView configWithImage:targetImage];
    } else if ([targetImage isKindOfClass:[NSURL class]]) {
        [self downLoadImageWithUrl:targetImage];
    } else if ([targetImage isKindOfClass:[NSString class]]) {
        [self downLoadImageWithUrl:[NSURL URLWithString:targetImage]];
    }
}

- (void)downLoadImageWithUrl:(NSURL *)url
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[SDWebImageManager sharedManager] loadImageWithURL:url options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%.1ld", receivedSize/expectedSize);
            });
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.editView configWithImage:image];
            });
        }];
    });
}


@end
