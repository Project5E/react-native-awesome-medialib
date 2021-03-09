//
//  ImageUtil.m
//  ParentingRN
//
//  Created by skylar on 2021/1/4.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "ImageUtil.h"

@implementation ImageUtil

+ (NSString *)createFilePathWithFileSuffix:(NSString *)suffix {
    NSString *rootPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@""];
    NSString *uuidStr = [[NSUUID UUID] UUIDString];
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", uuidStr, suffix];
    return [rootPath stringByAppendingPathComponent:fileName];
}

+ (NSData *)cropImageToSquare:(UIImage *)image point:(CGPoint)point width:(CGFloat)width {
    UIGraphicsImageRendererFormat *format = [[UIGraphicsImageRendererFormat alloc] init];
    format.scale = 0.5;
    UIGraphicsImageRenderer *render = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(width, width) format:format];
    NSData *data = [render JPEGDataWithCompressionQuality:0.7 actions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
      [image drawAtPoint:CGPointMake(-point.x, -point.y)];
    }];
    return data;
}

@end
