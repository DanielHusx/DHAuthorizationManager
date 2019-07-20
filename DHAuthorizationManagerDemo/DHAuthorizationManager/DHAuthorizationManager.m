//
//  DHAuthorizationManager.m
//  OCComponents
//
//  Created by Daniel on 2019/6/19.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "DHAuthorizationManager.h"


typedef NSString * DHPrivacyInfoKey;

/** 判断info.plist是否存在键值 */
static inline bool dh_checkInfoKeyExist(NSString *infoKey) {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:infoKey];
}

/** 保证在主线程 */
static inline void dh_dispatch_async_on_main_queue(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}


/**
 扩展类型，标记需要的额外的操作
 */
typedef NS_ENUM(NSInteger, DHAuthorizationHandlerExternType) {
    DHAuthorizationHandlerExternTypeHoldOn,
};

#pragma mark - Handler 权限协议
@protocol DHAuthorizationHandlerDelegate;
@protocol DHAuthorizationHandler <NSObject>
@required
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;

- (void)requestAccess;

@optional
@property (nonatomic, strong, nullable) id parameter;
- (DHAuthorizationHandlerExternType)externType;

@end

@protocol DHAuthorizationHandlerDelegate <NSObject>
- (void)authorizationKey:(DHAuthorizationKey)key
           requestResult:(DHAuthorizationStatus)status;
@end


#pragma mark - Camera 相机权限
@import AVFoundation;
static DHPrivacyInfoKey const DHPrivacyInfoKeyCamera               = @"NSCameraUsageDescription";
@interface DHAuthorizationCameraHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;
@end

@implementation DHAuthorizationCameraHandler

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeyCamera;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return DHPrivacyInfoKeyCamera;
}

- (DHAuthorizationStatus)authorizationStatus {
    if (!dh_checkInfoKeyExist([self privacyInfoKey])) return DHAuthorizationStatusNotConfigured;
    
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            result = DHAuthorizationStatusAuthorized;
            break;
        case AVAuthorizationStatusDenied:
            result = DHAuthorizationStatusDenied;
            break;
        case AVAuthorizationStatusRestricted:
            result = DHAuthorizationStatusRestricted;
            break;
        case AVAuthorizationStatusNotDetermined:
            result = DHAuthorizationStatusNotDetermined;
            break;
        default:
            break;
    }
    return result;
}

- (void)requestAccess {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
            [self.delegate authorizationKey:[self authorizationKey]
                              requestResult:[self authorizationStatus]];
    }];
}

@end


#pragma mark - Microphone 麦克风权限
static DHPrivacyInfoKey const DHPrivacyInfoKeyMicrophone           = @"NSMicrophoneUsageDescription";
@interface DHAuthorizationMicrophoneHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;

@end

@implementation DHAuthorizationMicrophoneHandler

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeyMicrophone;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return DHPrivacyInfoKeyMicrophone;
}

- (DHAuthorizationStatus)authorizationStatus {
    if (!dh_checkInfoKeyExist([self privacyInfoKey])) return DHAuthorizationStatusNotConfigured;
    
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            result = DHAuthorizationStatusAuthorized;
            break;
        case AVAuthorizationStatusDenied:
            result = DHAuthorizationStatusDenied;
            break;
        case AVAuthorizationStatusRestricted:
            result = DHAuthorizationStatusRestricted;
            break;
        case AVAuthorizationStatusNotDetermined:
            result = DHAuthorizationStatusNotDetermined;
            break;
        default:
            break;
    }
    return result;
}

- (void)requestAccess {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
            [self.delegate authorizationKey:[self authorizationKey]
                              requestResult:[self authorizationStatus]];

    }];
}

@end


#pragma mark - PhotoLibrary 相册权限
static DHPrivacyInfoKey const DHPrivacyInfoKeyPhotoLibrary         = @"NSPhotoLibraryUsageDescription";
@import AssetsLibrary;
@import Photos;
@interface DHAuthorizationPhotoLibraryHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;

@end

@implementation DHAuthorizationPhotoLibraryHandler

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeyPhotoLibrary;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return DHPrivacyInfoKeyPhotoLibrary;
}

- (DHAuthorizationStatus)authorizationStatus {
    if (!dh_checkInfoKeyExist([self privacyInfoKey])) return DHAuthorizationStatusNotConfigured;
    
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    if (@available(iOS 8.0, *)) {
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        switch (authStatus) {
            case PHAuthorizationStatusAuthorized:
                result = DHAuthorizationStatusAuthorized;
                break;
            case PHAuthorizationStatusDenied:
                result = DHAuthorizationStatusDenied;
                break;
            case PHAuthorizationStatusRestricted:
                result = DHAuthorizationStatusRestricted;
                break;
            case PHAuthorizationStatusNotDetermined:
                result = DHAuthorizationStatusNotDetermined;
                break;
            default:
                break;
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        switch (authStatus) {
            case ALAuthorizationStatusAuthorized:
                result = DHAuthorizationStatusAuthorized;
                break;
            case ALAuthorizationStatusDenied:
                result = DHAuthorizationStatusDenied;
                break;
            case ALAuthorizationStatusRestricted:
                result = DHAuthorizationStatusRestricted;
                break;
                
            case ALAuthorizationStatusNotDetermined:
                result = DHAuthorizationStatusNotDetermined;
                break;
            default:
                break;
        }
#pragma clang diagnostic pop
    }
    return result;
}

- (void)requestAccess {
    if (@available(iOS 8.0, *)) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
                [self.delegate authorizationKey:[self authorizationKey]
                                  requestResult:[self authorizationStatus]];
        }];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
            [self.delegate authorizationKey:[self authorizationKey]
                              requestResult:DHAuthorizationStatusNotSupported];
    }
}

