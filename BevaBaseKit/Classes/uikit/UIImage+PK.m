//
//  UIImage+PK.m
//  BevaBaseKit
//
//  Created by 魏佳林 on 2019/10/11.
//

#import "UIImage+PK.h"

@implementation UIImage (PK)

+ (UIImage *)pureColorImageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
