//
//  UIColor+PK.m
//  BevaBaseKit
//
//  Created by 魏佳林 on 2019/8/12.
//

#import "UIColor+PK.h"

@implementation UIColor (HexColor)

+ (UIColor *)colorWithHexString:(NSString *)hex {
    return [self colorWithHexString:hex alpha:1];
}

+ (UIColor *)colorWithHexString:(NSString *)hex alpha:(CGFloat)alpha {
    if (![hex isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString * hexString = nil;
    if ([hex hasPrefix:@"0x"]) {
        if (hex.length < 8) {
            return nil;
        }
        hexString = [hex substringWithRange:NSMakeRange(2, 6)];
    } else if ([hex hasPrefix:@"#"]) {
        if (hex.length < 7) {
            return nil;
        }
        hexString = [hex substringWithRange:NSMakeRange(1, 6)];
    } else {
        if (hex.length < 6) {
            return nil;
        }
        hexString = hex;
    }
    
    unsigned int hexInt = 0x000000;
    if (hexString) {
        NSScanner * scaner = [[NSScanner alloc] initWithString:hexString];
        [scaner scanHexInt:&hexInt];
    }
    
    return [self colorWithHexInt:hexInt alpha:alpha];
}

+ (UIColor *)colorWithHexInt:(unsigned int)hex {
    return [self colorWithHexInt:hex alpha:1];
}

+ (UIColor *)colorWithHexInt:(unsigned int)hex alpha:(CGFloat)alpha {
    unsigned int r = (hex & 0x00FF0000) >> 16;
    unsigned int g = (hex & 0x0000FF00) >> 8;
    unsigned int b = (hex & 0x000000FF);
    CGFloat red = r / 255.0f;
    CGFloat green = g / 255.0f;
    CGFloat blue = b / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - 适配iOS13的黑暗模式
+ (UIColor *)colorByUserInterfaceStyle:(UIColor *)lightColor darkColor:(UIColor *)darkColor {
    if (!darkColor) {
        return lightColor;
    }
    
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return darkColor;
            } else {
                return lightColor;
            }
        }];
    }
    
    return lightColor;
}

+ (UIColor *)colorByUserInterfaceStyleUsingHexInt:(unsigned int)lightHexInt dark:(unsigned int)darkHexInt {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [self colorWithHexInt:darkHexInt];
            } else {
                return [self colorWithHexInt:lightHexInt];
            }
        }];
    }
    
    return [self colorWithHexInt:lightHexInt];
}

+ (UIColor *)colorByUserInterfaceStyleUsingHexString:(NSString *)lightHexString dark:(NSString *)darkHexString {
    if (!darkHexString) {
        return [self colorWithHexString:lightHexString];
    }
    
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [self colorWithHexString:darkHexString];
            } else {
                return [self colorWithHexString:lightHexString];
            }
        }];
    }
    
    return [self colorWithHexString:lightHexString];
}

@end
