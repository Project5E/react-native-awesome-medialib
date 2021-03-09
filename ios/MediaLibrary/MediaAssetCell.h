//
//  MediaAssetCell.h
//  ParentingRN
//
//  Created by Evan Hong on 2020/12/17.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSInteger {
  MediaAssetCellTypePhoto = 0,
  MediaAssetCellTypeLivePhoto,
  MediaAssetCellTypePhotoGif,
  MediaAssetCellTypeVideo,
  MediaAssetCellTypeAudio,
} MediaAssetCellType;

@class MediaAssetModel;
@interface MediaAssetCell : UICollectionViewCell

// 照片勾选按钮
@property (nonatomic, strong) UIButton *selectPhotoButton;

// 不能选择时蒙层
@property (nonatomic, strong) UIView *cannotSelectLayer;

@property (nonatomic, strong) MediaAssetModel *model;

// 展示Asset的ID
@property (nonatomic, copy) NSString *representedAssetIdentifier;

// 请求图片的requestID
@property (nonatomic, assign) int32_t imageRequestID;

// 类型
@property (nonatomic, assign) MediaAssetCellType type;

// 索引
@property (nonatomic, assign) NSInteger index;

// 是否展示勾选按钮
@property (nonatomic, assign) BOOL showSelectButton;

@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);

@end

NS_ASSUME_NONNULL_END
