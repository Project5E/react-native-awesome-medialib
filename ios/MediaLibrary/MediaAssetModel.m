//
//  MediaAssetModel.m
//  ParentingRN
//
//  Created by Evan Hong on 2020/12/17.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "MediaAssetModel.h"
#import "MediaPickerManager.h"


@implementation MediaAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(MediaAssetType)type {
    MediaAssetModel *model = [[MediaAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(MediaAssetType)type timeLength:(NSString *)timeLength {
    MediaAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

@end


@implementation MediaAlbumModel

- (void)setResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets {
    _result = result;
    if (needFetchAssets) {
        [[MediaPickerManager manager] getAssetsFromFetchResult:result completion:^(NSArray<MediaAssetModel *> *models) {
            self->_models = models;
        }];
    }
}

- (void)refreshFetchResult {
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:self.collection options:self.options];
    self.count = fetchResult.count;
    self.result = fetchResult;
}

- (NSString *)name {
    if (_name) {
        return _name;
    }
    return @"";
}

@end