@end


#pragma mark - Contact 通讯录权限
static DHPrivacyInfoKey const DHPrivacyInfoKeyContact              = @"NSContactsUsageDescription";
@import AddressBook;
@import Contacts;
@interface DHAuthorizationContactHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;

@end

@implementation DHAuthorizationContactHandler

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeyContact;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return DHPrivacyInfoKeyContact;
}

- (DHAuthorizationStatus)authorizationStatus {
    if (!dh_checkInfoKeyExist([self privacyInfoKey])) return DHAuthorizationStatusNotConfigured;
    
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    if (@available(iOS 9.0, *)) {
        CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        switch (authStatus) {
            case CNAuthorizationStatusAuthorized:
                result = DHAuthorizationStatusAuthorized;
                break;
            case CNAuthorizationStatusRestricted:
                result = DHAuthorizationStatusRestricted;
                break;
            case CNAuthorizationStatusDenied:
                result = DHAuthorizationStatusDenied;
                break;
            case CNAuthorizationStatusNotDetermined:
                result = DHAuthorizationStatusNotDetermined;
                break;
            
            default:
                break;
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
        switch (authStatus) {
            case kABAuthorizationStatusAuthorized:
                result = DHAuthorizationStatusAuthorized;
                break;
            case kABAuthorizationStatusRestricted:
                result = DHAuthorizationStatusRestricted;
                break;
            case kABAuthorizationStatusDenied:
                result = DHAuthorizationStatusDenied;
                break;
            case kABAuthorizationStatusNotDetermined:
                result = DHAuthorizationStatusNotDetermined;
                break;
            default:
                break;
        }
#pragma clang diagnostic pop
    }
    return result;
}

- (void)requestAccess {
    if (@available(iOS 9.0, *)) {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
                [self.delegate authorizationKey:[self authorizationKey]
                                  requestResult:[self authorizationStatus]];
        }];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ABAddressBookRef addressBook = ABAddressBookCreate();
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
                [self.delegate authorizationKey:[self authorizationKey]
                                  requestResult:[self authorizationStatus]];
        });
#pragma clang diagnostic pop
    }
}

@end


#pragma mark - Calendar 日历权限
static DHPrivacyInfoKey const DHPrivacyInfoKeyCalendar             = @"NSCalendarsUsageDescription";
@import EventKit;
@interface DHAuthorizationCalendarHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;

@end

@implementation DHAuthorizationCalendarHandler

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeyCalendar;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return DHPrivacyInfoKeyCalendar;
}

- (DHAuthorizationStatus)authorizationStatus {
    if (!dh_checkInfoKeyExist([self privacyInfoKey])) return DHAuthorizationStatusNotConfigured;
    
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (authStatus) {
        case EKAuthorizationStatusDenied:
            result = DHAuthorizationStatusDenied;
            break;
        case EKAuthorizationStatusRestricted:
            result = DHAuthorizationStatusRestricted;
            break;
        case EKAuthorizationStatusAuthorized:
            result = DHAuthorizationStatusAuthorized;
            break;

        case EKAuthorizationStatusNotDetermined:
            result = DHAuthorizationStatusNotDetermined;
            break;
        default:
            break;
    }
    return result;
}

- (void)requestAccess {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
            [self.delegate authorizationKey:[self authorizationKey]
                              requestResult:[self authorizationStatus]];
        
    }];
}

@end


#pragma mark - Reminder 提醒权限
static DHPrivacyInfoKey const DHPrivacyInfoKeyReminder             = @"NSRemindersUsageDescription";
@interface DHAuthorizationReminderHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;

@end

@implementation DHAuthorizationReminderHandler

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeyReminder;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return DHPrivacyInfoKeyReminder;
}

- (DHAuthorizationStatus)authorizationStatus {
    if (!dh_checkInfoKeyExist([self privacyInfoKey])) return DHAuthorizationStatusNotConfigured;
    
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    switch (authStatus) {
        case EKAuthorizationStatusDenied:
            result = DHAuthorizationStatusDenied;
            break;
        case EKAuthorizationStatusRestricted:
            result = DHAuthorizationStatusRestricted;
            break;
        case EKAuthorizationStatusAuthorized:
            result = DHAuthorizationStatusAuthorized;
            break;
            
        case EKAuthorizationStatusNotDetermined:
            result = DHAuthorizationStatusNotDetermined;
            break;
        default:
            break;
    }
    return result;
}

- (void)requestAccess {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
            [self.delegate authorizationKey:[self authorizationKey]
                              requestResult:[self authorizationStatus]];
    }];
}

@end


#pragma mark - LocationWhenInUse 定位权限
static DHPrivacyInfoKey const DHPrivacyInfoKeyLocationWhenInUse    = @"NSLocationWhenInUseUsageDescription";
@import CoreLocation;
@interface DHAuthorizationLocationWhenInUseHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;

@end

@interface DHAuthorizationLocationWhenInUseHandler () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation DHAuthorizationLocationWhenInUseHandler

- (DHAuthorizationHandlerExternType)externType {
    return DHAuthorizationHandlerExternTypeHoldOn;
}

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeyLocationWhenInUse;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return DHPrivacyInfoKeyLocationWhenInUse;
}

