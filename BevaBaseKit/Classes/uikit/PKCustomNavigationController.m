//
//  PKNavigationController.m
//  BevaProject
//
//  Created by 魏佳林 on 2019/5/10.
//  Copyright © 2019 ProdKids. All rights reserved.
//

#import <objc/runtime.h>

#import "Masonry.h"

#import "PKDevice.h"
#import "PKViewController.h"

#import "PKCustomNavigationController.h"

@interface PKCustomNavigationController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@end

@implementation PKCustomNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[PKCustomNavigationBar class] toolbarClass:nil]) {
        self.viewControllers = @[rootViewController];
    }
    return self;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    if (![navigationBarClass isKindOfClass:[PKCustomNavigationBar class]]) {
        NSAssert(false, @"导航栏必须为PKNavigationBar");
        return nil;
    }
    return [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
}

- (instancetype)init {
    return [self initWithNavigationBarClass:[PKCustomNavigationBar class] toolbarClass:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 右滑手势代理
    self.interactivePopGestureRecognizer.delegate = self;
    // 导航控制器代理
    self.delegate = self;
    // 设置导航栏为透明
    [self _setNavigationBarToClear];
}

- (void)popFromViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (![viewController isKindOfClass:[UIViewController class]]) {
        return;
    }
    
    NSArray *viewControllers = self.viewControllers;
    NSInteger index = [viewControllers indexOfObject:viewController];
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
    [self popToViewController:targetViewController animated:animated];
}

