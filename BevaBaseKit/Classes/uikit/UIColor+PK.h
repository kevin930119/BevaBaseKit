//
//  UIColor+PK.h
//  BevaBaseKit
//
//  Created by 魏佳林 on 2019/8/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define PKColorWithRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

@interface UIColor (HexColor)

/**
 通过十六进制字符串生成颜色
 
 @param hex 十六进制颜色，示例：@"0x000000",@"#000000",@"000000"
 @return 颜色（输入非法时为nil）
 */
+ (nullable UIColor *)colorWithHexString:(NSString *)hex;

/**
 通过十六进制字符串以及透明度生成颜色
 
 @param hex 十六进制字符串，示例：@"0x000000",@"#000000",@"000000"
 @param alpha 透明度 0.0~1.0
 @return 颜色（输入非法时为nil）
 */
+ (nullable UIColor *)colorWithHexString:(NSString *)hex alpha:(CGFloat)alpha;

/**
 通过十六进制数字生成颜色
 
 @param hex 十六进制数字，示例：0x000000
 @return 颜色（输入非法时为nil）
 */
+ (nullable UIColor *)colorWithHexInt:(unsigned int)hex;

/**
 通过十六进制数字以及透明度生成颜色
 
 @param hex 十六进制数字，示例：0x000000
 @param alpha 透明度 0.0~1.0
 @return 颜色（输入非法时为nil）
 */
+ (nullable UIColor *)colorWithHexInt:(unsigned int)hex alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END