- (DHAuthorizationStatus)authorizationStatus {
    if (!dh_checkInfoKeyExist([self privacyInfoKey])) return DHAuthorizationStatusNotConfigured;
    
    if (![CLLocationManager locationServicesEnabled]) return DHAuthorizationStatusDenied;
    
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    CLAuthorizationStatus authStatus = CLLocationManager.authorizationStatus;
    switch (authStatus) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            result = DHAuthorizationStatusAuthorized;
            break;
        case kCLAuthorizationStatusRestricted:
            result = DHAuthorizationStatusRestricted;
            break;
        case kCLAuthorizationStatusDenied:
            result = DHAuthorizationStatusDenied;
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusNotDetermined:
            result = DHAuthorizationStatusNotDetermined;
            break;
        default:
            break;
    }
    return result;
}

- (void)requestAccess {
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined
        || status == kCLAuthorizationStatusAuthorizedAlways) return ;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
        [self.delegate authorizationKey:[self authorizationKey]
                          requestResult:[self authorizationStatus]];
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

@end


#pragma mark - LocationAlways 定位权限
static DHPrivacyInfoKey const DHPrivacyInfoKeyLocationAlways       = @"NSLocationAlwaysUsageDescription";
static DHPrivacyInfoKey const DHPrivacyInfoKeyAlwaysAndWhenInUse   = @"NSLocationAlwaysAndWhenInUseUsageDescription";
@import CoreLocation;
@interface DHAuthorizationLocationAlwaysHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;

@end

@interface DHAuthorizationLocationAlwaysHandler () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation DHAuthorizationLocationAlwaysHandler

- (DHAuthorizationHandlerExternType)externType {
    return DHAuthorizationHandlerExternTypeHoldOn;
}

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeyLocationAlways;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return DHPrivacyInfoKeyLocationAlways;
}

- (DHAuthorizationStatus)authorizationStatus {
    if (!dh_checkInfoKeyExist([self privacyInfoKey])
        || !dh_checkInfoKeyExist(DHPrivacyInfoKeyAlwaysAndWhenInUse)) return DHAuthorizationStatusNotConfigured;
    
    if (![CLLocationManager locationServicesEnabled]) return DHAuthorizationStatusDenied;
    
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    switch (authStatus) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            result = DHAuthorizationStatusAuthorized;
            break;
        case kCLAuthorizationStatusRestricted:
            result = DHAuthorizationStatusRestricted;
            break;
        case kCLAuthorizationStatusDenied:
            result = DHAuthorizationStatusDenied;
            break;
        case kCLAuthorizationStatusNotDetermined:
            result = DHAuthorizationStatusNotDetermined;
            break;
        default:
            break;
    }
    return result;
}

- (void)requestAccess {
    [self.locationManager requestAlwaysAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined
        || status == kCLAuthorizationStatusAuthorizedWhenInUse) return ;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
        [self.delegate authorizationKey:[self authorizationKey]
                          requestResult:[self authorizationStatus]];
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

@end


#pragma mark - AppleMusic 苹果音乐权限
static DHPrivacyInfoKey const DHPrivacyInfoKeyAppleMusic           = @"NSAppleMusicUsageDescription";
@import MediaPlayer;
@interface DHAuthorizationAppleMusicHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;

@end

@implementation DHAuthorizationAppleMusicHandler

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeyAppleMusic;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return DHPrivacyInfoKeyAppleMusic;
}

- (DHAuthorizationStatus)authorizationStatus {
    if (!dh_checkInfoKeyExist([self privacyInfoKey])) return DHAuthorizationStatusNotConfigured;
    
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    if (@available(iOS 9.3, *)) {
        MPMediaLibraryAuthorizationStatus authStatus = [MPMediaLibrary authorizationStatus];
        switch (authStatus) {
            case MPMediaLibraryAuthorizationStatusDenied:
                result = DHAuthorizationStatusDenied;
                break;
            case MPMediaLibraryAuthorizationStatusRestricted:
                result = DHAuthorizationStatusRestricted;
                break;
            case MPMediaLibraryAuthorizationStatusAuthorized:
                result = DHAuthorizationStatusAuthorized;
                break;

            case MPMediaLibraryAuthorizationStatusNotDetermined:
                result = DHAuthorizationStatusNotDetermined;
                break;
            default:
                break;
        }
    } else {
        result = DHAuthorizationStatusNotSupported;
    }

    return result;
}

- (void)requestAccess {
    if (@available(iOS 9.3, *)) {
        [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
                [self.delegate authorizationKey:[self authorizationKey]
                                  requestResult:[self authorizationStatus]];
        }];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
            [self.delegate authorizationKey:[self authorizationKey]
                              requestResult:DHAuthorizationStatusNotSupported];
    }
}

@end


#pragma mark - SpeechRecognition 语音识别权限
static DHPrivacyInfoKey const DHPrivacyInfoKeySpeechRecognition    = @"NSSpeechRecognitionUsageDescription";
@import Speech;
@interface DHAuthorizationSpeechRecognitionHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;
@end

@implementation DHAuthorizationSpeechRecognitionHandler

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeySpeechRecognition;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return DHPrivacyInfoKeySpeechRecognition;
}

- (DHAuthorizationStatus)authorizationStatus {
    if (!dh_checkInfoKeyExist([self privacyInfoKey])) return DHAuthorizationStatusNotConfigured;
    
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    
    if (@available(iOS 10.0, *)) {
        SFSpeechRecognizerAuthorizationStatus authStatus = [SFSpeechRecognizer authorizationStatus];
        switch (authStatus) {
            case SFSpeechRecognizerAuthorizationStatusDenied:
                result = DHAuthorizationStatusDenied;
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                result = DHAuthorizationStatusRestricted;
                break;
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                result = DHAuthorizationStatusAuthorized;
                break;

            case SFSpeechRecognizerAuthorizationStatusNotDetermined: {
                result = DHAuthorizationStatusNotDetermined;;
                break;
            }
            default:
                break;
        }
    } else {
        result = DHAuthorizationStatusNotSupported;
    }
    
    return result;
}

