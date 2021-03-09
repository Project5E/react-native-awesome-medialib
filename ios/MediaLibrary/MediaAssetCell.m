//
//  MediaAssetCell.m
//  ParentingRN
//
//  Created by Evan Hong on 2020/12/17.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "MediaAssetCell.h"
#import "MediaAssetModel.h"
#import "MediaPickerManager.h"
#import "MediaPickerConst.h"
#import "MediaPickerTools.h"
#import "MediaProgressView.h"
#import <Photos/Photos.h>

@interface MediaAssetCell()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *timeLength;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIImageView *selectImageView;

@property (nonatomic, strong) UILabel *indexLabel;

@property (nonatomic, assign) int32_t bigImageRequestID;

@property (nonatomic, strong) MediaProgressView *progressView;

@end

@implementation MediaAssetCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:kReloadLibraryItemNotification object:nil];
    self.contentView.layer.cornerRadius = 2.0f;
    self.contentView.layer.masksToBounds = YES;
    return self;
}

- (void)requestBigImage {
    if (_bigImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequestID];
    }
    
    _bigImageRequestID = [[MediaPickerManager manager] requestImageDataForAsset:_model.asset completion:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        BOOL iCloudSyncFailed = !imageData && [MediaPickerTools isICloudSyncError:info[PHImageErrorKey]];
        self.model.iCloudFailed = iCloudSyncFailed;
        if (iCloudSyncFailed && self.didSelectPhotoBlock) {
            self.didSelectPhotoBlock(YES);
            self.selectImageView.image = [UIImage imageNamed:@"medialibrary_selectimage_def"];
        }
        [self hideProgressView];
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        if (self.model.isSelected) {
            self.progressView.progress = progress;
            self.progressView.hidden = NO;
            self.imageView.alpha = 0.4;
            if (progress >= 1) {
                [self hideProgressView];
            }
        } else {
            [self cancelBigImageRequest];
        }
    }];
    if (_model.type == MediaAssetCellTypeVideo) {
        [[MediaPickerManager manager] getVideoWithAsset:_model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
            BOOL iCloudSyncFailed = !playerItem && [MediaPickerTools isICloudSyncError:info[PHImageErrorKey]];
            self.model.iCloudFailed = iCloudSyncFailed;
            if (iCloudSyncFailed && self.didSelectPhotoBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.didSelectPhotoBlock(YES);
                    self.selectImageView.image = [UIImage imageNamed:@"medialibrary_selectimage_def"];
                });
            }
        }];
    }
}

- (void)cancelBigImageRequest {
    if (_bigImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequestID];
    }
    [self hideProgressView];
}

- (void)hideProgressView {
    if (_progressView) {
        self.progressView.hidden = YES;
        self.imageView.alpha = 1.0;
    }
}

#pragma mark - event

- (void)reload:(NSNotification *)noti {
    if (self.model.isSelected) {
        self.selectPhotoButton.selected = YES;
        self.index = [[MediaPickerManager manager].selectedAssetIDs indexOfObject:self.model.asset.localIdentifier] + 1;
    } else {
        self.selectPhotoButton.selected = NO;
    }
    self.indexLabel.hidden = !self.selectPhotoButton.isSelected;
    self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamed:@"medialibrary_selectimage_sel"] : [UIImage imageNamed:@"medialibrary_selectimage_def"];
    if ([MediaPickerManager manager].selectedModels.count >= [MediaPickerManager manager].maxSelectedMediaCount && !self.model.isSelected) {
        self.cannotSelectLayer.hidden = NO;
    } else {
        self.cannotSelectLayer.hidden = YES;
    }
}

#pragma mark - setter

- (void)setModel:(MediaAssetModel *)model {
    _model = model;
    self.representedAssetIdentifier = model.asset.localIdentifier;
    int32_t imageRequestID = [[MediaPickerManager manager] getPhotoWithAsset:model.asset photoWidth:self.frame.size.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if ([self.representedAssetIdentifier isEqualToString:model.asset.localIdentifier]) {
            self.imageView.image = photo;
            [self setNeedsLayout];
        } else {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
            [self hideProgressView];
            self.imageRequestID = 0;
        }
    } progressHandler:nil networkAccessAllowed:NO];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
    self.selectPhotoButton.selected = model.isSelected;
    self.indexLabel.hidden = !self.selectPhotoButton.isSelected;
    self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamed:@"medialibrary_selectimage_sel"] : [UIImage imageNamed:@"medialibrary_selectimage_def"];
    self.type = (NSInteger)model.type;
  
    if (model.isSelected) {
        [self requestBigImage];
    } else {
        [self cancelBigImageRequest];
    }
    
    [self setNeedsLayout];
    
}


