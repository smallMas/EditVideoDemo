//
//  UIButton+FSUtility.h
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/15.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (FSUtility)

// mas 创建
+ (UIButton *)createWithType:(UIButtonType)type target:(id)target action:(SEL)action;

// frame 创建
+ (UIButton *)createWithFrame:(CGRect)frame type:(UIButtonType)type target:(id)target action:(SEL)action;
@end

NS_ASSUME_NONNULL_END
