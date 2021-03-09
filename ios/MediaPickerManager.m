//
//  MediaPickerManager.m
//  ParentingRN
//
//  Created by Evan Hong on 2020/12/17.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "MediaPickerManager.h"
#import "MediaAssetModel.h"
#import "MediaPickerConst.h"
#import "MediaPickerImageRequestOperation.h"
#import <MobileCoreServices/MobileCoreServices.h>


@implementation MediaPickerManager

static MediaPickerManager *manager;
static dispatch_once_t onceToken;

+ (instancetype)manager {
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)clear {
    [self.selectedModels removeAllObjects];
    [self.selectedAssetIDs removeAllObjects];
    self.videoOnly = NO;
    self.model = nil;
    self.albums = nil;
}

- (void)jumpToSetting {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
}

- (void)addSelectedModel:(MediaAssetModel *)model {
    [self.selectedModels addObject:model];
    [self.selectedAssetIDs addObject:model.asset.localIdentifier];
}

- (void)removeSelectedModel:(MediaAssetModel *)model {
    [self.selectedModels removeObject:model];
    [self.selectedAssetIDs removeObject:model.asset.localIdentifier];
}

- (void)removeAllSelectedModels {
    [self.selectedModels removeAllObjects];
    [self.selectedAssetIDs removeAllObjects];
}

- (BOOL)libraryAuthorizationStatusAuthorized {
    return [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized;
}

- (BOOL)libraryLimited {
    if (@available(iOS 14.0, *)) {
        return [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite] == PHAuthorizationStatusLimited;
    } else {
        return NO;
    }
}

- (BOOL)libraryDenied {
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    return (authStatus == PHAuthorizationStatusRestricted || authStatus == PHAuthorizationStatusDenied);
}


- (BOOL)cameraAuthorizationStatusAuthorized {
    return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized;
}

- (void)requestLibraryAuthorizationWithCompletion:(void (^)(BOOL result))completion {
    void (^callCompletionBlock)(BOOL result) = ^(BOOL result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(result);
            }
        });
    };
    
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    
    if (authStatus == PHAuthorizationStatusRestricted || authStatus == PHAuthorizationStatusDenied) {
        callCompletionBlock(NO);
        [[NSNotificationCenter defaultCenter] postNotificationName:kLibraryStatusDeniedNotification object:nil];
    } else if (authStatus == PHAuthorizationStatusNotDetermined) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                callCompletionBlock(status == PHAuthorizationStatusAuthorized);
            }];
        });
    } else {
        callCompletionBlock(YES);
    }
}

- (void)requestCameraAuthorizationWithCompletion:(void (^)(BOOL result))completion {
    void (^callCompletionBlock)(BOOL result) = ^(BOOL result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(result);
            }
        });
    };
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)) {
        callCompletionBlock(NO);
        
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            callCompletionBlock(granted);
            if (granted) {
                // start video preview session
            }
        }];
    } else {
        // start video preview session
        callCompletionBlock(YES);
    }
}

- (void)showCameraNoAuthorizationAlertWithCompletion:(void (^) (void))completion {
    NSDictionary *infoDict = [self getInfoDictionary];
    NSString *appName = [infoDict valueForKey:@"CFBundleDisplayName"];
    if (!appName) appName = [infoDict valueForKey:@"CFBundleName"];
    if (!appName) appName = [infoDict valueForKey:@"CFBundleExecutable"];
    
    NSString *title = @"未获得授权使用相机";
    NSString *message = @"请在iOS\"设置\"-\"隐私\"-\"相机\"中打开";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completion();
    }];
    [alertController addAction:cancelAct];
    UIAlertAction *settingAct = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[MediaPickerManager manager] jumpToSetting];
        completion();
    }];
    [alertController addAction:settingAct];
    [[UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)getCameraRollAlbumWithCompletion:(void (^)(MediaAlbumModel *model))completion {
    __block MediaAlbumModel *model;
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    if (self.isVideoOnly) {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                                           PHAssetMediaTypeVideo];
    } else {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                                           PHAssetMediaTypeImage];
    }
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in smartAlbums) {
        
        if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
        
        if (collection.estimatedAssetCount <= 0) continue;
        if ([self isCameraRollAlbum:collection]) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            model = [self modelWithResult:fetchResult collection:collection isCameraRoll:YES needFetchAssets:YES options:option];
            self.model = model;
            if (completion) completion(model);
            break;
        }
    }
}