- (void)requestAccess {
    if (@available(iOS 10.0, *)) {
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
                [self.delegate authorizationKey:[self authorizationKey]
                                  requestResult:[self authorizationStatus]];
        }];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
            [self.delegate authorizationKey:[self authorizationKey]
                              requestResult:DHAuthorizationStatusNotSupported];
    }
}

@end


#pragma mark - Motion 运动权限
static DHPrivacyInfoKey const DHPrivacyInfoKeyMotion               = @"NSMotionUsageDescription";
@import CoreMotion;
@interface DHAuthorizationMotionHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;

@end

@interface DHAuthorizationMotionHandler ()
@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;
@end

@implementation DHAuthorizationMotionHandler

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeyMotion;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return DHPrivacyInfoKeyMotion;
}

- (DHAuthorizationStatus)authorizationStatus {
    if (!dh_checkInfoKeyExist([self privacyInfoKey])) return DHAuthorizationStatusNotConfigured;
    
    if (![CMMotionActivityManager isActivityAvailable]) return DHAuthorizationStatusNotSupported;
    
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    
    CMAuthorizationStatus authStatus = [CMMotionActivityManager authorizationStatus];
    switch (authStatus) {
        case CMAuthorizationStatusAuthorized:
            result = DHAuthorizationStatusAuthorized;
            break;
        case CMAuthorizationStatusRestricted:
            result = DHAuthorizationStatusRestricted;
            break;
        case CMAuthorizationStatusNotDetermined:
            result = DHAuthorizationStatusNotDetermined;
            break;
        case CMAuthorizationStatusDenied:
            result = DHAuthorizationStatusDenied;
            break;
        default:
            break;
    }
    
    return result;
}

- (void)requestAccess {
    NSDate *now = [NSDate date];
    
    __weak typeof(self) weakself = self;
    [self.motionActivityManager queryActivityStartingFromDate:now toDate:now toQueue:[NSOperationQueue mainQueue] withHandler:^(NSArray<CMMotionActivity *> * _Nullable activities, NSError * _Nullable error) {
        __strong typeof(weakself) strongself = weakself;
        
        [strongself.motionActivityManager stopActivityUpdates];
        if (strongself.delegate && [strongself.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
            [strongself.delegate authorizationKey:[strongself authorizationKey]
                                    requestResult:[strongself authorizationStatus]];
    }];
    

}

- (CMMotionActivityManager *)motionActivityManager {
    if (!_motionActivityManager) {
        _motionActivityManager = [[CMMotionActivityManager alloc] init];
    }
    return _motionActivityManager;
}

@end


#pragma mark - HealthUpdate 健康更新
static DHPrivacyInfoKey const DHPrivacyInfoKeyHealthUpdate         = @"NSHealthUpdateUsageDescription";
@import HealthKit;
@interface DHAuthorizationHealthUpdateHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;
@property (nonatomic, strong) id parameter;

@end

@interface DHAuthorizationHealthUpdateHandler ()
@property (nonatomic, strong) HKHealthStore *healthStore;

@property (nonatomic, strong) NSSet <HKSampleType *> *shareTypes;
@property (nonatomic, strong) NSSet <HKObjectType *> *readTypes;
@end

@implementation DHAuthorizationHealthUpdateHandler

- (void)setParameter:(id)parameter {
    if (![parameter isKindOfClass:[NSSet class]]
        || ![parameter isKindOfClass:[NSArray class]]) return ;
    
    if ([parameter count] == 0) return ;
    
    NSMutableSet *shareSets = [NSMutableSet set];
    NSMutableSet *readSets = [NSMutableSet set];
    
    for (id type in _parameter) {
        if ([type isKindOfClass:[HKSampleType class]]) {
            [shareSets addObject:type];
        } else if ([type isKindOfClass:[HKObjectType class]]) {
            [readSets addObject:type];
        }
    }
    
    NSInteger shareCount = [shareSets count];
    NSInteger readCount = [readSets count];
    
    // 集合里的对象无法识别
    if (shareCount == 0 && readCount == 0) return ;
    
    _shareTypes = shareCount != 0 ? [shareSets copy] : nil;
    _readTypes = readCount != 0 ? [readSets copy] : nil;
    
    _parameter = parameter;
}

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeyHealthUpdate;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return DHPrivacyInfoKeyHealthUpdate;
}

- (DHAuthorizationStatus)authorizationStatus {
    if (!dh_checkInfoKeyExist([self privacyInfoKey])) return DHAuthorizationStatusNotConfigured;
    
    if (![HKHealthStore isHealthDataAvailable]) return DHAuthorizationStatusNotSupported;
    
    // 必须存在parameters
    if (!_parameter) return DHAuthorizationStatusNotSupported;
    
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    NSMutableArray *statusForHealth = [NSMutableArray arrayWithCapacity:[_parameter count]];
    for (HKObjectType *type in _parameter) {
        @autoreleasepool {
            HKAuthorizationStatus authStatus = [self.healthStore authorizationStatusForType:type];
            [statusForHealth addObject:@(authStatus)];
        }
    }
    
    if ([statusForHealth containsObject:@(HKAuthorizationStatusNotDetermined)]) {
        result = DHAuthorizationStatusNotDetermined;
    } else if ([statusForHealth containsObject:@(HKAuthorizationStatusSharingDenied)]) {
        result = DHAuthorizationStatusDenied;
    } else {
        result = DHAuthorizationStatusAuthorized;
    }
    
    return result;
}

- (void)requestAccess {
    [self.healthStore requestAuthorizationToShareTypes:self.shareTypes readTypes:self.readTypes completion:^(BOOL success, NSError * _Nullable error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
            [self.delegate authorizationKey:[self authorizationKey]
                              requestResult:success?DHAuthorizationStatusAuthorized:DHAuthorizationStatusDenied];
    }];
}

- (HKHealthStore *)healthStore {
    if (!_healthStore) {
        _healthStore = [[HKHealthStore alloc] init];
    }
    return _healthStore;
}

@end


#pragma mark - 健康分享权限
static DHPrivacyInfoKey const DHPrivacyInfoKeyHealthShare          = @"NSHealthShareUsageDescription";
@import HealthKit;
@interface DHAuthorizationHealthShareHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;
@property (nonatomic, strong) id parameter;

@end

@interface DHAuthorizationHealthShareHandler ()
@property (nonatomic, strong) HKHealthStore *healthStore;

@property (nonatomic, strong) NSSet <HKSampleType *> *shareTypes;
@property (nonatomic, strong) NSSet <HKObjectType *> *readTypes;
@end

@implementation DHAuthorizationHealthShareHandler

- (void)setParameter:(id)parameter {
    if (![parameter isKindOfClass:[NSSet class]]
        || ![parameter isKindOfClass:[NSArray class]]) return ;
    
    if ([parameter count] == 0) return ;
    
    NSMutableSet *shareSets = [NSMutableSet set];
    NSMutableSet *readSets = [NSMutableSet set];
    
    for (id type in _parameter) {
        if ([type isKindOfClass:[HKSampleType class]]) {
            [shareSets addObject:type];
        } else if ([type isKindOfClass:[HKObjectType class]]) {
            [readSets addObject:type];
        }
    }
    
    NSInteger shareCount = [shareSets count];
    NSInteger readCount = [readSets count];
    
    // 集合里的对象无法识别
    if (shareCount == 0 && readCount == 0) return ;
    
    _shareTypes = shareCount != 0 ? [shareSets copy] : nil;
    _readTypes = readCount != 0 ? [readSets copy] : nil;
    
    _parameter = parameter;
}

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeyHealthShare;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return DHPrivacyInfoKeyHealthShare;
}

