//
//  FSClipVideoController.m
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/16.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "FSClipVideoController.h"
#import "FSStreamingContext.h"
#import "FSTimeLine.h"
#import "FSClipVideoView.h"
#import "FSEditVideoController.h"

@interface FSClipVideoController () <FSClipVideoViewDelegate>

// 关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UILabel *secondLabel;

@property (nonatomic, strong) FSStreamingContext *streamingContext;
@property (nonatomic, strong) FSTimeLine *timeline;
@property (nonatomic, strong) FSClipVideoView *clipView;

@property (nonatomic, assign) int64_t start;
@property (nonatomic, assign) int64_t end;

@end

@implementation FSClipVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
    [self layoutUI];
    [self initStreaming];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self stop];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self replay];
}

- (void)setupView {
    [self.playerView setBackgroundColor:[UIColor randomColor]];
    [self.view addSubview:self.playerView];
    [self.view addSubview:self.nextBtn];
    [self.view addSubview:self.closeBtn];
    [self.view addSubview:self.clipView];
}

- (void)layoutUI {
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.top.mas_equalTo(45);
        make.width.height.mas_equalTo(44);
    }];
    
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view).inset(20);
        make.centerY.mas_equalTo(self.closeBtn);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(30);
    }];
    
    [self.clipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(100);
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).inset(50);
    }];
}

- (void)initStreaming {
    int64_t duration = [FSCompoundTool getMediaDurationWithMediaURL:self.recordingInfo.recordingURL];
    NSLog(@"duration >>>> %lld",duration);
    [self.timeline appendVideoClip:self.recordingInfo.recordingURL.path trimIn:0 trimOut:duration];
    
    // 连接
    [self.streamingContext connectionTimeLine:self.timeline playerView:self.playerView];
    
    // 配置缩略图
    [self.clipView configTimeline:self.timeline];
    
    self.start = 0;
    self.end = self.timeline.duration;
    if (self.timeline.duration > FSMaxClipTime) {
        self.end = FSMaxClipTime;
    }
}

#pragma mark - 懒加载
- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton createWithType:UIButtonTypeCustom target:self action:@selector(closeAction:)];
        [_closeBtn setImage:[UIImage imageNamed:@"pb_icon_close"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton createWithType:UIButtonTypeCustom target:self action:@selector(nextAction:)];
        [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextBtn setBackgroundColor:COLHEX(@"#FF5757")];
        [_nextBtn setRoundRadius:3 borderColor:[UIColor clearColor]];
    }
    return _nextBtn;
}

- (UILabel *)secondLabel {
    if (!_secondLabel) {
        _secondLabel = [UILabel createFont:[UIFont systemFontOfSize:13] color:COLHEXA(@"#FFFFFF", 0.5)];
    }
    return _secondLabel;
}

- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    return _playerView;
}

- (FSClipVideoView *)clipView {
    if (!_clipView) {
        _clipView = [FSClipVideoView new];
        _clipView.delegate = (id <FSClipVideoViewDelegate>)self;
    }
    return _clipView;
}

- (FSStreamingContext *)streamingContext {
    if (!_streamingContext) {
        _streamingContext = [[FSStreamingContext alloc] init];
        _streamingContext.delegate = (id <FSStreamingContextDelegate>) self;
    }
    return _streamingContext;
}

- (FSTimeLine *)timeline {
    if (!_timeline) {
        _timeline = [[FSTimeLine alloc] init];
    }
    return _timeline;
}

#pragma mark - btn action
- (void)closeAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextAction:(id)sender {
    [self stop];
    
    NSLog(@"self.start >>> %lld  self.end >>> %lld all >>> %lld",self.start,self.end,self.timeline.duration);
    self.recordingInfo.trimIn = self.start;
    self.recordingInfo.trimOut = self.end;
    
    FSEditVideoController *vc = [FSEditVideoController new];
    vc.recordingInfo = self.recordingInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 内部方法
- (void)continuePlay {
    [self.streamingContext playStartTime:[self.streamingContext getTimelineCurrentPosition] endTime:self.end];
}

- (void)replay {
    NSLog(@"重新开始播放 self.start : %lld self.end : %lld",self.start,self.end);
    [self.streamingContext playStartTime:self.start endTime:self.end];
}

- (void)stop {
    [self.streamingContext stop];
}

- (void)seekTimelinePosition:(int64_t)position {
    [self.streamingContext seekToTime:position];
}

- (void)showSecondValue:(CGFloat)value {
    [self.secondLabel setText:[NSString stringWithFormat:@"已选取 %.1fs",value]];
}

#pragma mark - FSStreamingContextDelegate
- (void)didPlaybackTimelinePosition:(FSTimeLine *)timeline position:(int64_t)position {
    [self.clipView playPosition:position];
}

- (void)didPlaybackStopped:(FSTimeLine *)timeline {
    
}

- (void)didPlaybackEOF:(FSTimeLine *)timeline {
    [self replay];
}

#pragma mark - FSClipVideoViewDelegate
// 变化 微秒
- (void)changeStartPosition:(int64_t)startPosition endPosition:(int64_t)endPosition {
    self.start = startPosition;
    self.end = endPosition;
    
    [self showSecondValue:(endPosition-startPosition)/FS_TIME_BASE];
}

// scollview拖动结束
- (void)dragScrollTimelineEnded:(int64_t)timestamp {
    [self seekTimelinePosition:timestamp];
    [self continuePlay];
}

// 开始播放
- (void)startPlay {
    [self replay];
}

// 继续播放
- (void)contPlay {
    [self continuePlay];
}

// 暂停播放
- (void)stopPlay {
    [self stop];
}

// 拖拽进度 0-1
- (void)dragProgress:(CGFloat)progress {
    CGFloat position = self.timeline.duration*progress;
    [self seekTimelinePosition:position];
//    [self continuePlay];
}

@end
