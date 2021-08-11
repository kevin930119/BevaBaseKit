//
//  UIView+PK.h
//  BevaVideo
//
//  Created by 魏佳林 on 2019/7/2.
//  Copyright © 2019 ProdKids. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 动画类型
typedef NS_ENUM(NSInteger, PKViewTransitionType) {
    PKViewTransitionTypeFade = 0,   // 淡入淡出
    PKViewTransitionTypePush,   // 推挤
    PKViewTransitionTypeReveal, // 揭开
    PKViewTransitionTypeMoveIn, // 覆盖
    PKViewTransitionTypeCube,   // 立方体
    PKViewTransitionTypeOglFlip,    // 翻转
    PKViewTransitionTypePageCurl,   // 翻页
    PKViewTransitionTypePageUnCurl, // 反翻页
    PKViewTransitionTypeRandom  // 随机
};

// 动画方向
typedef NS_ENUM(NSInteger, PKViewTransitionSubType) {
    PKViewTransitionSubTypeTop = 0, // 上
    PKViewTransitionSubTypeBottom,  // 下
    PKViewTransitionSubTypeLeft,    // 左
    PKViewTransitionSubTypeRight,   // 右
    PKViewTransitionSubTypeRandom   // 随机
};

// 动画速度曲线
typedef NS_ENUM(NSInteger, PKViewTransitionCurve) {
    PKViewTransitionCurveDefault = 0,   // 默认
    PKViewTransitionCurveEaseIn,    // 缓进
    PKViewTransitionCurveEaseOut,   // 缓出
    PKViewTransitionCurveEaseInEaseOut, // 缓进缓出
    PKViewTransitionCurveLinear,    // 线性
    PKViewTransitionCurveRandom // 随机
};

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

/**
 上下震动
 
 @param t 横移幅度，传0，默认为4个像素
 */
- (void)shakeTraverseUpDown:(CGFloat)t;

/**
 执行一个视图过渡动画
 self 执行动画的对象
 fromView 执行动画前的子视图
 toView 执行动画后的子视图
 */
- (void)executeTransition:(UIViewAnimationOptions)type fromView:(UIView *)fromView toView:(UIView *)toView duration:(CGFloat)duration completion:(nullable void(^)(BOOL finished))completion;

/**
 layer层Transition动画
 */
- (void)addLayerTransition:(PKViewTransitionType)type subType:(PKViewTransitionSubType)subType curve:(PKViewTransitionCurve)curve duration:(CGFloat)duration delegate:(nullable id<CAAnimationDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