- (MediaAssetModel *)createModelWithAsset:(PHAsset *)asset {
    return [MediaAssetModel modelWithAsset:asset type:MediaAssetTypePhoto];
}

- (void)getAllAlbumsWithFetchAssets:(BOOL)needFetchAssets completion:(void (^)(NSArray<MediaAlbumModel *> *models))completion {
    
    NSMutableArray *albumArr = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    if (self.isVideoOnly) {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    } else {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    }
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 用户创建的相册
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            // 空相册
            if (collection.estimatedAssetCount <= 0 && ![self isCameraRollAlbum:collection]) continue;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (fetchResult.count < 1 && ![self isCameraRollAlbum:collection]) continue;
            
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) continue;
            // 最近删除
            if (collection.assetCollectionSubtype == 1000000201) continue;
            if ([self isCameraRollAlbum:collection]) {
                [albumArr insertObject:[self modelWithResult:fetchResult collection:collection isCameraRoll:YES needFetchAssets:needFetchAssets options:option] atIndex:0];
            } else {
                [albumArr addObject:[self modelWithResult:fetchResult collection:collection isCameraRoll:NO needFetchAssets:needFetchAssets options:option]];
            }
        }
    }
    if (completion) {
        completion(albumArr);
    }
}

- (void)getAllAlbumsWithFetchCover:(BOOL)fetchCover completion:(void (^)(NSArray *result, BOOL success))completion {
    NSMutableArray *result = [NSMutableArray array];
    [[MediaPickerManager manager] getAllAlbumsWithFetchAssets:NO completion:^(NSArray<MediaAlbumModel *> * _Nonnull models) {
        [MediaPickerManager manager].albums = models;
        for (NSInteger i = 0; i<models.count; i++) {
            MediaAlbumModel *model = models[i];
            [[MediaPickerManager manager] getAlbumCoverWithAlbumModel:model completion:^(UIImage * _Nonnull photo) {
                NSString *filename = [self randomStringWithLength:10];
                NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", filename]];
                NSURL *outputPath = [NSURL fileURLWithPath:filePath];
                BOOL success = [UIImagePNGRepresentation(photo) writeToURL:outputPath atomically:YES];
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:model.name forKey:@"name"];
                [dict setValue:@(i) forKey:@"index"];
                [dict setValue:@(model.count) forKey:@"count"];
                [dict setValue:success ? filePath : @"" forKey:@"cover"];
                [result addObject:dict];
                if (result.count == models.count) {
                    //排序
                    [result sortUsingComparator:^NSComparisonResult(NSMutableDictionary *_Nonnull obj1, NSMutableDictionary *_Nonnull obj2) {
                        if ([obj1[@"index"] integerValue] < [obj2[@"index"] integerValue]) {
                            return NSOrderedAscending;
                        } else {
                            return NSOrderedDescending;
                        }
                    }];
                    completion([result copy], YES);
                }
            }];
        }
    }];
}

- (void)getAssetsFromFetchResult:(PHFetchResult *)result completion:(void (^)(NSArray<MediaAssetModel *> *))completion {
    NSMutableArray *photoArr = [NSMutableArray array];
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        MediaAssetModel *model = [self assetModelWithAsset:asset];
        if (model) {
            [photoArr addObject:model];
        }
    }];
    if (completion) completion(photoArr);
}

