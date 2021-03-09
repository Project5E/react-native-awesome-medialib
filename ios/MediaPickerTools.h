//
//  MediaPickerTools.h
//  ParentingRN
//
//  Created by Evan Hong on 2020/12/24.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediaPickerTools : NSObject

+ (BOOL)isICloudSyncError:(NSError *)error;

+ (CGFloat)statusBarHeight;

+ (UIEdgeInsets)safeAreaInsets;

@end

NS_ASSUME_NONNULL_END
