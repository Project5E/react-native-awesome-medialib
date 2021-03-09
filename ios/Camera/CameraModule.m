//
//  CameraModule.m
//  ParentingRN
//
//  Created by skylar on 2020/12/17.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "CameraModule.h"
#import "CameraCaptureSession.h"
#import "MediaPickerManager.h"
#import "ImageUtil.h"

@interface CameraModule ()

@property (nonatomic, strong) CameraPromise *promise;

@end

@implementation CameraModule
RCT_EXPORT_MODULE(CameraModule)

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_METHOD(startRunning) {
  [[CameraCaptureSession shared] startRunning];
}

RCT_EXPORT_METHOD(stopRunning) {
  [[CameraCaptureSession shared] stopRunning];
}

RCT_EXPORT_METHOD(takePhoto:(BOOL)isSquare resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
  CameraPromise *promise = [[CameraPromise alloc] init];
  promise.resolve = resolve;
  promise.reject = reject;
  [[CameraCaptureSession shared] takePhoto:isSquare promise:promise];
}

RCT_EXPORT_METHOD(deletePhoto:(NSString *)filePath resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        NSLog(@"delete file ");
    } else {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

RCT_EXPORT_METHOD(cropPhotoToSquare:(NSString *)filePath
                  pointX:(NSNumber *)x
                  pointY:(NSNumber *)y
                  width:(NSNumber *)width
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    NSNumber *length = [NSNumber numberWithFloat:floor(width.floatValue)]; // 取整
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:imageData];
    NSData *data = [ImageUtil cropImageToSquare:image point:CGPointMake(x.floatValue, y.floatValue) width:length.floatValue];
    NSString *path = [ImageUtil createFilePathWithFileSuffix:@"jpeg"];
    [data writeToFile:path atomically:YES];
    resolve(@{@"url": path, @"width": length, @"height": length});
}

RCT_EXPORT_METHOD(switchCamera) {
  [[CameraCaptureSession shared] switchCamera];
}

RCT_EXPORT_METHOD(saveImage:(NSString *)url resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    [[MediaPickerManager manager] savePhotoWithSourceFileURLStr:url completion:^(PHAsset * _Nonnull asset, NSError * _Nonnull error) {
        if (asset) {
            NSLog(@"%@", asset.localIdentifier);

        }
        resolve(@1);
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
  if (self.promise) {
    self.promise.resolve(@1);
    self.promise = nil;
  }
}

@end