- (MediaAssetModel *)assetModelWithAsset:(PHAsset *)asset {
    MediaAssetModel *model;
    MediaAssetType type = [self getAssetType:asset];
    //过滤GIF
    if (type == MediaAssetTypePhotoGIF) return nil;
    PHAsset *phAsset = (PHAsset *)asset;
    NSString *timeLength = type == MediaAssetTypeVideo ? [NSString stringWithFormat:@"%0.0f",phAsset.duration] : @"";
    timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
    model = [MediaAssetModel modelWithAsset:asset type:type timeLength:timeLength];
    return model;
}


- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    return [self getPhotoWithAsset:asset photoWidth:[UIScreen mainScreen].bounds.size.width completion:completion progressHandler:progressHandler networkAccessAllowed:networkAccessAllowed];
}

- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion {
    return [self getPhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}


- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(nullable void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    CGSize imageSize;
    CGFloat scale = [UIScreen mainScreen].scale;
    if (photoWidth < [UIScreen mainScreen].bounds.size.width) {
        imageSize = CGSizeMake(photoWidth * scale, photoWidth * scale);
    } else {
        PHAsset *phAsset = (PHAsset *)asset;
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat pixelWidth = photoWidth * scale;
        // 超宽图片
        if (aspectRatio > 1.8) {
            pixelWidth = pixelWidth * aspectRatio;
        }
        // 超高图片
        if (aspectRatio < 0.2) {
            pixelWidth = pixelWidth * 0.5;
        }
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        imageSize = CGSizeMake(pixelWidth, pixelHeight);
    }
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    // 方法可能会返回多次result，可能会有degraded的画质。
    int32_t imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *result, NSDictionary *info) {
        BOOL cancelled = [[info objectForKey:PHImageCancelledKey] boolValue];
        if (!cancelled && result) {
            result = [self fixOrientation:result];
            if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        }
        // iCloud
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result && networkAccessAllowed) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progressHandler) {
                        progressHandler(progress, error, stop, info);
                    }
                });
            };
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                UIImage *resultImage = [UIImage imageWithData:imageData];
                if (!resultImage && result) {
                    resultImage = result;
                }
                resultImage = [self fixOrientation:result];
                if (completion) completion(resultImage,info,NO);
            }];
        }
    }];
    return imageRequestID;
}


- (PHImageRequestID)requestImageDataForAsset:(PHAsset *)asset completion:(void (^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressHandler) {
                progressHandler(progress, error, stop, info);
            }
        });
    };
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    int32_t imageRequestID = [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        if (completion) completion(imageData,dataUTI,orientation,info);
    }];
    return imageRequestID;
}


- (void)getVideoWithAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem *, NSDictionary *))completion {
    [self getVideoWithAsset:asset progressHandler:nil completion:completion];
}

- (void)getVideoWithAsset:(PHAsset *)asset progressHandler:(nullable void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(AVPlayerItem *, NSDictionary *))completion {
    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    option.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressHandler) {
                progressHandler(progress, error, stop, info);
            }
        });
    };
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:option resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
        if (completion) completion(playerItem,info);
    }];
}

- (void)requestVideoURLWithSuccess:(void (^)(NSURL *videoURL, CGFloat scale))success failure:(void (^)(NSDictionary* info))failure {
    MediaAssetModel *model = [MediaPickerManager manager].selectedModels.firstObject;
    if (model.asset.duration > 180) {
        failure(@{@"desc": @"请选择时常小于3分钟的视频"});
        return;
    }
    if (model.asset.duration < 5) {
        failure(@{@"desc": @"请选择时长大于5秒的视频"});
        return;
    }
    [[PHImageManager defaultManager] requestAVAssetForVideo:model.asset options:[self getVideoRequestOptions] resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
        if ([avasset isKindOfClass:[AVComposition class]]) {
            //慢动作视频过滤
            failure(@{@"desc": @"暂不支持的视频格式"});
            return;
        }
        if ([avasset isKindOfClass:[AVURLAsset class]]) {
            AVAssetTrack *track = [[avasset tracksWithMediaType:AVMediaTypeVideo] firstObject];
            CGSize transfromSize = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
            CGFloat scale = transfromSize.height / transfromSize.width;
            NSURL *url = [(AVURLAsset *)avasset URL];
            if (success) {
                success(url, scale);
            }
        } else if (failure) {
            failure(info);
        }
    }];
}


