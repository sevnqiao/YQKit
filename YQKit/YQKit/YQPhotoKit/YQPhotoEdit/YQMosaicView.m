//
//  YQMosaicView.m
//  YQKit
//
//  Created by world on 2018/8/20.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQMosaicView.h"

#define kBitsPerComponent (8)
#define kBitsPerPixel (32)
#define kPixelChannelCount (4)

@interface YQMosaicView ()
@property (nonatomic, strong) UIImageView *mosaicImageView;
@property (nonatomic, strong) CALayer *imageLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) CGMutablePathRef path;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSMutableArray *allPaths;
@property (nonatomic, strong) NSMutableArray *appendPaths;
@end

@implementation YQMosaicView

- (NSMutableArray *)allPaths
{
    if (!_allPaths) {
        _allPaths = [NSMutableArray array];
    }
    return _allPaths;
}

- (NSMutableArray *)appendPaths
{
    if (!_appendPaths) {
        _appendPaths = [NSMutableArray array];
    }
    return _appendPaths;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //添加imageview（mosaicImageView）到self上
        self.mosaicImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:self.mosaicImageView];

        //添加layer（imageLayer）到self上
        self.imageLayer = [CALayer layer];
        self.imageLayer.frame = self.bounds;
        self.imageLayer.contentsGravity = @"resizeAspect";
        [self.layer addSublayer:self.imageLayer];
        
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.frame = self.bounds;
        self.shapeLayer.lineCap = kCALineCapRound;
        self.shapeLayer.lineJoin = kCALineJoinRound;
        self.shapeLayer.lineWidth = 10.f;
        self.shapeLayer.strokeColor = [UIColor blueColor].CGColor;
        self.shapeLayer.fillColor = nil;//此处设置颜色有异常效果，可以自己试试
        
        [self.layer addSublayer:self.shapeLayer];
        self.imageLayer.mask = self.shapeLayer;
        
        self.path = CGPathCreateMutable();
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    //底图
    _image = image;
    self.imageLayer.contents = (id)image.CGImage;
}

- (void)setMosaicImage:(UIImage *)mosaicImage
{
    //顶图
    _mosaicImage = mosaicImage;
    self.mosaicImageView.image = mosaicImage;
    self.image = [self transToMosaicImage:mosaicImage blockLevel:10];
    
    CGRect rect = self.frame;
    rect.size.height = mosaicImage.size.height / mosaicImage.size.width * self.bounds.size.width;
    rect.origin.y = (self.bounds.size.height - rect.size.height) / 2;
    self.mosaicImageView.frame = rect;
    
    self.imageLayer.frame = self.bounds;
    self.shapeLayer.frame = self.bounds;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPathMoveToPoint(self.path, NULL, point.x, point.y);
    CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
    self.shapeLayer.path = path;
    CGPathRelease(path);
    self.appendPaths = [NSMutableArray array];
    [self.appendPaths addObject:[NSValue valueWithCGPoint:point]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPathAddLineToPoint(self.path, NULL, point.x, point.y);
    CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
    self.shapeLayer.path = path;
    CGPathRelease(path);
    [self.appendPaths addObject:[NSValue valueWithCGPoint:point]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.allPaths addObject:self.appendPaths];
    
}
//清除
- (void)clear{
    
    [self.allPaths removeAllObjects];
    self.path = CGPathCreateMutable();
    CGPathMoveToPoint(self.path, NULL, 0, 0);
    CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
    self.shapeLayer.path = path;
    CGPathRelease(path);
}
//撤回
- (void)back{
    
    [self.allPaths removeLastObject];
    self.path = CGPathCreateMutable();
    //如果撤回步骤大于0次执行撤回 否则执行清除操作
    if (self.allPaths.count>0) {
        for (int i=0; i<self.allPaths.count; i++) {
            NSArray * array = self.allPaths[i];
            for (int j =0 ; j<array.count; j++) {
                CGPoint point = [array[j] CGPointValue];
                if (j==0) {
                    CGPathMoveToPoint(self.path, NULL, point.x, point.y);
                    CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
                    self.shapeLayer.path = path;
                    CGPathRelease(path);
                    
                }else{
                    
                    CGPathAddLineToPoint(self.path, NULL, point.x, point.y);
                    CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
                    self.shapeLayer.path = path;
                    CGPathRelease(path);
                }
            }
        }
        
    }else{
        [self clear];
    }
}


- (void)didFinishHandleWithCompletionBlock:(void (^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIImage *temImage = [weakSelf _buildImage];
            if (completionBlock)
            {
                completionBlock(temImage, nil, nil);
            }
        });
    });
}

