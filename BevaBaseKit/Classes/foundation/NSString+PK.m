//
//  NSString+PK.m
//  BevaBaseKit
//
//  Created by 魏佳林 on 2019/10/11.
//

#import <CommonCrypto/CommonDigest.h>

#import "NSString+PK.h"

@implementation NSString (PK)

- (NSString *)MD5String {
    if ([self length] == 0) {
        return nil;
    }
    
    const char * value = [self UTF8String];
    
    unsigned char buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), buffer);
    
    NSMutableString * string = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; ++count) {
        [string appendFormat:@"%02x",buffer[count]];
    }
    
    return string;
}

@end
