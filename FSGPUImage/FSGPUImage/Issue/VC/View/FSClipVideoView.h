//
//  FSClipVideoView.h
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/16.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSTimeLine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FSClipVideoViewDelegate <NSObject>

@optional
// 变化 微秒
- (void)changeStartPosition:(int64_t)startPosition endPosition:(int64_t)endPosition;
// scollview拖动结束
- (void)dragScrollTimelineEnded:(int64_t)timestamp;
// 开始播放
- (void)startPlay;
// 继续播放
- (void)contPlay;
// 暂停播放
- (void)stopPlay;
// 拖拽进度 0-1
- (void)dragProgress:(CGFloat)progress;

@end

@interface FSClipVideoView : UIView

@property (nonatomic, weak) id <FSClipVideoViewDelegate> delegate;

- (void)configTimeline:(FSTimeLine *)timeline;
// 时间
- (void)playPosition:(int64_t)position;

@end

NS_ASSUME_NONNULL_END
