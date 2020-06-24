//
//  PKViewController.m
//  BevaBaseKit
//
//  Created by 673729631@qq.com on 08/13/2019.
//  Copyright (c) 2019 673729631@qq.com. All rights reserved.
//

#import <BevaBaseKit/BevaBaseKit.h>

#import "PKTwoViewController.h"

#import "PKOneViewController.h"

@interface PKOneViewController () <CAAnimationDelegate>

@property (nonatomic, strong) UIView *fromView;
@property (nonatomic, strong) UIView *toView;

@end

@implementation PKOneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"第一个";
    
    self.pk_navigationBarShadowLineHidden = YES;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(40, 120, 200, 40)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(_action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(btn.frame)+30, [PKDevice currentDevice].minLengthOfScreen-40, 300)];
    view.backgroundColor = [UIColor blueColor];
    [self.view addSubview:view];
    self.fromView = view;
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(btn.frame)+30, [PKDevice currentDevice].minLengthOfScreen-40, 300)];
    view1.backgroundColor = [UIColor redColor];
    self.toView = view1;
}

- (void)_action {
//    PKTwoViewController *vc = [PKTwoViewController new];
//    [self.navigationController pushViewController:vc animated:YES];
    
//    [self.view addLayerTransition:PKViewTransitionTypeCube subType:PKViewTransitionSubTypeRight curve:PKViewTransitionCurveEaseInEaseOut duration:1.0 delegate:self];
//    [self.view addSubview:self.toView];
    
    if (self.fromView.superview) {
        [self.view executeTransition:UIViewAnimationOptionTransitionCurlUp fromView:self.fromView toView:self.toView duration:1 completion:^(BOOL finished) {

        }];
    } else {
        [self.view executeTransition:UIViewAnimationOptionTransitionCurlDown fromView:self.toView toView:self.fromView duration:1 completion:^(BOOL finished) {

        }];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.fromView removeFromSuperview];
}

@end
