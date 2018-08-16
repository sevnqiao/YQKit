//
//  YQPhotoAlbumListViewController.m
//  YQKit
//
//  Created by world on 2018/8/14.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoAlbumListViewController.h"
#import "YQPhotoAlbumDetailViewController.h"
#import "YQAlbumModel.h"
#import "YQAlbumManager.h"
#import "YQPhotoAlbumListCell.h"

@interface YQPhotoAlbumListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *albumListArray;
@end

@implementation YQPhotoAlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initNavBar];
    [self initTableView];
    
    [self loadAllAlbumData];
}

- (void)initTableView
{
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    
}

- (void)initNavBar
{
    self.navigationItem.title = @"相册列表";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
}
- (void)cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getter / setter
- (NSMutableArray *)albumListArray
{
    if (!_albumListArray) {
        _albumListArray = [NSMutableArray array];
    }
    return _albumListArray;
}

#pragma mark - load all album
- (void)loadAllAlbumData
{
    __weak typeof(self) weakSelf = self;
    [[YQAlbumManager sharedManager] getAllAlbumsWithCompletion:^(NSArray *allAlbumsArray) {
        [weakSelf.albumListArray addObjectsFromArray:allAlbumsArray];
        [weakSelf.tableView reloadData];
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albumListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YQPhotoAlbumListCell *cell = [YQPhotoAlbumListCell cellWithTableView:tableView];
    YQAlbumModel *model = self.albumListArray[indexPath.row];
    [cell configCellWithAlbumModel:model];
    return cell;        
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YQPhotoAlbumDetailViewController *detailVC = [[YQPhotoAlbumDetailViewController alloc]init];
    detailVC.albumModel = self.albumListArray[indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
}
@end
