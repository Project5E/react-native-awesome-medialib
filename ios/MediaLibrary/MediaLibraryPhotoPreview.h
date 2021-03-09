//
//  MediaLibraryPhotoPreview.h
//  ParentingRN
//
//  Created by Evan Hong on 2021/1/6.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediaLibraryPhotoPreview : UIView

@property (nonatomic, copy) RCTBubblingEventBlock onFinishSelect;

@property (nonatomic, copy) RCTBubblingEventBlock onShowToast;

@end

NS_ASSUME_NONNULL_END
