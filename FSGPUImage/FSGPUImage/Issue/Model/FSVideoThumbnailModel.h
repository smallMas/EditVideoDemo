//
//  FSVideoThumbnailModel.h
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/16.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSVideoThumbnailModel : NSObject <CHGCollectionViewCellModelProtocol>
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, assign) CGSize size;
@end

NS_ASSUME_NONNULL_END
