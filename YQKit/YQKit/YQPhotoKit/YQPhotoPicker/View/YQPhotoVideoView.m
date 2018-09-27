//
//  YQPhotoVideoView.m
//  YQKit
//
//  Created by world on 2018/8/29.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "YQPhotoVideoView.h"

@interface YQPhotoVideoView ()
@property (nonatomic, strong) UIView *playView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, assign) BOOL playEnd;
@property (nonatomic, strong) id observer;
@end

@implementation YQPhotoVideoView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    self.playView = [[UIView alloc]initWithFrame:self.bounds];
    [self addSubview:self.playView];
    
    self.startButton = [[UIButton alloc] initWithFrame:self.bounds];
    [self.startButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.startButton];

    self.playerLayer = [AVPlayerLayer layer];
    self.playerLayer.bounds = self.bounds;
    self.playerLayer.position = self.center;
    [self.playView.layer addSublayer:self.playerLayer];
    
    __weak typeof(self) weakSelf = self;
    self.observer = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (CMTimeCompare(self.player.currentItem.duration, self.player.currentItem.currentTime) <= 0) {
            [weakSelf.startButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            weakSelf.playEnd = YES;
        }
    }];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    _playerItem = playerItem;
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [UIView animateWithDuration:5 animations:^{
            
        }completion:^(BOOL finished) {
            
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            self.playerLayer.player = self.player;
            
        }];

    });
}

- (void)startPlay
{
    if (self.player.rate == 0) {
        
        if (self.playEnd) {
            [self.player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
                [self.player play];
                [self.startButton setBackgroundImage:nil forState:UIControlStateNormal];
                [self.startButton setImage:nil forState:UIControlStateNormal];
            }];
        } else {
            [self.player play];
            [self.startButton setBackgroundImage:nil forState:UIControlStateNormal];
            [self.startButton setImage:nil forState:UIControlStateNormal];
        }
    } else {
        [self.player pause];
        [self.startButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

- (void)dealloc
{
    [self.player removeTimeObserver:self.observer];
    [self.player pause];
    [self.playerLayer removeFromSuperlayer];
    self.player = nil;
}

- (void)resetToDefault
{
    [self.player removeTimeObserver:self.observer];
    [self.player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        [self.player pause];
        [self.startButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }];
}

@end
