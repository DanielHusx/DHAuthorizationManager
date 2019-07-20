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
- **Siri**: 需要打开`项目->TARGET->Capabilities->Siri`

### 已知Bug——如果你有很好的解决办法，请告知我，谢谢

- [ ] **UserNotification**: 始终反馈已授权，其中的`-requestAccess`也没反应

- [ ] **Cellular**: 一直得不到正确状态

- [ ] **BluetoothPeripheral**: 得不到正确状态



## 安装

```objective-c
pod 'DHAuthorizationManager'
```

- 最新版本：1.0.0



## 使用方法

### 1. 引用头文件并设置为强引用属性

- 设置为属性，授权弹框才能正常显示

```objective-c
#import "DHAuthorizationManager.h"

@property (nonatomic, strong) DHAuthorizationManager *authorizationManager;
```

### 2. 初始化

```objective-c
self.authorizationManager = [[DHAuthorizationManager alloc] init];
self.authorizationManager.delegate = self;
```

### 3. 请求授权

```objective-c
[self.authorizationManager checkAuthorizationForKey:DHAuthorizationKeyCamera|DHAuthorizationMicrophone withParameters:nil completion:^(NSDictionary <NSNumber *, NSNumber *> *_Nonnull result) {
  // 授权结果result <@(DHAuthorizationKey), @(DHAuthorizationStatus)>
  // do something...
}];

>> or
[self.authorizationManager checkAuthorizationForKey:DHAuthorizationKeyCamera|DHAuthorizationMicrophone withParameters:nil];
/** 授权结果result <@(DHAuthorizationKey), @(DHAuthorizationStatus)> */
- (void)authorizationResult:(NSDictionary <NSNumber *, NSNumber *> *)result {
  // do something...
}
```



## DHAuthorizationStatus说明

- `DHAuthorizationStatusDefault`: 默认
- `DHAuthorizationStatusNotDetermined`: 未决定。未曾请求过授权，此时会尝试请求授权
- `DHAuthorizationStatusAuthorized`: 已授权
- `DHAuthorizationStatusNotConfigured`: 未配置。info.plist文件未设置相应的键值，用于编码时测试
- `DHAuthorizationStatusDenied`: 已拒绝。用户已拒绝授权
- `DHAuthorizationStatusRestricted`: 受限制
- `DHAuthorizationStatusNotSupported`: 系统版本或硬件不支持
- `DHAuthorizationStatusSystemSetting`: 未提供授权方法，建议跳转至系统进行设置