//
//  PKImageView.m
//  BevaProject
//
//  Created by 魏佳林 on 2019/5/10.
//  Copyright © 2019 ProdKids. All rights reserved.
//

#import "PKImageView.h"

@implementation PKImageView

- (void)setImageWithURLString:(NSString *)urlString {
    if ([self _isNetImageURL:urlString]) {
        [self sd_setImageWithURL:[NSURL URLWithString:urlString]];
    } else {
        UIImage *image = [self _getImageWithFileString:urlString];
        self.image = image;
    }
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage {
    if ([self _isNetImageURL:urlString]) {
        [self sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:placeholderImage];
    } else {
        UIImage *image = [self _getImageWithFileString:urlString];
        if (!image) {
            if (placeholderImage) {
                self.image = placeholderImage;
            }
        } else {
            self.image = image;
        }
    }
}

#pragma mark - Private methods
- (UIImage *)_getImageWithFileString:(NSString *)fileString {
    return [UIImage imageNamed:fileString];
}

- (BOOL)_isNetImageURL:(NSString *)urlString {
    BOOL flag = NO;
    if ([urlString rangeOfString:@"http"].location != NSNotFound) {
        flag = YES;
    }
    return flag;
}

@end
