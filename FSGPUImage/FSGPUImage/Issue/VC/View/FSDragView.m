//
//  FSDragView.m
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/16.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "FSDragView.h"

@interface FSDragView ()

@property (nonatomic, assign) CGFloat startX;

@end

@implementation FSDragView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(0);
    }];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognize:)];//初始化平移手势识别器(Pan)
    panGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>) self;
    [self addGestureRecognizer:panGestureRecognizer];
}

#pragma mark - 懒加载
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        [_lineView setRoundRadius:3 borderColor:[UIColor clearColor]];
    }
    return _lineView;
}

#pragma mark - SET GET方法
- (void)setDragLineColor:(UIColor *)dragLineColor {
    _dragLineColor = dragLineColor;
    [self.lineView setBackgroundColor:dragLineColor];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    
    [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(lineWidth);
    }];
}

- (CGFloat)half {
    CGFloat dragW = self.frame.size.width;
    CGFloat half = (dragW-self.lineWidth)/2.0;
    return half;
}

#pragma mark - EVENT
- (void)panGestureRecognize:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        // 开始
        self.startX = self.frame.origin.x;
        [self beginDrag];
    }else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint currentPoint = [sender translationInView:self.superview];
        CGFloat x = self.startX + currentPoint.x;
        
        [self updateDragPostion:x];
    }else {
        [self endDrag];
    }
}

#pragma mark - 内部方法
- (void)beginDrag {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDragBegin)]) {
        [self.delegate didDragBegin];
    }
}

- (void)updateDragPostion:(CGFloat)x {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDragPositionX:)]) {
        [self.delegate didDragPositionX:x];
    }
}

- (void)endDrag {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDragEnd)]) {
        [self.delegate didDragEnd];
    }
}

@end
