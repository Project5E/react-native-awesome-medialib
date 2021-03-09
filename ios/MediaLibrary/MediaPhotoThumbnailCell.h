//
//  MediaPhotoThumbnailCell.h
//  ParentingRN
//
//  Created by Evan Hong on 2021/1/12.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MediaAssetModel;
@interface MediaPhotoThumbnailCell : UICollectionViewCell

@property (nonatomic, strong) MediaAssetModel *model;

@property (nonatomic, copy) NSString *representedAssetIdentifier;

// 请求图片的requestID
@property (nonatomic, assign) int32_t imageRequestID;

@end

NS_ASSUME_NONNULL_END
