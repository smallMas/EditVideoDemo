//
//  UIColor+FSUtility.h
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/14.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (FSUtility)

/*! 16进制生成Color对象 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;
/* !16进制、alpha 生成Color对象*/
+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

/*! 随机颜色 */
+ (UIColor *)randomColor;
@end

NS_ASSUME_NONNULL_END
