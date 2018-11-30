//
//  YQSliderView.m
//  YQKit
//
//  Created by world on 2018/11/27.
//  Copyright © 2018 xyq. All rights reserved.
//

#import "YQSliderView.h"

@interface YQSliderView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *indicationView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *sliderLabelArray;

@end

@implementation YQSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _normalColor = [UIColor grayColor];
        _selectColor = [UIColor redColor];
        _indicationViewColor = _selectColor;
        _itemSpace = 30;
        
        
        
        [self initSubView];
    }
    return self;
}

- (void)initSubView {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.indicationView];
}

- (void)configSliderViewWithDataArray:(NSArray *)dataArray {
    self.dataArray = dataArray;
    
    for (int i = 0; i < dataArray.count; i++) {
        YQSliderLabel *sliderLabel = [[YQSliderLabel alloc]init];
        sliderLabel.font = [UIFont systemFontOfSize:14];
        sliderLabel.userInteractionEnabled = YES;
        sliderLabel.text = dataArray[i];
        sliderLabel.tag = i;
        sliderLabel.textColor = self.normalColor;
        sliderLabel.fillColor = i == 0 ? self.selectColor : self.normalColor;
        sliderLabel.progress = i == 0 ? 1 : 0;
        [self.scrollView addSubview:sliderLabel];
        [self.sliderLabelArray addObject:sliderLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [sliderLabel addGestureRecognizer:tap];
    }
    [self.scrollView bringSubviewToFront:self.indicationView];
}

- (void)tap:(UITapGestureRecognizer *)tap {
    NSUInteger tag = tap.view.tag;
    [self updateIndicationViewWithProgress:tag];
}


// 设置偏移量
- (void)updateIndicationViewWithProgress:(CGFloat)progress {
    if (!self.sliderLabelArray || self.sliderLabelArray.count == 0) {
        return;
    }
    // 当前索引
    NSInteger index = progress - CGFLOAT_MIN;
    
    YQSliderLabel *leftItem = (YQSliderLabel *)[self.sliderLabelArray objectAtIndex:index ];
    
    YQSliderLabel *rightItem ;
    if (index < self.dataArray.count-1) {
        rightItem = (YQSliderLabel *)[self.sliderLabelArray objectAtIndex:index + 1];
    }
    
    // 相对于当前屏幕的宽度
    CGFloat rightPageLeftDelta = progress - index;
    
    if ([leftItem isKindOfClass:[YQSliderLabel class]]) {
        leftItem.textColor = _selectColor;
        leftItem.fillColor = _normalColor;
        leftItem.progress = rightPageLeftDelta;
    }
    if ([rightItem isKindOfClass:[YQSliderLabel class]]) {
        rightItem.textColor = _normalColor;
        rightItem.fillColor = _selectColor;
        rightItem.progress = rightPageLeftDelta;
    }
    
    for (YQSliderLabel *itemView in self.sliderLabelArray) {
        if (itemView.tag!= index && itemView.tag != index + 1) {
            itemView.textColor = _normalColor;
            itemView.fillColor = _selectColor;
            itemView.progress = 0;
        }
    }

    
    [self slideBottomViewToIndexOffset:progress];
}

#pragma mark - setBottomView

- (void)slideBottomViewWithCurrentItem:(NSInteger)currentIten nextItem:(NSInteger)nextItem {
    
}

- (void)slideBottomViewToIndexOffset:(CGFloat)indexOffset {
    
    NSInteger selectIndex = indexOffset - CGFLOAT_MIN;
    
    CGFloat progress = indexOffset - selectIndex;
    

    YQSliderLabel *currentItemView = self.sliderLabelArray[selectIndex];
    YQSliderLabel *nextItemView = nil;
    CGFloat x = 0;
    CGFloat w = 0;
    CGFloat currentWidth = currentItemView.frame.size.width;
    
    if (selectIndex < self.sliderLabelArray.count - 1) {
        nextItemView = self.sliderLabelArray[selectIndex + 1];
    }
    
    
    if ((selectIndex == 0 && progress < 0) || (selectIndex == self.sliderLabelArray.count - 1 && progress > 0)) {
        x = CGRectGetMinX(currentItemView.frame) + (CGRectGetMaxX(currentItemView.frame) - CGRectGetMinX(currentItemView.frame)) * progress;
        w = currentWidth + (currentWidth - currentWidth) * progress;
    } else {
        CGFloat nextMaxX = 0;
        CGFloat nextWidth = 0;
        if  (nextItemView != nil) {
            nextMaxX = CGRectGetMinX(nextItemView.frame);
            nextWidth = nextItemView.frame.size.width;
        }
        if (progress < 0.5) {
            x = CGRectGetMinX(currentItemView.frame) + (nextMaxX - CGRectGetMinX(currentItemView.frame)) * progress - progress*_itemSpace;
            w = currentWidth  + (nextWidth - currentWidth) * progress + progress * _itemSpace * 2;
        }else {
            x = CGRectGetMinX(currentItemView.frame) + (nextMaxX - CGRectGetMinX(currentItemView.frame)) * progress  - (1-progress) * _itemSpace;
            w = currentWidth  + (nextWidth - currentWidth) * progress + (1-progress) * _itemSpace * 2;
        }
    }
    self.indicationView.frame = CGRectMake(x, self.frame.size.height - 5, w, 5);
}



#pragma mark - layout subviews
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // sliderLabel
    CGFloat lastMaxX = 0;
    for (int i = 0; i < self.sliderLabelArray.count; i++) {
        YQSliderLabel *sliderLabel = self.sliderLabelArray[i];
        CGFloat x = 0,y = 0,w = 0,h = self.bounds.size.height;
        if (self.sliderAlignment == YQSliderViewAlignmentJustified) { //两端对齐
            w = self.bounds.size.width / self.sliderLabelArray.count;
            x = i * w;
        } else if (self.sliderAlignment == YQSliderViewAlignmentNatural) { // 自由对齐
            x = lastMaxX + _itemSpace;
            w = [self calculateWidthWithContent:self.dataArray[i] font:[UIFont systemFontOfSize:14]];
            lastMaxX = x + w;
        }
        sliderLabel.frame = CGRectMake(x, y, w, h);
    }
    
    // scrollview
    self.scrollView.frame = self.bounds;
    if (self.sliderAlignment == YQSliderViewAlignmentJustified) { //两端对齐
        self.scrollView.contentSize = self.bounds.size;
    } else if (self.sliderAlignment == YQSliderViewAlignmentNatural) { // 自由对齐
        self.scrollView.contentSize = CGSizeMake(lastMaxX, self.bounds.size.height);
    }
    
    // indicationView
    if (self.sliderAlignment == YQSliderViewAlignmentJustified) { //两端对齐
        CGFloat w = self.bounds.size.width / self.sliderLabelArray.count;
        self.indicationView.frame = CGRectMake(0, self.bounds.size.height - self.indicationViewHeight, w, self.indicationViewHeight);
    } else if (self.sliderAlignment == YQSliderViewAlignmentNatural) { // 自由对齐
        CGFloat w = [self calculateWidthWithContent:self.dataArray[0] font:[UIFont systemFontOfSize:14]];
        self.indicationView.frame = CGRectMake(self.itemSpace, self.bounds.size.height - self.indicationViewHeight, w, self.indicationViewHeight);
    }
    self.indicationView.layer.cornerRadius = self.indicationViewHeight / 2;
    
}

- (CGFloat)calculateWidthWithContent:(NSString *)content font:(UIFont *)font {
    CGSize actureSize = [content boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 15) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    return actureSize.width;
}

#pragma mark - init view
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.delegate = self;
        
    }
    return _scrollView;
}

- (UIView *)indicationView {
    if (!_indicationView) {
        _indicationView = [[UIView alloc]init];
        _indicationView.backgroundColor = [UIColor redColor];
        _indicationView.layer.masksToBounds = YES;
    }
    return _indicationView;
}

- (NSMutableArray *)sliderLabelArray {
    if (!_sliderLabelArray) {
        _sliderLabelArray = [NSMutableArray array];
    }
    return _sliderLabelArray;
}

#pragma mark -
- (void)setIndicationViewColor:(UIColor *)indicationViewColor {
    _indicationViewColor = indicationViewColor;
    _indicationView.backgroundColor = indicationViewColor;
}

@end


@implementation YQSliderLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

// 滑动进度
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [_fillColor set];
    
    CGRect newRect = rect;
    newRect.size.width = rect.size.width * self.progress;
    UIRectFillUsingBlendMode(newRect, kCGBlendModeSourceIn);
}

@end
