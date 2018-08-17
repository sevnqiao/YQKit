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

@interface YQPhotoPreviewItemCell()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
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
    return self.imageView;
}


- (void)configImageViewWith:(YQAssetModel *)assetModel localIdentifier:(NSString *)localIdentifier tapHandle:(void(^)(void))tapHandle {
    self.tapHandle = tapHandle;
    
    self.localIdentifier = localIdentifier;
    [[YQAlbumManager sharedManager] getPhotoWithAsset:assetModel.asset photoSize:self.bounds.size isSynchronous:NO complete:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.localIdentifier isEqualToString:assetModel.asset.localIdentifier]) {
                self.imageView.image = image;
                assetModel.highImage = image;
                [self layoutImageViewWithTargetSize:CGSizeMake(assetModel.asset.pixelWidth, assetModel.asset.pixelHeight)];
            }
        });
    }];
}

- (void)layoutImageViewWithTargetSize:(CGSize)targetSize
{
    CGFloat normalScale = self.contentView.bounds.size.height / self.contentView.bounds.size.width;
    CGFloat targetScale = targetSize.height / targetSize.width;
    
    if (targetScale > normalScale) {
        self.imageView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.width * targetScale);
        self.scrollView.contentSize = self.imageView.bounds.size;
    } else {
        self.imageView.frame = self.contentView.bounds;
        self.scrollView.contentSize = self.contentView.bounds.size;
    }
}

- (void)resetToDefault
{
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
}
@end