- (DHAuthorizationStatus)authorizationStatus {
    if (!dh_checkInfoKeyExist([self privacyInfoKey])) return DHAuthorizationStatusNotConfigured;
    
    if (![HKHealthStore isHealthDataAvailable]) return DHAuthorizationStatusNotSupported;
    
    // 必须存在parameters
    if (!_parameter) return DHAuthorizationStatusNotSupported;
    
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    NSMutableArray *statusForHealth = [NSMutableArray arrayWithCapacity:[_parameter count]];
    for (HKObjectType *type in _parameter) {
        @autoreleasepool {
            HKAuthorizationStatus authStatus = [self.healthStore authorizationStatusForType:type];
            [statusForHealth addObject:@(authStatus)];
        }
    }
    
    if ([statusForHealth containsObject:@(HKAuthorizationStatusNotDetermined)]) {
        result = DHAuthorizationStatusNotDetermined;
    } else if ([statusForHealth containsObject:@(HKAuthorizationStatusSharingDenied)]) {
        result = DHAuthorizationStatusDenied;
    } else {
        result = DHAuthorizationStatusAuthorized;
    }
    
    return result;
}

- (void)requestAccess {
    [self.healthStore requestAuthorizationToShareTypes:self.shareTypes readTypes:self.readTypes completion:^(BOOL success, NSError * _Nullable error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
            [self.delegate authorizationKey:[self authorizationKey]
                              requestResult:success?DHAuthorizationStatusAuthorized:DHAuthorizationStatusDenied];
    }];
}

- (HKHealthStore *)healthStore {
    if (!_healthStore) {
        _healthStore = [[HKHealthStore alloc] init];
    }
    return _healthStore;
}

@end

#pragma mark - Siri 语音控制权限
static DHPrivacyInfoKey DHPrivacyInfoKeySiri = @"NSSiriUsageDescription";
@import Intents;
@interface DHAuthorizationSiriHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;

@end

@implementation DHAuthorizationSiriHandler

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeySiri;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return DHPrivacyInfoKeySiri;
}

- (DHAuthorizationStatus)authorizationStatus {
    if (!dh_checkInfoKeyExist([self privacyInfoKey])) return DHAuthorizationStatusNotConfigured;
    
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    
    if (@available(iOS 10.0, *)) {
        INSiriAuthorizationStatus authStatus = [INPreferences siriAuthorizationStatus];
        switch (authStatus) {
            case INSiriAuthorizationStatusAuthorized:
                result = DHAuthorizationStatusAuthorized;
                break;
            case INSiriAuthorizationStatusRestricted:
                result = DHAuthorizationStatusRestricted;
                break;
            case INSiriAuthorizationStatusDenied:
                result = DHAuthorizationStatusDenied;
                break;
            case INSiriAuthorizationStatusNotDetermined:
                result = DHAuthorizationStatusNotDetermined;;
                break;
            default:
                break;
        }
    } else {
        result = DHAuthorizationStatusNotSupported;
    }
    
    return result;
}

