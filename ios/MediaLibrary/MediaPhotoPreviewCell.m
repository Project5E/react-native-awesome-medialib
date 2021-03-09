//
//  MediaPhotoPreviewCell.m
//  ParentingRN
//
//  Created by Evan Hong on 2021/1/6.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "MediaPhotoPreviewCell.h"
#import "MediaPickerManager.h"
#import "MediaAssetModel.h"
#import "MediaPickerTools.h"
#import "MediaProgressView.h"

@implementation MediaPhotoPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self configSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoPreviewCollectionViewDidScroll) name:@"photoPreviewCollectionViewDidScroll" object:nil];
    }
    return self;
}

- (void)configSubviews {
  self.previewView = [[MediaPhotoPreviewView alloc] initWithFrame:CGRectZero];
  __weak typeof(self) weakSelf = self;
  [self.previewView setImageProgressUpdateBlock:^(double progress) {
      __strong typeof(weakSelf) strongSelf = weakSelf;
      if (strongSelf.imageProgressUpdateBlock) {
          strongSelf.imageProgressUpdateBlock(progress);
      }
  }];
  [self.contentView addSubview:self.previewView];
}

- (void)setModel:(MediaAssetModel *)model {
  _model = model;
  _previewView.model = model;
}

#pragma mark - Event
- (void)photoPreviewCollectionViewDidScroll {
  NSLog(@"photoPreviewCollectionViewDidScroll");
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.previewView.frame = self.bounds;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end


@implementation MediaPhotoPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    
      _imageView = [[UIImageView alloc] init];
      _imageView.backgroundColor = [UIColor redColor];
      _imageView.contentMode = UIViewContentModeScaleAspectFill;
      _imageView.clipsToBounds = YES;
      [self addSubview:_imageView];
      
      _iCloudErrorIcon = [[UIImageView alloc] init];
      _iCloudErrorIcon.image = [UIImage imageNamed:@"iCloud_error"];
      _iCloudErrorIcon.hidden = YES;
      [self addSubview:_iCloudErrorIcon];
      _iCloudErrorLabel = [[UILabel alloc] init];
      _iCloudErrorLabel.font = [UIFont systemFontOfSize:10];
      _iCloudErrorLabel.textColor = [UIColor whiteColor];
      _iCloudErrorLabel.text = @"iCloud同步失败";
      _iCloudErrorLabel.hidden = YES;
      [self addSubview:_iCloudErrorLabel];
      
      [self configProgressView];
  }
  return self;
}

- (void)configProgressView {
    _progressView = [[MediaProgressView alloc] init];
    _progressView.hidden = YES;
    [self addSubview:_progressView];
}

- (void)setModel:(MediaAssetModel *)model {
  _model = model;
  self.asset = model.asset;
}

- (void)setAsset:(id)asset {
  if (_asset && self.imageRequestID) {
      [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
  }
  _asset = asset;
  self.imageRequestID = [[MediaPickerManager manager] getPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
      BOOL iCloudSyncFailed = !photo && [MediaPickerTools isICloudSyncError:info[PHImageErrorKey]];
      self.iCloudErrorLabel.hidden = !iCloudSyncFailed;
      self.iCloudErrorIcon.hidden = !iCloudSyncFailed;
      if (self.iCloudSyncFailedHandle) {
          self.iCloudSyncFailedHandle(asset, iCloudSyncFailed);
      }
      if (![asset isEqual:self->_asset]) return;
      if (photo) {
          self.imageView.image = photo;
      }
      [self resizeSubviews];

      self->_progressView.hidden = YES;
      if (self.imageProgressUpdateBlock) {
          self.imageProgressUpdateBlock(1);
      }
      if (!isDegraded) {
          self.imageRequestID = 0;
      }
  } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
      if (![asset isEqual:self->_asset]) return;
      self->_progressView.hidden = NO;
      [self bringSubviewToFront:self->_progressView];
      progress = progress > 0.02 ? progress : 0.02;
      self->_progressView.progress = progress;
      if (self.imageProgressUpdateBlock && progress < 1) {
          self.imageProgressUpdateBlock(progress);
      }

      if (progress >= 1) {
          self->_progressView.hidden = YES;
          self.imageRequestID = 0;
      }
  } networkAccessAllowed:YES];

}


- (void)resizeSubviews {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat imageViewWidth = screenWidth;
    CGFloat imageViewHeight = 0;
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.frame.size.height / screenWidth) {
        imageViewHeight = floor(image.size.height / (image.size.width / screenWidth));
    } else {
        CGFloat height = image.size.height / image.size.width * screenWidth;
        if (height < 1 || isnan((height))) height = self.frame.size.height;
        height = floor(height);
        imageViewHeight = height;
    }
    _imageView.frame = CGRectMake(0, 0, imageViewWidth, imageViewHeight);
    _imageView.center = CGPointMake(_imageView.center.x, self.frame.size.height * 0.5);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    static CGFloat progressWH = 40;
    CGFloat progressX = ([UIScreen mainScreen].bounds.size.width - progressWH) / 2;
    CGFloat progressY = ([UIScreen mainScreen].bounds.size.height - progressWH) / 2;
    _progressView.frame = CGRectMake(progressX, progressY, progressWH, progressWH);
    _iCloudErrorIcon.frame = CGRectMake(20, [MediaPickerTools statusBarHeight] + 44 + 10, 28, 28);
    _iCloudErrorLabel.frame = CGRectMake(53, [MediaPickerTools statusBarHeight] + 44 + 10, [UIScreen mainScreen].bounds.size.width - 63, 28);
    [self resizeSubviews];
    
}


@end
