//
//  FSRecordingInfo.h
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/14.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSRecordingInfo : NSObject
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) NSURL *recordingURL;

@property (nonatomic, assign) int64_t trimIn;
@property (nonatomic, assign) int64_t trimOut;
@end

NS_ASSUME_NONNULL_END
