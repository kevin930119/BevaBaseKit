//
//  UIView+PK.h
//  BevaVideo
//
//  Created by 魏佳林 on 2019/7/2.
//  Copyright © 2019 ProdKids. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (PKAnimation)

/**
 缩放淡入动画效果

 @param duration 动画时长
 @param delegate 动画代理对象
 */
- (void)fadeInUsingScaleWithDuration:(CGFloat)duration delegate:(nullable id<CAAnimationDelegate>)delegate;

/**
 缩放淡出动画效果
 
 @param duration 动画时长
 @param delegate 动画代理对象
 */
- (void)fadeOutUsingScaleWithDuration:(CGFloat)duration delegate:(nullable id<CAAnimationDelegate>)delegate;

/**
 横移震动
 
 @param t 横移幅度，传0，默认为4个像素
 */
- (void)shakeTraverse:(CGFloat)t;

@end

NS_ASSUME_NONNULL_END
