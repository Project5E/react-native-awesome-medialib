//
//  MediaLibraryViewManager.m
//  ParentingRN
//
//  Created by Evan Hong on 2020/12/17.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "MediaLibraryViewManager.h"
#import "MediaLibraryView.h"
#import "MediaPickerConst.h"
#import "MediaAssetCell.h"
#import "MediaCameraCell.h"
#import "MediaAssetModel.h"
#import "MediaPickerManager.h"
#import "MediaLibraryLimitedView.h"
#import <Masonry/Masonry.h>
#import "RCTConvert.h"

@interface MediaLibraryViewManager()<UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver>

@property (nonatomic, weak) MediaLibraryView *libraryView;

@property (nonatomic, copy) NSString *cameraCellID;

@end

@implementation MediaLibraryViewManager
RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(onMediaItemSelect, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPushPreviewPage, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPushCameraPage, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onShowToast, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAlbumUpdate, RCTBubblingEventBlock)
- (UIView *)view {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWH = ([UIScreen mainScreen].bounds.size.width - (kLibraryViewColumnNumber + 1) * kLibraryViewItemMargin) / kLibraryViewColumnNumber;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = kLibraryViewItemMargin;
    layout.minimumLineSpacing = kLibraryViewItemMargin;
    MediaLibraryView *libraryView = [[MediaLibraryView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    libraryView.backgroundColor = [UIColor colorWithRed:26 / 255.0 green:26 / 255.0 blue:26 / 255.0 alpha:1];
    libraryView.dataSource = self;
    libraryView.delegate = self;
    libraryView.alwaysBounceHorizontal = NO;
    libraryView.showsHorizontalScrollIndicator = NO;
    libraryView.contentInset = UIEdgeInsetsMake(kLibraryViewItemMargin, kLibraryViewItemMargin, kLibraryViewItemMargin, kLibraryViewItemMargin);
    [libraryView registerClass:[MediaAssetCell class] forCellWithReuseIdentifier:@"MediaAssetCell"];
    self.cameraCellID = [[MediaPickerManager manager] randomStringWithLength:10];
    [libraryView registerClass:[MediaCameraCell class] forCellWithReuseIdentifier:@"MediaCameraCell"];
    [libraryView registerClass:[MediaLibraryLimitedView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MediaLibraryLimitedView"];
    _libraryView = libraryView;
    [self addObserver];
    return libraryView;
}

RCT_CUSTOM_VIEW_PROPERTY(maxSelectedMediaCount, NSInteger, UICollectionView) {
    [MediaPickerManager manager].maxSelectedMediaCount = [RCTConvert NSInteger:json];
}

// 获取单个相册内容
- (void)fetchAssetWithAlbumModel:(MediaAlbumModel *)albumModel {
    __weak typeof(self) weakSelf = self;
    [[MediaPickerManager manager] getAssetsFromFetchResult:albumModel.result completion:^(NSArray<MediaAssetModel *> * _Nonnull models) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MediaPickerManager manager].model.models = models;
            [weakSelf checkSelectModels];
            [weakSelf.libraryView reloadData];
        });
    }];
}

- (void)checkSelectModels {
    NSArray *selectedModels = [MediaPickerManager manager].selectedModels;
    NSMutableSet *selectedAssets = [NSMutableSet setWithCapacity:selectedModels.count];
    for (MediaAssetModel *model in selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (MediaAssetModel *model in [MediaPickerManager manager].model.models) {
        model.isSelected = NO;
        if ([selectedAssets containsObject:model.asset]) {
            model.isSelected = YES;
        }
    }
}


#pragma mark - private

- (void)addObserver {
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(libraryStatusDenied:) name:kLibraryStatusDeniedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePhotoSelectCount:) name:kSelectPhotoCountUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPHAsset:) name:kAddPHAssetNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLibrary:) name:kReloadLibraryNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchAlbum:) name:kSwitchAlbumNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchAllAssets:) name:kFetchAllAssetsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(libraryViewDealloc:) name:kLibraryDeallocNotification object:nil];
}

