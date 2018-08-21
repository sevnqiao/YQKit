//
//  YQPhotoEditViewController.m
//  YQKit
//
//  Created by world on 2018/8/20.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoEditViewController.h"
#import "YQPhotoEditView.h"



@interface YQPhotoEditViewController ()
@property (nonatomic, strong) YQPhotoEditView *editView;
@end

@implementation YQPhotoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    YQPhotoEditView *editView = [[YQPhotoEditView alloc]initWithFrame:self.view.bounds];
    [editView configWithImage:[UIImage imageNamed:@"abc.jpg"]];
    [self.view addSubview:editView];
    self.editView = editView;

    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 50, 30)];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)save:(UIButton *)sender
{
    [self.editView didFinishHandleWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo) {

        NSLog(@"%@",image);

        UIViewController *vc = [[UIViewController alloc]init];

        UIImageView *imageview = [[UIImageView alloc]initWithFrame:vc.view.bounds];
        imageview.image = image;
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        [vc.view addSubview:imageview];

        [self presentViewController:vc animated:YES completion:nil];
    }];
}





@end
