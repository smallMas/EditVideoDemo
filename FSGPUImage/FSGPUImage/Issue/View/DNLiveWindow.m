//
//  DNLiveWindow.m
//  DnaerApp
//
//  Created by 燕来秋 on 2020/7/7.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "DNLiveWindow.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "FSCameraConfig.h"

@interface DNLiveWindow ()

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic, assign) AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property (nonatomic, strong) AVCaptureDeviceInput *input;

//音频轨道
@property (nonatomic, strong) AVCaptureDeviceInput *audioCaptureDeviceInput;

//照片输出流
@property (nonatomic, strong) AVCaptureStillImageOutput *ImageOutPut;

//视频输出流
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutput;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic, strong) AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;


@end

@implementation DNLiveWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self initNotification];
    [self customCamera];
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCaptureSessionWasInterruptedNotification:) name:AVCaptureSessionWasInterruptedNotification object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCaptureSessionInterruptionEndedNotification:) name:AVCaptureSessionInterruptionEndedNotification object:self.session];
}

- (void)AVCaptureSessionWasInterruptedNotification:(NSNotification *)notification {
    AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
    NSLog(@"fanshijian 中断 : %d reason : %ld",self.session.interrupted,(long)reason);
    if (reason == AVCaptureSessionInterruptionReasonAudioDeviceInUseByAnotherClient) {
        [self removeAudioInput];
    }
}

- (void)AVCaptureSessionInterruptionEndedNotification:(NSNotification *)notification {
    NSLog(@"fanshijian 中断结束 : %d",self.session.interrupted);
    if (![FSCameraConfig shareInstance].isSystemCall) {
        [self addAudioInput];
    }
}

- (void)addVideoInput {
    if (!_input) {
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
}

- (void)addAudioInput {
    if (!_audioCaptureDeviceInput) {
        //添加一个音频输入设备
        AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        //添加音频
        NSError *error = nil;
        AVCaptureDeviceInput *audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
        if (error) {
            NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
            return;
        }
        self.audioCaptureDeviceInput = audioCaptureDeviceInput;
    }
    
    if ([self.session canAddInput:self.audioCaptureDeviceInput]) {
        [self.session addInput:self.audioCaptureDeviceInput];
    }
}

- (void)removeAudioInput {
    [self.session removeInput:self.audioCaptureDeviceInput];
}

- (void)addDNImageOutPut {
    if (!_ImageOutPut) {
        _ImageOutPut = [[AVCaptureStillImageOutput alloc]init];
    }
    if ([self.session canAddOutput:self.ImageOutPut]) {
        [self.session addOutput:self.ImageOutPut];
    }
}

- (void)addMovieFileOutput {
    if (!_captureMovieFileOutput) {
        _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];//视频输出
    }
    
    //将输出设备添加到会话 (刚开始 是照片为输出对象)
    if ([self.session canAddOutput:self.captureMovieFileOutput]) {
        [self.session addOutput:self.captureMovieFileOutput];
        
        //设置视频防抖
        AVCaptureConnection *connection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoStabilizationSupported]) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
        }
    }
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc]init];
    }
    return _session;
}

- (void)customCamera {
    [self addVideoInput];
    [self addAudioInput];
    [self addDNImageOutPut];
    [self addMovieFileOutput];
    
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
//    CGRect screenRect = CGRectMake(0, 0, self.view.vt_w, self.view.vt_h);
//    CGFloat ratio = 16.0/9.0;
//    CGFloat width = self.view.vt_w;
//    CGFloat height = width*ratio;
//    CGFloat y = (screenRect.size.height-height)/2.0f;
//    CGRect previewRect = CGRectMake(0, y, width, height);
    CGRect previewRect = self.bounds;
    self.previewLayer.frame = previewRect;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:self.previewLayer];
    
    //开始启动
    [self.session startRunning];
    
    //修改设备的属性，先加锁
    if ([self.device lockForConfiguration:nil]) {
        
        //闪光灯自动
        if ([self.device isFlashModeSupported:AVCaptureFlashModeOn]) {
            [self.device setFlashMode:AVCaptureFlashModeOn];
        }
        
        //自动白平衡
        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        
        //解锁
        [self.device unlockForConfiguration];
    }
}

// 切换摄像头
- (void)changeCamera {
    //获取摄像头的数量
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    //摄像头小于等于1的时候直接返回
    if (cameraCount <= 1) return;
    
    AVCaptureDevice *newCamera = nil;
    AVCaptureDeviceInput *newInput = nil;
    //获取当前相机的方向(前还是后)
    AVCaptureDevicePosition position = [[self.input device] position];
    
    //为摄像头的转换加转场动画
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = 0.5;
    animation.type = @"oglFlip";
    
    if (position == AVCaptureDevicePositionFront) {
        //获取后置摄像头
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        animation.subtype = kCATransitionFromLeft;
    }else{
        //获取前置摄像头
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        animation.subtype = kCATransitionFromRight;
    }
    
    [self.previewLayer addAnimation:animation forKey:nil];
    //输入流
    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
    
    
    if (newInput != nil) {
        
        [self.session beginConfiguration];
        //先移除原来的input
        [self.session removeInput:self.input];
        
        if ([self.session canAddInput:newInput]) {
            [self.session addInput:newInput];
            self.input = newInput;
            
        } else {
            //如果不能加现在的input，就加原来的input
            [self.session addInput:self.input];
        }
        
        [self.session commitConfiguration];
    }
}

