//
//  MediaPickerConst.m
//  ParentingRN
//
//  Created by Evan Hong on 2020/12/17.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "MediaPickerConst.h"

CGFloat const kLibraryViewItemMargin = 6;
CGFloat const kLibraryViewColumnNumber = 3;

NSString *const kLibraryDeallocNotification = @"kLibraryDeallocNotification";
// 拍照后通知
NSString *const kAddPHAssetNotification = @"kAddPHAssetNotification";
NSString *const kLibraryStatusDeniedNotification = @"kLibraryStatusDeniedNotification";
NSString *const kSelectPhotoCountUpdateNotification = @"kSelectPhotoCountUpdateNotification";
NSString *const kReloadLibraryNotification = @"kReloadLibraryNotification";
NSString *const kSwitchAlbumNotification = @"kSwitchAlbumNotification";
NSString *const kReloadLibraryItemNotification = @"kReloadLibraryItemNotification";
NSString *const kStartCameraPreviewNotification = @"kStartCameraPreviewNotification";
NSString *const kStopCameraPreviewNotification = @"kStopCameraPreviewNotification";
NSString *const kFetchAllAssetsNotification = @"kFetchAllAssetsNotification";

NSString *const kLibraryNotAuthorized = @"Library Not Authorized";
NSString *const kCameraNotAuthorized = @"Camera Not Authorized";
NSString *const kGetAlbumsInfoFailed = @"Get Albums Info Failed";
NSString *const kGetVideoURLFailed = @"Get Video URL Failed";
NSString *const kExportFailed = @"Export Failed";
