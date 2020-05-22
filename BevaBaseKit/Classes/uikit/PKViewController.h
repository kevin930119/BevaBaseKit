//
//  PKViewController.h
//  BevaProject
//
//  Created by 魏佳林 on 2019/5/10.
//  Copyright © 2019 ProdKids. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKViewController : UIViewController

/**
 是否支持导航控制器的Pop手势，默认YES
 */
@property (nonatomic, readonly) BOOL pk_supportPopGestureRecognizer;

/**
 是否隐藏导航栏，默认NO，用于平滑地隐藏导航栏
 */
@property (nonatomic, readonly) BOOL pk_prefersNavigationBarHidden;

/**
 当前视图是否正在展示
 */
@property (nonatomic, assign, readonly) BOOL pk_viewVisible;

@end

@interface PKViewController (NavigationController)

/**
 自定义导航栏返回按钮点击，默认pop回上个页面，需要额外操作需重写此方法
 */
- (void)customNavigationBarBackItemDidClick;

/**
 将自身控制器从导航控制器栈上移除（之后的控制器一并出栈）
 
 @param animated 是否需要动画效果
 */
- (void)popMyselfOutOfNavigationStackWithAnimated:(BOOL)animated;

@end

@interface PKViewController (NavigationBar)

/**
 顶部预留空间的偏移量（状态栏+导航栏高度）
 */
@property (nonatomic, assign, readonly) NSInteger pk_offetForHeadspace;

/**
 * 以下属性请确保在控制器viewDidLoad里初始化
 */

/**
 导航栏颜色，默认白色
 */
@property (nonatomic, strong) UIColor *pk_navigationBarColor;

/**
 导航栏透明度，默认1
 */
@property (nonatomic, assign) float pk_navigationBarAlpha;

/**
 导航栏阴影线是否隐藏，默认YES
 */
@property (nonatomic, assign) BOOL pk_navigationBarShadowLineHidden;

/**
 是否隐藏导航栏，默认NO，这里的隐藏导航栏并不会真正隐藏导航栏，只不过将导航栏变透明了
 */
@property (nonatomic, assign) BOOL pk_navigationBarHidden;

/**
 更新导航栏样式
 PS：想要修改导航栏样式请修改完以上属性后调用该方法使导航栏样式更新
 */
- (void)setNeedsUpdateOfPKNavigationBar;

/**
更新导航栏颜色
*/
- (void)setNeedsUpdateOfPKNavigationBarColor;

/**
 设置是否隐藏假导航栏
 
 @param hidden 是否隐藏
 */
- (void)setFakeNavigationBarHidden:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END
