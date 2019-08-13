//
//  PKViewController.m
//  BevaProject
//
//  Created by 魏佳林 on 2019/5/10.
//  Copyright © 2019 ProdKids. All rights reserved.
//

#import <objc/runtime.h>

#import "Masonry.h"

#import "PKCustomNavigationController.h"
#import "PKDevice.h"

#import "PKViewController.h"

@interface PKViewController ()

@property (nonatomic, strong) UIView *pk_fakeNavigationBar;
@property (nonatomic, strong) UIView *pk_fakeNavigationBarShadowLine;
@property (nonatomic, assign) BOOL pk_isViewDidApear;

@end

@implementation PKViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.pk_isViewDidApear = YES;
    // 更新导航栏
    [self setNeedsUpdateOfPKNavigationBar];
}

#pragma mark - Configs
- (BOOL)pk_supportPopGestureRecognizer {
    return YES;
}

- (BOOL)pk_prefersNavigationBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

#pragma mark - Autorotate
- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Orientations
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Getters
- (UIView *)pk_fakeNavigationBar {
    if (!_pk_fakeNavigationBar) {
        _pk_fakeNavigationBar = [UIView new];
        _pk_fakeNavigationBar.userInteractionEnabled = NO;
        _pk_fakeNavigationBar.backgroundColor = self.pk_navigationBarColor;;
        _pk_fakeNavigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _pk_fakeNavigationBar.hidden = YES;
    }
    return _pk_fakeNavigationBar;
}

- (UIView *)pk_fakeNavigationBarShadowLine {
    if (!_pk_fakeNavigationBarShadowLine) {
        _pk_fakeNavigationBarShadowLine = [UIView new];
        _pk_fakeNavigationBarShadowLine.userInteractionEnabled = NO;
        _pk_fakeNavigationBarShadowLine.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
        _pk_fakeNavigationBarShadowLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _pk_fakeNavigationBarShadowLine.hidden = YES;
    }
    return _pk_fakeNavigationBarShadowLine;
}

@end

@implementation PKViewController (NavigationController)

- (void)customNavigationBarBackItemDidClick {
    if (!self.navigationController) {
        return;
    }
    
    if (self.navigationController.viewControllers.lastObject != self) {
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)popMyselfOutOfNavigationStackWithAnimated:(BOOL)animated {
    if (!self.navigationController) {
        return;
    }
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    NSInteger index = [viewControllers indexOfObject:self];
    if (index == NSNotFound) {
        return;
    }
    NSInteger targetIndex = index - 1;
    if (targetIndex < 0) {
        return;
    }
    if (targetIndex >= viewControllers.count - 1) {
        return;
    }
    UIViewController *targetViewController = viewControllers[targetIndex];
    if (!targetViewController) {
        return;
    }
    [self.navigationController popToViewController:targetViewController animated:animated];
}

@end

@implementation PKViewController (NavigationBar)

- (NSInteger)pk_offetForHeadspace {
    if (!self.navigationController) {
        return 0;
    }
    if (self.navigationController.navigationBarHidden) {
        return 0;
    }
    NSInteger statusBarHeight = kPKDeviceStatusBarHeight;
    // 检查是否隐藏了导航栏
    BOOL prefersStatusBarHidden = [self prefersStatusBarHidden];
    if (prefersStatusBarHidden) {
        statusBarHeight = 0;
    }
    return kPKDeviceNavigationBarHeight + statusBarHeight;
}

- (void)setPk_navigationBarColor:(UIColor *)pk_navigationBarColor {
    if (!pk_navigationBarColor) {
        pk_navigationBarColor = [UIColor clearColor];
    }
    if (![pk_navigationBarColor isKindOfClass:[UIColor class]]) {
        pk_navigationBarColor = [UIColor clearColor];
    }
    objc_setAssociatedObject(self, "pk_navigationBarColor", pk_navigationBarColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.pk_fakeNavigationBar.backgroundColor = pk_navigationBarColor;
}

- (UIColor *)pk_navigationBarColor {
    UIColor *color = objc_getAssociatedObject(self, "pk_navigationBarColor");
    if (!color) {
        return [UIColor whiteColor];
    }
    return color;
}

- (void)setPk_navigationBarAlpha:(float)pk_navigationBarAlpha {
    objc_setAssociatedObject(self, "pk_navigationBarAlpha", @(pk_navigationBarAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.pk_fakeNavigationBar.alpha = pk_navigationBarAlpha;
}

- (float)pk_navigationBarAlpha {
    NSNumber *pk_navigationBarAlpha_value = objc_getAssociatedObject(self, "pk_navigationBarAlpha");
    if (pk_navigationBarAlpha_value) {
        return [pk_navigationBarAlpha_value floatValue];
    } else {
        return 1.0f;
    }
}

- (void)setPk_navigationBarShadowLineHidden:(BOOL)pk_navigationBarShadowLineHidden {
    objc_setAssociatedObject(self, "pk_navigationBarShadowLineHidden", @(pk_navigationBarShadowLineHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.pk_fakeNavigationBarShadowLine.hidden = pk_navigationBarShadowLineHidden;
}

- (BOOL)pk_navigationBarShadowLineHidden {
    NSNumber *pk_navigationBarShadowLineHidden_value = objc_getAssociatedObject(self, "pk_navigationBarShadowLineHidden");
    if (pk_navigationBarShadowLineHidden_value) {
        return [pk_navigationBarShadowLineHidden_value boolValue];
    } else {
        return NO;
    }
}

- (void)setPk_navigationBarHidden:(BOOL)pk_navigationBarHidden {
    objc_setAssociatedObject(self, "pk_navigationBarHidden", @(pk_navigationBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.pk_fakeNavigationBar.hidden = pk_navigationBarHidden;
}

- (BOOL)pk_navigationBarHidden {
    NSNumber *pk_navigationBarHidden_value = objc_getAssociatedObject(self, "pk_navigationBarHidden");
    if (pk_navigationBarHidden_value) {
        return [pk_navigationBarHidden_value boolValue];
    } else {
        return NO;
    }
}

- (void)setNeedsUpdateOfPKNavigationBar {
    if (!self.pk_isViewDidApear) {
        // 为了保证在转场动画期间无法修改导航栏样式，避免冲突
        return;
    }
    if (!self.navigationController) {
        return;
    }
    if (![self.navigationController isKindOfClass:[PKCustomNavigationController class]]) {
        return;
    }
    PKCustomNavigationController *navigationController = (PKCustomNavigationController *)self.navigationController;
    // 更新导航栏
    [navigationController updateOfBaseNavigationBarUsingTopViewControllerConfig];
}

- (void)setFakeNavigationBarHidden:(BOOL)hidden {
    if (!self.pk_fakeNavigationBar.superview) {
        [self.view addSubview:self.pk_fakeNavigationBar];
        self.pk_fakeNavigationBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.pk_offetForHeadspace);
        [self.pk_fakeNavigationBar addSubview:self.pk_fakeNavigationBarShadowLine];
        [self.pk_fakeNavigationBarShadowLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.bottom.equalTo(self.pk_fakeNavigationBar);
            make.height.mas_equalTo(0.5);
        }];
    }
    if (hidden) {
        self.pk_fakeNavigationBar.hidden = YES;
    } else {
        self.pk_fakeNavigationBar.hidden = self.pk_navigationBarHidden;
        [self.pk_fakeNavigationBar.superview bringSubviewToFront:self.pk_fakeNavigationBar];
    }
}

@end