- (void)createPlaceholder {
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor colorWithRed:26 / 255.0 green:26 / 255.0 blue:26 / 255.0 alpha:1];
    [self.libraryView addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.libraryView);
        make.width.height.equalTo(self.libraryView);
    }];
    UILabel *mainLabel = [[UILabel alloc] init];
    mainLabel.textColor = [UIColor colorWithRed:229 / 255.0 green:229 / 255.0 blue:229 / 255.0 alpha:1];
    mainLabel.font = [UIFont systemFontOfSize:16 weight:500];
    mainLabel.textAlignment = NSTextAlignmentCenter;
    mainLabel.text = @"呼啦亲子没有权限访问您的相册";
    [containerView addSubview:mainLabel];
    [mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containerView);
        make.centerY.equalTo(containerView).mas_offset(-20);
    }];
    UILabel *subLabel = [[UILabel alloc] init];
    subLabel.textColor = mainLabel.textColor;
    subLabel.font = mainLabel.font;
    subLabel.textAlignment = NSTextAlignmentCenter;
    subLabel.text = @"请前往“设置”开启权限";
    [containerView addSubview:subLabel];
    [subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(mainLabel);
        make.top.equalTo(mainLabel.mas_bottom).mas_offset(10);
    }];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSMutableAttributedString *descStr = [[NSMutableAttributedString alloc] initWithString:@"前往系统设置"];
    NSDictionary *attrs = @{
        NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle],
        NSFontAttributeName: [UIFont systemFontOfSize:16 weight:600],
        NSForegroundColorAttributeName: [UIColor whiteColor],
    };
    [descStr addAttributes:attrs range:NSMakeRange(0, [descStr length])];
    [button setAttributedTitle:descStr forState:UIControlStateNormal];
    [button addTarget:self action:@selector(jumpToSetting) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(165);
        make.height.mas_equalTo(38);
        make.centerX.mas_equalTo(containerView);
        make.top.equalTo(subLabel).mas_offset(40);
    }];
}


#pragma mark - event

- (void)libraryStatusDenied:(NSNotification *)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createPlaceholder];
    });
}

- (void)jumpToSetting {
    [[MediaPickerManager manager] jumpToSetting];
}

- (void)updatePhotoSelectCount:(NSNotification *)noti {
    self.libraryView.onMediaItemSelect(@{@"selectedMediaCount": @([MediaPickerManager manager].selectedModels.count), @"overLimit": @(NO)});
}

- (void)addPHAsset:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    PHAsset *asset = userInfo[@"asset"];
    MediaAssetModel *model = [[MediaPickerManager manager] createModelWithAsset:asset];
    if ([MediaPickerManager manager].selectedModels.count < [MediaPickerManager manager].maxSelectedMediaCount) {
        model.isSelected = YES;
        [[MediaPickerManager manager] addSelectedModel:model];
        //更新rn
        self.libraryView.onMediaItemSelect(@{@"selectedMediaCount": @([MediaPickerManager manager].selectedModels.count)});
    }
}

- (void)reloadLibrary:(NSNotification *)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.libraryView reloadData];
    });
}

- (void)fetchAllAssets:(NSNotification *)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.libraryView reloadData];
    });
}

- (void)switchAlbum:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    NSInteger albumIndex = [userInfo[@"albumIndex"] integerValue];
    MediaAlbumModel *model = [[MediaPickerManager manager].albums objectAtIndex:albumIndex];
    [model refreshFetchResult];
    [MediaPickerManager manager].model = model;
    [self fetchAssetWithAlbumModel:model];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    __weak typeof(self) weakSelf = self;
    [[MediaPickerManager manager].model refreshFetchResult];
    [self fetchAssetWithAlbumModel:[MediaPickerManager manager].model];
    [[MediaPickerManager manager] getAllAlbumsWithFetchCover:YES completion:^(NSArray * _Nonnull result, BOOL success) {
        if (success) {
            weakSelf.libraryView.onAlbumUpdate(@{@"newAlbums": result});
        }
    }];
}

- (void)libraryViewDealloc:(NSNotification *)noti {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLibraryStatusDeniedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSelectPhotoCountUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddPHAssetNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReloadLibraryNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFetchAllAssetsNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLibraryDeallocNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - setter


#pragma mark - getter


#pragma mark - data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([MediaPickerManager manager].libraryDenied) {
        return 0;
    }
    NSInteger modelsCount = [MediaPickerManager manager].model.models.count;
    return [MediaPickerManager manager].isVideoOnly ? modelsCount : modelsCount + 1;
}

