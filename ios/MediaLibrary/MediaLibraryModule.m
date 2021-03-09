//
//  MediaLibraryModule.m
//  ParentingRN
//
//  Created by Evan Hong on 2020/12/21.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "MediaLibraryModule.h"
#import "MediaPickerManager.h"
#import "CameraCaptureSession.h"
#import "MediaPickerConst.h"
//#import "ParentingRN-Swift.h"
#import "ImageUtil.h"

@implementation MediaLibraryModule
RCT_EXPORT_MODULE(MediaLibraryModule)

- (dispatch_queue_t)methodQueue {
    return dispatch_queue_create("com.parentingrn.medialibrarymodule", DISPATCH_QUEUE_SERIAL);
}

+ (BOOL)requiresMainQueueSetup {
    return NO;
}


RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(libraryAuthorized) {
    return @([[MediaPickerManager manager] libraryAuthorizationStatusAuthorized]);
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(cameraAuthorized) {
    return @([[MediaPickerManager manager] cameraAuthorizationStatusAuthorized]);
}


RCT_EXPORT_METHOD(fetchAllAssets
                  :(BOOL)showVideoOnly) {
    [MediaPickerManager manager].videoOnly = showVideoOnly;
    [[MediaPickerManager manager] getCameraRollAlbumWithCompletion:^(MediaAlbumModel * _Nonnull model) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kFetchAllAssetsNotification object:nil userInfo:@{@"showVideoOnly": @(showVideoOnly)}];
    }];
}

RCT_EXPORT_METHOD(fetchAllAlbums
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    [[MediaPickerManager manager] getAllAlbumsWithFetchCover:YES completion:^(NSArray * _Nonnull result, BOOL success) {
        if (success) {
            resolve(result);
        } else {
            NSError *error = [NSError errorWithDomain:kGetAlbumsInfoFailed code:1003 userInfo:nil];
            reject(@"no_events", @"there were no events", error);
        }
    }];
}

RCT_EXPORT_METHOD(fetchVideoURL
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    [[MediaPickerManager manager] requestVideoURLWithSuccess:^(NSURL * _Nonnull videoURL, CGFloat scale) {
        resolve(@{@"url": videoURL.absoluteString, @"scale": @(scale)});
    } failure:^(NSDictionary * _Nonnull info) {
        NSError *error = [NSError errorWithDomain:kGetVideoURLFailed code:1004 userInfo:nil];
        NSString *message = [info valueForKey:@"desc"];
        reject(@"no_events", message && message.length > 0 ? message : @"导出视频失败", error);
    }];
}

RCT_EXPORT_METHOD(compressVideo:(NSString *)url resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    NSURL *inputURL = [NSURL URLWithString:url];
    NSURL *outputURL = [NSURL fileURLWithPath:[ImageUtil createFilePathWithFileSuffix:@"mp4"]];
//    FFVideoCompressor *compressor = [[FFVideoCompressor alloc] initWithInputURL:inputURL outputURL:outputURL];
//    [compressor startUsingSystemSessionWithResolve:resolve reject:reject];
}


RCT_EXPORT_METHOD(clear) {
    [[MediaPickerManager manager] clear];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLibraryDeallocNotification object:nil];
    
}

RCT_EXPORT_METHOD(startCameraPreview) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kStartCameraPreviewNotification object:nil];
}

RCT_EXPORT_METHOD(stopCameraPreview) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kStopCameraPreviewNotification object:nil];
}



RCT_EXPORT_METHOD(requestLibraryAuthorization
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    [[MediaPickerManager manager] requestLibraryAuthorizationWithCompletion:^(BOOL result) {
        if (result) {
            resolve(@(YES));
        } else {
            NSError *error = [NSError errorWithDomain:kLibraryNotAuthorized code:1001 userInfo:nil];
            reject(@"no_events", @"there were no events", error);
        }
    }];
    
}

RCT_EXPORT_METHOD(onSelectAlbumAtIndex
                  :(NSNumber *)index) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSwitchAlbumNotification object:nil userInfo:@{@"albumIndex": index}];
}


RCT_EXPORT_METHOD(requestCameraAuthorization
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    [[MediaPickerManager manager] requestCameraAuthorizationWithCompletion:^(BOOL result) {
        if (result) {
            resolve(@(YES));
        } else {
            NSError *error = [NSError errorWithDomain:kCameraNotAuthorized code:1001 userInfo:nil];
            reject(@"no_events", @"there were no events", error);
        }
    }];
}


RCT_EXPORT_METHOD(finishSelectMedia
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
  [[MediaPickerManager manager] finishSelectMediaWithCompletion:^(NSArray *result) {
    if (result.count > 0) {
      resolve(result);
    } else {
      NSError *error = [NSError errorWithDomain:kExportFailed code:1002 userInfo:nil];
      reject(@"no_events", @"there were no events", error);
    }
  }];
}


#pragma mark - private

- (void)requestLibraryAuthorizationWithResolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [[MediaPickerManager manager] requestLibraryAuthorizationWithCompletion:^(BOOL result) {
        if (result) {
            resolve(@(YES));
        } else {
            NSError *error = [NSError errorWithDomain:kLibraryNotAuthorized code:1000 userInfo:nil];
            reject(@"no_events", @"there were no events", error);
        }
    }];
}

@end
