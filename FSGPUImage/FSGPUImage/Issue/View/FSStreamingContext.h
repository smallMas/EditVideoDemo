//
//  FSStreamingContext.h
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/15.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSTimeLine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FSStreamingContextDelegate <NSObject>

@optional
- (void)didPlaybackTimelinePosition:(FSTimeLine *)timeline position:(int64_t)position;
- (void)didPlaybackStopped:(FSTimeLine *)timeline;
- (void)didPlaybackEOF:(FSTimeLine *)timeline;

@end

@interface FSStreamingContext : NSObject

@property (nonatomic, weak) id <FSStreamingContextDelegate> delegate;

- (BOOL)connectionTimeLine:(FSTimeLine *)timeline playerView:(UIView *)view;

- (int64_t)getTimelineCurrentPosition;

- (void)seekToTime:(int64_t)time;
// 微妙
- (void)playStartTime:(int64_t)startTime endTime:(int64_t)endTime;
- (void)stop;

// 合成视频
- (void)compileVideoOutPutPath:(NSString *)outPutPath block:(FSSuccessDataBlock)block;

@end

NS_ASSUME_NONNULL_END
