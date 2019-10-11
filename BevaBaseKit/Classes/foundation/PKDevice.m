//
//  PKDevice.m
//  BevaProject
//
//  Created by 魏佳林 on 2019/5/23.
//  Copyright © 2019 ProdKids. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <AdSupport/ASIdentifierManager.h>

#import "PKBundleManager.h"

#import "PKDevice.h"

static NSString * const kPKClientKeychainAccountName = @"com.prokids.apps";
static NSString * const kPKClientDeviceIDKeychainServiceName = @"device_id";
static NSString * const kPKClientDeviceIDUserDefaultsKey = @"com.prokids.apps.device.id";
static NSString * const kPKClientUUIDPattern = @"^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$";

@interface PKDevice ()

@property (nonatomic, assign) float maxLengthOfScreen;
@property (nonatomic, assign) float minLengthOfScreen;
@property (nonatomic, copy, nullable) NSString *deviceIdentifier;
@property (nonatomic, copy, nullable) NSString *deviceIdentifierWithoutHyphen;
@property (nonatomic, copy, nonnull) NSString *UUID;
@property (nonatomic, copy, nonnull) NSString *IDFA;
@property (nonatomic, copy, nonnull) NSString *IDFV;
@property (nonatomic, copy, nullable) NSString *appBundleIdentifier;
@property (nonatomic, copy, nullable) NSString *appVersion;
@property (nonatomic, copy, nullable) NSString *appBuild;
@property (nonatomic, copy, nullable) NSString *appFullVersion;

@end

@implementation PKDevice

+ (instancetype)currentDevice {
    static PKDevice *pkdevice = nil;
    static dispatch_once_t pkdevicetoken;
    dispatch_once(&pkdevicetoken, ^{
        pkdevice = [PKDevice new];
    });
    return pkdevice;
}

- (BOOL)isPad {
    NSString *model = [[UIDevice currentDevice] model];
    BOOL isPad = [model rangeOfString:@"iPad"].location != NSNotFound;
    
    return isPad;
}

- (BOOL)isIphoneX {
    if (self.isPad) {
        return NO;
    }
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    if (MAX(size.width, size.height) >= 812.f) {
        return YES;
    }
    return NO;
}

- (CGFloat)maxLengthOfScreen {
    if (_maxLengthOfScreen) {
        return _maxLengthOfScreen;
    }
    _maxLengthOfScreen = MAX(kPKDeviceScreenWidth, kPKDeviceScreenHeight);
    return _maxLengthOfScreen;
}

- (CGFloat)minLengthOfScreen {
    if (_minLengthOfScreen) {
        return _minLengthOfScreen;
    }
    _minLengthOfScreen = MIN(kPKDeviceScreenWidth, kPKDeviceScreenHeight);
    return _minLengthOfScreen;
}

- (NSString *)deviceIdentifier {
    if (!_deviceIdentifier) {
        _deviceIdentifier = [self _deviceIdentifierByCreating];
    }
    return _deviceIdentifier;
}