- (void)updateOfBaseNavigationBarUsingTopViewControllerConfig {
    if (!self.viewControllers.lastObject) {
        return;
    }
    if (![self.viewControllers.lastObject isKindOfClass:[PKViewController class]]) {
        return;
    }
    // 更新导航栏
    [self _updateNavigationBarWithViewController:self.viewControllers.lastObject];
    // 隐藏所有子控制器的假导航栏
    for (UIViewController *vc in self.viewControllers) {
        if (![vc isKindOfClass:[PKViewController class]]) {
            continue;
        }
        PKViewController *baseChildVC = (PKViewController *)vc;
        [baseChildVC setFakeNavigationBarHidden:YES];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.viewControllers.count < 2) {
        return NO;
    }
    // 获取最上层控制器是否支持pop手势
    UIViewController *lastViewController = self.topViewController;
    if (![lastViewController isKindOfClass:[PKViewController class]]) {
        return YES;
    }
    
    PKViewController *baseVC = (PKViewController *)lastViewController;
    BOOL supportPopGestureRecognizer = [baseVC pk_supportPopGestureRecognizer];
    return supportPopGestureRecognizer;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (![viewController isKindOfClass:[PKViewController class]]) {
        return;
    }
    
    PKViewController *baseVC = (PKViewController *)viewController;
    BOOL prefersNavigationBarHidden = [baseVC pk_prefersNavigationBarHidden];
    if (self.navigationBarHidden != prefersNavigationBarHidden) {
        [self setNavigationBarHidden:prefersNavigationBarHidden animated:animated];
    }
    
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (coordinator) {
        PKViewController *from = (PKViewController *)[coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
        PKViewController *to = (PKViewController *)[coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
        
        if ([from isKindOfClass:[PKViewController class]] && [to isKindOfClass:[PKViewController class]]) {
            // 显示子控制器的假导航栏
            [from setFakeNavigationBarHidden:NO];
            [to setFakeNavigationBarHidden:NO];
            // 更新导航栏为透明
            [self _updateNavigationBarToEmpty];
        }
    } else {
        // 更新导航栏
        [self _updateNavigationBarWithViewController:baseVC];
        // 隐藏子控制器的假导航栏
        [baseVC setFakeNavigationBarHidden:YES];
    }
    
    // 更新状态栏样式
    [self _updateStatusBarWithViewController:baseVC];
}

#pragma mark - Original methods
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.navigationItem.hidesBackButton = YES;
    if (self.viewControllers.count > 0) {
        // 第二个控制器开始隐藏底部栏
        viewController.hidesBottomBarWhenPushed = YES;
        // 增加返回按钮
        if (self.pk_customBackNavigationItemImage) {
            [self _addBackItemForViewController:viewController];
        }
    }
    [super pushViewController:viewController animated:animated];
}

#pragma mark - Private methods
- (void)_addBackItemForViewController:(UIViewController *)viewController {
    UIBarButtonItem *backItem = nil;
    if ([viewController isKindOfClass:[PKViewController class]]) {
        PKViewController *baseVC = (PKViewController *)viewController;
        backItem = [[UIBarButtonItem alloc] initWithImage:self.pk_customBackNavigationItemImage style:UIBarButtonItemStylePlain target:baseVC action:@selector(customNavigationBarBackItemDidClick)];
    } else {
        backItem = [[UIBarButtonItem alloc] initWithImage:self.pk_customBackNavigationItemImage style:UIBarButtonItemStylePlain target:self action:@selector(_customBackItemClick)];
    }
    viewController.navigationItem.leftBarButtonItem = backItem;
}

- (void)_customBackItemClick {
    [self popViewControllerAnimated:YES];
}

- (void)_setNavigationBarToClear {
    // 设置导航栏为透明
    self.navigationBar.shadowImage = [UIImage new];
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
}

- (void)_updateNavigationBarWithViewController:(PKViewController *)viewController {
    UIColor *pk_navigationBarColor = viewController.pk_navigationBarColor;
    ((PKCustomNavigationBar *)self.navigationBar).pk_navigationBarColor = pk_navigationBarColor;
    float pk_navigationBarAlpha = viewController.pk_navigationBarAlpha;
    ((PKCustomNavigationBar *)self.navigationBar).pk_navigationBarAlpha = pk_navigationBarAlpha;
    BOOL pk_navigationBarHidden = viewController.pk_navigationBarHidden;
    ((PKCustomNavigationBar *)self.navigationBar).pk_navigationBarHidden = pk_navigationBarHidden;
    BOOL pk_navigationBarShadowLineHidden = viewController.pk_navigationBarShadowLineHidden;
    ((PKCustomNavigationBar *)self.navigationBar).pk_navigationBarShadowLineHidden = pk_navigationBarShadowLineHidden;
    // 更新状态栏样式
    [self _updateStatusBarWithViewController:viewController];
}

- (void)_updateStatusBarWithViewController:(PKViewController *)viewController {
    // 设置状态栏样式
    UIStatusBarStyle statusBarStyle = [viewController preferredStatusBarStyle];
    if (statusBarStyle == UIStatusBarStyleDefault) {
        // 黑色
        self.navigationBar.barStyle = UIBarStyleDefault;
    } else {
        // 白色
        self.navigationBar.barStyle = UIBarStyleBlack;
    }
}

- (void)_updateNavigationBarToEmpty {
    ((PKCustomNavigationBar *)self.navigationBar).pk_navigationBarColor = [UIColor clearColor];
    ((PKCustomNavigationBar *)self.navigationBar).pk_navigationBarAlpha = 1.0f;
    ((PKCustomNavigationBar *)self.navigationBar).pk_navigationBarHidden = NO;
    ((PKCustomNavigationBar *)self.navigationBar).pk_navigationBarShadowLineHidden = YES;
}

#pragma mark - Autorotate
- (BOOL)shouldAutorotate {
    return [self.viewControllers.lastObject shouldAutorotate];
}

#pragma mark - Orientations
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

@end

@interface PKCustomNavigationBar ()

@property (nonatomic, strong) UIView *pk_insteadBackgroundView;
@property (nonatomic, strong) UIView *pk_insteadShadowLine;

@end

@implementation PKCustomNavigationBar

- (void)addSubview:(UIView *)view {
    // 解决iOS8设备的系统bug，该bug造成右滑时出现系统返回按钮
    if ([NSStringFromClass([view class]) isEqualToString:@"UINavigationItemButtonView"]) {
        view.hidden = YES;
    }
    [super addSubview:view];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.pk_insteadBackgroundView.superview) {
        return;
    }
    [self.subviews.firstObject insertSubview:self.pk_insteadBackgroundView atIndex:0];
    self.pk_insteadBackgroundView.frame = self.pk_insteadBackgroundView.superview.bounds;
    [self.pk_insteadBackgroundView addSubview:self.pk_insteadShadowLine];
    [self.pk_insteadShadowLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.width.equalTo(self.pk_insteadBackgroundView);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)setFrame:(CGRect)frame {
    if (frame.origin.y <= 0) {
        frame.origin.y = kPKDeviceStatusBarHeight;
    }
    
    [super setFrame:frame];
}

- (void)setPk_navigationBarColor:(UIColor *)pk_navigationBarColor {
    _pk_navigationBarColor = pk_navigationBarColor;
    self.pk_insteadBackgroundView.backgroundColor = pk_navigationBarColor;
}

- (void)setPk_navigationBarAlpha:(float)pk_navigationBarAlpha {
    _pk_navigationBarAlpha = pk_navigationBarAlpha;
    self.pk_insteadBackgroundView.alpha = pk_navigationBarAlpha;
}

- (void)setPk_navigationBarHidden:(BOOL)pk_navigationBarHidden {
    _pk_navigationBarHidden = pk_navigationBarHidden;
    self.pk_insteadBackgroundView.hidden = pk_navigationBarHidden;
}

- (void)setPk_navigationBarShadowLineHidden:(BOOL)pk_navigationBarShadowLineHidden {
    _pk_navigationBarShadowLineHidden = pk_navigationBarShadowLineHidden;
    self.pk_insteadShadowLine.hidden = pk_navigationBarShadowLineHidden;
}

- (UIView *)pk_insteadBackgroundView {
    if (!_pk_insteadBackgroundView) {
        _pk_insteadBackgroundView = [UIView new];
        _pk_insteadBackgroundView.userInteractionEnabled = NO;
        _pk_insteadBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _pk_insteadBackgroundView;
}

- (UIView *)pk_insteadShadowLine {
    if (!_pk_insteadShadowLine) {
        _pk_insteadShadowLine = [UIView new];
        _pk_insteadShadowLine.userInteractionEnabled = NO;
        _pk_insteadShadowLine.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
        _pk_insteadShadowLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _pk_insteadShadowLine.hidden = YES;
    }
    return _pk_insteadShadowLine;
}

// 处理点击事件透传
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (!view) {
        return nil;
    }
    NSString *viewClassName = NSStringFromClass([view class]);
    viewClassName = [viewClassName stringByReplacingOccurrencesOfString:@"_" withString:@""];
    if ([viewClassName isEqualToString:@"UINavigationBarContentView"] || [viewClassName isEqualToString:@"PKCustomNavigationBar"]) {
        // 获取背景色alpha
        CGFloat alpha = 0;
        if (self.pk_navigationBarColor) {
            [self.pk_navigationBarColor getRed:NULL green:NULL blue:NULL alpha:&alpha];
        }
        if (self.pk_navigationBarAlpha <= 0.01 || self.pk_navigationBarHidden || alpha <= 0.01) {
            return nil;
        }
    }
    return view;
}

@end

@implementation UIBarButtonItem (PKNavigationController)

+ (void)load {
    [super load];
    
    Method originalMethod = class_getInstanceMethod([self class], @selector(initWithImage:style:target:action:));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(_swizzledInitWithImage:style:target:action:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (instancetype)_swizzledInitWithImage:(nullable UIImage *)image style:(UIBarButtonItemStyle)style target:(nullable id)target action:(nullable SEL)action {
    return [self _swizzledInitWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:style target:target action:action];
}

@end
