//
//  FSCameraConfig.h
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/14.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSTimeLine.h"

#define FSMaxClipTime 30*FS_TIME_BASE
#define FSMinTime 3*FS_TIME_BASE

NS_ASSUME_NONNULL_BEGIN

@interface FSCameraConfig : NSObject
@property (nonatomic, assign) BOOL isSystemCall; // 是否系统电话通话中
+ (instancetype)shareInstance;
@end

NS_ASSUME_NONNULL_END
