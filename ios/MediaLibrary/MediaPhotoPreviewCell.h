//
//  MediaPhotoPreviewCell.h
//  ParentingRN
//
//  Created by Evan Hong on 2021/1/6.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class MediaAssetModel, MediaPhotoPreviewView, MediaProgressView;

@interface MediaPhotoPreviewCell : UICollectionViewCell
@property (nonatomic, strong) MediaAssetModel *model;
@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);
@property (nonatomic, strong) MediaPhotoPreviewView *previewView;
@end

@interface MediaPhotoPreviewView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) MediaAssetModel *model;
@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);
@property (nonatomic, assign) int32_t imageRequestID;
@property (nonatomic, strong) id asset;
@property (nonatomic, copy) void (^iCloudSyncFailedHandle)(id asset, BOOL isSyncFailed);
@property (nonatomic, strong) UIImageView *iCloudErrorIcon;
@property (nonatomic, strong) UILabel *iCloudErrorLabel;
@property (nonatomic, strong) MediaProgressView *progressView;
@end

NS_ASSUME_NONNULL_END
