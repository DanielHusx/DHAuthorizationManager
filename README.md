# DHAuthorization
Collection all most iOS authorization request

# 使用方法
```
#import "DHAuthorization.h"
/// 必须是全局变量，对象才不会在弹框之前被释放
@property (nonatomic, strong) DHAuthorizationManager *authorizationManager;

self.authorizationManager = [[DHAuthorizationManager alloc] init];
self.authorizationManager.delegate = self;
// 校验授权
[self.authorizationManager checkAuthorizationForKey:DHAuthorizationKeyCamera withParameters:nil];

// 回调
- (void)authorizationResult:(NSDictionary <NSNumber *, NSNumber *> *)result {}
```