- (void)requestAccess {
    if (@available(iOS 10.0, *)) {
        [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus status) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
                [self.delegate authorizationKey:[self authorizationKey]
                                  requestResult:[self authorizationStatus]];
        }];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
            [self.delegate authorizationKey:[self authorizationKey]
                              requestResult:DHAuthorizationStatusNotSupported];
    }
}

@end


#pragma mark - UserNotification 本地通知权限
@import UserNotifications;
@interface DHAuthorizationUserNotificationHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;
@property (nonatomic, strong) id parameter;
@end

@implementation DHAuthorizationUserNotificationHandler

- (void)setParameter:(id)parameter {
    if (![parameter isKindOfClass:[NSNumber class]]) return ;
    
    _parameter = parameter;
}

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeyUserNotification;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return nil;
}

- (DHAuthorizationStatus)authorizationStatus {
    __block DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    
    if (@available(iOS 10.0, *)) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            switch (settings.authorizationStatus) {
                case UNAuthorizationStatusProvisional:
                case UNAuthorizationStatusAuthorized:
                    // FIXME: 一直得到的都是Authorized
                    result = DHAuthorizationStatusAuthorized;
                    break;
                case UNAuthorizationStatusDenied:
                    result = DHAuthorizationStatusDenied;
                    break;
                case UNAuthorizationStatusNotDetermined:
                    result = DHAuthorizationStatusNotDetermined;
                    break;
                default:
                    break;
            }
            dispatch_semaphore_signal(semaphore);
        }];
        // 等待异步线程返回结果
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    } else if (@available(iOS 8.0, *)) {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            result = DHAuthorizationStatusAuthorized;
        } else {
            result = DHAuthorizationStatusDenied;
        }
    } else {
        result = DHAuthorizationStatusNotSupported;
    }
    
    return result;
}

- (void)requestAccess {
    if (@available(iOS 10.0, *)) {
        NSAssert(_parameter, @"iOS 10.0以后请求本地通知权限必须设置options, parameter必须为NSNumber类型");
        // UNAuthorizationOptionNone请求权限不会弹出弹框，故默认为已授权
        if (![_parameter isEqualToNumber:@(UNAuthorizationOptionNone)]) {
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:[((NSNumber *)_parameter) unsignedIntegerValue] completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
                    [self.delegate authorizationKey:[self authorizationKey]
                                      requestResult:[self authorizationStatus]];
            }];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
                [self.delegate authorizationKey:[self authorizationKey]
                                  requestResult:DHAuthorizationStatusAuthorized];
        }
        
    } else if (@available(iOS 8.0, *)) {
        DHAuthorizationStatus status = [[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)] ? DHAuthorizationStatusAuthorized : DHAuthorizationStatusDenied;
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
            [self.delegate authorizationKey:[self authorizationKey]
                              requestResult:status];
        
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
            [self.delegate authorizationKey:[self authorizationKey]
                              requestResult:DHAuthorizationStatusNotSupported];
    }
}

@end


#pragma mark - Cellular 移动网络权限
@import CoreTelephony;
@interface DHAuthorizationCellularHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;

@end

@interface DHAuthorizationCellularHandler ()
@property (nonatomic, strong) CTCellularData *cellularData;

@end

@implementation DHAuthorizationCellularHandler

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeyCellular;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return nil;
}

- (DHAuthorizationStatus)authorizationStatus {
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    
    if (@available(iOS 10.0, *)) {
        CTCellularDataRestrictedState authStatus = [self.cellularData restrictedState];
        switch (authStatus) {
            case kCTCellularDataNotRestricted:  // WLAN & Cellular
                result = DHAuthorizationStatusAuthorized;
                break;
            case kCTCellularDataRestricted: // WLAN
                result = DHAuthorizationStatusDenied;
                break;
                // FIXME: 一直得到Unknow，暂时定为系统设置吧
            case kCTCellularDataRestrictedStateUnknown:
                result = DHAuthorizationStatusSystemSetting;
//                result = DHAuthorizationStatusNotDetermined;
                break;
        }
    } else {
        result = DHAuthorizationStatusAuthorized;
    }
    
    return result;
}

