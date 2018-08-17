//
//  YQPhotoCollectionCell.m
//  YQKit
//
//  Created by world on 2018/8/15.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoCollectionCell.h"
#import "YQAlbumManager.h"
#import "YQAlbumModel.h"

@interface YQPhotoCollectionCell()
@property (weak, nonatomic) IBOutlet UIImageView *assetImageView;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (nonatomic, copy) NSString *localIdentifier;
@end

@implementation YQPhotoCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configCellWithAssetModel:(YQAssetModel *)assetModel targetSize:(CGSize)targetSize localIdentifier:(NSString *)localIdentifier
{
    self.localIdentifier = localIdentifier;
    
    if (assetModel.thumbImage) {
        self.assetImageView.image = assetModel.thumbImage;
    } else {
        [[YQAlbumManager sharedManager] getPhotoWithAsset:assetModel.asset photoSize:targetSize isSynchronous:NO complete:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.localIdentifier isEqualToString:assetModel.asset.localIdentifier]) {
                    self.assetImageView.image = image;
                    assetModel.thumbImage = image;
                }
            });
        }];
    }
    
    if ([[YQAlbumManager sharedManager] isContainObject:assetModel.asset.localIdentifier]) {
        assetModel.selected = YES;
    }
    self.selectButton.selected = assetModel.isSelected;
}

- (IBAction)select:(UIButton *)sender {
    if (self.selectHandle) {
        self.selectHandle();
    }
}

@end
