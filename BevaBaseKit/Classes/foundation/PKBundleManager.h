//
//  PKBundleManager.h
//  BevaBaseKit
//
//  Created by 魏佳林 on 2019/8/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKBundleManager : NSObject

+ (instancetype)bundleManager;

/**
 获取项目bundle

 @return 返回bundle，有可能为空
 */
- (nullable NSBundle *)pkBundle;

@end

NS_ASSUME_NONNULL_END
