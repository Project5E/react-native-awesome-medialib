//
//  CameraCaptureSession.m
//  ParentingRN
//
//  Created by skylar on 2020/12/17.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "CameraCaptureSession.h"
#import "ImageUtil.h"

@implementation CameraPromise

- (instancetype)initWithResolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter {
    if (self = [super init]) {
        _resolve = resolver;
        _reject = rejecter;
    }
    return self;
}

@end

@interface CameraCaptureSession ()

@property (nonatomic, strong) dispatch_queue_t sessionQueue;

@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) BOOL isSquare;

@property (nonatomic, strong, readwrite) AVCaptureSession *session;
@property (nonatomic, strong, readwrite) AVCapturePhotoOutput *output;
@property (nonatomic, strong) CameraPromise *promise;

@end

@implementation CameraCaptureSession

+ (instancetype)shared {
    static CameraCaptureSession *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CameraCaptureSession alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _sessionQueue = dispatch_queue_create("com.camera.session", DISPATCH_QUEUE_SERIAL);
        _output = [[AVCapturePhotoOutput alloc] init];
        _session = [[AVCaptureSession alloc] init];
        [self configureSession];
    }
    return self;
}

- (void)configureSession {
    [self.session beginConfiguration];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                                     mediaType:AVMediaTypeVideo
                                                                      position:AVCaptureDevicePositionBack];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:nil];
    if ([self.session canAddInput:deviceInput]) {
        [self.session addInput:deviceInput];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    [self.session commitConfiguration];
}

- (void)startRunning {
  dispatch_async(self.sessionQueue, ^{
    if (!self.isRunning) {
      self.isRunning = YES;
      [self.session startRunning];
    }
  });
}

- (void)stopRunning {
    dispatch_async(self.sessionQueue, ^{
      if (self.isRunning) {
        self.isRunning = NO;
        [self.session stopRunning];
      }
    });
}

- (void)takePhoto:(BOOL)isSquare promise:(CameraPromise *)promise {
    AVCaptureConnection *photoOutputConnection = [self.output connectionWithMediaType:AVMediaTypeVideo];
    photoOutputConnection.videoOrientation = [self fetchOrientation];
    self.isSquare = isSquare;
    self.promise = promise;
    AVCapturePhotoSettings *photoSettings = [[AVCapturePhotoSettings alloc] init];
    [self.output capturePhotoWithSettings:photoSettings delegate:self];
}

- (void)switchCamera {
  [self.session beginConfiguration];
  AVCaptureDeviceInput *currentInput = self.session.inputs.firstObject;
  [self.session removeInput:currentInput];
  AVCaptureDevicePosition position = currentInput.device.position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
  AVCaptureDevice *newCameraDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                                        mediaType:AVMediaTypeVideo
                                                                         position:position];
  AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:newCameraDevice error:nil];
  if ([self.session canAddInput:deviceInput]) {
      [self.session addInput:deviceInput];
  }
  [self.session commitConfiguration];
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    NSString *filePath = [ImageUtil createFilePathWithFileSuffix:@"jpeg"];
    NSData *imageData;
    if (self.isSquare) {
        UIImage *image = [UIImage imageWithData:photo.fileDataRepresentation];
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        CGFloat minLength = MIN(width, height);
        CGPoint point;
        if (width > height) {
            point = CGPointMake((width - height) / 2, 0);
        } else {
            point = CGPointMake(0, (height - width) / 2);
        }
        imageData = [ImageUtil cropImageToSquare:[UIImage imageWithData:photo.fileDataRepresentation] point:point width:minLength];
    } else {
        imageData = photo.fileDataRepresentation;
    }
    [imageData writeToFile:filePath atomically:YES];
    self.promise.resolve(@{@"url": filePath});
    self.promise = nil;
}

- (AVCaptureVideoOrientation)fetchOrientation {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIDeviceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeRight;
        case UIDeviceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeLeft;
        default:
            return AVCaptureVideoOrientationPortrait;
    }
}

@end
