//
//  FSClipVideoView.m
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/16.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "FSClipVideoView.h"
#import "FSVideoThumbnailModel.h"
#import "FSDragView.h"
#import "FSThumbnailSequenceView.h"

@interface FSClipVideoView () <FSDragViewDelegate> {
    CGFloat marginLR;
    // left right宽度
    CGFloat lrWidth;
    // top bottom高度
    CGFloat tbHeight;
    // 最大秒数(15秒)单位微秒
    CGFloat maxSecond;
    // 最小秒数(3秒)单位微秒
    CGFloat minSecond;
    // 1s的长度距离
    CGFloat everyLength;
    CGFloat dragW;
}

@property (nonatomic, strong) FSThumbnailSequenceView *sequnceView;

@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIImageView *leftImgView;
@property (nonatomic, strong) UIImageView *rightImgView;
@property (nonatomic, strong) FSDragView *dragView;

@property (nonatomic, assign) int64_t duration;

@end

@implementation FSClipVideoView

- (void)dealloc
{
    [self.sequnceView removeScrollViewDelegate:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self setup];
        [self layoutUI];
    }
    return self;
}

- (void)initData {
    marginLR = 40;
    lrWidth = 10;
    tbHeight = 2;
    maxSecond = FSMaxClipTime;
    minSecond = FSMinTime;
    dragW = 24;
}

- (void)setup {
    NSLog(@"%s",__FUNCTION__);
    self.sequnceView.startPadding = marginLR;
    self.sequnceView.endPadding = marginLR;
    [self addSubview:self.sequnceView];
    
    _topView = [self createView];
    [self addSubview:self.topView];
    
    _bottomView = [self createView];
    [self addSubview:self.bottomView];
    
    _leftView = [self createView];
    [self addSubview:self.leftView];

    _rightView = [self createView];
    [self addSubview:self.rightView];
    
    _leftImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pb_icon_drag"]];
    [self.leftView addSubview:self.leftImgView];
    
    _rightImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pb_icon_drag"]];
    [self.rightView addSubview:self.rightImgView];
}

- (void)layoutUI {
    NSLog(@"%s",__FUNCTION__);
    [self.sequnceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(70);
        make.centerY.mas_equalTo(self);
    }];
    
    [self addSubview:self.dragView];
    [self.dragView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.left.mas_equalTo(marginLR-(dragW-self.dragView.lineWidth)/2.0);
        make.width.mas_equalTo(dragW);
    }];
    
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).inset(marginLR-lrWidth);
        make.width.mas_equalTo(lrWidth);
        make.height.mas_equalTo(70);
        make.centerY.mas_equalTo(self.sequnceView);
    }];
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).inset(marginLR-lrWidth);
        make.width.mas_equalTo(lrWidth);
        make.height.mas_equalTo(70);
        make.centerY.mas_equalTo(self.sequnceView);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sequnceView.mas_top);
        make.height.mas_equalTo(tbHeight);
        make.left.mas_equalTo(self.leftView).inset(lrWidth/2.0);
        make.right.mas_equalTo(self.rightView).inset(lrWidth/2.0);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.sequnceView.mas_bottom);
        make.height.mas_equalTo(tbHeight);
        make.left.mas_equalTo(self.leftView).inset(lrWidth/2.0);
        make.right.mas_equalTo(self.rightView).inset(lrWidth/2.0);
    }];
    
    [self.leftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(7);
        make.height.mas_equalTo(22);
        make.centerX.mas_equalTo(self.leftView);
        make.centerY.mas_equalTo(self.leftView);
    }];
    
    [self.rightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(7);
        make.height.mas_equalTo(22);
        make.centerX.mas_equalTo(self.rightView);
        make.centerY.mas_equalTo(self.rightView);
    }];
    
    [self.leftView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftGestureRecognize:)]];
    [self.rightView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightGestureRecognize:)]];
}

#pragma mark - 懒加载
- (FSThumbnailSequenceView *)sequnceView {
    if (!_sequnceView) {
        _sequnceView = [FSThumbnailSequenceView new];
        [_sequnceView addScrollViewDelegate:(id <CHGScrollViewDelegate>)self];
    }
    return _sequnceView;
}

- (FSDragView *)dragView {
    if (!_dragView) {
        _dragView = [[FSDragView alloc] init];
        _dragView.dragLineColor = [UIColor whiteColor];
        _dragView.lineWidth = 3.0;
        _dragView.delegate = (id <FSDragViewDelegate>)self;
    }
    return _dragView;
}

- (UIView *)createView {
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:COLHEX(@"#59B4FF")];
    return view;
}

#pragma mark - 外部调用
- (void)configTimeline:(FSTimeLine *)timeline {
    if (timeline) {
        // 计算
        _duration = timeline.duration;
        CGFloat length = SCREENWIDTH-marginLR*2;
        if (self.duration > maxSecond) {
            length = (self.duration/maxSecond)*length;
        }
        
        everyLength = length/(self.duration/FS_TIME_BASE);
        
        DN_WEAK_SELF
        [self.sequnceView configTimeline:timeline maxDuration:maxSecond block:^{
            DN_STRONG_SELF
//            [self startPlay];
        }];
    }
}

// 百分比位置
- (void)playLocation:(CGFloat)location {
    CGFloat totalLength = self.sequnceView.frame.size.width-marginLR*2;
    CGFloat locationLength = totalLength*location;
    CGFloat x = marginLR+locationLength-(self.dragView.frame.size.width-self.dragView.lineWidth)/2.0;
    [self updatePositionX:x];
}

