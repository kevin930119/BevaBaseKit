//
//  PKNavigationController.h
//  BevaProject
//
//  Created by 魏佳林 on 2019/5/10.
//  Copyright © 2019 ProdKids. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKCustomNavigationController : UINavigationController

/**
 自定义导航栏返回按钮图片
 */
@property (nonatomic, strong, nullable) UIImage *pk_customBackNavigationItemImage;

/**
 pop回指定控制器之前的界面
 
 @param viewController 指定控制器
 @param animated 是否需要动画效果
 */
- (void)popFromViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 使用最上层控制器的配置更新导航栏
 */
- (void)updateOfBaseNavigationBarUsingTopViewControllerConfig;

@end

@interface PKCustomNavigationBar : UINavigationBar

@property (nonatomic, strong) UIColor *pk_navigationBarColor;

@property (nonatomic, assign) float pk_navigationBarAlpha;

@property (nonatomic, assign) BOOL pk_navigationBarHidden;

@property (nonatomic, assign) BOOL pk_navigationBarShadowLineHidden;

@end

@interface UIBarButtonItem (PKNavigationController)

@end

NS_ASSUME_NONNULL_END
