//
//  UIImage+PK.h
//  BevaBaseKit
//
//  Created by 魏佳林 on 2019/10/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (PK)

/**
 获取一张纯色图片
 */
+ (UIImage *)pureColorImageWithColor:(UIColor *)color size:(CGSize)size;

/**
 对图片进行圆角处理
 */
+ (UIImage *)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r;

@end

NS_ASSUME_NONNULL_END
