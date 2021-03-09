//
//  MediaLibraryPhotoPreviewManager.m
//  ParentingRN
//
//  Created by Evan Hong on 2021/1/6.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "MediaLibraryPhotoPreviewManager.h"
#import "MediaLibraryPhotoPreview.h"
#import "MediaPickerManager.h"
#import "MediaAssetModel.h"
#import "MediaPhotoPreviewCell.h"
#import "MediaPhotoThumbnailCell.h"
#import "MediaPickerConst.h"
#import "MediaPickerTools.h"
#import <Masonry/Masonry.h>

@interface MediaLibraryPhotoPreviewManager()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) MediaLibraryPhotoPreview *preview;

@property (nonatomic, weak) UICollectionView *previewCollectionView;

@property (nonatomic, weak) UICollectionView *selectedPhotoCollectionView;

@property (nonatomic, weak) UIButton *selectButton;

@property (nonatomic, weak) UILabel *indexLabel;

@property (nonatomic, weak) UILabel *descLabel;

@property (nonatomic, weak) UIButton *doneButton;

@end

@implementation MediaLibraryPhotoPreviewManager
RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(onFinishSelect, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onShowToast, RCTBubblingEventBlock)

- (UIView *)view {
    MediaLibraryPhotoPreview *preview = [[MediaLibraryPhotoPreview alloc] init];
    UICollectionView *previewCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[self configPreviewLayout]];
    previewCollectionView.backgroundColor = [UIColor blackColor];
    previewCollectionView.dataSource = self;
    previewCollectionView.delegate = self;
    previewCollectionView.pagingEnabled = YES;
    previewCollectionView.scrollsToTop = NO;
    previewCollectionView.showsHorizontalScrollIndicator = NO;
    previewCollectionView.showsVerticalScrollIndicator = NO;
    previewCollectionView.contentOffset = CGPointMake([MediaPickerManager manager].curIndex * [UIScreen mainScreen].bounds.size.width, 0);
    previewCollectionView.contentSize = CGSizeMake([MediaPickerManager manager].model.models.count * [UIScreen mainScreen].bounds.size.width, 0);
    previewCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [previewCollectionView registerClass:[MediaPhotoPreviewCell class] forCellWithReuseIdentifier:@"MediaPhotoPreviewCell"];
    [preview addSubview:previewCollectionView];
    [previewCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.left.top.equalTo(preview);
    }];
    self.previewCollectionView = previewCollectionView;
    self.preview = preview;
    [self addBottomBar];
    return preview;
}


- (UICollectionViewFlowLayout *)configPreviewLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    return layout;
}

- (void)addBottomBar {
    UIView *bottomBar = [[UIView alloc] init];
    bottomBar.backgroundColor = [UIColor colorWithRed:26 / 255.0 green:26 / 255.0 blue:26 /255.0 alpha:0.5];
    CGFloat height = 146 + [MediaPickerTools safeAreaInsets].bottom;
    [self.preview addSubview:bottomBar];
    [bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.preview);
        make.width.equalTo(self.preview);
        make.height.mas_equalTo(height);
        make.bottom.equalTo(self.preview);
    }];
    
    //
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(68, 68);
    layout.minimumInteritemSpacing = 16;
    layout.minimumLineSpacing = 16;
    UICollectionView *selectedPhotoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    selectedPhotoCollectionView.backgroundColor = [UIColor clearColor];
    selectedPhotoCollectionView.alwaysBounceHorizontal = YES;
    selectedPhotoCollectionView.dataSource = self;
    selectedPhotoCollectionView.delegate = self;
    selectedPhotoCollectionView.showsHorizontalScrollIndicator = NO;
    selectedPhotoCollectionView.showsVerticalScrollIndicator = NO;
    selectedPhotoCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    selectedPhotoCollectionView.contentInset = UIEdgeInsetsMake(0, 16, 0, 0);
    [selectedPhotoCollectionView registerClass:[MediaPhotoThumbnailCell class] forCellWithReuseIdentifier:@"MediaPhotoThumbnailCell"];
    [bottomBar addSubview:selectedPhotoCollectionView];
    self.selectedPhotoCollectionView = selectedPhotoCollectionView;
    [selectedPhotoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.equalTo(bottomBar);
        make.height.mas_equalTo(96);
    }];
    
    //
    MediaAssetModel *displayModel = [[MediaPickerManager manager].model.models objectAtIndex:[MediaPickerManager manager].curIndex];
    UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectButton setImage:[UIImage imageNamed:@"medialibrary_preview_selectimage_def"] forState:UIControlStateNormal];
    [selectButton setImage:[UIImage imageNamed:@"medialibrary_selectimage_sel"] forState:UIControlStateSelected];
    [selectButton addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:selectButton];
    self.selectButton = selectButton;
    [selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(44);
        make.left.equalTo(bottomBar).mas_offset(10);
        make.top.equalTo(selectedPhotoCollectionView.mas_bottom).mas_offset(3);
    }];

    UILabel *indexLabel = [[UILabel alloc] init];
    indexLabel.font = [UIFont systemFontOfSize:12 weight:700];
    indexLabel.textColor = [UIColor colorWithRed:26 / 255.0 green:26 / 255.0 blue:26 / 255.0 alpha:1];
    indexLabel.textAlignment = NSTextAlignmentCenter;
    [selectButton addSubview:indexLabel];
    self.indexLabel = indexLabel;
    [indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(selectButton);
        make.width.height.mas_equalTo(32);
    }];
         
    
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.font = [UIFont systemFontOfSize:14 weight:600];
    descLabel.textColor = [UIColor whiteColor];
    descLabel.textAlignment = NSTextAlignmentCenter;
    [bottomBar addSubview:descLabel];
    self.descLabel = descLabel;
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bottomBar);
        make.top.equalTo(selectedPhotoCollectionView.mas_bottom).mas_offset(15);
    }];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton addTarget:self action:@selector(doneSelect:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitle:@"下一步" forState:UIControlStateNormal];
    doneButton.titleLabel.textColor = [UIColor whiteColor];
    doneButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:600];
    [bottomBar addSubview:doneButton];
    self.doneButton = doneButton;
    [doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(56);
        make.height.mas_equalTo(25);
        make.top.equalTo(selectedPhotoCollectionView.mas_bottom).mas_equalTo(12.5);
        make.right.equalTo(bottomBar).mas_equalTo(-16);
    }];
    
    [self updateUIWithCurModel:displayModel];
    
}