- (void)switchFlash {
    NSError *error;
    if (self.device.hasTorch) {  // 判断设备是否有闪光灯
        BOOL b = [self.device lockForConfiguration:&error];
        if (!b) {
            if (error) {
                NSLog(@"lock torch configuration error:%@", error.localizedDescription);
            }
            return;
        }
        self.device.torchMode = (self.device.torchMode == AVCaptureTorchModeOff ? AVCaptureTorchModeOn : AVCaptureTorchModeOff);
        [self.device unlockForConfiguration];
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}

- (void)takePicture {
    AVCaptureConnection *myVideoConnection = nil;
    
    //从 AVCaptureStillImageOutput 中取得正确类型的 AVCaptureConnection
    for (AVCaptureConnection *connection in self.ImageOutPut.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                
                myVideoConnection = connection;
                break;
            }
        }
    }
    
    //撷取影像（包含拍照音效）
    [self.ImageOutPut captureStillImageAsynchronouslyFromConnection:myVideoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSLog(@"拍照 Error : %@",error);
        //完成撷取时的处理程序(Block)
        if (imageDataSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            
            //取得的静态影像
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            
            UIImageOrientation imgOrientation; //拍摄后获取的的图像方向
            if ([self.input device].position == AVCaptureDevicePositionFront) {
                NSLog(@"前置摄像头");
                // 前置摄像头图像方向 UIImageOrientationLeftMirrored
                // IOS前置摄像头左右成像
                imgOrientation = UIImageOrientationLeftMirrored;
                image = [[UIImage alloc]initWithCGImage:image.CGImage scale:1.0f orientation:imgOrientation];
            }
            
            // 矫正方向
            image = [image fixOrientation];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(live_didTakeImage:)]) {
                [self.delegate live_didTakeImage:image];
            }
        }
    }];
}

- (void)startRecordFileURL:(NSURL *)URL {
    NSLog(@"%s",__FUNCTION__);
    if (URL) {
        AVCaptureConnection *connection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeAudio];
        //根据连接取得设备输出的数据
        if (![self.captureMovieFileOutput isRecording]) {
            //如果支持多任务则开始多任务
            
            //预览图层和视频方向保持一致
            connection.videoOrientation = [self.previewLayer connection].videoOrientation;
            NSURL *fileUrl = URL;
            [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:(id <AVCaptureFileOutputRecordingDelegate>)self];
        }
    }else {
        NSLog(@"录制视频 路径为空");
    }
}

- (void)endRecord {
    NSLog(@"%s",__FUNCTION__);
    [self.captureMovieFileOutput stopRecording];//停止录制
}

- (void)progressValue {
//    self.currentTime += 0.1;
//
//    CGFloat progress = 1;
//    if (self.currentTime >= self.allTime) {
//        [self.recordButton stopAnimation];
//        [self endRecord];
//    }else {
//        progress = (CGFloat)self.currentTime/self.allTime;
//    }
//    [self.recordButton progressValue:progress];
//
//    if (progress != 1 && self.isRecording == YES) {
//        [self performSelector:@selector(progressValue) withObject:nil afterDelay:0.1];
//    }
    
//    NSLog(@"%s : %lld  %d",__FUNCTION__,self.captureMovieFileOutput.movieFragmentInterval.value,self.captureMovieFileOutput.movieFragmentInterval.timescale);
//    if ([self.captureMovieFileOutput isRecording]) {
//        [self performSelector:@selector(progressValue) withObject:nil afterDelay:0.1];
//    }
}

- (BOOL)isRecording {
    return [self.captureMovieFileOutput isRecording];
}

- (void)setMaxSeconds:(CGFloat)maxSeconds {
    _maxSeconds = maxSeconds;
    if (maxSeconds > 0) {
        if (self.captureMovieFileOutput) {
            self.captureMovieFileOutput.maxRecordedDuration = CMTimeMakeWithSeconds(maxSeconds, 30);
        }
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"开始录制");
//    [self performSelector:@selector(progressValue) withObject:nil afterDelay:0.2];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"录制结束 error : %@",error);
    if (self.delegate && [self.delegate respondsToSelector:@selector(live_didFinishRecordOutPutFileURL:error:)]) {
        [self.delegate live_didFinishRecordOutPutFileURL:outputFileURL error:error];
    }
}

@end
