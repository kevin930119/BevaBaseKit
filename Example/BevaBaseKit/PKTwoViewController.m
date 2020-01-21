//
//  PKTwoViewController.m
//  BevaBaseKit_Example
//
//  Created by 魏佳林 on 2019/10/23.
//  Copyright © 2019 673729631@qq.com. All rights reserved.
//

#import "PKTwoViewController.h"

@interface PKTwoViewController ()

@end

@implementation PKTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"第二个";
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(40, 120, 200, 40)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(_action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)_action {
    
}

@end