- (void)didICloudSyncStatusChanged:(MediaAssetModel *)model{
    dispatch_async(dispatch_get_main_queue(), ^{
        MediaAssetModel *currentModel = [MediaPickerManager manager].model.models[[MediaPickerManager manager].curIndex];
        if ([MediaPickerManager manager].selectedModels.count <= 0) {
            self.doneButton.enabled = !currentModel.iCloudFailed;
        } else {
            self.doneButton.enabled = YES;
        }
        self.selectButton.hidden = currentModel.iCloudFailed;
    });
}

#pragma mark - event

- (void)selectPhoto:(UIButton *)sender {
    if (!sender.isSelected && [MediaPickerManager manager].selectedModels.count >= [MediaPickerManager manager].maxSelectedMediaCount) {
        self.preview.onShowToast(@{@"desc": [NSString stringWithFormat:@"最多只能选择%zd张照片", [MediaPickerManager manager].maxSelectedMediaCount]});
        return;
    }
    MediaAssetModel *displayModel = [[MediaPickerManager manager].model.models objectAtIndex:[MediaPickerManager manager].curIndex];
    displayModel.isSelected = !displayModel.isSelected;
    if (displayModel.isSelected) {
        [[MediaPickerManager manager] addSelectedModel:displayModel];
    } else {
        [[MediaPickerManager manager] removeSelectedModel:displayModel];
    }
    [self.selectedPhotoCollectionView reloadData];
    [self updateUIWithCurModel:displayModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectPhotoCountUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadLibraryItemNotification object:nil];
}

- (void)doneSelect:(UIButton *)sender {
    if ([MediaPickerManager manager].selectedModels.count <= 0) {
        NSLog(@"太少");
        return;
    }
    
    self.preview.onFinishSelect(@{});
}


#pragma mark - delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.previewCollectionView == collectionView) {
        return [MediaPickerManager manager].model.models.count;
    } else {
        return [MediaPickerManager manager].selectedModels.count;
    }

}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MediaAssetModel *model;
    if (self.previewCollectionView == collectionView) {
        model = [MediaPickerManager manager].model.models[indexPath.item];
        MediaPhotoPreviewCell *photoPreviewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaPhotoPreviewCell" forIndexPath:indexPath];
        photoPreviewCell.model = model;
        photoPreviewCell.previewView.iCloudSyncFailedHandle = ^(id asset, BOOL isSyncFailed) {
            model.iCloudFailed = isSyncFailed;
        };
        return photoPreviewCell;
    } else {
        model = [MediaPickerManager manager].selectedModels[indexPath.item];
        MediaPhotoThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaPhotoThumbnailCell" forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.selectedPhotoCollectionView) {
        MediaAssetModel *model = [MediaPickerManager manager].selectedModels[indexPath.item];
        NSInteger index = [[MediaPickerManager manager].model.models indexOfObject:model];
        if (index != NSNotFound) {
            [self scrollAtIndexIfNeeded:index];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.previewCollectionView == scrollView) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat offsetWidth = scrollView.contentOffset.x;
        
        NSInteger currentIndex = offsetWidth / screenWidth;
        if (currentIndex < [MediaPickerManager manager].model.models.count && [MediaPickerManager manager].curIndex != currentIndex) {
            [MediaPickerManager manager].curIndex = currentIndex;
            MediaAssetModel *curModel = [MediaPickerManager manager].model.models[currentIndex];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kPreviewCellDisScrollNotification" object:nil userInfo:@{@"ID": curModel.asset.localIdentifier}];
            [self updateUIWithCurModel:curModel];
        }
    }
}

- (void)scrollAtIndexIfNeeded:(NSInteger)index {
    // 偏移量
    if ([MediaPickerManager manager].model.models.count && index >= 0) {
        [self.previewCollectionView setContentOffset:CGPointMake(index * [UIScreen mainScreen].bounds.size.width, 0) animated:NO];
    }
}

- (void)updateUIWithCurModel:(MediaAssetModel *)model {
    BOOL isSelected = model.isSelected;
    self.selectButton.selected = isSelected;
    self.indexLabel.hidden = !isSelected;
    self.indexLabel.text = isSelected ? [NSString stringWithFormat:@"%zd", [[MediaPickerManager manager].selectedAssetIDs indexOfObject:model.asset.localIdentifier] + 1] : @"";
    self.descLabel.text = [NSString stringWithFormat:@"已选%zd张", [MediaPickerManager manager].selectedModels.count];
    self.doneButton.enabled = [MediaPickerManager manager].selectedModels.count > 0;
    
}

@end
