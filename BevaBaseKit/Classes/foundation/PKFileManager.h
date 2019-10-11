//
//  PKFileManager.h
//  BevaBaseKit
//
//  Created by 魏佳林 on 2019/10/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKFileManager : NSObject

+ (instancetype)defaultManager;

/**
 获取MainBundle里面的文件路径

 @param fileName 文件名
 @param type 文件类型（后缀名） 如果不传，文件名需要包含后缀名
 @return 文件路径
 */
- (nullable NSString *)bundleFilePathInMainBundleUsingFileName:(NSString *)fileName type:(nullable NSString *)type;

@end

NS_ASSUME_NONNULL_END
