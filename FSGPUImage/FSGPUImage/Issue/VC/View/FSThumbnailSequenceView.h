//
//  FSThumbnailSequenceView.h
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/16.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSTimeLine.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSThumbnailSequenceView : UIView

@property (nonatomic, assign) CGFloat startPadding;
@property (nonatomic, assign) CGFloat endPadding;

- (void)addScrollViewDelegate:(id)delegate;
- (void)removeScrollViewDelegate:(id)delegate;

- (void)configTimeline:(FSTimeLine *)timeline maxDuration:(int64_t)max block:(FSComplete)block;

- (int64_t)mapTimelinePosFromX:(CGFloat)x;

@end

NS_ASSUME_NONNULL_END