- (void)requestAccess {
    if (@available(iOS 10.0, *)) {
        __weak typeof(self) weakself = self;
        self.cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state) {
            __strong typeof(weakself) strongself = weakself;
            if (strongself.delegate && [strongself.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
                [strongself.delegate authorizationKey:[strongself authorizationKey]
                                  requestResult:[strongself authorizationStatus]];
        };
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
            [self.delegate authorizationKey:[self authorizationKey]
                              requestResult:DHAuthorizationStatusAuthorized];
    }
}

- (CTCellularData *)cellularData {
    if (!_cellularData) {
        _cellularData = [[CTCellularData alloc] init];
    }
    return _cellularData;
}

@end



#pragma mark - BluetoothPeripheral 蓝牙权限
static DHPrivacyInfoKey const DHPrivacyInfoKeyBluetoothPeripheral = @"NSBluetoothPeripheralUsageDescription";
@import CoreBluetooth;
@interface DHAuthorizationBluetoothPeripheralHandler : NSObject <DHAuthorizationHandler>
@property (nonatomic, assign) DHAuthorizationKey authorizationKey;
@property (nonatomic, strong, nullable) DHPrivacyInfoKey privacyInfoKey;
@property (nonatomic, assign) DHAuthorizationStatus authorizationStatus;
@property (nonatomic, weak) id<DHAuthorizationHandlerDelegate> delegate;

@end

@interface DHAuthorizationBluetoothPeripheralHandler () <CBPeripheralManagerDelegate>
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

@end

@implementation DHAuthorizationBluetoothPeripheralHandler

- (DHAuthorizationKey)authorizationKey {
    return DHAuthorizationKeyBluetoothPeripheral;
}

- (DHPrivacyInfoKey)privacyInfoKey {
    return DHPrivacyInfoKeyBluetoothPeripheral;
}

- (DHAuthorizationStatus)authorizationStatus {
    if (!dh_checkInfoKeyExist([self privacyInfoKey])) return DHAuthorizationStatusNotConfigured;
    
    return DHAuthorizationStatusSystemSetting;
    // 调用此方法，异步回调正确状态在-centralManagerDidUpdateState:
//    DHAuthorizationStatus result = [self convertState:[self.peripheralManager state]];
// FIXME: 得不到正确值
//    return result;

}

- (void)requestAccess {
    if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
        [self.delegate authorizationKey:[self authorizationKey]
                          requestResult:DHAuthorizationStatusSystemSetting];
}

- (DHAuthorizationStatus)convertState:(CBManagerState)state {
    DHAuthorizationStatus result = DHAuthorizationStatusDefault;
    switch (state) {
        case CBManagerStatePoweredOff:
        case CBManagerStateUnsupported:
            result = DHAuthorizationStatusNotSupported;
            break;
        case CBManagerStatePoweredOn: {
            CBPeripheralManagerAuthorizationStatus authStatus = [CBPeripheralManager authorizationStatus];
            switch (authStatus) {
                case CBPeripheralManagerAuthorizationStatusDenied:
                    result = DHAuthorizationStatusDenied;
                    break;
                case CBPeripheralManagerAuthorizationStatusAuthorized:
                    result = DHAuthorizationStatusAuthorized;
                    break;
                case CBPeripheralManagerAuthorizationStatusRestricted:
                    result = DHAuthorizationStatusRestricted;
                    break;
                case CBPeripheralManagerAuthorizationStatusNotDetermined:
                    result = DHAuthorizationStatusNotDetermined;
                    break;
                default:
                    break;
            }
            break;
        }
        case CBManagerStateUnknown:
            result = DHAuthorizationStatusNotDetermined;
            break;
        case CBManagerStateUnauthorized:
            result = DHAuthorizationStatusDenied;
            break;
        default:
            break;
    }
    return result;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    DHAuthorizationStatus status = [self convertState:peripheral.state];
    if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationKey:requestResult:)])
        [self.delegate authorizationKey:[self authorizationKey]
                          requestResult:status];
}

- (CBPeripheralManager *)peripheralManager {
    if (!_peripheralManager) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        //options:@{CBPeripheralManagerOptionShowPowerAlertKey:@NO}];
    }
    return _peripheralManager;
}

@end


#pragma mark -
#pragma mark --- 华丽的分割线 ---
#pragma mark -

#pragma mark Context Protocol
@class DHAuthorizationContext;

@protocol DHAuthorizationContextProtocol <NSObject>
@required
- (void)contextAuthorizedResult:(NSDictionary<NSNumber *, NSNumber *> *)result;

@end


#pragma mark - Context
@interface DHAuthorizationContext : NSObject

@property (nonatomic, weak) id<DHAuthorizationContextProtocol> delegate;

- (void)checkAuthorizationForKey:(DHAuthorizationKey)key
                  withParameters:(NSDictionary<NSNumber *,id> * _Nullable)parameters;

@end

@interface DHAuthorizationContext () <DHAuthorizationHandlerDelegate>

@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) dispatch_group_t serialGroup;
@property (nonatomic, strong) NSLock *lock;

/// 单个DHAuthorizationKey与id<DHAuthorizationHandler>类名关联
@property (nonatomic, strong) NSDictionary <NSNumber *, NSString *> *authorizationClassKeyPath;
/// 记录最后结果
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, id> *result;
/// 特殊handler——比如定位必须是强引用，才不会被ARC提前释放导致弹框一闪而逝
@property (nonatomic, strong) id<DHAuthorizationHandler> specialHandler;

@end

@implementation DHAuthorizationContext

- (void)checkAuthorizationForKey:(DHAuthorizationKey)key
                  withParameters:(NSDictionary<NSNumber *,id> *)parameters {
    [self.result removeAllObjects];
    
    NSSet *handlers = [self handlersWithKeySet:[self keySetWithKey:key] withParameters:parameters];
    
    if (!_semaphore)
        _semaphore = dispatch_semaphore_create(0);
    
    if (!_serialQueue)
        _serialQueue = dispatch_queue_create("RequestAuthorizationQueue", DISPATCH_QUEUE_SERIAL);
    
    // 遍历当前授权状态，当NotDetermined时才尝试授权
    for (id<DHAuthorizationHandler> handler in handlers) {
        
        DHAuthorizationStatus status = [handler authorizationStatus];
        
        if (status == DHAuthorizationStatusNotDetermined) {
            // 标记特别的操作
            if ([handler respondsToSelector:@selector(externType)]) {
                if ([handler externType] == DHAuthorizationHandlerExternTypeHoldOn)
                    _specialHandler = handler;
            }
            
            dispatch_async(self.serialQueue, ^{
                dh_dispatch_async_on_main_queue(^{
                    [handler requestAccess];
                });
                dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            });
        } else {
            [self.lock lock];
            [self.result addEntriesFromDictionary:@{@(handler.authorizationKey):@(handler.authorizationStatus)}];
            [self.lock unlock];
        }
        
    }
    
    dispatch_async(self.serialQueue, ^{
        self.specialHandler = nil;
        [self.delegate contextAuthorizedResult:[self.result copy]];
    });
}

/**
 请求权限-[handler requestAccess]的回调结果
 */
