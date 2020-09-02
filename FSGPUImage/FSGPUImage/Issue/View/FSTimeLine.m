//
//  FSTimeLine.m
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/15.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "FSTimeLine.h"
#import "FSVideoThumbnailModel.h"

@interface FSTimeLine ()

@property (nonatomic, strong) AVMutableComposition *mixComposition;
@property (nonatomic, strong) AVURLAsset* videoAsset;

@end

@implementation FSTimeLine

#pragma mark - 懒加载
- (AVMutableComposition *)mixComposition {
    if (!_mixComposition) {
        _mixComposition = [AVMutableComposition composition];
    }
    return _mixComposition;
}

#pragma mark - 内部方法
- (void)calculateDuration {
    CMTime time = self.mixComposition.duration;
    CGFloat second = (CGFloat)time.value / (CGFloat)time.timescale;
    int64_t duration = second*FS_TIME_BASE;
    _duration = duration;
}

#pragma mark - 外部调用
- (void)appendVideoClip:(NSString *)path trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut {
    NSLog(@"video trimIn:%lld trimOut : %lld",trimIn,trimOut);
    NSURL *videoUrl = [NSURL fileURLWithPath:path];
    if (videoUrl) {
        AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
        self.videoAsset = videoAsset;
        
        //开始位置startTime
        CMTime startTime = CMTimeMake(trimIn, FS_TIME_BASE);//CMTimeMakeWithSeconds(trimIn, videoAsset.duration.timescale);
        //截取长度videoDuration
        CMTime videoDuration = CMTimeMake(trimOut-trimIn, FS_TIME_BASE);//CMTimeMakeWithSeconds(trimOut, videoAsset.duration.timescale);
        CMTimeRange videoTimeRange = CMTimeRangeMake(startTime, videoDuration);
        
        //视频采集compositionVideoTrack
        AVMutableCompositionTrack *compositionVideoTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        NSError *error = nil;
        //TimeRange截取的范围长度
        //ofTrack来源
        //atTime插放在视频的时间位置
        NSArray *videoTracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = videoTracks.count > 0 ? videoTracks.firstObject : nil;
        BOOL is = [compositionVideoTrack insertTimeRange:videoTimeRange ofTrack:videoTrack atTime:kCMTimeZero error:&error];
        if (!is) {
            NSLog(@"video insert error : %@",error);
        }
        
        // 添加原视频的声音
        //视频声音采集(也可不执行这段代码不采集视频音轨，合并后的视频文件将没有视频原来的声音)
        AVMutableCompositionTrack *compositionVoiceTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        NSArray *voiceTracks = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
        AVAssetTrack *voiceTrack = voiceTracks.count > 0 ? voiceTracks.firstObject : nil;
        BOOL isVoice = [compositionVoiceTrack insertTimeRange:videoTimeRange
                                       ofTrack:voiceTrack
                                        atTime:kCMTimeZero error:&error];
        if (!isVoice) {
            NSLog(@"voice insert error : %@",error);
        }
        [self calculateDuration];
    }
}

- (void)appendAudioClip:(NSString *)path trimIn:(int64_t)trimIn trimOut:(int64_t)trimOut {
//    CGFloat duration = [FSCompoundTool getMediaDurationWithMediaURL:[NSURL fileURLWithPath:path]];
//    NSLog(@"duration >> %f",duration);
//    if (trimIn > duration) {
//        NSLog(@"加入音频轨道失败 : 开始时间超过音频的时间");
//        return;
//    }
//    if (trimIn > trimOut) {
//        NSLog(@"加入音频轨道失败 : 开始时间超过了结束时间");
//    }
    
    int64_t audioIn = trimIn;
    int64_t audioOut = trimOut;
//    if (trimOut > duration) {
//        audioOut = duration;
//        return;
//    }
    
    NSURL *audioUrl = [NSURL fileURLWithPath:path];
    if (audioUrl) {
        AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];
        NSLog(@"audioIn >>>> %lld audioOut >>>> %lld",audioIn,audioOut);
        //开始位置startTime
        CMTime startTime = CMTimeMake(audioIn, FS_TIME_BASE);//CMTimeMakeWithSeconds(audioIn, audioAsset.duration.timescale);
        //截取长度videoDuration
        CMTime videoDuration = CMTimeMake(audioOut-audioIn, FS_TIME_BASE);//CMTimeMakeWithSeconds(audioOut, audioAsset.duration.timescale);
        
        CMTimeRange audioTimeRange = CMTimeRangeMake(startTime, videoDuration);
        
        //音频采集compositionCommentaryTrack
        AVMutableCompositionTrack *compositionAudioTrack = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        NSError *error = nil;
        NSArray *audioTracks = [audioAsset tracksWithMediaType:AVMediaTypeAudio];
        AVAssetTrack *audioTrack = audioTracks.count > 0 ? audioTracks.firstObject : nil;
        BOOL is = [compositionAudioTrack insertTimeRange:audioTimeRange ofTrack:audioTrack atTime:kCMTimeZero error:&error];
        if (!is) {
            NSLog(@"audio insert error : %@",error);
        }
    }
}

- (AVAsset *)getTimeAsset {
    return self.mixComposition;
}

- (AVMutableVideoComposition *)videoComposition {
    AVMutableVideoComposition *composition = [FSCompoundTool getVideoComposition:self.videoAsset];
    return composition;
}

// 获取某个时间点的视频帧
- (UIImage *)getImageWithTime:(CMTime)time {
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.mixComposition];
    imageGenerator.videoComposition = [self videoComposition];
    imageGenerator.maximumSize = CGSizeMake(200, 0);//按比例生成， 不指定会默认视频原来的格式大小
    CMTime actualTime;//获取到图片确切的时间
    NSError *error = nil;
    CGImageRef CGImage = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if (!error) {
        
        UIImage *image = [UIImage imageWithCGImage:CGImage];
        CMTimeShow(actualTime);   //{111600/90000 = 1.240}
        CMTimeShow(time); // {1/1 = 1.000}
        
        return image;
    }
    return nil;
}

- (void)getThumbnailArrayMaxDuration:(int64_t)maxDuration width:(CGFloat)width block:(FSArrayBlock)block {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        int64_t tmpDuration = self.duration;
        if (self.duration > maxDuration) {
            tmpDuration = maxDuration;
        }
        // 每微妙多大UI宽
        CGFloat usecWidth = width/(CGFloat)tmpDuration;
        // 整个视频的UI宽
        CGFloat allWidth = self.duration*usecWidth;
        // 每一帧50的宽度
        CGFloat frameWidth = 50.0f;
        // 总图片数
        CGFloat imageCount = ceil(allWidth/frameWidth);
        // 每帧的微妙数
        int64_t frameUsec = self.duration/imageCount;
        int64_t usec = frameUsec;
        CGFloat x = 0;
        while (usec < self.duration) {
            CMTime time = CMTimeMake((int64_t)(usec), FS_TIME_BASE);
            UIImage *image = [self getImageWithTime:time];
            if (image) {
                FSVideoThumbnailModel *model = [FSVideoThumbnailModel new];
                model.thumbnailImage = image;
                if (x+frameWidth <= allWidth) {
                    model.size = CGSizeMake(frameWidth, 0);
                }else {
                    model.size = CGSizeMake(allWidth-x, 0);
                }
                [array addObject:model];
                if (array.count == 15) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) {
                            block(array);
                        }
                    });
                }
            }
            x += frameWidth;
            usec += frameUsec;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(array);
            }
        });
    });
}

@end