#pragma mark 绘制当前的界面
- (UIImage *)_buildImage
{
    CGFloat wScale = self.mosaicImage.size.width / self.bounds.size.width;
    CGFloat hScale = self.mosaicImage.size.height / self.bounds.size.height;
    UIGraphicsBeginImageContextWithOptions(self.mosaicImage.size, NO, 0);
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    CGContextScaleCTM(ctx, wScale, hScale);
    [self.layer renderInContext:ctx];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


/*
 *转换成马赛克,level代表一个点转为多少level*level的正方形
 */
- (UIImage *)transToMosaicImage:(UIImage*)orginImage blockLevel:(NSUInteger)level
{
    //获取BitmapData
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = orginImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  kBitsPerComponent,        //每个颜色值8bit
                                                  width*kPixelChannelCount, //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit
                                                  colorSpace,
                                                  kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    unsigned char *bitmapData = CGBitmapContextGetData (context);
    
    //这里把BitmapData进行马赛克转换,就是用一个点的颜色填充一个level*level的正方形
    unsigned char pixel[kPixelChannelCount] = {0};
    NSUInteger index,preIndex;
    for (NSUInteger i = 0; i < height - 1 ; i++) {
        for (NSUInteger j = 0; j < width - 1; j++) {
            index = i * width + j;
            if (i % level == 0) {
                if (j % level == 0) {
                    memcpy(pixel, bitmapData + kPixelChannelCount*index, kPixelChannelCount);
                }else{
                    memcpy(bitmapData + kPixelChannelCount*index, pixel, kPixelChannelCount);
                }
            } else {
                preIndex = (i-1)*width +j;
                memcpy(bitmapData + kPixelChannelCount*index, bitmapData + kPixelChannelCount*preIndex, kPixelChannelCount);
            }
        }
    }
    
    NSInteger dataLength = width*height* kPixelChannelCount;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData, dataLength, NULL);
    //创建要输出的图像
    CGImageRef mosaicImageRef = CGImageCreate(width, height,
                                              kBitsPerComponent,
                                              kBitsPerPixel,
                                              width*kPixelChannelCount ,
                                              colorSpace,
                                              kCGBitmapByteOrderDefault,
                                              provider,
                                              NULL, NO,
                                              kCGRenderingIntentDefault);
    CGContextRef outputContext = CGBitmapContextCreate(nil,
                                                       width,
                                                       height,
                                                       kBitsPerComponent,
                                                       width*kPixelChannelCount,
                                                       colorSpace,
                                                       kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(outputContext, CGRectMake(0.0f, 0.0f, width, height), mosaicImageRef);
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContext);
    UIImage *resultImage = nil;
    if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
        float scale = [[UIScreen mainScreen] scale];
        resultImage = [UIImage imageWithCGImage:resultImageRef scale:scale orientation:UIImageOrientationUp];
    } else {
        resultImage = [UIImage imageWithCGImage:resultImageRef];
    }
    //释放
    if(resultImageRef){
        CFRelease(resultImageRef);
    }
    if(mosaicImageRef){
        CFRelease(mosaicImageRef);
    }
    if(colorSpace){
        CGColorSpaceRelease(colorSpace);
    }
    if(provider){
        CGDataProviderRelease(provider);
    }
    if(context){
        CGContextRelease(context);
    }
    if(outputContext){
        CGContextRelease(outputContext);
    }
    return resultImage;
    
}


- (void)dealloc
{
    if (self.path) {
        CGPathRelease(self.path);
    }
}
@end
