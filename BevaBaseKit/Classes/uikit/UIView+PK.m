//
//  UIView+PK.m
//  BevaVideo
//
//  Created by 魏佳林 on 2019/7/2.
//  Copyright © 2019 ProdKids. All rights reserved.
//

#import "UIView+PK.h"

@implementation UIView (PK)

- (void)fadeInUsingScaleWithDuration:(CGFloat)duration delegate:(id<CAAnimationDelegate>)delegate {
    //淡入
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = duration;
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat:1.0f];
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = NO;
    animation.removedOnCompletion = NO;
    
    //放大
    CABasicAnimation * scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = [NSNumber numberWithFloat:0];
    scale.toValue = [NSNumber numberWithFloat:1];
    scale.autoreverses = NO;
    scale.repeatCount = 1;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    scale.duration = duration;
    
    CAAnimationGroup * groupAnimation = [CAAnimationGroup animation];
    groupAnimation.repeatCount = 1;
    groupAnimation.duration = duration;
    groupAnimation.autoreverses = NO;
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.fillMode = kCAFillModeForwards;
    groupAnimation.animations = @[animation, scale];
    if (delegate) {
        groupAnimation.delegate = delegate;
    }
    
    [self.layer addAnimation:groupAnimation forKey:@"pk_fade_in"];
}

- (void)fadeOutUsingScaleWithDuration:(CGFloat)duration delegate:(id<CAAnimationDelegate>)delegate {
    // 淡出
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = duration;
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = NO;
    animation.removedOnCompletion = NO;
    
    //缩放
    CABasicAnimation * scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = [NSNumber numberWithFloat:1];
    scale.toValue = [NSNumber numberWithFloat:0];
    scale.autoreverses = NO;
    scale.repeatCount = 1;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    scale.duration = duration;
    
    CAAnimationGroup * groupAnimation = [CAAnimationGroup animation];
    groupAnimation.repeatCount = 1;
    groupAnimation.duration = duration;
    groupAnimation.autoreverses = NO;
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.fillMode = kCAFillModeForwards;
    groupAnimation.animations = @[animation, scale];
    if (delegate) {
        groupAnimation.delegate = delegate;
    }
    
    [self.layer addAnimation:groupAnimation forKey:@"pk_fade_out"];
}

- (void)shakeTraverse:(CGFloat)t {
    if (t == 0) {
        t = 4;
    }
    CGFloat duration = 0.07;
    CGFloat duration2 = 0.05;
    
    CGAffineTransform translateRight = CGAffineTransformMakeTranslation(t, 0);
    CGAffineTransform translateLeft = CGAffineTransformMakeTranslation(-t, 0);
    
    self.transform = translateLeft;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2];
        self.transform = translateRight;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

@end
