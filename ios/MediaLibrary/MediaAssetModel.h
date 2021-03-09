//
//  MediaAssetModel.h
//  ParentingRN
//
//  Created by Evan Hong on 2020/12/17.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSInteger {
  MediaAssetTypePhoto = 0,
  MediaAssetTypeLivePhoto,
  MediaAssetTypePhotoGIF,
  MediaAssetTypeVideo,
  MediaAssetTypeAudio
} MediaAssetType;

@class PHAsset;
@interface MediaAssetModel : NSObject

@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) MediaAssetType type;

@property (nonatomic, copy) NSString *timeLength;

@property (nonatomic, copy) NSString *URLStr;

@property (nonatomic, assign) BOOL iCloudFailed;

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(MediaAssetType)type;

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(MediaAssetType)type timeLength:(NSString *)timeLength;

@end


@class PHFetchResult;
@interface MediaAlbumModel : NSObject

@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, strong) PHFetchResult *result;

@property (nonatomic, strong) PHAssetCollection *collection;

@property (nonatomic, strong) PHFetchOptions *options;

@property (nonatomic, strong) NSArray *models;

@property (nonatomic, strong) NSArray *selectedModels;

@property (nonatomic, assign) NSUInteger selectedCount;

@property (nonatomic, assign) BOOL isCameraRoll;

- (void)refreshFetchResult;

- (void)setResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets;

@end

NS_ASSUME_NONNULL_END
