//
//  MediaPhotoThumbnailCell.m
//  ParentingRN
//
//  Created by Evan Hong on 2021/1/12.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "MediaPhotoThumbnailCell.h"
#import "MediaAssetModel.h"
#import <Masonry/Masonry.h>
#import <Photos/Photos.h>
#import "MediaPickerManager.h"

@interface MediaPhotoThumbnailCell()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *selectedView;

@end

@implementation MediaPhotoThumbnailCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _selectedView = [[UIView alloc] init];
        _selectedView.backgroundColor = [UIColor whiteColor];
        _selectedView.layer.cornerRadius = 2;
        _selectedView.layer.masksToBounds = YES;
        _selectedView.hidden = YES;
        [self.contentView addSubview:_selectedView];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.layer.cornerRadius = 2;
        _imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_imageView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(previewCellDidScroll:) name:@"kPreviewCellDisScrollNotification" object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kPreviewCellDisScrollNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)previewCellDidScroll:(NSNotification *)noti {
    NSString *ID = [noti.userInfo valueForKey:@"ID"];
    if ([ID isEqualToString:self.model.asset.localIdentifier]) {
        self.selectedView.hidden = NO;
    } else {
        self.selectedView.hidden = YES;
    }
}


- (void)setModel:(MediaAssetModel *)model {
    _model = model;
    
    MediaAssetModel *disPlayModel = [[MediaPickerManager manager].model.models objectAtIndex:[MediaPickerManager manager].curIndex];
    if ([disPlayModel.asset.localIdentifier isEqualToString:self.model.asset.localIdentifier]) {
        _selectedView.hidden = NO;
    } else {
        _selectedView.hidden = YES;
    }
    
    [_selectedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.height.equalTo(self.contentView);
    }];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView).mas_offset(2);
        make.right.bottom.equalTo(self.contentView).mas_offset(-2);
    }];
    
    self.representedAssetIdentifier = model.asset.localIdentifier;
    int32_t imageRequestID = [[MediaPickerManager manager] getPhotoWithAsset:model.asset photoWidth:self.frame.size.width - 4 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if ([self.representedAssetIdentifier isEqualToString:model.asset.localIdentifier]) {
            self.imageView.image = photo;
        } else {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
    } progressHandler:nil networkAccessAllowed:NO];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
    
}



@end
