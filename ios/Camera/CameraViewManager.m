//
//  CameraViewManager.m
//  ParentingRN
//
//  Created by skylar on 2020/12/17.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "CameraViewManager.h"
#import "CameraCaptureSession.h"
#import "CameraPreview.h"

@implementation CameraViewManager
RCT_EXPORT_MODULE()

- (UIView *)view {
    return [[CameraPreview alloc] init];
}

@end
