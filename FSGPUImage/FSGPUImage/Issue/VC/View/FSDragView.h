//
//  FSDragView.h
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/16.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FSDragViewDelegate <NSObject>

@optional
- (void)didDragBegin;
- (void)didDragPositionX:(CGFloat)x;
- (void)didDragEnd;

@end

@interface FSDragView : UIView
@property (nonatomic, weak) id <FSDragViewDelegate> delegate;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIColor *dragLineColor;
@property (nonatomic, assign) CGFloat lineWidth;
// 当前位置 0-1
@property (nonatomic, assign) CGFloat currentLocation;

@property (nonatomic, assign, readonly) CGFloat half;
@end

NS_ASSUME_NONNULL_END