- (NSString *)deviceIdentifierWithoutHyphen {
    if (!_deviceIdentifierWithoutHyphen) {
        NSString *deviceId = [self deviceIdentifier];
        // 移除"-"
        _deviceIdentifierWithoutHyphen = [deviceId stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    return _deviceIdentifierWithoutHyphen;
}

- (NSString *)UUID {
    if (!_UUID) {
        _UUID = [[NSUUID UUID] UUIDString];
    }
    return _UUID;
}

- (NSString *)IDFA {
    if (!_IDFA) {
        _IDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    return _IDFA;
}

- (NSString *)IDFV {
    if (!_IDFV) {
        _IDFV = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return _IDFV;
}

- (NSString *)appBundleIdentifier {
    if (!_appBundleIdentifier) {
        _appBundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    }
    return _appBundleIdentifier;
}

- (NSString *)appVersion {
    if (!_appVersion) {
        _appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    }
    return _appVersion;
}

- (NSString *)appBuild {
    if (!_appBuild) {
        _appBuild = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    }
    return _appBuild;
}

- (NSString *)appFullVersion {
    if (!_appFullVersion) {
        if ([self appVersion] && [self appBuild]) {
            _appFullVersion = [NSString stringWithFormat:@"%@.%@", [self appVersion], [self appBuild]];
        }
    }
    return _appFullVersion;
}

- (BOOL)isValidDeviceID:(NSString *)deviceID {
    if (![deviceID isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    // 移除 "-"
    deviceID = [deviceID stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    // 移除 "0"
    deviceID = [deviceID stringByReplacingOccurrencesOfString:@"0" withString:@""];
    
    if ([deviceID length] == 0) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Private methods
- (NSString *)_deviceIdentifierByCreating {
    // 从钥匙串中读取
    NSString *deviceIDStr = [self _deviceIDFromKeychain];
    if ([self _isValidDeviceID:deviceIDStr]) {
        return deviceIDStr;
    }
    
    // 从user default中读取
    deviceIDStr = [self _deviceIDFromUserDefaults];
    if ([self _isValidDeviceID:deviceIDStr]) {
        [self _saveDeviceIDToKeychain:deviceIDStr];
        return deviceIDStr;
    }
    
    // 获取IDFA
    deviceIDStr = [self IDFA];
    if ([self _isValidDeviceID:deviceIDStr]) {
        // 保存
        [self _saveDeviceIDToKeychain:deviceIDStr];
        [self _saveDeviceIDToUserDefaults:deviceIDStr];
        return deviceIDStr;
    }
    
    // 获取IDFV
    deviceIDStr = [self IDFV];
    if ([self _isValidDeviceID:deviceIDStr]) {
        // 保存
        [self _saveDeviceIDToKeychain:deviceIDStr];
        [self _saveDeviceIDToUserDefaults:deviceIDStr];
        return deviceIDStr;
    }
    
    // 获取UUID
    deviceIDStr = [self UUID];
    if ([self _isValidDeviceID:deviceIDStr]) {
        // 保存
        [self _saveDeviceIDToKeychain:deviceIDStr];
        [self _saveDeviceIDToUserDefaults:deviceIDStr];
        return deviceIDStr;
    }
    
    return nil;
}

- (NSString *)_deviceIDFromKeychain {
    NSString *classKey = (__bridge NSString *)kSecClass;
    NSString *classValue = (__bridge NSString *)kSecClassGenericPassword;
    NSString *accessibleKey = (__bridge NSString *)kSecAttrAccessible;
    NSString *accessibleValue = (__bridge NSString *)kSecAttrAccessibleAlways;
    NSString *accountKey = (__bridge NSString *)kSecAttrAccount;
    NSString *accountValue = kPKClientKeychainAccountName;
    NSString *serviceKey = (__bridge NSString *)kSecAttrService;
    NSString *serviceValue = kPKClientDeviceIDKeychainServiceName;
    NSString *rtnDataKey = (__bridge NSString *)kSecReturnData;
    NSString *rtnDataValue = (__bridge id)kCFBooleanTrue;
    NSString *rtnAttrsKey = (__bridge NSString *)kSecReturnAttributes;
    NSString *rtnAttrsValue = (__bridge id)kCFBooleanTrue;
    NSDictionary *keychainItems = @{classKey : classValue, accessibleKey : accessibleValue, accountKey : accountValue, serviceKey : serviceValue, rtnDataKey : rtnDataValue, rtnAttrsKey : rtnAttrsValue};
    CFDictionaryRef query = (CFDictionaryRef)CFBridgingRetain(keychainItems);
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching(query, &result);
    CFRelease(query);
    if (status != errSecSuccess) {
        return nil;
    }
    NSDictionary *resultDict = (__bridge NSDictionary *)result;
    NSData *data = [resultDict objectForKey:(__bridge NSString *)kSecValueData];
    if (!data) {
        CFRelease(result);
        return nil;
    }
    NSString *str = [[NSString alloc] initWithData:data
                                          encoding:NSUTF8StringEncoding];
    CFRelease(result);
    return str;
}

- (NSString *) _deviceIDFromUserDefaults {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud objectForKey:kPKClientDeviceIDUserDefaultsKey];
}

- (void)_saveDeviceIDToKeychain:(NSString *)deviceID {
    NSString *classKey = (__bridge NSString *)kSecClass;
    NSString *classValue = (__bridge NSString *)kSecClassGenericPassword;
    NSString *accessibleKey = (__bridge NSString *)kSecAttrAccessible;
    NSString *accessibleValue = (__bridge NSString *)kSecAttrAccessibleAlways;
    NSString *accountKey = (__bridge NSString *)kSecAttrAccount;
    NSString *accountValue = kPKClientKeychainAccountName;
    NSString *serviceKey = (__bridge NSString *)kSecAttrService;
    NSString *serviceValue = kPKClientDeviceIDKeychainServiceName;
    NSString *valueDataKey = (__bridge NSString *)kSecValueData;
    NSData *data = [deviceID dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *keychainItems = @{classKey : classValue, accessibleKey : accessibleValue, accountKey : accountValue, serviceKey : serviceValue, valueDataKey : data};
    SecItemAdd((__bridge CFDictionaryRef)keychainItems, NULL);
}

- (void)_saveDeviceIDToUserDefaults:(NSString *)deviceID {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:deviceID forKey:kPKClientDeviceIDUserDefaultsKey];
}

- (BOOL)_isValidDeviceID:(NSString *)deviceID {
    if (![deviceID isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kPKClientUUIDPattern options:0 error:&error];
    if (error) {
        return NO;
    }
    NSRange range = NSMakeRange(0, [deviceID length]);
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:deviceID options:0 range:range];
    if (numberOfMatches != 1) {
        return NO;
    }
    
    deviceID = [deviceID stringByReplacingOccurrencesOfString:@"-" withString:@""];
    deviceID = [deviceID stringByReplacingOccurrencesOfString:@"0" withString:@""];
    if ([deviceID length] == 0) {
        return NO;
    }
    return YES;
}

@end
