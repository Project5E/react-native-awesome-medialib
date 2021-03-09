//
//  MediaPickerManager.h
//  ParentingRN
//
//  Created by Evan Hong on 2020/12/17.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN
@class MediaAlbumModel,MediaAssetModel;
@interface MediaPickerManager : NSObject

+ (instancetype)manager;

@property (nonatomic, assign) NSInteger columnNumber;

@property (nonatomic, assign) NSInteger maxSelectedMediaCount;

@property (nonatomic, strong) NSMutableArray *selectedModels;

@property (nonatomic, strong) NSMutableArray *selectedAssetIDs;

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, strong, nullable) NSArray *albums;

// 当前相册model
@property (nonatomic, strong, nullable) MediaAlbumModel *model;

// 当前照片索引
@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, assign, getter=isVideoOnly) BOOL videoOnly;

@property (nonatomic, assign, getter=isFetchingMedia) BOOL fetchingMedia;

- (void)clear;

- (void)jumpToSetting;

- (void)addSelectedModel:(MediaAssetModel *)model;

- (void)removeSelectedModel:(MediaAssetModel *)model;

- (MediaAssetModel *)createModelWithAsset:(PHAsset *)asset;

- (void)removeAllSelectedModels;

- (BOOL)libraryAuthorizationStatusAuthorized;

- (BOOL)libraryLimited;

- (BOOL)libraryDenied;

- (BOOL)cameraAuthorizationStatusAuthorized;

- (void)requestLibraryAuthorizationWithCompletion:(void (^)(BOOL result))completion;

- (void)requestCameraAuthorizationWithCompletion:(void (^)(BOOL result))completion;

- (void)showCameraNoAuthorizationAlertWithCompletion:(void (^) (void))completion;

- (void)getCameraRollAlbumWithCompletion:(void (^)(MediaAlbumModel *model))completion;

- (void)finishSelectMediaWithCompletion:(void (^) (NSArray *result))completion;

// 获取所有相册
- (void)getAllAlbumsWithFetchAssets:(BOOL)needFetchAssets completion:(void (^)(NSArray<MediaAlbumModel *> *models))completion;

// 获取所有相册(包括相册封面)
- (void)getAllAlbumsWithFetchCover:(BOOL)fetchCover completion:(void (^)(NSArray *result, BOOL success))completion;

// 生成指定长度的随机字符串
- (NSString *)randomStringWithLength:(int)len;

// 获取选择的图片
//- (void)getSelectedPhotosWithCompletion:(void (^)(NSArray *result))completion;

// 获取相册封面(本地url)
- (PHImageRequestID)getAlbumCoverWithAlbumModel:(MediaAlbumModel *)model completion:(void (^)(UIImage *photo))completion;

- (void)getAssetsFromFetchResult:(PHFetchResult *)result completion:(void (^)(NSArray<MediaAssetModel *> *models))completion;

- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;

- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(nullable void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;

- (PHImageRequestID)requestImageDataForAsset:(PHAsset *)asset completion:(void (^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;

- (void)getVideoWithAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))completion;

- (void)getVideoWithAsset:(PHAsset *)asset progressHandler:(nullable void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(AVPlayerItem *, NSDictionary *))completion;

- (void)requestVideoURLWithSuccess:(void (^)(NSURL *videoURL, CGFloat scale))success failure:(void (^)(NSDictionary* info))failure;

- (void)savePhotoWithSourceFileURLStr:(NSString *)URLStr completion:(void (^)(PHAsset *asset, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