// 设置播放的时间
- (void)playPosition:(int64_t)position {
    int64_t start = [self.sequnceView mapTimelinePosFromX:marginLR];
    int64_t end = [self.sequnceView mapTimelinePosFromX:self.frame.size.width-marginLR];
    if (end == 0) {
        [self playLocation:0];
    }else {
        int64_t allSpace = end-start;
        int64_t playSpace = position-start;
        CGFloat ratio = playSpace/(CGFloat)allSpace;
        
        [self playLocation:ratio];
    }
}

#pragma mark - 手势
// 以left的右边为准 以right的左边为准
- (void)leftGestureRecognize:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self stopPlay];
    }
    CGPoint point = [sender locationInView:self];
    
    CGFloat x = point.x;
    if (x <= marginLR-lrWidth) {
        x = marginLR-lrWidth;
    }
    
    CGFloat minLengthX = minSecond/FS_TIME_BASE*everyLength;
    if (x > (self.rightView.frame.origin.x-minLengthX)) {
        x = self.rightView.frame.origin.x-minLengthX;
    }
    
    [self.leftView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).inset(x);
    }];
    
    int64_t start = [self.sequnceView mapTimelinePosFromX:x+self.leftView.frame.size.width];
    int64_t end = [self.sequnceView mapTimelinePosFromX:self.rightView.frame.origin.x];
    [self changeStart:start end:end];
    
    CGFloat dragPosition = self.dragView.frame.origin.x;
    if (x >= dragPosition) {
        [self updatePositionX:x];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self startPlay];
    }
}

- (void)rightGestureRecognize:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self stopPlay];
    }
    CGPoint point = [sender locationInView:self];
    
    CGFloat rightX = self.frame.size.width-point.x;
    if (rightX <= marginLR) {
        rightX = marginLR;
    }
    
    CGFloat minLengthX = minSecond/FS_TIME_BASE*everyLength;
    if (rightX > (self.frame.size.width-(self.leftView.frame.origin.x+self.leftView.frame.size.width+minLengthX))) {
        rightX = self.frame.size.width-(self.leftView.frame.origin.x+self.leftView.frame.size.width+minLengthX);
    }
 
    [self.rightView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).inset(rightX-lrWidth);
    }];
    
    int64_t start = [self.sequnceView mapTimelinePosFromX:self.leftView.frame.origin.x+self.leftView.frame.size.width];
    int64_t end = [self.sequnceView mapTimelinePosFromX:self.frame.size.width-rightX];
    [self changeStart:start end:end];
    
    CGFloat x = self.frame.size.width-rightX-self.rightView.frame.size.width;
    CGFloat dragPosition = self.dragView.frame.origin.x+self.dragView.frame.size.width;
    if (x <= dragPosition) {
        [self updatePositionX:x];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self startPlay];
    }
}

#pragma mark - 内部方法
- (void)updatePositionX:(CGFloat)x {
    CGFloat positionX = x;
    CGFloat left = self.leftView.frame.origin.x+self.leftView.frame.size.width-(self.dragView.frame.size.width-self.dragView.lineWidth)/2.0;
    CGFloat right = self.rightView.frame.origin.x-(self.dragView.frame.size.width+self.dragView.lineWidth)/2.0;
    if (x <= left) {
        positionX = left;
    }else if (x >= right) {
        positionX = right;
    }
    if ([self.dragView superview]) {
        [self.dragView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(positionX);
        }];
    }
}

- (void)updateValue {
    int64_t timestamp = [self.sequnceView mapTimelinePosFromX:self.leftView.frame.origin.x+self.leftView.frame.size.width];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dragScrollTimelineEnded:)]) {
        [self.delegate dragScrollTimelineEnded:timestamp];
    }
}

- (void)changeStart:(CGFloat)start end:(CGFloat)end {
    NSLog(@"start >>> %f end >>> %f",start,end);
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeStartPosition:endPosition:)]) {
        [self.delegate changeStartPosition:start endPosition:end];
    }
}

- (void)startPlay {
    if (self.delegate && [self.delegate respondsToSelector:@selector(startPlay)]) {
        [self.delegate startPlay];
    }
}

- (void)continuePlay {
    if (self.delegate && [self.delegate respondsToSelector:@selector(contPlay)]) {
        [self.delegate contPlay];
    }
}

- (void)stopPlay {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stopPlay)]) {
        [self.delegate stopPlay];
    }
}

#pragma mark - FSDragViewDelegate
- (void)didDragPositionX:(CGFloat)x {
    [self updatePositionX:x];
    
    CGFloat totalLength = self.sequnceView.frame.size.width-marginLR*2;
    CGFloat locationX = x+(self.dragView.frame.size.width+self.dragView.lineWidth)/2.0 - marginLR;
    CGFloat location = locationX/totalLength;
    if (location > 1) {
        location = 1;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(dragProgress:)]) {
        [self.delegate dragProgress:location];
    }
}

- (void)didDragBegin {
    [self stopPlay];
}

- (void)didDragEnd {
    [self continuePlay];
}

#pragma mark - CHGScrollViewDelegate
- (void)chg_scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopPlay];
}

- (void)chg_scrollViewDidScroll:(UIScrollView *)scrollView {
    int64_t start = [self.sequnceView mapTimelinePosFromX:self.leftView.frame.origin.x+self.leftView.frame.size.width];
    int64_t end = [self.sequnceView mapTimelinePosFromX:self.rightView.frame.origin.x];
    [self changeStart:start end:end];
}

- (void)chg_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) {
        return;
    }
    [self updateValue];
}

- (void)chg_scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateValue];
}

@end
