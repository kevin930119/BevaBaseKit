//
//  PKImageView.h
//  BevaProject
//
//  Created by 魏佳林 on 2019/5/10.
//  Copyright © 2019 ProdKids. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SDWebImage/SDAnimatedImageView+WebCache.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKImageView : SDAnimatedImageView

/**
 设置本地/网络图片，支持gif图

 @param urlString 图片地址
 */
- (void)setImageWithURLString:(nullable NSString *)urlString;

/**
 设置本地/网络图片，支持gif图
 
 @param urlString 图片地址
 @param placeholderImage 默认填充图片
 */
- (void)setImageWithURLString:(nullable NSString *)urlString placeholderImage:(nullable UIImage *)placeholderImage;

@end

NS_ASSUME_NONNULL_END
