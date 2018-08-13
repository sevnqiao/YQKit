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
@end

@implementation YQPhotoItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
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
        [self.scrollView addSubview:imageView];
        imageView;
    });
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}


- (void)configImageViewWith:(id)image {
    if ([image isKindOfClass:[NSString class]]) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:@""]];
    } else if ([image isKindOfClass:[NSURL class]]) {
        [self.imageView sd_setImageWithURL:image placeholderImage:[UIImage imageNamed:@""]];
    } else if ([image isKindOfClass:[UIImage class]]) {
        self.imageView.image = image;
    } else {
        self.imageView.image = [UIImage imageNamed:@""];
    }
}



@end