- (PHImageRequestID)getAlbumCoverWithAlbumModel:(MediaAlbumModel *)model completion:(void (^)(UIImage *photo))completion {
    id asset = [model.result firstObject];
    if (!asset) {
        return -1;
    }
    return [[MediaPickerManager manager] getPhotoWithAsset:asset photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (isDegraded) return;
        if (completion) completion(photo);
    }];
}

- (void)savePhotoWithSourceFileURLStr:(NSString *)URLStr completion:(void (^)(PHAsset *asset, NSError *error))completion {
    __block NSString *localIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[NSURL fileURLWithPath:URLStr]];
        localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
        request.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
        [[NSFileManager defaultManager] removeItemAtPath:URLStr error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && completion) {
                [self fetchAssetByIocalIdentifier:localIdentifier retryCount:10 completion:completion];
            } else if (error) {
                NSLog(@"保存照片出错:%@",error.localizedDescription);
                if (completion) {
                    completion(nil, error);
                }
            }
        });
        
    }];
}

- (void)fetchAssetByIocalIdentifier:(NSString *)localIdentifier retryCount:(NSInteger)retryCount completion:(void (^)(PHAsset *asset, NSError *error))completion {
    PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil] firstObject];
    if (asset || retryCount <= 0) {
        if (completion) {
            completion(asset, nil);
            if (asset) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAddPHAssetNotification object:nil userInfo:@{@"asset": asset}];
            }
        }
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fetchAssetByIocalIdentifier:localIdentifier retryCount:retryCount - 1 completion:completion];
    });
}


- (MediaAssetType)getAssetType:(PHAsset *)asset {
    MediaAssetType type = MediaAssetTypePhoto;
    PHAsset *phAsset = (PHAsset *)asset;
    if (phAsset.mediaType == PHAssetMediaTypeVideo)      type = MediaAssetTypeVideo;
    else if (phAsset.mediaType == PHAssetMediaTypeAudio) type = MediaAssetTypeAudio;
    else if (phAsset.mediaType == PHAssetMediaTypeImage) {
        if ([[phAsset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
            type = MediaAssetTypePhotoGIF;
        }
    }
    return type;
}

- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}


- (BOOL)isCameraRollAlbum:(PHAssetCollection *)metadata {
    return ((PHAssetCollection *)metadata).assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary;
}

- (NSDictionary *)getInfoDictionary {
    NSDictionary *infoDict = [NSBundle mainBundle].localizedInfoDictionary;
    if (!infoDict || !infoDict.count) {
        infoDict = [NSBundle mainBundle].infoDictionary;
    }
    if (!infoDict || !infoDict.count) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        infoDict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return infoDict ? infoDict : @{};
}

- (MediaAlbumModel *)modelWithResult:(PHFetchResult *)result collection:(PHAssetCollection *)collection isCameraRoll:(BOOL)isCameraRoll needFetchAssets:(BOOL)needFetchAssets options:(PHFetchOptions *)options {
    MediaAlbumModel *model = [[MediaAlbumModel alloc] init];
    [model setResult:result needFetchAssets:needFetchAssets];
    model.name = collection.localizedTitle;
    model.collection = collection;
    model.options = options;
    model.isCameraRoll = isCameraRoll;
    model.count = result.count;
    return model;
}

- (PHVideoRequestOptions *)getVideoRequestOptions {
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    return options;
}

// 修正图片方向
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

// 下一步
- (void)finishSelectMediaWithCompletion:(void (^) (NSArray *result))completion {
    [self exportImageWithCompletion:completion];
}


- (void)exportImageWithCompletion:(void (^) (NSArray *result))completion {
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *photos = [NSMutableArray array];
    NSMutableArray *infoArr = [NSMutableArray array];
    __block BOOL noErrors = YES;
    for (NSInteger i = 0; i <self.selectedModels.count; i++) { [photos addObject:@1];[assets addObject:@1];[infoArr addObject:@1]; }
    for (NSInteger i = 0; i<self.selectedModels.count; i++) {
        MediaAssetModel *model = self.selectedModels[i];
        MediaPickerImageRequestOperation *operation = [[MediaPickerImageRequestOperation alloc] initWithAsset:model.asset completion:^(UIImage * _Nonnull photo, NSDictionary * _Nonnull info, BOOL isDegraded) {
            // 全损画质
            if (isDegraded) return;
            if (photo) {
                [photos replaceObjectAtIndex:i withObject:photo];
            }
            if (info)  [infoArr replaceObjectAtIndex:i withObject:info];
            [assets replaceObjectAtIndex:i withObject:model.asset];
            
            for (id item in photos) {if ([item isKindOfClass:[NSNumber class]]) return;}
            
            if (noErrors) {
                [[MediaPickerManager manager] didGetAllPhotos:photos assets:assets infoArr:infoArr completion:completion];
            } else {
                completion(@[]);
            }
        } progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
            if (progress < 1 && noErrors) {
                // 正在从iCloud同步
                noErrors = NO;
                return;
            }
            if (progress >= 1) {
                noErrors = YES;
            }
        }];
        [self.operationQueue addOperation:operation];
    }
}