- (void)setType:(MediaAssetCellType)type {
    _type = type;
    
    if (type == MediaAssetCellTypePhoto || type == MediaAssetCellTypeLivePhoto || type == MediaAssetCellTypePhotoGif) {
        // image
        _selectImageView.hidden = NO;
        _selectPhotoButton.hidden = NO;
    } else {
        // video
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
        self.bottomView.hidden = NO;
        self.timeLength.text = _model.timeLength;
    }
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    self.indexLabel.text = [NSString stringWithFormat:@"%zd", index];
    [self.contentView bringSubviewToFront:self.indexLabel];
}

- (void)setShowSelectButton:(BOOL)showSelectButton {
    _showSelectButton = showSelectButton;
    
    if (!self.selectPhotoButton.hidden) {
        self.selectPhotoButton.hidden = !showSelectButton;
    }
    if (!self.selectImageView.hidden) {
        self.selectImageView.hidden = !showSelectButton;
    }
}

#pragma getter

- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

- (UIButton *)selectPhotoButton {
    if (_selectPhotoButton == nil) {
        UIButton *selectPhotoButton = [[UIButton alloc] init];
        [selectPhotoButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectPhotoButton];
        _selectPhotoButton = selectPhotoButton;
    }
    return _selectPhotoButton;
}

- (UIView *)cannotSelectLayer {
    if (_cannotSelectLayer == nil) {
        UIView *cannotSelectLayer = [[UIView alloc] init];
        cannotSelectLayer.backgroundColor = [UIColor colorWithRed:247 / 255.0 green:247 / 255.0 blue:247 / 255.0 alpha:0.65];
        [self.contentView addSubview:cannotSelectLayer];
        _cannotSelectLayer = cannotSelectLayer;
    }
    return _cannotSelectLayer;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        bottomView.userInteractionEnabled = NO;
        bottomView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UILabel *)timeLength {
    if (_timeLength == nil) {
        UILabel *timeLength = [[UILabel alloc] init];
        timeLength.font = [UIFont boldSystemFontOfSize:11];
        timeLength.textColor = [UIColor whiteColor];
        timeLength.textAlignment = NSTextAlignmentRight;
        [self.bottomView addSubview:timeLength];
        _timeLength = timeLength;
    }
    return _timeLength;
}

- (UIImageView *)selectImageView {
    if (_selectImageView == nil) {
        UIImageView *selectImageView = [[UIImageView alloc] init];
        selectImageView.contentMode = UIViewContentModeCenter;
        selectImageView.clipsToBounds = YES;
        [self.contentView addSubview:selectImageView];
        _selectImageView = selectImageView;
    }
    return _selectImageView;
}

- (UILabel *)indexLabel {
    if (_indexLabel == nil) {
        UILabel *indexLabel = [[UILabel alloc] init];
        indexLabel.font = [UIFont systemFontOfSize:12 weight:700];
        indexLabel.adjustsFontSizeToFitWidth = YES;
        indexLabel.textColor = [UIColor colorWithRed:26 / 255.0 green:26 / 255.0 blue:26 / 255.0 alpha:1];
        indexLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:indexLabel];
        _indexLabel = indexLabel;
    }
    return _indexLabel;
}

- (MediaProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [[MediaProgressView alloc] init];
        _progressView.hidden = YES;
        [self addSubview:_progressView];
    }
    return _progressView;
}

#pragma mark - event

- (void)selectPhotoButtonClick:(UIButton *)sender {
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.isSelected);
    }
    self.selectImageView.image = sender.isSelected ? [UIImage imageNamed:@"medialibrary_selectimage_sel"] : [UIImage imageNamed:@"medialibrary_selectimage_def"];
    
    if (sender.isSelected) {
        [self requestBigImage];
    } else {
        [self cancelBigImageRequest];
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _selectPhotoButton.frame = CGRectMake(self.frame.size.width - 44, 0, 44, 44);
    _cannotSelectLayer.frame = self.bounds;
    _imageView.frame = self.bounds;
    _selectImageView.frame = CGRectMake(self.frame.size.width - 38, 6, 32, 32);
    _selectImageView.contentMode = UIViewContentModeScaleAspectFit;
    _indexLabel.frame = _selectImageView.frame;
    
    _bottomView.frame = CGRectMake(0, self.frame.size.height - 17, self.frame.size.width, 17);
    _timeLength.frame = CGRectMake(0, 0, self.frame.size.width - 5, 17);
    
    CGFloat progressWH = 20;
    CGFloat progressXY = (self.frame.size.width - progressWH) / 2;
    _progressView.frame = CGRectMake(progressXY, progressXY, progressWH, progressWH);


    [self.contentView bringSubviewToFront:_bottomView];
    [self.contentView bringSubviewToFront:_cannotSelectLayer];
    [self.contentView bringSubviewToFront:_selectPhotoButton];
    [self.contentView bringSubviewToFront:_selectImageView];
    [self.contentView bringSubviewToFront:_indexLabel];
}

@end
