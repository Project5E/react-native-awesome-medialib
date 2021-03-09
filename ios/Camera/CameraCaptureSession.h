//
//  CameraCaptureSession.h
//  ParentingRN
//
//  Created by skylar on 2020/12/17.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <React/RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraPromise : NSObject

@property(nonatomic, copy) RCTPromiseResolveBlock resolve;
@property(nonatomic, copy) RCTPromiseRejectBlock reject;

@end

@interface CameraCaptureSession : NSObject <AVCapturePhotoCaptureDelegate>

@property (nonatomic, strong, readonly) AVCaptureSession *session;

+ (instancetype)shared;
- (void)startRunning;
- (void)stopRunning;
- (void)takePhoto:(BOOL)isSquare promise:(CameraPromise *)promise;
- (void)switchCamera;

@end

NS_ASSUME_NONNULL_END
