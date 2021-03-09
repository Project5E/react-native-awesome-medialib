//
//  MediaLibraryView.h
//  ParentingRN
//
//  Created by Evan Hong on 2020/12/23.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediaLibraryView : UICollectionView

@property (nonatomic, copy) RCTBubblingEventBlock onPushCameraPage;

@property (nonatomic, copy) RCTBubblingEventBlock onPushPreviewPage;

@property (nonatomic, copy) RCTBubblingEventBlock onMediaItemSelect;

@property (nonatomic, copy) RCTBubblingEventBlock onShowToast;

@property (nonatomic, copy) RCTBubblingEventBlock onAlbumUpdate;

@end

NS_ASSUME_NONNULL_END
