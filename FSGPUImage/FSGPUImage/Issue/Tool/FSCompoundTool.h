//
//  FSCompoundTool.h
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/14.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSCompoundTool : NSObject

/*! 生成一个UUID */
+ (NSString*)uuid;

/**
 添加音频

 @param videoUrl 视频url
 @param audioUrl 音频url
 @param needVoice 是否需要保留原音
 @param videoRange 视频的开始时间和时长 （设置和用法如下） 取秒
      CGFloat ff1 = [self getMediaSecondWithMediaURL:vpath];
      NSMakeRange(0.0, ff1)
 @param outPutPath 合成后的路径
 @param completionHandle 回调
 */
+ (void)addBackgroundMiusicWithVideoUrlStr:(NSURL *)videoUrl
                                  audioUrl:(NSURL *)audioUrl
                                 needVoice:(BOOL)needVoice
                  andCaptureVideoWithRange:(NSRange)videoRange
                                outPutPath:(NSString *)outPutPath
                                completion:(FSComplete)completionHandle;

/**
 根据视频路径获取视频时长 秒

 @param mediaPath 本地路径
 @return 返回时长
 */
+ (CGFloat)getMediaSecondWithMediaPath:(NSString *)mediaPath;
+ (CGFloat)getMediaSecondWithMediaURL:(NSURL *)mediaUrl;

/**
根据视频路径获取视频时长 微妙

@param mediaPath 本地路径
@return 返回时长
*/
+ (CGFloat)getMediaDurationWithMediaURL:(NSURL *)mediaUrl;

// 获取视频方向信息
+ (AVMutableVideoComposition *)getVideoComposition:(AVAsset *)asset;

@end

NS_ASSUME_NONNULL_END
