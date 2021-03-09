//
//  CameraPreview.m
//  ParentingRN
//
//  Created by skylar on 2020/12/18.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "CameraPreview.h"
#import "CameraCaptureSession.h"

@implementation CameraPreview

- (instancetype)init {
  if (self = [super init]) {
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[CameraCaptureSession shared].session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:layer];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.layer.sublayers.firstObject.frame = self.bounds;
}

- (void)dealloc {
  
}

@end
