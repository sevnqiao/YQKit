//
//  YQPhotoAlbumListCell.h
//  YQKit
//
//  Created by world on 2018/8/15.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YQAlbumModel;

@interface YQPhotoAlbumListCell : UITableViewCell
+ (YQPhotoAlbumListCell *)cellWithTableView:(UITableView *)tableView;
- (void)configCellWithAlbumModel:(YQAlbumModel *)albumModel;
@end
