//
//  PKViewController.m
//  BevaBaseKit
//
//  Created by 673729631@qq.com on 08/13/2019.
//  Copyright (c) 2019 673729631@qq.com. All rights reserved.
//

#import <BevaBaseKit/BevaBaseKit.h>
#import <Masonry.h>

#import "PKOneViewController.h"

@interface PKOneViewController ()

@end

@implementation PKOneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    PKImageView *imgView = [PKImageView new];
    imgView.backgroundColor = [UIColor redColor];
    [imgView setImageWithURLString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1565686233565&di=75ed57d9feb3e33082eab85dd7eb9884&imgtype=0&src=http%3A%2F%2Fhiphotos.baidu.com%2Ffeed%2Fpic%2Fitem%2F0eb30f2442a7d933b0b7b483a14bd11373f00126.jpg"];
    [self.view addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.center.equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
