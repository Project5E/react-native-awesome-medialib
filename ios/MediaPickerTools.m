//
//  MediaPickerTools.m
//  ParentingRN
//
//  Created by Evan Hong on 2020/12/24.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "MediaPickerTools.h"

@implementation MediaPickerTools

+ (BOOL)isICloudSyncError:(NSError *)error {
    if (!error) return NO;
    if ([error.domain isEqualToString:@"CKErrorDomain"] || [error.domain isEqualToString:@"CloudPhotoLibraryErrorDomain"]) {
        return YES;
    }
    return NO;
}

+ (CGFloat)statusBarHeight {
    if ([UIWindow instancesRespondToSelector:@selector(safeAreaInsets)]) {
        return [self safeAreaInsets].top ?: 20;
    }
    return 20;
}

+ (UIEdgeInsets)safeAreaInsets {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    if (![window isKeyWindow]) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (CGRectEqualToRect(keyWindow.bounds, [UIScreen mainScreen].bounds)) {
            window = keyWindow;
        }
    }
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets insets = [window safeAreaInsets];
        return insets;
    }
    return UIEdgeInsetsZero;
}

@end
