//
//  PKAdaptScreenEdgePanScrollView.m
//  BevaProject
//
//  Created by 魏佳林 on 2019/5/24.
//  Copyright © 2019 ProdKids. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PKAdaptScreenEdgePanScrollView.h"

@implementation PKAdaptScreenEdgePanScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 首先判断otherGestureRecognizer是不是系统pop手势
    if ([otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

@end