#pragma mark - delegate

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0 && ![MediaPickerManager manager].isVideoOnly) {
        MediaCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaCameraCell" forIndexPath:indexPath];
        return cell;
    }
    NSInteger index = [MediaPickerManager manager].isVideoOnly ? indexPath.item : indexPath.item - 1;
    MediaAssetModel *model = [MediaPickerManager manager].model.models[index];
    MediaAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaAssetCell" forIndexPath:indexPath];
    cell.model = model;
    cell.showSelectButton = ![MediaPickerManager manager].isVideoOnly;
    if (model.isSelected) cell.index = [[MediaPickerManager manager].selectedAssetIDs indexOfObject:model.asset.localIdentifier] + 1;
    if (model.type == MediaAssetCellTypeVideo) {
        cell.cannotSelectLayer.hidden = !(model.asset.duration < 5 || model.asset.duration > 180);
    } else {
        if ([MediaPickerManager manager].selectedModels.count >= [MediaPickerManager manager].maxSelectedMediaCount && !model.isSelected) {
            cell.cannotSelectLayer.hidden = NO;
        } else {
            cell.cannotSelectLayer.hidden = YES;
        }
    }

    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
        __strong typeof(weakCell) strongCell = weakCell;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        BOOL overLimit = NO;
        if (isSelected) {
            //取消选择
            overLimit = NO;
            strongCell.selectPhotoButton.selected = NO;
            model.isSelected = NO;
            NSArray *selectedModels = [NSArray arrayWithArray:[MediaPickerManager manager].selectedModels];
            for (MediaAssetModel *model_item in selectedModels) {
                if ([model.asset.localIdentifier isEqualToString:model_item.asset.localIdentifier]) {
                    //移除
                    [[MediaPickerManager manager] removeSelectedModel:model_item];
                    break;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadLibraryItemNotification object:nil];
            if (model.iCloudFailed) {
                // iCloud同步失败提醒
                strongSelf.libraryView.onShowToast(@{@"desc": @"iCloud 同步失败"});
            }

        } else {
            //选择
            if ([MediaPickerManager manager].selectedModels.count < [MediaPickerManager manager].maxSelectedMediaCount) {
                overLimit = NO;
                strongCell.selectPhotoButton.selected = YES;
                model.isSelected = YES;
                [[MediaPickerManager manager] addSelectedModel:model];
                [[NSNotificationCenter defaultCenter] postNotificationName:kReloadLibraryItemNotification object:nil];
            } else {
                overLimit = YES;
            }
        }
        if (overLimit) {
            //超出限制
            strongSelf.libraryView.onShowToast(@{@"desc": [NSString stringWithFormat:@"最多只能选%zd张图片", [MediaPickerManager manager].maxSelectedMediaCount]});
        } else {
            //更新RN已选数量
            strongSelf.libraryView.onMediaItemSelect(@{@"selectedMediaCount": @([MediaPickerManager manager].selectedModels.count)});
        }

    };

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0 && ![MediaPickerManager manager].isVideoOnly) {
        if ([MediaPickerManager manager].cameraAuthorizationStatusAuthorized) {
            self.libraryView.onPushCameraPage(@{});
        } else {
            [[MediaPickerManager manager] showCameraNoAuthorizationAlertWithCompletion:^{
                
            }];
        }
        return;
    }
    
    [MediaPickerManager manager].curIndex = [MediaPickerManager manager].isVideoOnly ? indexPath.item : indexPath.item - 1;
    MediaAssetModel *model = [[MediaPickerManager manager].model.models objectAtIndex:[MediaPickerManager manager].curIndex];
    if (model.type == MediaAssetCellTypeVideo) {
        [[MediaPickerManager manager] removeAllSelectedModels];
        [[MediaPickerManager manager] addSelectedModel:model];
    }
    self.libraryView.onPushPreviewPage(@{});
    
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (@available(iOS 14.0, *)) {
        return [MediaPickerManager manager].libraryLimited ? CGSizeMake([UIScreen mainScreen].bounds.size.width, 92) : CGSizeZero;
    } else {
        return CGSizeZero;
    }
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MediaLibraryLimitedView" forIndexPath:indexPath];
}



@end
