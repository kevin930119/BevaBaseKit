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

- (void)shakeTraverseUpDown:(CGFloat)t {
    if (t == 0) {
        t = 4;
    }
    CGFloat duration = 0.20;
//    CGFloat duration2 = 0.20;
    
    CGAffineTransform translateUp = CGAffineTransformMakeTranslation(0, t);
    CGAffineTransform translatedDown = CGAffineTransformMakeTranslation(0, -t);
    
    self.transform = translateUp;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2];
        self.transform = translatedDown;
    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:duration2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//            self.transform = CGAffineTransformIdentity;
//        } completion:nil];
    }];
}

- (void)addLayerTransition:(PKViewTransitionType)type subType:(PKViewTransitionSubType)subType curve:(PKViewTransitionCurve)curve duration:(CGFloat)duration delegate:(nullable id<CAAnimationDelegate>)delegate {
    // 创建动画
    NSString *key = @"transition";
    if ([self.layer animationForKey:key]) {
        [self.layer removeAnimationForKey:key];
    }
    
    CATransition *transition = [CATransition animation];
    
    NSArray *typeArray = @[@"fade", @"push", @"reveal", @"moveIn", @"cube", @"oglFlip", @"pageCurl", @"pageUnCurl", @"random"];
    NSString *typeString = nil;
    if (type == PKViewTransitionTypeRandom) {
        typeString = [self _objectInArray:typeArray index:type random:YES];
    } else {
        typeString = [self _objectInArray:typeArray index:type random:NO];
    }
    NSArray *subTypeArray = @[kCATransitionFromTop, kCATransitionFromBottom, kCATransitionFromLeft, kCATransitionFromRight, @"random"];
    NSString *subTypeString = nil;
    if (subType == PKViewTransitionSubTypeRandom) {
        subTypeString = [self _objectInArray:subTypeArray index:subType random:YES];
    } else {
        subTypeString = [self _objectInArray:subTypeArray index:subType random:NO];
    }
    NSArray *curveArray = @[kCAMediaTimingFunctionDefault, kCAMediaTimingFunctionEaseIn, kCAMediaTimingFunctionEaseOut, kCAMediaTimingFunctionEaseInEaseOut, kCAMediaTimingFunctionLinear, @"random"];
    NSString *curveString = nil;
    if (curve == PKViewTransitionCurveRandom) {
        curveString = [self _objectInArray:curveArray index:curve random:YES];
    } else {
        curveString = [self _objectInArray:curveArray index:curve random:NO];
    }
    
    transition.type = typeString;
    transition.subtype = subTypeString;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:curveString];
    transition.duration = duration;
    transition.removedOnCompletion = YES;
    if (delegate) {
        transition.delegate = delegate;
    }
    
    [self.layer addAnimation:transition forKey:key];
}

- (void)executeTransition:(UIViewAnimationOptions)type fromView:(UIView *)fromView toView:(UIView *)toView duration:(CGFloat)duration completion:(void (^)(BOOL))completion {
    if (![self.subviews containsObject:fromView]) {
        [self addSubview:fromView];
    }
    
    [UIView transitionFromView:fromView toView:toView duration:duration options:type completion:^(BOOL finished) {
        [fromView removeFromSuperview];
        
        if (completion) {
            completion(finished);
        }
    }];
    
    [self addSubview:toView];
}

- (id)_objectInArray:(NSArray *)array index:(NSInteger)index random:(BOOL)random {
    NSInteger count = array.count;
    NSInteger i = random?((NSInteger)arc4random_uniform((uint32_t)count)):(index);
    return array[i];
}

@end
