//
//  NSURL+PK.m
//  BevaBaseKit
//
//  Created by 魏佳林 on 2019/10/11.
//

#import "NSURL+PK.h"

@implementation NSURL (PK)

- (NSDictionary *)parameters {
    NSString *queryString = self.query;
    NSArray *array = [queryString componentsSeparatedByString:@"&"];
    NSUInteger count = [array count];
    if (count == 0) {
        return nil;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:count];
    
    for (NSString *item in array) {
        NSRange range = [item rangeOfString:@"="];
        if (range.location == NSNotFound) {
            continue;
        }
        
        NSString *key = [item substringToIndex:range.location];
        NSString *value = [item substringFromIndex:range.location + range.length];
        [parameters setObject:value forKey:key];
    }
    
    return parameters;
}

@end