- (void)didGetAllPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr completion:(void (^) (NSArray *result))completion {
    // infoArr PHImageFileURLKey
    NSMutableArray *info = [NSMutableArray array];
    for (NSInteger i = 0; i<photos.count; i++) {
        UIImage *image = photos[i];
        NSDictionary *dict = [self resizeWithImage:image];
        [info addObject:dict];
    }
    completion(info);
    [self clear];
}


- (NSDictionary *)resizeWithImage:(UIImage *)image{
    NSUInteger oneMB = 1024 * 1024;
    NSUInteger twoMB = 2 * oneMB;
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    NSUInteger imageSizeKB = imageData.length;
    
    if (imageSizeKB >= oneMB && imageSizeKB < twoMB) {
        imageData = UIImageJPEGRepresentation(image, 0.5);
    }
    
    if (imageSizeKB >= twoMB) {
        imageData = UIImageJPEGRepresentation(image, 0.3);
    }
    
    NSString *filename = [self randomStringWithLength:10];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", filename]];
    NSURL *outputPath = [NSURL fileURLWithPath:filePath];
    [imageData writeToURL:outputPath atomically:YES];
    
    return @{
        @"type": @"image",
        @"width": @(image.size.width),
        @"height": @(image.size.height),
        @"url": filePath,
        @"key": filePath,
    };
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

- (NSString *)randomStringWithLength:(int)len {

    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];

    for (int i=0; i<len; i++) {
         [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform(len)]];
    }

    return randomString;
}


#pragma mark - getter

- (NSMutableArray *)selectedModels {
    if (_selectedModels == nil) {
        _selectedModels = [NSMutableArray array];
    }
    return _selectedModels;
}

- (NSMutableArray *)selectedAssetIDs {
    if (_selectedAssetIDs == nil) {
        _selectedAssetIDs = [NSMutableArray array];
    }
    return _selectedAssetIDs;
}

- (NSOperationQueue *)operationQueue {
    if (_operationQueue == nil) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 3;
    }
    return _operationQueue;
}

- (NSArray *)albums {
    if (_albums == nil) {
        _albums = [NSArray array];
    }
    return _albums;
}

@end
