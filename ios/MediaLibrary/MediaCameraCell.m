//
//  MediaCameraCell.m
//  ParentingRN
//
//  Created by Evan Hong on 2020/12/17.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "MediaCameraCell.h"
#import <AVFoundation/AVFoundation.h>
#import "MediaPickerConst.h"
#import "MediaPickerManager.h"

@interface MediaCameraCell()
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong, readwrite) AVCapturePhotoOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIToolbar *blurView;
@end

@implementation MediaCameraCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      self.contentView.layer.cornerRadius = 2.0f;
      self.contentView.layer.masksToBounds = YES;
      
      _sessionQueue = dispatch_queue_create("com.cell.session", DISPATCH_QUEUE_SERIAL);
      _output = [[AVCapturePhotoOutput alloc] init];
      _session = [[AVCaptureSession alloc] init];
      [_session beginConfiguration];
      _session.sessionPreset = AVCaptureSessionPresetPhoto;
      AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                                     mediaType:AVMediaTypeVideo
                                                                      position:AVCaptureDevicePositionBack];
      AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:nil];
      if ([_session canAddInput:deviceInput]) {
          [_session addInput:deviceInput];
      }
      
      if ([_session canAddOutput:_output]) {
        [_session addOutput:_output];
      }
      
      [_session commitConfiguration];
      
      _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
      _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
      [self.contentView.layer addSublayer:_previewLayer];
      
      _blurView = [[UIToolbar alloc] init];
      _blurView.barStyle = UIBarStyleBlack;
      _blurView.translucent = YES;
      [self.contentView addSubview:_blurView];
      
      _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"medialibrary_camera_icon"]];
      [self.contentView addSubview:_imageView];
      
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPreview:) name:kStartCameraPreviewNotification object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPreview:) name:kStopCameraPreviewNotification object:nil];
      
    }
    return self;
}

- (void)startPreview:(NSNotification *)noti {
    if (self.previewLayer && [[MediaPickerManager manager] cameraAuthorizationStatusAuthorized]) {
      [self startRunning];
    }
}

- (void)stopPreview:(NSNotification *)noti {
    [self stopRunning];
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

- (void)layoutSubviews {
    [super layoutSubviews];
    _previewLayer.frame = self.bounds;
    _blurView.frame = self.bounds;
    _imageView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kStartCameraPreviewNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kStopCameraPreviewNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
}
@end
