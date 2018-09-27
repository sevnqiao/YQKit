//
//  YQPhotoPreviewItemCell.m
//  YQKit
//
//  Created by world on 2018/8/13.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoPreviewItemCell.h"
#import "YQAlbumManager.h"
#import "YQAlbumModel.h"
#import <PhotosUI/PhotosUI.h>
#import "YQPhotoVideoView.h"

@interface YQPhotoPreviewItemCell()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) PHLivePhotoView *livePhotoView API_AVAILABLE(ios(9.1));
@property (nonatomic, strong) YQPhotoVideoView *videoView;
@property (nonatomic, strong) YQAssetModel *assetModel;

@property (nonatomic, copy) NSString *localIdentifier;
@property (nonatomic, copy) void (^tapHandle)(void);
@end

@implementation YQPhotoPreviewItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
        [self initGesture];
    }
    return self;
}

- (void)initSubViews {
    self.scrollView = ({
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.contentView.bounds];
        scrollView.delegate = self;
        scrollView.minimumZoomScale = 1;
        scrollView.maximumZoomScale = 2;
        [self.contentView addSubview:scrollView];
        scrollView;
    });
    
    self.imageView = ({
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.contentView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = YES;
        [self.scrollView addSubview:imageView];
        imageView;
    });
    
    
    if (@available(iOS 9.1, *)) {
        self.livePhotoView = ({
            PHLivePhotoView *view = [[PHLivePhotoView alloc] initWithFrame:self.contentView.bounds];
            [self.scrollView addSubview:view];
            view;
        });
    }
    
    self.videoView = ({
        YQPhotoVideoView *videoView = [[YQPhotoVideoView alloc]initWithFrame:self.contentView.bounds];
        [self.scrollView addSubview:videoView];
        videoView;
    });
}

- (void)initGesture {
    UITapGestureRecognizer *sigleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    sigleTap.numberOfTapsRequired = 1;
    [self.contentView addGestureRecognizer:sigleTap];
    
    UITapGestureRecognizer *mutleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    sigleTap.numberOfTapsRequired = 2;
    [self.contentView addGestureRecognizer:mutleTap];
    
    [mutleTap requireGestureRecognizerToFail:sigleTap];
}

- (void)tap:(UITapGestureRecognizer *)tapG {
    if (tapG.numberOfTapsRequired == 1) {
        if (self.tapHandle) {
            self.tapHandle();
        }
    } else {
        if (self.scrollView.zoomScale == self.scrollView.maximumZoomScale) {
            [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
        } else {
            [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
        }
        
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.assetModel.type == YQAssetMediaTypeLivePhoto) {
        if (@available(iOS 9.1, *)) {
            return self.livePhotoView;
        } else {
            return self.imageView;
        }
    } else if (self.assetModel.type == YQAssetMediaTypeVideo) {
        return self.videoView;
    } else {
        return self.imageView;
    }
}


- (void)configImageViewWith:(YQAssetModel *)assetModel localIdentifier:(NSString *)localIdentifier tapHandle:(void(^)(void))tapHandle {
    self.tapHandle = tapHandle;
    self.assetModel = assetModel;
    self.localIdentifier = localIdentifier;
    self.imageView.hidden = (assetModel.type != YQAssetMediaTypeImage);
    self.videoView.hidden = (assetModel.type != YQAssetMediaTypeVideo);
    if (@available(iOS 9.1, *)) {
        self.livePhotoView.hidden = (assetModel.type != YQAssetMediaTypeLivePhoto);
    }

    if (assetModel.type == YQAssetMediaTypeLivePhoto) {
        if (@available(iOS 9.1, *)) {
            [self configLivePhotoWithAsset:assetModel];
        } else {
            [self configPhotoWithAsset:assetModel];
        }
    } else if (assetModel.type == YQAssetMediaTypeVideo) {
        [self configVideoWithAsset:assetModel];
    } else {
        [self configPhotoWithAsset:assetModel];
    }
}

- (void)configVideoWithAsset:(YQAssetModel *)assetModel
{
//    if (assetModel.playerItem) {
//        self.videoView.playerItem = assetModel.playerItem;
//    } else {
        [[YQAlbumManager sharedManager] getVideoWithAsset:assetModel.asset complete:^(AVPlayerItem *playerItem) {
            self.videoView.playerItem = playerItem;
            assetModel.playerItem = playerItem;
        }];
//    }
}
- (void)configLivePhotoWithAsset:(YQAssetModel *)assetModel
{
    if (@available(iOS 9.1, *)) {
        if (assetModel.livePhoto) {
            self.livePhotoView.livePhoto = assetModel.livePhoto;
            [self layoutImageViewWithTargetSize:CGSizeMake(assetModel.asset.pixelWidth, assetModel.asset.pixelHeight) type:YQAssetMediaTypeLivePhoto];
        } else {
            [[YQAlbumManager sharedManager] getLivePhotoWithAsset:assetModel.asset photoSize:self.bounds.size complete:^(PHLivePhoto *livePhoto) {
                self.livePhotoView.livePhoto = livePhoto;
                assetModel.livePhoto = livePhoto;
                [self layoutImageViewWithTargetSize:CGSizeMake(assetModel.asset.pixelWidth, assetModel.asset.pixelHeight) type:YQAssetMediaTypeLivePhoto];
            }];
        }
    }
}
- (void)configPhotoWithAsset:(YQAssetModel *)assetModel
{
    if (assetModel.highImage) {
        self.imageView.image = assetModel.highImage;
        [self layoutImageViewWithTargetSize:CGSizeMake(assetModel.asset.pixelWidth, assetModel.asset.pixelHeight) type:YQAssetMediaTypeImage];
    } else {
        [[YQAlbumManager sharedManager] getPhotoWithAsset:assetModel.asset photoSize:self.bounds.size isSynchronous:NO complete:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.localIdentifier isEqualToString:assetModel.asset.localIdentifier]) {
                    self.imageView.image = image;
                    assetModel.highImage = image;
                    [self layoutImageViewWithTargetSize:CGSizeMake(assetModel.asset.pixelWidth, assetModel.asset.pixelHeight) type:YQAssetMediaTypeImage];
                }
            });
        }];
    }
}

- (void)layoutImageViewWithTargetSize:(CGSize)targetSize type:(YQAssetMediaType)type
{
    CGFloat normalScale = self.contentView.bounds.size.height / self.contentView.bounds.size.width;
    CGFloat targetScale = targetSize.height / targetSize.width;
    CGRect targetFrame = CGRectZero;
    if (targetScale > normalScale) {
        targetFrame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.width * targetScale);
        self.scrollView.contentSize = self.imageView.bounds.size;
    } else {
        targetFrame = self.contentView.bounds;
        self.scrollView.contentSize = self.contentView.bounds.size;
    }
    if (type == YQAssetMediaTypeLivePhoto) {
        if (@available(iOS 9.1, *)) {
            self.livePhotoView.frame = targetFrame;
        } else {
            // Fallback on earlier versions
        }
    } else if (type == YQAssetMediaTypeVideo) {
        self.videoView.frame = targetFrame;
    } else {
        self.imageView.frame = targetFrame;
    }
}

- (void)resetToDefault
{
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    [self.videoView resetToDefault];
}
@end
