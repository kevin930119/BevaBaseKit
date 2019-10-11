//
//  PKBundleManager.m
//  BevaBaseKit
//
//  Created by 魏佳林 on 2019/8/28.
//

#import "PKBundleManager.h"

@interface PKBundleManager ()

@property (nonatomic, strong) NSBundle *bundle;

@end

@implementation PKBundleManager

+ (instancetype)bundleManager {
    static PKBundleManager *pkbundlemanager = nil;
    static dispatch_once_t pkbundlemanagertoken;
    dispatch_once(&pkbundlemanagertoken, ^{
        pkbundlemanager = [PKBundleManager new];
    });
    return pkbundlemanager;
}

- (NSBundle *)pkBundle {
    if (self.bundle) {
        return self.bundle;
    }
    NSString *resourcePath = [[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:@"BevaBaseKit.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:resourcePath];
    self.bundle = bundle;
    return bundle;
}

@end
