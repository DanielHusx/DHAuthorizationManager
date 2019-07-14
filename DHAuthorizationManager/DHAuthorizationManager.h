//
//  DHAuthorizationManager.h
//  OCComponents
//
//  Created by Daniel on 2019/6/19.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 授权Key
 */
typedef NS_OPTIONS(NSInteger, DHAuthorizationKey) {
    /// 未知
    DHAuthorizationKeyUnknown               = 0,
    /// 相机
    DHAuthorizationKeyCamera                = 1 << 0,
    /// 麦克风
    DHAuthorizationKeyMicrophone            = 1 << 1,
    /// 相册
    DHAuthorizationKeyPhotoLibrary          = 1 << 2,
    /// 通讯录
    DHAuthorizationKeyContact               = 1 << 3,
    /// 日历
    DHAuthorizationKeyCalendar              = 1 << 4,
    /// 提醒
    DHAuthorizationKeyReminder              = 1 << 5,
    /// 使用期间的定位
    DHAuthorizationKeyLocationWhenInUse     = 1 << 6,
    /// 一直使用的定位
    DHAuthorizationKeyLocationAlways        = 1 << 7,
    /// 苹果音乐
    DHAuthorizationKeyAppleMusic            = 1 << 8,
    /// 语音识别
    DHAuthorizationKeySpeechRecognition     = 1 << 9,
    /// Siri——额外配置：项目->TARGET->Capabilities->Siri
    DHAuthorizationKeySiri                  = 1 << 10,
    /// 运动
    DHAuthorizationKeyMotion                = 1 << 11,
    /// 健康更新——parameters: NSSet<HKObjectType*>*
    DHAuthorizationKeyHealthUpdate          = 1 << 12,
    /// 健康分享——parameters: NSSet<HKSampleType*>*
    DHAuthorizationKeyHealthShare           = 1 << 13,
    /// 推送——parameters: @(UNAuthorizationOptions)
    DHAuthorizationKeyUserNotification      = 1 << 14,
    /// 蓝牙
    DHAuthorizationKeyBluetoothPeripheral   = 1 << 15,
    /// 蜂窝数据
    DHAuthorizationKeyCellular              = 1 << 16,
    
};

/**
 回调状态
 */
typedef NS_ENUM(NSInteger, DHAuthorizationStatus) {
    /// 暂时未处理
    DHAuthorizationStatusDefault        = 0,
    /// 未决定
    DHAuthorizationStatusNotDetermined  = 1,
    /// 已授权
    DHAuthorizationStatusAuthorized     = 2,
    
    /// 未配置——在info.plist缺少必要键
    DHAuthorizationStatusNotConfigured  = -1,
    /// 拒绝
    DHAuthorizationStatusDenied         = -2,
    /// 受限制
    DHAuthorizationStatusRestricted     = -3,
    /// 系统不支持
    DHAuthorizationStatusNotSupported   = -4,
    /// 系统设置，需要跳转至系统设置
    DHAuthorizationStatusSystemSetting  = -5,
};

NS_ASSUME_NONNULL_BEGIN
/** 授权结果回调<@(DHAuthorizationKey), 参数> */
typedef void (^DHAuthorizationResultBlock)(NSDictionary <NSNumber *, NSNumber *> *result);

@protocol DHAuthorizationManagerDelegate <NSObject>
/**
 授权结果
 <@(DHAuthorizationKey), 参数>
 */
- (void)authorizationResult:(NSDictionary <NSNumber *, NSNumber *> *)result;

@end

/**
 许可管理者
 */
@interface DHAuthorizationManager : NSObject

@property (nonatomic, weak) id<DHAuthorizationManagerDelegate> delegate;

/**
 校验授权配置

 @param key DHAuthorizationKey
 @param parameters <@(DHAuthorizationKey), 参数>
 */
- (void)checkAuthorizationForKey:(DHAuthorizationKey)key
                  withParameters:(NSDictionary <NSNumber *, id> *_Nullable)parameters;

/**
 同-checkAuthorizationForKey:withParameters:
 */
- (void)checkAuthorizationForKey:(DHAuthorizationKey)key
                  withParameters:(NSDictionary <NSNumber *, id> *_Nullable)parameters
                      completion:(DHAuthorizationResultBlock)completion;

@end

/**
 info.plist配置
 
 <!--DHAuthorizationKeyCamera-->
 <key>NSCameraUsageDescription</key>
 <string>App需要您的同意,才能访问相机</string>
 
 <!--DHAuthorizationKeyMicrophone-->
 <key>NSMicrophoneUsageDescription</key>
 <string>App需要您的同意,才能访问麦克风</string>
 
 <!--DHAuthorizationKeyPhotoLibrary-->
 <key>NSPhotoLibraryUsageDescription</key>
 <string>App需要您的同意,才能访问相册</string>
 
 <!--DHAuthorizationKeyContact-->
 <key>NSContactsUsageDescription</key>
 <string>App需要您的同意,才能访问通讯录</string>
 
 <!--DHAuthorizationKeyCalendar-->
 <key>NSCalendarsUsageDescription</key>
 <string>App需要您的同意,才能访问日历</string>
 
 <!--DHAuthorizationKeyReminder-->
 <key>NSRemindersUsageDescription</key>
 <string>App需要您的同意,才能访问提醒事项</string>
 
 <!--DHAuthorizationKeyLocationWhenInUse-->
 <key>NSLocationAlwaysUsageDescription</key>
 <string>App需要您的同意,才能使用期间访问位置</string>
 
 <!--DHAuthorizationKeyLocationAlways 必须同时三个描述-->
 <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
 <string>App需要您的同意,才能访问位置</string>
 <key>NSLocationAlwaysUsageDescription</key>
 <string>App需要您的同意,才能使用期间访问位置</string>
 <key>NSLocationAlwaysUsageDescription</key>
 <string>App需要您的同意,才能始终访问位置</string>
 
 <!--DHAuthorizationKeyAppleMusic-->
 <key>NSAppleMusicUsageDescription</key>
 <string>App需要您的同意,才能访问媒体资料库</string>
 
 <!--DHAuthorizationKeySpeechRecognition-->
 <key>NSSpeechRecognitionUsageDescription</key>
 <string>App需要您的同意,才能使用语音识别</string>
 
 <!--DHAuthorizationKeySiri-->
 <key>NSSiriUsageDescription</key>
 <string>App需要您的同意,才能访问Siri</string>
 
 <!--DHAuthorizationKeyMotion-->
 <key>NSMotionUsageDescription</key>
 <string>App需要您的同意,才能访问运动与健身</string>
 
 <!--DHAuthorizationKeyHealthUpdate-->
 <key>NSHealthUpdateUsageDescription</key>
 <string>App需要您的同意,才能访问健康更新 </string>
 
 <!--DHAuthorizationKeyHealthShare-->
 <key>NSHealthShareUsageDescription</key>
 <string>App需要您的同意,才能访问健康分享</string>
 
 <!--DHAuthorizationKeyBluetoothPeripheral-->
 <key>NSBluetoothPeripheralUsageDescription</key>
 <string>App需要您的同意,才能访问蓝牙</string>
 
 */

NS_ASSUME_NONNULL_END
