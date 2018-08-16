//
//  YQPhotoPickerViewController.m
//  YQKit
//
//  Created by world on 2018/8/14.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoPickerViewController.h"
#import "YQPhotoAlbumListViewController.h"
#import "YQPhotoAlbumDetailViewController.h"
#import "YQAlbumManager.h"

@interface YQPhotoPickerViewController ()

@end

@implementation YQPhotoPickerViewController

- (instancetype)init
{
    YQPhotoAlbumListViewController *vc = [[YQPhotoAlbumListViewController alloc]init];
    self = [super initWithRootViewController:vc];
    if (self)
    {
        [self checkauthorizationStatus];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)checkauthorizationStatus
{
    [YQAlbumManager requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                    [self requestAllAlbumList];
                    break;
                case PHAuthorizationStatusDenied:
                    [self alertAuthorization];
                    break;
                default:
                    break;
            }
        });
    }];
    
}

- (void)requestAllAlbumList
{
    [[YQAlbumManager sharedManager] getCamerRollAlbumWithComplete:^(YQAlbumModel *model) {
        YQPhotoAlbumDetailViewController *detailVC = [[YQPhotoAlbumDetailViewController alloc]init];
        detailVC.albumModel = model;
        [super pushViewController:detailVC animated:NO];
    }];
}

- (void)alertAuthorization
{
    
}


@end
