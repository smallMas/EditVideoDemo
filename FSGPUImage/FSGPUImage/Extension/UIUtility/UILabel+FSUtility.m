//
//  UILabel+FSUtility.m
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/16.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "UILabel+FSUtility.h"

@implementation UILabel (FSUtility)

#pragma mark - 快捷创建方法
+ (UILabel *)createFrame:(CGRect)frame font:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = font;
    label.textColor = color;
    return label;
}

+ (UILabel *)createFrame:(CGRect)frame font:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment {
    UILabel *label = [self createFrame:frame font:font color:color];
    label.textAlignment = alignment;
    return label;
}

+ (UILabel *)createFont:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = color;
    return label;
}

+ (UILabel *)createFont:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment {
    UILabel *label = [self createFont:font color:color];
    label.textAlignment = alignment;
    return label;
}

@end
