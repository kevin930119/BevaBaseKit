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

@interface PKOneViewController ()

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
}

- (void)_action {
    PKTwoViewController *vc = [PKTwoViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
