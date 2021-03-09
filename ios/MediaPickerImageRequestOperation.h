//
//  MediaPickerImageRequestOperation.h
//  ParentingRN
//
//  Created by Evan Hong on 2020/12/28.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediaPickerImageRequestOperation : NSOperation

typedef void(^MediaPickerImageRequestCompletedBlock)(UIImage *photo, NSDictionary *info, BOOL isDegraded);
typedef void(^MediaPickerImageRequestProgressBlock)(double progress, NSError *error, BOOL *stop, NSDictionary *info);

@property (nonatomic, copy, nullable) MediaPickerImageRequestCompletedBlock completedBlock;
@property (nonatomic, copy, nullable) MediaPickerImageRequestProgressBlock progressBlock;
@property (nonatomic, strong, nullable) PHAsset *asset;

@property (nonatomic, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, assign, getter=isFinished) BOOL finished;

- (instancetype)initWithAsset:(PHAsset *)asset completion:(MediaPickerImageRequestCompletedBlock)completionBlock progressHandler:(MediaPickerImageRequestProgressBlock)progressHandler;
- (void)done;


@end

NS_ASSUME_NONNULL_END
