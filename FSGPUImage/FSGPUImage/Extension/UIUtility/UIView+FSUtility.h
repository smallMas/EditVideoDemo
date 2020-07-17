//
//  UIView+FSUtility.h
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/14.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (FSUtility)


/*! layer设置圆角 */
- (void)setRoundRadius:(float)radius borderColor:(UIColor *)bColor;
- (void)setRoundRadius:(float)radius borderColor:(UIColor *)bColor board:(CGFloat)board;

@end

NS_ASSUME_NONNULL_END
