//
//  FSCompoundTool.m
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/14.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "FSCompoundTool.h"

@implementation FSCompoundTool

+ (NSString*)uuid {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

/**
 添加音频

 @param videoUrl 视频url
 @param audioUrl 音频url
 @param needVoice 是否需要保留原音
 @param videoRange 视频的开始时间和时长 （设置和用法如下）
      CGFloat ff1 = [self getMediaSecondWithMediaUrl:vpath];
      NSMakeRange(0.0, ff1)
 @param outPutPath 合成后的路径
 @param completionHandle 回调
 */
+ (void)addBackgroundMiusicWithVideoUrlStr:(NSURL *)videoUrl
                                  audioUrl:(NSURL *)audioUrl
                                 needVoice:(BOOL)needVoice
                  andCaptureVideoWithRange:(NSRange)videoRange
                                outPutPath:(NSString *)outPutPath
                                completion:(FSComplete)completionHandle {
    //AVURLAsset此类主要用于获取媒体信息，包括视频、声音等
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    
    //创建AVMutableComposition对象来添加视频音频资源的AVMutableCompositionTrack
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //CMTimeRangeMake(start, duration),start起始时间，duration时长，都是CMTime类型
    //CMTimeMake(int64_t value, int32_t timescale)，返回CMTime，value视频的一个总帧数，timescale是指每秒视频播放的帧数，视频播放速率，（value / timescale）才是视频实际的秒数时长，timescale一般情况下不改变，截取视频长度通过改变value的值
    //CMTimeMakeWithSeconds(Float64 seconds, int32_t preferredTimeScale)，返回CMTime，seconds截取时长（单位秒），preferredTimeScale每秒帧数
    
    //开始位置startTime
    CMTime startTime = CMTimeMakeWithSeconds(videoRange.location, videoAsset.duration.timescale);
    //截取长度videoDuration
    CMTime videoDuration = CMTimeMakeWithSeconds(videoRange.length, videoAsset.duration.timescale);
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(startTime, videoDuration);
    
    //视频采集compositionVideoTrack
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //TimeRange截取的范围长度
    //ofTrack来源
    //atTime插放在视频的时间位置
    [compositionVideoTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeVideo].count>0) ? [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject : nil atTime:kCMTimeZero error:nil];
    
    if (needVoice) {
        //视频声音采集(也可不执行这段代码不采集视频音轨，合并后的视频文件将没有视频原来的声音)
        AVMutableCompositionTrack *compositionVoiceTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [compositionVoiceTrack insertTimeRange:videoTimeRange
                                       ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeAudio].count>0)?[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject:nil
                                        atTime:kCMTimeZero error:nil];
    }
    
    //声音长度截取范围==视频长度
    CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, videoDuration);
    
    //音频采集compositionCommentaryTrack
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionAudioTrack insertTimeRange:audioTimeRange ofTrack:([audioAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil atTime:kCMTimeZero error:nil];
    
    //AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];//AVAssetExportPreset640x480
    
    // fansj 识别方向
    AVMutableVideoComposition *avMutableVideoComposition = [self getVideoComposition:videoAsset];
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
        
        completionHandle();
    }];
}

+ (AVMutableVideoComposition *)getVideoComposition:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    CGSize videoSize = videoTrack.naturalSize;
    BOOL isPortrait_ = [self isVideoPortrait:asset];
    if(isPortrait_) {
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    }
    composition.naturalSize     = videoSize;
    videoComposition.renderSize = videoSize;
    
    videoComposition.frameDuration = CMTimeMakeWithSeconds( 1 / videoTrack.nominalFrameRate, 600);
    AVMutableCompositionTrack *compositionVideoTrack;
    compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    AVMutableVideoCompositionLayerInstruction *layerInst;
    layerInst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [layerInst setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
    AVMutableVideoCompositionInstruction *inst = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    inst.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    inst.layerInstructions = [NSArray arrayWithObject:layerInst];
    videoComposition.instructions = [NSArray arrayWithObject:inst];
    return videoComposition;
}

+ (BOOL)isVideoPortrait:(AVAsset *)asset {
    BOOL isPortrait = NO;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks    count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        CGAffineTransform t = videoTrack.preferredTransform;
        // Portrait
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
        {
            isPortrait = YES;
        }
        // PortraitUpsideDown
        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
            
            isPortrait = YES;
        }
        // LandscapeRight
        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
        {
            isPortrait = NO;
        }
        // LandscapeLeft
        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
        {
            isPortrait = NO;
        }
    }
    return isPortrait;
}

/**
 根据视频路径获取视频时长 秒

 @param mediaPath 本地路径
 @return 返回时长
 */
+ (CGFloat)getMediaSecondWithMediaPath:(NSString *)mediaPath {
    NSURL *mediaUrl = [NSURL fileURLWithPath:mediaPath];
    return [self getMediaSecondWithMediaURL:mediaUrl];
}

/**
根据视频路径获取视频时长 秒

@param mediaUrl 本地路径URL
@return 返回时长
*/
+ (CGFloat)getMediaSecondWithMediaURL:(NSURL *)mediaUrl {
    AVURLAsset *mediaAsset = [[AVURLAsset alloc] initWithURL:mediaUrl options:nil];
    CMTime duration = mediaAsset.duration;
    
    return (CGFloat)duration.value / (CGFloat)duration.timescale;
}


/**
根据视频路径获取视频时长 微妙

@param mediaUrl 本地路径URL
@return 返回时长
*/
+ (CGFloat)getMediaDurationWithMediaURL:(NSURL *)mediaUrl {
    AVURLAsset *mediaAsset = [[AVURLAsset alloc] initWithURL:mediaUrl options:nil];
    CMTime duration = mediaAsset.duration;
    
    CGFloat second = (CGFloat)duration.value / (CGFloat)duration.timescale;
    return second * FS_TIME_BASE;
}


@end
