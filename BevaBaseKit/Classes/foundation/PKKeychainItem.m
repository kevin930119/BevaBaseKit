//
//  PKKeychainItem.m
//  BevaBaseKit
//
//  Created by 魏佳林 on 2020/5/8.
//

#import "PKKeychainItem.h"

@interface PKKeychainItem ()

@property (nonatomic, copy) NSString *service;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *accessGroup;

@end

@implementation PKKeychainItem

+ (NSMutableDictionary *)keychainQueryWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup {
    if (!service.length || !account.length) {
        return nil;
    }
    
    NSString *classKey = (__bridge NSString *)kSecClass;
    NSString *classValue = (__bridge NSString *)kSecClassGenericPassword;
    NSString *serviceKey = (__bridge NSString *)kSecAttrService;
    NSString *accountKey = (__bridge NSString *)kSecAttrAccount;
    NSString *accessGroupKey = (__bridge NSString *)kSecAttrAccessGroup;
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[classKey] = classValue;
    query[serviceKey] = service;
    query[accountKey] = account;
    if (accessGroup.length) {
        query[accessGroupKey] = accessGroup;
    }
    return query;
}

- (instancetype)initWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup {
    if (self = [super init]) {
        self.service = service;
        self.account = account;
        self.accessGroup = accessGroup;
    }
    return self;
}

- (NSString *)readItem {
    NSMutableDictionary *query = [[self class] keychainQueryWithService:self.service account:self.account accessGroup:self.accessGroup];
    if (!query) {
        return nil;
    }
    
    NSString *matchLimitKey = (__bridge NSString *)kSecMatchLimit;
    NSString *matchLimitValue = (__bridge NSString *)kSecMatchLimitOne;
    NSString *returnAttributesKey = (__bridge NSString *)kSecReturnAttributes;
    NSString *returnAttributesValue = (__bridge id)kCFBooleanTrue;
    NSString *returnDataKey = (__bridge NSString *)kSecReturnData;
    NSString *returnDataValue = (__bridge id)kCFBooleanTrue;
    
    query[matchLimitKey] = matchLimitValue;
    query[returnAttributesKey] = returnAttributesValue;
    query[returnDataKey] = returnDataValue;
    
    CFDictionaryRef queryRef = (CFDictionaryRef)CFBridgingRetain(query);
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching(queryRef, &result);
    CFRelease(queryRef);
    if (status != errSecSuccess) {
        return nil;
    }
    NSDictionary *resultDict = (__bridge NSDictionary *)result;
    NSData *data = [resultDict objectForKey:(__bridge NSString *)kSecValueData];
    if (!data) {
        CFRelease(result);
        return nil;
    }
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    CFRelease(result);
    return str;
}

- (BOOL)saveItem:(NSString *)password {
    if (!password) {
        return NO;
    }
    NSData *data = [password dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return NO;
    }
    // 判断是否已存在了
    if ([self readItem]) {
        NSDictionary *query = [[self class] keychainQueryWithService:self.service account:self.account accessGroup:self.accessGroup];
        
        NSDictionary *attToUpdate = @{((__bridge NSString *)kSecValueData) : data};
        // 更新数据
        OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attToUpdate);
        if (status == noErr) {
            return YES;
        }
    } else {
        NSMutableDictionary *query = [[self class] keychainQueryWithService:self.service account:self.account accessGroup:self.accessGroup];
        query[((__bridge NSString *)kSecValueData)] = data;
        // 添加数据
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
        if (status == noErr) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)deleteItem {
    NSDictionary *query = [[self class] keychainQueryWithService:self.service account:self.account accessGroup:self.accessGroup];
    if (!query) {
        return NO;
    }
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status == noErr || status == errSecItemNotFound) {
        return YES;
    }
    return NO;
}

@end
