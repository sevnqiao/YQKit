//
//  YQPhotoBrowseViewController.m
//  YQKit
//
//  Created by world on 2018/8/13.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoBrowseViewController.h"
#import "YQPhotoItemCell.h"

#define KMARGIN 20

@interface YQPhotoBrowseViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataSourceArray;
@end

@implementation YQPhotoBrowseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *url = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1534172203337&di=c5144f25d8b51e2dee7185f76becf7a3&imgtype=0&src=http%3A%2F%2F04.imgmini.eastday.com%2Fmobile%2F20180729%2F20180729080013_2e0e4f43723e01e40b81bee9e4d4d4e9_1.jpeg";
    self.dataSourceArray = @[url,url,url,url,url,url,url,url,url,url,url];
    
    [self initCollectionView];
}

- (void)initCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, KMARGIN/2, 0, KMARGIN/2);
    layout.itemSize = self.view.bounds.size;
    layout.minimumLineSpacing = KMARGIN;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-KMARGIN/2, 0, self.view.frame.size.width + KMARGIN, self.view.frame.size.height) collectionViewLayout:layout];
    
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.pagingEnabled = YES;
    [self.view addSubview:collectionView];
    
    [collectionView registerClass:[YQPhotoItemCell class] forCellWithReuseIdentifier:@"YQPhotoItemCellIdentifier"];
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YQPhotoItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YQPhotoItemCellIdentifier" forIndexPath:indexPath];
    [cell configImageViewWith:self.dataSourceArray[indexPath.row]];
    return cell;
}

@end
