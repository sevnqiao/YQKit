//
//  ViewController.m
//  YQKit
//
//  Created by world on 2018/8/13.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "ViewController.h"
#import "YQPhotoBrowseViewController.h"
#import "YQPhotoPickerViewController.h"
#import "YQPhotoEditViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellIdentifier"];
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"图片浏览器";
            break;
        case 1:
            cell.textLabel.text = @"选择图片";
            break;
        case 2:
            cell.textLabel.text = @"图片编辑";
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            [self jumpToPhotoBrowse];
            break;
        case 1:
            [self jumpToPhotoPicker];
            break;
        case 2:
            [self jumpToPhotoEdit];
            break;
        default:
            break;
    }
}

- (void)jumpToPhotoEdit
{
    YQPhotoEditViewController *vc = [[YQPhotoEditViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
    
    [vc configWithImage:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1534236096855&di=fca54631e350c49623d0a95a201fce1e&imgtype=0&src=http%3A%2F%2Fimage.uc.cn%2Fs%2Fwemedia%2Fs%2F2017%2Faf080383f88dc68113e16214c9bf6fa1x640x1137x72.jpeg" complete:^(UIImage *image, NSError *error, NSDictionary *userInfo) {
        UIViewController *vc = [[UIViewController alloc]init];
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:vc.view.bounds];
        imageview.image = image;
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        [vc.view addSubview:imageview];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)jumpToPhotoPicker
{
    YQPhotoPickerViewController *vc = [[YQPhotoPickerViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)jumpToPhotoBrowse
{
    YQPhotoBrowseViewController *vc = [[YQPhotoBrowseViewController alloc]init];
    vc.dataSourceArray = @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1534172203337&di=c5144f25d8b51e2dee7185f76becf7a3&imgtype=0&src=http%3A%2F%2F04.imgmini.eastday.com%2Fmobile%2F20180729%2F20180729080013_2e0e4f43723e01e40b81bee9e4d4d4e9_1.jpeg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1534236096855&di=fca54631e350c49623d0a95a201fce1e&imgtype=0&src=http%3A%2F%2Fimage.uc.cn%2Fs%2Fwemedia%2Fs%2F2017%2Faf080383f88dc68113e16214c9bf6fa1x640x1137x72.jpeg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1534236096852&di=c5029042f014fe5eb71b6b08aa6455b9&imgtype=0&src=http%3A%2F%2Fi.shangc.net%2F2018%2F0626%2F20180626012028678.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1534236096852&di=4c748c94e4b34e60d5ca1f59a49fb147&imgtype=0&src=http%3A%2F%2Fimg.52fuqing.com%2Fupload%2Feditor%2F2018-07-01%2F1530455883tS9CRG.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1534236096849&di=a70b3e087181e8b3f95d8fceae836d35&imgtype=0&src=http%3A%2F%2Fp0.ifengimg.com%2Fpmop%2F2017%2F0919%2F676D1C5C73AE64D8F7ADB1D91763AE91DD327E89_size1958_w320_h274.gif",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1534236096845&di=08ad0ef79d9466bc28aa58fd1df4ff03&imgtype=0&src=http%3A%2F%2Fs9.rr.itc.cn%2Fr%2FwapChange%2F20176_12_19%2Fa8gno08924087786544.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1534236139598&di=66551d56d781ffb3d94211db08c2798a&imgtype=0&src=http%3A%2F%2Fs9.rr.itc.cn%2Fr%2FwapChange%2F20178_10_23%2Fa687t614515801197405.jpg"];
    vc.currentIndex = 5;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
