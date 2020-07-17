//
//  FSThumbnailSequenceView.m
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/16.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "FSThumbnailSequenceView.h"
#import "FSVideoThumbnailModel.h"

@interface FSThumbnailSequenceView ()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) FSVideoThumbnailModel *leftModel;
@property (nonatomic, strong) FSVideoThumbnailModel *rightModel;

@property (nonatomic, assign) int64_t duration;
@property (nonatomic, assign) CGFloat thumbnailWidth; // 默认50

@end

@implementation FSThumbnailSequenceView

- (void)dealloc
{
    
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
    self.thumbnailWidth = 50.0f;
}

- (void)setup {
    [self addSubview:self.collectionView];
}

- (void)layoutUI {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)reloadData {
    self.leftModel.size = CGSizeMake(self.startPadding, self.frame.size.height);
    self.rightModel.size = CGSizeMake(self.endPadding, self.frame.size.height);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:self.leftModel];
    [array addObjectsFromArray:self.dataArray];
    [array addObject:self.rightModel];
    self.collectionView.cellDatas = @[array];
}

#pragma mark - 懒加载
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];

        [_collectionView setBackgroundColor:[UIColor clearColor]];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        // cell的行边距[ = ](上下边距)
        _layout.minimumLineSpacing = 0.0f;
        // cell的纵边距[ || ](左右边距)
        _layout.minimumInteritemSpacing = 0.0f;
        [_layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    }
    return _layout;
}

- (FSVideoThumbnailModel *)createThumbnailModelWidth:(CGFloat)width {
    FSVideoThumbnailModel *model = [FSVideoThumbnailModel new];
    model.size = CGSizeMake(width, self.collectionView.bounds.size.height);
    return model;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (FSVideoThumbnailModel *)leftModel {
    if (!_leftModel) {
        _leftModel = [self createThumbnailModelWidth:self.startPadding];
    }
    return _leftModel;
}

- (FSVideoThumbnailModel *)rightModel {
    if (!_rightModel) {
        _rightModel = [self createThumbnailModelWidth:self.endPadding];
    }
    return _rightModel;
}

#pragma mark - 外部调用
- (void)configTimeline:(FSTimeLine *)timeline maxDuration:(int64_t)max block:(FSComplete)block {
    if (timeline) {
        _duration = timeline.duration;
        DN_WEAK_SELF
        [timeline getThumbnailArrayMaxDuration:max width:(SCREENWIDTH-self.startPadding-self.endPadding) block:^(NSArray *array) {
            DN_STRONG_SELF
            [self.dataArray removeAllObjects];
            for (FSVideoThumbnailModel *model in array) {
                CGSize size = model.size;
                size.height = self.frame.size.height;
                model.size = size;
            }
            [self.dataArray addObjectsFromArray:array];
            [self reloadData];
            
            if (block) {
                block();
            }
        }];
    }
}

- (int64_t)mapTimelinePosFromX:(CGFloat)x {
    CGFloat w = self.collectionView.contentSize.width-self.startPadding-self.endPadding;
    CGFloat contentX = self.collectionView.contentOffset.x+x-self.startPadding;
    CGFloat ratio = contentX/w;
    int64_t time = ratio*self.duration;
    if (time > self.duration ) {
        time = self.duration;
    }
    if (time < 0) {
        time = 0;
    }
    return time;
}

- (void)addScrollViewDelegate:(id)delegate {
    [self.collectionView addCHGScrollViewDelegate:(id <CHGScrollViewDelegate>)delegate];
}

- (void)removeScrollViewDelegate:(id)delegate {
    [self.collectionView removeCHGScrollViewDelegate:(id <CHGScrollViewDelegate>)delegate];
}

@end
