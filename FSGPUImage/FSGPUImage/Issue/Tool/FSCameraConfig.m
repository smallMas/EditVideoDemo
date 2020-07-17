//
//  FSCameraConfig.m
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/14.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "FSCameraConfig.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface FSCameraConfig ()
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
// 必须在这里声明，要不不会回调block
@property (nonatomic, strong) CTCallCenter *callCenter;
#pragma clang diagnostic pop

@end

@implementation FSCameraConfig

+ (void)load {
    [FSCameraConfig shareInstance];
}

+ (instancetype)shareInstance {
    static FSCameraConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [FSCameraConfig new];
    });
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self receiveCall];
    }
    return self;
}

#pragma mark - 监听系统电话
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
- (void)receiveCall {
    DN_WEAK_SELF
    self.callCenter = [[CTCallCenter alloc] init];
    self.callCenter.callEventHandler = ^(CTCall * call) {
        DN_STRONG_SELF
        if([call.callState isEqualToString:CTCallStateDisconnected]) {
            NSLog(@"Call has been disconnected");//电话被挂断(我们用的这个)
            self.isSystemCall = NO;
        } else if([call.callState isEqualToString:CTCallStateConnected]) {
            NSLog(@"Call has been connected");//电话被接听
        } else if([call.callState isEqualToString:CTCallStateIncoming]) {
            NSLog(@"Call is incoming");//来电话了
            self.isSystemCall = YES;
        } else if([call.callState isEqualToString:CTCallStateDialing]) {
            NSLog(@"Call is Dialing");//拨号
            self.isSystemCall = YES;
        } else {
            NSLog(@"Nothing is done");
        }
    };
}
#pragma clang diagnostic pop

@end
