//
//  PKDevice.h
//  BevaProject
//
//  Created by 魏佳林 on 2019/5/23.
//  Copyright © 2019 ProdKids. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kPKDeviceScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kPKDeviceScreenHeight   [UIScreen mainScreen].bounds.size.height
#define kPKDeviceNavigationBarHeight    [[PKDevice currentDevice] navigationBarHeight]
#define kPKDeviceStatusBarHeight    ([PKDevice currentDevice].isIphoneX?44:20)
#define kPKDeviceTabBarHeight   ([PKDevice currentDevice].isIphoneX?(49+34):([PKDevice currentDevice].isIpadFullScreen?(49+20):49))
#define kPKDeviceTopSafeHeight  ([PKDevice currentDevice].isIphoneX?44:20)
#define kPKDeviceBottomSafeHeight  ([PKDevice currentDevice].isIphoneX?34:([PKDevice currentDevice].isIpadFullScreen?20:0))

@interface PKDevice : NSObject

/**
 是否为pad
 */
@property (nonatomic, assign, readonly) BOOL isPad;

/**
 是否为x
 */
@property (nonatomic, assign, readonly) BOOL isIphoneX;

/**
 是否为iPad全面屏
 */
@property (nonatomic, assign, readonly) BOOL isIpadFullScreen;

/**
 设备机型
 */
@property (nonatomic, copy, readonly) NSString *deviceModel;

/**
 最大屏幕长度
 */
@property (nonatomic, assign, readonly) float maxLengthOfScreen;

/**
 最小屏幕长度
 */
@property (nonatomic, assign, readonly) float minLengthOfScreen;

/**
 设备标识符(E621E1F8-C36C-495A-93FC-0C247A3E6E5F)
 */
@property (nonatomic, copy, readonly, nullable) NSString *bevaIdentifier;

/**
 去除横杠的设备标识符(E621E1F8C36C495A93FC0C247A3E6E5F)
 */
@property (nonatomic, copy, readonly, nullable) NSString *bevaIdentifierWithoutHyphen;

@property (nonatomic, copy, readonly, nonnull) NSString *UUID;

@property (nonatomic, copy, readonly, nonnull) NSString *IDFV;

@property (nonatomic, copy, readonly, nullable) NSString *appBundleIdentifier;

/**
 app版本
 eg:6.2.7
 */
@property (nonatomic, copy, readonly, nullable) NSString *appVersion;

/**
 app build版本
 ed:479
 */
@property (nonatomic, copy, readonly, nullable) NSString *appBuild;

/**
 app完整版本（携带build版本）
 eg:6.2.7.479
 */
@property (nonatomic, copy, readonly, nullable) NSString *appFullVersion;

+ (instancetype)currentDevice;

/**
 检查是否合法device id
 关闭广告追踪的设备id都为0

 @param deviceID 设备id
 @return 合法返回YES
 */
- (BOOL)isValidBevaID:(NSString *)deviceID;

/**
 导航栏高度
 */
- (NSInteger)navigationBarHeight;

@end

NS_ASSUME_NONNULL_END
