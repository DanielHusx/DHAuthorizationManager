//
//  ViewController.m
//  DHAuthorization
//
//  Created by Daniel on 2019/7/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "ViewController.h"
#import "DHAuthorizationManager/DHAuthorizationManager.h"
@import UserNotifications;
@import HealthKit;

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, DHAuthorizationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *authTableView;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSDictionary *titleSource;

@property (nonatomic, strong) DHAuthorizationManager *authorizationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDataSource];
    [self.authTableView reloadData];
}

- (void)setupDataSource {
    _titleSource =
    @{
      @(DHAuthorizationKeyCamera):@"相机权限",
      @(DHAuthorizationKeyMicrophone):@"麦克风权限",
      @(DHAuthorizationKeyPhotoLibrary):@"相册权限",
      @(DHAuthorizationKeyContact):@"通讯录权限",
      @(DHAuthorizationKeyCalendar):@"日历权限",
      @(DHAuthorizationKeyReminder):@"提醒权限",
      @(DHAuthorizationKeyLocationWhenInUse):@"试用期间定位权限",
      @(DHAuthorizationKeyLocationAlways):@"始终使用定位权限",
      @(DHAuthorizationKeyAppleMusic):@"媒体库权限-真机测",
      @(DHAuthorizationKeySpeechRecognition):@"语音识别权限",
      @(DHAuthorizationKeyMotion):@"运动权限-真机测",
      @(DHAuthorizationKeyHealthUpdate):@"健康更新权限",
      @(DHAuthorizationKeyHealthShare):@"健康分享权限",
      @(DHAuthorizationKeySiri):@"Siri权限",
      @(DHAuthorizationKeyCellular):@"蜂窝数据权限",
      @(DHAuthorizationKeyBluetoothPeripheral):@"蓝牙权限",
      @(DHAuthorizationKeyUserNotification):@"本地通知权限",
      };
    
    _dataSource =
    @[
      @(DHAuthorizationKeyCamera),
      @(DHAuthorizationKeyMicrophone),
      @(DHAuthorizationKeyPhotoLibrary),
      @(DHAuthorizationKeyCamera|DHAuthorizationKeyMicrophone),
      @(DHAuthorizationKeyContact),
      @(DHAuthorizationKeyCalendar),
      @(DHAuthorizationKeyReminder),
      @(DHAuthorizationKeyLocationWhenInUse),
      @(DHAuthorizationKeyLocationAlways),
      @(DHAuthorizationKeyAppleMusic),
      @(DHAuthorizationKeySpeechRecognition),
      @(DHAuthorizationKeyMotion),
      @(DHAuthorizationKeyHealthUpdate),
      @(DHAuthorizationKeyHealthShare),
      @(DHAuthorizationKeySiri),
      @(DHAuthorizationKeyCellular),
      @(DHAuthorizationKeyBluetoothPeripheral),
      @(DHAuthorizationKeyUserNotification),
      ];
    
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    cell.textLabel.text = [self titleWithRow:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.authorizationManager checkAuthorizationForKey:[self.dataSource[indexPath.row] integerValue]
                                         withParameters:@{
                                                          @(DHAuthorizationKeyHealthUpdate):[HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                                                          @(DHAuthorizationKeyHealthShare):[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount], @(DHAuthorizationKeyUserNotification):@(UNAuthorizationOptionSound)
                                                          }];
}


#pragma mark - DHAuthorizationManagerDelegate
- (void)authorizationResult:(NSDictionary<NSNumber *,NSNumber *> *)result {
    
    __block NSMutableString *message = [NSMutableString string];
    [result enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
        DHAuthorizationStatus status = [obj integerValue];
        NSString *title = [self.titleSource objectForKey:key];
        NSString *statusString = nil;
        switch (status) {
            case DHAuthorizationStatusAuthorized:
                statusString = @"已授权";
                break;
            case DHAuthorizationStatusDenied:
                statusString = @"已拒绝";
                break;
            case DHAuthorizationStatusRestricted:
                statusString = @"受限制";
                break;
            case DHAuthorizationStatusNotSupported:
                statusString = @"系统不支持";
                break;
            case DHAuthorizationStatusNotConfigured:
                statusString = @"未在info.plist配置";
                break;
            case DHAuthorizationStatusSystemSetting:
                statusString = @"请跳转至系统设置";
                break;
            case DHAuthorizationStatusDefault:
            case DHAuthorizationStatusNotDetermined:
                statusString = @"出错啦";// 理论上不可能回调此结果
                break;
            default:
                break;
        }
        [message appendFormat:@"%@: %@\n", title, statusString];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"授权结果" message:[message copy] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}


#pragma mark - private
- (NSString *)titleWithRow:(NSInteger)row {
    NSInteger data = [_dataSource[row] integerValue];
    NSString *result = nil;
    if (data == 1 || data % 2 == 0) {
        result = [_titleSource objectForKey:@(data)];
    } else {
        NSInteger decimal = data;
        NSInteger reminder, times = 0;
        NSMutableString *temp = [NSMutableString string];
        
        do {
            reminder = decimal % 2;
            decimal /= 2;
            
            if (reminder != 0) {
                // 拼接
                [temp appendFormat:@"%@%@", [_titleSource objectForKey:@(1 << times)], decimal > 0 ? @"与":@""];
            }
            
            times++;
        } while (decimal > 0);
        result = [temp copy];
    }
    NSLog(@"%zd-result = %@",row, result);
    return result;
}


#pragma mark - getter
- (DHAuthorizationManager *)authorizationManager {
    if (!_authorizationManager) {
        _authorizationManager = [[DHAuthorizationManager alloc] init];
        _authorizationManager.delegate = self;
    }
    return _authorizationManager;
}

@end
