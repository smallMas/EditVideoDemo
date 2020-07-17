//
//  FSVideoThumbnailModel.m
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/16.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "FSVideoThumbnailModel.h"

@implementation FSVideoThumbnailModel

#pragma mark - CHGCollectionViewCellModelProtocol
- (NSString*)cellClassNameInCollectionView:(UICollectionView*)collectionView atIndexPath:(NSIndexPath*)indexPath {
    return @"FSThumbnailCollectionCell";
}

- (CGSize)chg_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.size;
}

@end
