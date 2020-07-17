//
//  FSStreamingContext.m
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/15.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "FSStreamingContext.h"

@interface FSStreamingContext ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) FSTimeLine *timeline;
@property (nonatomic, strong) id timeObserve;
@property (nonatomic, assign) int64_t playEnd;
@property (nonatomic, assign) int64_t currentPosition;
@end

@implementation FSStreamingContext

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player removeTimeObserver:self.timeObserve];
}

- (instancetype)init {
    if (self = [super init]) {
        [self addObserver];
    }
    return self;
}

- (void)addObserver {
    //播放到末尾
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    //播放器暂停的时候
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemPlaybackStalled:) name:AVPlayerItemPlaybackStalledNotification object:self.player.currentItem];
    //视频无法播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemFailedToPlayToEndTimeError:) name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:self.player.currentItem];
}

#pragma mark - 外部调用
- (BOOL)connectionTimeLine:(FSTimeLine *)timeline playerView:(UIView *)view {
    if (!timeline) {
        NSLog(@"连接失败，时间为空");
        return NO;
    }
    
    if (!view) {
        NSLog(@"连接失败，预览view为空");
        return NO;
    }
    _timeline = timeline;
    
    // 传入地址 (CGSize)
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:[self.timeline getTimeAsset]];
    AVMutableVideoComposition *composition = [self.timeline videoComposition];
    [playerItem setVideoComposition:composition];
    
    // 播放器
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    _player = player;
    // 播放器layer
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    if (view) {
        playerLayer.frame = view.frame;
        // 视频填充模式
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//AVLayerVideoGravityResizeAspect;
        // 添加到imageview的layer上
        [view.layer addSublayer:playerLayer];
    }
    
    //实时监听播放状态
    DN_WEAK_SELF
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 20.0) queue:nil usingBlock:^(CMTime time) {
        DN_STRONG_SELF
        [self timeChange:time];
    }];
    return YES;
}

// 微妙
- (void)playStartTime:(int64_t)startTime endTime:(int64_t)endTime {
    if ((startTime > 0 && startTime < FS_TIME_BASE) ||
        startTime > self.timeline.duration) {
        NSLog(@"开始播放错误 : 开始时间错误");
        return;
    }
    if (endTime > self.timeline.duration) {
        NSLog(@"开始播放错误 : 播放结束时间超过视频时间 endTime : %lld self.timeline.duration >>> %lld",endTime,self.timeline.duration);
        return;
    }
    self.playEnd = endTime;
    [self seekToTime:startTime];
    [self play];
}

- (void)seekToTime:(int64_t)time {
    if ((time > 0 && time < FS_TIME_BASE) ||
        time > self.timeline.duration) {
        NSLog(@"seek错误 : seek时间错误");
        return;
    }
    
    CMTime start = CMTimeMake((int64_t)(time), FS_TIME_BASE);
    [self.player seekToTime:start];
    self.currentPosition = time;
}

- (void)play {
    [self.player play];
}

- (void)stop {
    [self.player pause];
}

- (int64_t)getTimelineCurrentPosition {
    return self.currentPosition;
}

// 合成视频
- (void)compileVideoOutPutPath:(NSString *)outPutPath block:(FSSuccessDataBlock)block {
    if (!outPutPath) {
        if (block) {
            block(NO, nil);
        }
        return;
    }
    //AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:[self.timeline getTimeAsset] presetName:AVAssetExportPresetHighestQuality];//AVAssetExportPreset640x480
    
    AVMutableVideoComposition *avMutableVideoComposition = [self.timeline videoComposition];
    [assetExportSession setVideoComposition:avMutableVideoComposition];
    
    //混合后的视频输出路径
    NSURL *outPutUrl = [NSURL fileURLWithPath:outPutPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outPutPath error:nil];
    }
    
    //输出视频格式 AVFileTypeMPEG4 AVFileTypeQuickTimeMovie...
    assetExportSession.outputFileType = AVFileTypeMPEG4;
    //    NSArray *fileTypes = assetExportSession.
    
    assetExportSession.outputURL = outPutUrl;
    //输出文件是否网络优化
    assetExportSession.shouldOptimizeForNetworkUse = YES;
    
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        BOOL is = [assetExportSession status] == AVAssetExportSessionStatusCompleted;
        switch ([assetExportSession status]) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Export failed: %@", [[assetExportSession error] localizedDescription]);
                break;
                
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
                
            case AVAssetExportSessionStatusCompleted:{
                NSLog(@"Export completed");
            }
                break;
                
            default:
                NSLog(@"Export other");

                break;
        }
        
        if (block) {
            block(is, outPutPath);
        }
    }];
}

#pragma mark - 内部调用
- (void)playEndCall {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPlaybackEOF:)]) {
        [self.delegate didPlaybackEOF:self.timeline];
    }
}

- (void)playStopCall {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPlaybackStopped:)]) {
        [self.delegate didPlaybackStopped:self.timeline];
    }
}

#pragma mark - 监听方法
/// 播放完成
/// @param notification notification description
- (void)moviePlayDidEnd:(NSNotification*)notification {
    NSLog(@"结束播放");
    [self playEndCall];
}

/// 暂停播放
/// @param notification notification description
- (void)playerItemPlaybackStalled:(NSNotification*)notification {
    [self playStopCall];
}

- (void)playerItemFailedToPlayToEndTimeError:(NSNotification*)notification {
    NSError *error = notification.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
    NSLog(@"播放失败  发生错误：%@",error);
}

/// 时间发生变化
/// @param time time description
- (void)timeChange:(CMTime)time {
    CGFloat second = (CGFloat)time.value / (CGFloat)time.timescale;
    int64_t duration = second*FS_TIME_BASE;
    self.currentPosition = duration;
    
//    NSLog(@"self.currentPosition >>>> %lld",self.currentPosition);
    if (duration > self.playEnd) {
        [self stop];
        [self playEndCall];
    }else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didPlaybackTimelinePosition:position:)]) {
            [self.delegate didPlaybackTimelinePosition:self.timeline position:duration];
        }
    }
}

@end
