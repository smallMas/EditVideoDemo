//
//  UIView+FSUtility.m
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/14.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "UIView+FSUtility.h"

@implementation UIView (FSUtility)

- (void)setRoundRadius:(float)radius borderColor:(UIColor *)bColor {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = radius;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [bColor CGColor];
}

- (void)setRoundRadius:(float)radius borderColor:(UIColor *)bColor board:(CGFloat)board {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = radius;
    self.layer.borderWidth = board;
    self.layer.borderColor = [bColor CGColor];
}


@end
