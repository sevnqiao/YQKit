//
//  YQPhotoItemCell.m
//  YQKit
//
//  Created by world on 2018/8/13.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoItemCell.h"
#import "UIImageView+WebCache.h"

@interface YQPhotoItemCell()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, copy) void (^tapHandle)(void);
@end

@implementation YQPhotoItemCell

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


- (void)configImageViewWith:(id)image tapHandle:(void(^)(void))tapHandle {
    if ([image isKindOfClass:[NSString class]]) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:@""]];
    } else if ([image isKindOfClass:[NSURL class]]) {
        [self.imageView sd_setImageWithURL:image placeholderImage:[UIImage imageNamed:@""]];
    } else if ([image isKindOfClass:[UIImage class]]) {
        self.imageView.image = image;
    } else {
        self.imageView.image = [UIImage imageNamed:@""];
    }
    
    self.tapHandle = tapHandle;
}

- (void)resetToDefault
{
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
}
@end
