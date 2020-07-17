//
//  DNLiveWindow.h
//  DnaerApp
//
//  Created by 燕来秋 on 2020/7/7.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DNLiveWindowDelegate <NSObject>

@optional
- (void)live_didTakeImage:(UIImage *)image;
- (void)live_didFinishRecordOutPutFileURL:(NSURL *)outputFileURL error:(NSError *)error;

@end

@interface DNLiveWindow : UIView
@property (nonatomic, weak) id <DNLiveWindowDelegate> delegate;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) CGFloat maxSeconds; // 录制最大时间

// 拍照
- (void)takePicture;
// 录制视频
- (void)startRecordFileURL:(NSURL *)URL;
// 停止录制
- (void)endRecord;
// 切换摄像头
- (void)changeCamera;
// 切换闪光灯
- (void)switchFlash;

@end

NS_ASSUME_NONNULL_END
