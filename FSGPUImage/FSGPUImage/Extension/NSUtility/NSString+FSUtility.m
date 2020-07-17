//
//  NSString+FSUtility.m
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/15.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "NSString+FSUtility.h"
#import "CommonCrypto/CommonDigest.h"
#import <CommonCrypto/CommonCryptor.h>  //DES 加密

@implementation NSString (FSUtility)

/*!
 *  获取字符串的MD5编码 32位
 *
 *  @return MD5编码
 */
- (NSString *)MD5_32 {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

- (id)toJsonObject {
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
}

@end
