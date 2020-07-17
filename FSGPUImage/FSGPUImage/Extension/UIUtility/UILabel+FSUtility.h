//
//  UILabel+FSUtility.h
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/16.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (FSUtility)

#pragma mark - 快捷创建方法
+ (UILabel *)createFrame:(CGRect)frame font:(UIFont *)font color:(UIColor *)color;
+ (UILabel *)createFrame:(CGRect)frame font:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment;
+ (UILabel *)createFont:(UIFont *)font color:(UIColor *)color;
+ (UILabel *)createFont:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment;

@end

NS_ASSUME_NONNULL_END
