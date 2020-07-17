//
//  UIButton+FSUtility.m
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/15.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "UIButton+FSUtility.h"

@implementation UIButton (FSUtility)
+ (UIButton *)createWithType:(UIButtonType)type target:(id)target action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:type];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

+ (UIButton *)createWithFrame:(CGRect)frame type:(UIButtonType)type target:(id)target action:(SEL)action {
    UIButton *btn = [self createWithType:type target:target action:action];
    return btn;
}
@end