- (void)authorizationKey:(DHAuthorizationKey)key
           requestResult:(DHAuthorizationStatus)status {
    [self.lock lock];
    [self.result addEntriesFromDictionary:@{@(key):@(status)}];
    [self.lock unlock];
    dispatch_semaphore_signal(self.semaphore);
}

/**
 根据key得到id<DHAuthorizationHandler>对象初始化列表
 */
- (NSSet <NSObject *> *)handlersWithKeySet:(NSSet <NSNumber *> *)keySet withParameters:(NSDictionary<NSNumber *,id> *)parameters {
    NSMutableSet *result = [NSMutableSet set];
    
    for (NSNumber *key in keySet) {
        NSString *className = [self.authorizationClassKeyPath objectForKey:key];
        if (!className) continue;
        
        id<DHAuthorizationHandler> handler = [[NSClassFromString(className) alloc] init];
        if ([handler respondsToSelector:@selector(setParameter:)])
            handler.parameter = [parameters objectForKey:key];
        handler.delegate = self;
        [result addObject:handler];
    }
    
    return [result copy];
}

/**
 十进制，转化为二进制单数数组
 例如：13->@[1, 4, 8]
 
 注：只有枚举DHAuthorizationKey是顺序排列的偏移，才有用
 */
- (NSSet <NSNumber *> *)keySetWithKey:(DHAuthorizationKey)key {
    NSInteger decimal = key;
    NSInteger reminder, times = 0;
    NSMutableSet *result = [NSMutableSet set];
    
    do {
        reminder = decimal % 2;
        decimal /= 2;
        
        if (reminder != 0) { [result addObject:@(1 << times)]; }
        
        times++;
    } while (decimal > 0);
    
    return [result copy];
}

- (NSDictionary<NSNumber *,NSString *> *)authorizationClassKeyPath {
    if (!_authorizationClassKeyPath) {
        _authorizationClassKeyPath =
        @{
          @(DHAuthorizationKeyCamera):NSStringFromClass([DHAuthorizationCameraHandler class]),
          @(DHAuthorizationKeyMicrophone):NSStringFromClass([DHAuthorizationMicrophoneHandler class]),
          @(DHAuthorizationKeyPhotoLibrary):NSStringFromClass([DHAuthorizationPhotoLibraryHandler class]),
          @(DHAuthorizationKeyContact):NSStringFromClass([DHAuthorizationContactHandler class]),
          @(DHAuthorizationKeyCalendar):NSStringFromClass([DHAuthorizationCalendarHandler class]),
          @(DHAuthorizationKeyReminder):NSStringFromClass([DHAuthorizationReminderHandler class]),
          @(DHAuthorizationKeyLocationWhenInUse):NSStringFromClass([DHAuthorizationLocationWhenInUseHandler class]),
          @(DHAuthorizationKeyLocationAlways):NSStringFromClass([DHAuthorizationLocationAlwaysHandler class]),
          @(DHAuthorizationKeyAppleMusic):NSStringFromClass([DHAuthorizationAppleMusicHandler class]),
          @(DHAuthorizationKeySpeechRecognition):NSStringFromClass([DHAuthorizationSpeechRecognitionHandler class]),
          @(DHAuthorizationKeyMotion):NSStringFromClass([DHAuthorizationMotionHandler class]),
          @(DHAuthorizationKeyHealthUpdate):NSStringFromClass([DHAuthorizationHealthUpdateHandler class]),
          @(DHAuthorizationKeyHealthShare):NSStringFromClass([DHAuthorizationHealthShareHandler class]),
          @(DHAuthorizationKeySiri):NSStringFromClass([DHAuthorizationSiriHandler class]),
          @(DHAuthorizationKeyCellular):NSStringFromClass([DHAuthorizationCellularHandler class]),
          @(DHAuthorizationKeyBluetoothPeripheral):NSStringFromClass([DHAuthorizationBluetoothPeripheralHandler class]),
          @(DHAuthorizationKeyUserNotification):NSStringFromClass([DHAuthorizationUserNotificationHandler class]),
          };
    }
    return _authorizationClassKeyPath;
}

- (NSMutableDictionary *)result {
    if (!_result) {
        _result = [NSMutableDictionary dictionary];
    }
    return _result;
}

- (NSLock *)lock {
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

@end


#pragma mark - Manager
@interface DHAuthorizationManager () <DHAuthorizationContextProtocol>
/// context
@property (nonatomic, strong) DHAuthorizationContext *context;
/// block
@property (nonatomic, copy) DHAuthorizationResultBlock completion;

@end

@implementation DHAuthorizationManager

- (void)checkAuthorizationForKey:(DHAuthorizationKey)key
                  withParameters:(NSDictionary<NSNumber *,id> *)parameters {
    // 遍历Key
    [self.context checkAuthorizationForKey:key
                            withParameters:parameters];
}

- (void)checkAuthorizationForKey:(DHAuthorizationKey)key withParameters:(NSDictionary<NSNumber *,id> *)parameters completion:(DHAuthorizationResultBlock)completion {
    self.completion = [completion copy];
    [self checkAuthorizationForKey:key withParameters:parameters];
}

- (void)contextAuthorizedResult:(NSDictionary<NSNumber *,NSNumber *> *)result {
    if (self.completion) {
        self.completion(result);
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(authorizationResult:)]) {
        [_delegate authorizationResult:result];
    }
}

- (DHAuthorizationContext *)context {
    if (!_context) {
        _context = [[DHAuthorizationContext alloc] init];
        _context.delegate = self;
    }
    return _context;
}

@end
