# [DHAuthorizationManager](https://github.com/DanielHusx/DHAuthorizationManager)

iOS授权集合，可同时请求多授权



## 支持授权

- [x] Camera: 相机
- [x] Microphone: 麦克风
- [x] PhoneLibrary: 相册
- [x] Contact: 通讯录
- [x] Calendar: 日历
- [x] Reminder: 提醒
- [x] LocationWhenInUse: 试用期间的定位
- [x] LocationAlways: 始终使用的定位
- [x] AppleMusic: 媒体库
- [x] SpeechRecognition: 语音识别
- [x] Siri
- [x] Motion: 运动
- [x] HealthUpdate: 健康更新
- [x] HealthShare: 健康分享
- [x] UserNotification: 本地推送
- [x] BluetoothPeripheral: 蓝牙
- [x] Cellular: 蜂窝数据



## 你需要知道的！

### 注意

- **AppleMusic**: 必须用真机测试，不然方法无响应，可能引起内存泄漏
- **HealthUpdate/HealthShare**: 必须提供`NSSet<HKOjbectType/HKSampleType*>`*参数
- **UserNotification**: 必须提供`@(UNAuthorizationOptions)`参数
- **Siri**: 必需打开`项目->TARGET->Capabilities->Siri`，不然点击必崩



## 安装

```objective-c
pod 'DHAuthorizationManager'
```

- 当前版本：1.0.1



## 使用方法

> 注意：必须将DHAuthorizationManager设置为强引用成员属性，授权弹框才能正常显示

### 方法一：使用Block

```objective-c
#import "DHAuthorizationManager.h"
// 强引用
@property (nonatomic, strong) DHAuthorizationManager *authorizationManager;
// 初始化
self.authorizationManager = [[DHAuthorizationManager alloc] init];
// 请求权限校验
DHAuthorizationKey key = DHAuthorizationKeyCamera|DHAuthorizationKeyMicrophone;
[self.authorizationManager checkAuthorizationForKey:key withParameters:nil completion:^(NSDictionary <NSNumber *, NSNumber *> *_Nonnull result) {
  // 授权结果result <@(DHAuthorizationKey), @(DHAuthorizationStatus)>
  // do something...
}];
```

### 方法二：使用代理

```objective-c
#import "DHAuthorizationManager.h"
// 强引用
@property (nonatomic, strong) DHAuthorizationManager *authorizationManager;
// 初始化
self.authorizationManager = [[DHAuthorizationManager alloc] init];
self.authorizationManager.delegate = self;

// 请求权限校验
DHAuthorizationKey key = DHAuthorizationKeyCamera|DHAuthorizationKeyMicrophone;
[self.authorizationManager checkAuthorizationForKey:key withParameters:nil];

/** 代理反馈授权结果result <@(DHAuthorizationKey), @(DHAuthorizationStatus)> */
- (void)authorizationResult:(NSDictionary <NSNumber *, NSNumber *> *)result {
  // do something...
}

```

### 

## DHAuthorizationStatus说明

- `DHAuthorizationStatusDefault`: 默认
- `DHAuthorizationStatusNotDetermined`: 未决定。未曾请求过授权，此时会尝试请求授权
- `DHAuthorizationStatusAuthorized`: 已授权
- `DHAuthorizationStatusNotConfigured`: 未配置。info.plist文件未设置相应的键值，用于编码时测试
- `DHAuthorizationStatusDenied`: 已拒绝。用户已拒绝授权
- `DHAuthorizationStatusRestricted`: 受限制
- `DHAuthorizationStatusNotSupported`: 系统版本或硬件不支持
- `DHAuthorizationStatusSystemSetting`: 未提供授权方法，建议跳转至系统进行设置