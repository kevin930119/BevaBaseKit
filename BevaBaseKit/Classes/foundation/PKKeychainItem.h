//
//  PKKeychainItem.h
//  BevaBaseKit
//
//  Created by 魏佳林 on 2020/5/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKKeychainItem : NSObject

@property (nonatomic, copy, readonly) NSString *service;
@property (nonatomic, copy, readonly) NSString *account;
@property (nonatomic, copy, readonly, nullable) NSString *accessGroup;

// 初始化一个钥匙串数据对象
- (instancetype)initWithService:(NSString *)service account:(NSString *)account accessGroup:(nullable NSString *)accessGroup;

// 读取钥匙串中的数据
- (nullable NSString *)readItem;

// 保存数据到钥匙串中
- (BOOL)saveItem:(NSString *)password;

// 删除钥匙串中的数据
- (BOOL)deleteItem;

@end

NS_ASSUME_NONNULL_END
