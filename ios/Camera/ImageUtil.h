//
//  ImageUtil.h
//  ParentingRN
//
//  Created by skylar on 2021/1/4.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageUtil : NSObject

+ (NSString *)createFilePathWithFileSuffix:(NSString *)suffix;
+ (NSData *)cropImageToSquare:(UIImage *)image point:(CGPoint)point width:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
