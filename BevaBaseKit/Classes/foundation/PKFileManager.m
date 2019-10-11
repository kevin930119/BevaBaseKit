//
//  PKFileManager.m
//  BevaBaseKit
//
//  Created by 魏佳林 on 2019/10/11.
//

#import "PKFileManager.h"

@interface PKFileManager ()

@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation PKFileManager

- (instancetype)init {
    if (self = [super init]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        self.fileManager = fileManager;
    }
    return self;
}

+ (instancetype)defaultManager {
    static PKFileManager *pkfilemanager = nil;
    static dispatch_once_t pkfilemanagertoken;
    dispatch_once(&pkfilemanagertoken, ^{
        pkfilemanager = [PKFileManager new];
    });
    return pkfilemanager;
}

- (NSString *)bundleFilePathInMainBundleUsingFileName:(NSString *)fileName type:(NSString *)type {
    if (![fileName isKindOfClass:[NSString class]]) {
        return nil;
    }
    // 获取main bundle里面的文件路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
    return filePath;
}

@end
