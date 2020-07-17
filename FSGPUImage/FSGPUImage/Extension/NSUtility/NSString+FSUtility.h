//
//  NSString+FSUtility.h
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/15.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (FSUtility)

- (NSString *)MD5_32;

#pragma mark - json转换
/*! 字符串转json对象 dictionary/array */
- (id)toJsonObject;

@end

NS_ASSUME_NONNULL_END
