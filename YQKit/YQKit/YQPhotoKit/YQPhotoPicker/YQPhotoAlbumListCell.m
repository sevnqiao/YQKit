//
//  YQPhotoAlbumListCell.m
//  YQKit
//
//  Created by world on 2018/8/15.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoAlbumListCell.h"
#import "YQAlbumModel.h"
#import "YQAlbumManager.h"

@interface YQPhotoAlbumListCell ()
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumCountLabel;
@end


@implementation YQPhotoAlbumListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (YQPhotoAlbumListCell *)cellWithTableView:(UITableView *)tableView
{
    YQPhotoAlbumListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YQPhotoAlbumListCellIdentifier"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"YQPhotoAlbumListCell" bundle:nil] forCellReuseIdentifier:@"YQPhotoAlbumListCellIdentifier"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"YQPhotoAlbumListCellIdentifier"];
    }
    return cell;
}

- (void)configCellWithAlbumModel:(YQAlbumModel *)albumModel
{
    NSArray *arr = [[YQAlbumManager sharedManager] getAssetWithFetchResult:albumModel.albumResult];
    YQAssetModel *assetModel = arr.count > 0 ? arr.firstObject : nil;
    [[YQAlbumManager sharedManager] getPhotoWithAsset:assetModel.asset photoSize:CGSizeMake(65, 65) complete:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.albumImageView.image = image;
        });
    }];
    self.albumNameLabel.text = albumModel.albumName;
    self.albumCountLabel.text = [NSString stringWithFormat:@"%@",@(albumModel.albumContainPhotoCount)];
}


@end
