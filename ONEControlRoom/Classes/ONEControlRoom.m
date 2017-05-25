//
//  ONEControlRoom.m
//  ELife
//
//  Created by yanglihua on 16/8/12.
//  Copyright © 2016年 Hangzhou TaiXuan Network Technology Co., Ltd. All rights reserved.
//

#import "ONEControlRoom.h"
#import "ONEControlRoomLog.h"
#import <objc/runtime.h>
#import "BusinessWhiteListItem.h"
#import "BusinessRegisterInfo.h"

@interface ONEControlRoom ()

@property (nonatomic, strong) NSMutableDictionary *registeredBusiness; //注册组件
@property (nonatomic, strong) NSArray *whiteList; //业务组件白名单

@end

@implementation ONEControlRoom

+ (instancetype)sharedInstance {
    
    static ONEControlRoom *room;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        room = [[ONEControlRoom alloc] initWithRoom];
    });
    return room;
}

- (instancetype)initWithRoom {
    if (self = [super init]) {
        _registeredBusiness = [NSMutableDictionary dictionary];
        
        NSString *whiteListPath = [[NSBundle mainBundle] pathForResource:@"BusinessModuleWhiteList" ofType:@"plist"];
        NSDictionary *file = [NSDictionary dictionaryWithContentsOfFile:whiteListPath];
        self.whiteList = file[@"WhiteList"];
    }
    return self;
}

//防止直接调用init方法
- (instancetype)init {
    return nil;
}

- (BOOL)registerBusiness:(NSString *)businessName class:(NSString *)className {
    
    if ([businessName length] == 0 || [className length] == 0) {
        ONEControlRoomLogInfo(@"register failed, businessName and className can not empty");
        return NO;
    }
    
    if (![self whiteListContainBusiness:businessName]) {
        ONEControlRoomLogInfo(@"register failed, whitelist not contain");
        return NO;
    }
    
    if ([[self.registeredBusiness allKeys] containsObject:businessName]) {
        ONEControlRoomLogInfo(@"register failed, businessName already exists");
        return NO;
    }
    
    Class class = NSClassFromString(className);
    id target = [[class alloc] init];
    if (target == nil) {
        ONEControlRoomLogInfo(@"init method failed");
        return NO;
    }
    
    BusinessRegisterInfo *info = [BusinessRegisterInfo new];
    info.businessName = businessName;
    info.handlerClassName = className;
    self.registeredBusiness[businessName] = info;
    return YES;
}

//业务组件 处理类(入口类)实例
- (id)businessHandlerInstance:(NSString *)businessName {
    
    if ([[self.registeredBusiness allKeys] containsObject:businessName]) {
        BusinessRegisterInfo *info = [self.registeredBusiness objectForKey:businessName];
        return info.handlerInstance;
    }
    
    ONEControlRoomLogInfo(@"operate failed, please check businessName");
    return nil;
}

#pragma mark private

//在App启动的时候，去创建所有注册业务组件<处理类(入口类)>实例
- (void)createAllInstance {
    
    for (BusinessRegisterInfo *info in [self.registeredBusiness allValues]) {
        Class class = NSClassFromString(info.handlerClassName);
        id target = [[class alloc] init];
        if (target == nil) {
            continue;
        }
        info.handlerInstance = target;
    }
}

- (void)allBusinessDistributeMessage:(SEL)selector {
    for (BusinessRegisterInfo *info in [self.registeredBusiness allValues]) {
        if (info.handlerInstance && [info.handlerInstance respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [info.handlerInstance performSelector:selector];
#pragma clang diagnostic pop
        }
    }
}

- (void)allBusinessDistributeMessage:(SEL)selector withObject:(id)object {
    for (BusinessRegisterInfo *info in [self.registeredBusiness allValues]) {
        if (info.handlerInstance && [info.handlerInstance respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [info.handlerInstance performSelector:selector withObject:object];
#pragma clang diagnostic pop
        }
    }
}

- (void)allBusinessDistributeMessage:(SEL)selector withObject:(id)object1 withObject:(id)object2 {
    for (BusinessRegisterInfo *info in [self.registeredBusiness allValues]) {
        if (info.handlerInstance && [info.handlerInstance respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [info.handlerInstance performSelector:selector withObject:object1 withObject:object2];
#pragma clang diagnostic pop
        }
    }
}

//白名单是否包含业务名称
- (BOOL)whiteListContainBusiness:(NSString *)businessName {
    
    for (NSDictionary *info in self.whiteList) {
        BusinessWhiteListItem *item = [BusinessWhiteListItem toObject:info];
        if ([item.businessName isEqualToString:businessName]) {
            return YES;
        }
    }
    
    return NO;
}

@end

#pragma mark 分发给各个模块，包括UIApplicationDelegate、UserNotifications等

//UIApplicationDelegate生命周期函数
@interface NSObject (UIApplicationDelegateLifeCircle)

@end

@implementation NSObject (UIApplicationDelegateLifeCircle)

+ (void)load {
    [self swizzleAppDelegateLifeCircleMethods_ONEControlRoom];
}

+ (void)swizzleAppDelegateLifeCircleMethods_ONEControlRoom {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = NSClassFromString(@"AppDelegate");
        
        SEL originalSelector = @selector(application:didFinishLaunchingWithOptions:);
        SEL swizzledSelector = @selector(ONEControlRoom_application:didFinishLaunchingWithOptions:);
        NSDictionary *didFinishSwizzle = @{@"originalSelector":NSStringFromSelector(originalSelector),@"swizzledSelector":NSStringFromSelector(swizzledSelector)};
        
        originalSelector = @selector(applicationWillResignActive:);
        swizzledSelector = @selector(ONEControlRoom_applicationWillResignActive:);
        NSDictionary *resignSwizzle = @{@"originalSelector":NSStringFromSelector(originalSelector),@"swizzledSelector":NSStringFromSelector(swizzledSelector)};
        
        originalSelector = @selector(applicationDidEnterBackground:);
        swizzledSelector = @selector(ONEControlRoom_applicationDidEnterBackground:);
        NSDictionary *didEnterBackgroundSwizzle = @{@"originalSelector":NSStringFromSelector(originalSelector),@"swizzledSelector":NSStringFromSelector(swizzledSelector)};
        
        originalSelector = @selector(applicationWillEnterForeground:);
        swizzledSelector = @selector(ONEControlRoom_applicationWillEnterForeground:);
        NSDictionary *willEnterForegroundSwizzle = @{@"originalSelector":NSStringFromSelector(originalSelector),@"swizzledSelector":NSStringFromSelector(swizzledSelector)};
        
        originalSelector = @selector(applicationDidBecomeActive:);
        swizzledSelector = @selector(ONEControlRoom_applicationDidBecomeActive:);
        NSDictionary *didBecomeActiveSwizzle = @{@"originalSelector":NSStringFromSelector(originalSelector),@"swizzledSelector":NSStringFromSelector(swizzledSelector)};
        
        originalSelector = @selector(applicationWillTerminate:);
        swizzledSelector = @selector(ONEControlRoom_applicationWillTerminate:);
        NSDictionary *willTerminateSwizzle = @{@"originalSelector":NSStringFromSelector(originalSelector),@"swizzledSelector":NSStringFromSelector(swizzledSelector)};
        
        //application:(UIApplication *)application handleOpenURL:(NSURL *)url
        //Will be deprecated at some point, please replace with application:openURL:sourceApplication:annotation:
        originalSelector = @selector(application:openURL:sourceApplication:annotation:);
        swizzledSelector = @selector(ONEControlRoom_application:openURL:sourceApplication:annotation:);
        NSDictionary *handleOpenUrlBefore9Swizzle = @{@"originalSelector":NSStringFromSelector(originalSelector),@"swizzledSelector":NSStringFromSelector(swizzledSelector)};
        
        //handleOpenURL after 9.0
        originalSelector = @selector(application:openURL:options:);
        swizzledSelector = @selector(ONEControlRoom_application:openURL:options:);
        NSDictionary *handleOpenUrlAfter9Swizzle = @{@"originalSelector":NSStringFromSelector(originalSelector),@"swizzledSelector":NSStringFromSelector(swizzledSelector)};
        
        //所有交换方法
        NSArray *allSwizzle = @[didFinishSwizzle,resignSwizzle,didEnterBackgroundSwizzle,willEnterForegroundSwizzle,didBecomeActiveSwizzle,willTerminateSwizzle,handleOpenUrlBefore9Swizzle,handleOpenUrlAfter9Swizzle];
        
        for (NSDictionary *info in allSwizzle) {
            SEL turnOrigin = NSSelectorFromString(info[@"originalSelector"]);
            SEL turnSwizzle = NSSelectorFromString(info[@"swizzledSelector"]);
            
            Method originalMethod = class_getInstanceMethod(class, turnOrigin);
            Method swizzledMethod = class_getInstanceMethod(class, turnSwizzle);
            
            BOOL didAddMethod =
            class_addMethod(class,
                            turnOrigin,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
            
            if (didAddMethod) {
                class_replaceMethod(class,
                                    turnSwizzle,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
            }
            else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    });
}

//目前支持分发方法

- (BOOL)ONEControlRoom_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ONEControlRoomLogInfo(@"ONEControlRoom didFinishLaunchingWithOptions");
    [[ONEControlRoom sharedInstance] createAllInstance];
    [[ONEControlRoom sharedInstance] allBusinessDistributeMessage:@selector(distributionMsgForDidFinishLaunching)];
    [[ONEControlRoom sharedInstance] allBusinessDistributeMessage:@selector(distributionMsgForDidFinishLaunching:)
                                                       withObject:launchOptions];
    return [self ONEControlRoom_application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)ONEControlRoom_applicationWillResignActive:(UIApplication *)application {
    ONEControlRoomLogInfo(@"ONEControlRoom applicationWillResignActive");
    
    [[ONEControlRoom sharedInstance] allBusinessDistributeMessage:@selector(distributionMsgForWillResignActive)];
    [self ONEControlRoom_applicationWillResignActive:application];
}

- (void)ONEControlRoom_applicationDidEnterBackground:(UIApplication *)application {
    ONEControlRoomLogInfo(@"ONEControlRoom applicationDidEnterBackground");
    
    [[ONEControlRoom sharedInstance] allBusinessDistributeMessage:@selector(distributionMsgForDidEnterBackground)];
    [self ONEControlRoom_applicationDidEnterBackground:application];
}

- (void)ONEControlRoom_applicationWillEnterForeground:(UIApplication *)application {
    ONEControlRoomLogInfo(@"ONEControlRoom applicationWillEnterForeground");
    
    [[ONEControlRoom sharedInstance] allBusinessDistributeMessage:@selector(distributionMsgForWillEnterForeground)];
    [self ONEControlRoom_applicationWillEnterForeground:application];
}

- (void)ONEControlRoom_applicationDidBecomeActive:(UIApplication *)application {
    ONEControlRoomLogInfo(@"ONEControlRoom applicationDidBecomeActive");
    
    [[ONEControlRoom sharedInstance] allBusinessDistributeMessage:@selector(distributionMsgForDidBecomeActive)];
    [self ONEControlRoom_applicationDidBecomeActive:application];
}

- (void)ONEControlRoom_applicationWillTerminate:(UIApplication *)application {
    ONEControlRoomLogInfo(@"ONEControlRoom applicationWillTerminate");
    
    [[ONEControlRoom sharedInstance] allBusinessDistributeMessage:@selector(distributionMsgForWillTerminate)];
    [self ONEControlRoom_applicationWillTerminate:application];
}

//handleOpenUrl before iOS9
- (BOOL)ONEControlRoom_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    ONEControlRoomLogInfo(@"ONEControlRoom application handleOpenURL before iOS9");
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    if ([sourceApplication length] > 0) {
        [options setObject:sourceApplication forKey:@"UIApplicationOpenURLOptionsSourceApplicationKey"];
    }
    if (annotation) {
        [options setObject:annotation forKey:@"UIApplicationOpenURLOptionsAnnotationKey"];
    }
    [[ONEControlRoom sharedInstance] allBusinessDistributeMessage:@selector(distributionMsgForHandleOpenURL:options:)
                                                       withObject:url
                                                       withObject:options];
    return [self ONEControlRoom_application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

//handleOpenUrl after iOS9
- (BOOL)ONEControlRoom_application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    ONEControlRoomLogInfo(@"ONEControlRoom application handleOpenURL after iOS9");
    [[ONEControlRoom sharedInstance] allBusinessDistributeMessage:@selector(distributionMsgForHandleOpenURL:options:)
                                                       withObject:url
                                                       withObject:options];
    return [self ONEControlRoom_application:application openURL:url options:options];
}

@end


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

//推送通知
@interface NSObject (DistributionForPushingNotification)

@end

@implementation NSObject (DistributionForPushingNotification)

+ (void)load {
    [self swizzleDistributionForPushingNotificationMethods_ONEControlRoom];
}

+ (void)swizzleDistributionForPushingNotificationMethods_ONEControlRoom {
    
    static dispatch_once_t swizzleNotificationOnceToken;
    dispatch_once(&swizzleNotificationOnceToken, ^{
        
        //只支持调换AppDelegate中实现的方法
        Class class = NSClassFromString(@"AppDelegate");
        
        SEL originalSelector = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
        SEL swizzledSelector = @selector(ONEControlRoom_application:didRegisterForRemoteNotificationsWithDeviceToken:);
        NSDictionary *didRegisterForRemoteSwizzle = @{@"originalSelector":NSStringFromSelector(originalSelector),@"swizzledSelector":NSStringFromSelector(swizzledSelector)};
        
        originalSelector = @selector(application:didReceiveRemoteNotification:);
        swizzledSelector = @selector(ONEControlRoom_application:didReceiveRemoteNotification:);
        NSDictionary *didReceiveRemoteSwizzle = @{@"originalSelector":NSStringFromSelector(originalSelector),@"swizzledSelector":NSStringFromSelector(swizzledSelector)};
        
        //所有交换方法
        NSMutableArray *allSwizzle = [NSMutableArray arrayWithObjects:didRegisterForRemoteSwizzle,didReceiveRemoteSwizzle,nil];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        
        //iOS10新增：处理前台收到通知的代理方法
        originalSelector = @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:);
        swizzledSelector = @selector(ONEControlRoom_userNotificationCenter:willPresentNotification:withCompletionHandler:);
        NSDictionary *willPresentNotificationSwizzle = @{@"originalSelector":NSStringFromSelector(originalSelector),@"swizzledSelector":NSStringFromSelector(swizzledSelector)};
        
        //iOS10新增：处理后台点击通知的代理方法
        originalSelector = @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
        swizzledSelector = @selector(ONEControlRoom_userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
        NSDictionary *didReceiveNotificationResponseSwizzle = @{@"originalSelector":NSStringFromSelector(originalSelector),@"swizzledSelector":NSStringFromSelector(swizzledSelector)};
        
        [allSwizzle addObjectsFromArray:@[willPresentNotificationSwizzle,didReceiveNotificationResponseSwizzle]];
        
#endif
        
        for (NSDictionary *info in allSwizzle) {
            SEL turnOrigin = NSSelectorFromString(info[@"originalSelector"]);
            SEL turnSwizzle = NSSelectorFromString(info[@"swizzledSelector"]);
            
            Method originalMethod = class_getInstanceMethod(class, turnOrigin);
            Method swizzledMethod = class_getInstanceMethod(class, turnSwizzle);
            
            BOOL didAddMethod =
            class_addMethod(class,
                            turnOrigin,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
            
            if (didAddMethod) {
                class_replaceMethod(class,
                                    turnSwizzle,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
            }
            else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
        
    });
}

- (void)ONEControlRoom_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    ONEControlRoomLogInfo(@"ONEControlRoom didRegisterForRemoteNotificationsWithDeviceToken %@",deviceToken);
    [[ONEControlRoom sharedInstance] allBusinessDistributeMessage:@selector(distributionMsgForRegistereRemoteNotifications:)
                                                       withObject:deviceToken];
    [self ONEControlRoom_application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)ONEControlRoom_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    ONEControlRoomLogInfo(@"ONEControlRoom didReceiveRemoteNotification userInfo:%@",userInfo);
    [[ONEControlRoom sharedInstance] allBusinessDistributeMessage:@selector(distributionMsgForReceiveRemoteNotification:)
                                                       withObject:userInfo];
    [self ONEControlRoom_application:application didReceiveRemoteNotification:userInfo];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

- (void)ONEControlRoom_userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    ONEControlRoomLogInfo(@"ONEControlRoom userNotificationCenter willPresentNotification:%@",notification);
    [[ONEControlRoom sharedInstance] allBusinessDistributeMessage:@selector(distributionMsgForWillPresentNotification:withCompletionHandler:)
                                                       withObject:notification
                                                       withObject:completionHandler];
    [self ONEControlRoom_userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
}

- (void)ONEControlRoom_userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    ONEControlRoomLogInfo(@"ONEControlRoom userNotificationCenter didReceiveNotificationResponse:%@",response);
    [[ONEControlRoom sharedInstance] allBusinessDistributeMessage:@selector(distributionMsgForDidReceiveNotificationResponse:withCompletionHandler:)
                                                       withObject:response
                                                       withObject:completionHandler];
    [self ONEControlRoom_userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
}

#endif

@end

#pragma mark 主界面展示核心业务组件（模块）

@implementation ONEControlRoom (RootDisplayer)

- (UIViewController *)createRootDisplayerOfBusiness:(NSString *)businessName {
    id instance = [self businessHandlerInstance:businessName];
    if (instance == nil) {
        ONEControlRoomLogInfo(@"call createRootDisplayerOfBusiness failed, because can not found instance");
        return nil;
    }
    
    SEL selector = @selector(initialRootDisplayer);
    if ([instance respondsToSelector:selector] == NO) {
        ONEControlRoomLogInfo(@"call createRootDisplayerOfBusiness failed, sel initRootDisplayer is not imp");
        return nil;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [instance performSelector:selector];
#pragma clang diagnostic pop
}

//容器通知业务 【将要】展示组件界面控制器
- (void)businessDisplayerWillShow:(NSString *)businessName {
    id instance = [self businessHandlerInstance:businessName];
    if (instance == nil) {
        ONEControlRoomLogInfo(@"call businessDisplayerWillShow failed, because can not found instance");
        return;
    }
    
    SEL selector = @selector(theRootDisplayerWillShow);
    if ([instance respondsToSelector:selector] == NO) {
        ONEControlRoomLogInfo(@"call businessDisplayerWillShow failed, sel theRootDisplayerWillShow is not imp");
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [instance performSelector:selector];
#pragma clang diagnostic pop
    
}

//容器通知业务 【已经】展示组件界面控制器
- (void)businessDisplayerDidShow:(NSString *)businessName {
    id instance = [self businessHandlerInstance:businessName];
    if (instance == nil) {
        ONEControlRoomLogInfo(@"call businessDisplayerDidShow failed, because can not found instance");
        return;
    }
    
    SEL selector = @selector(theRootDisplayerDidShow);
    if ([instance respondsToSelector:selector] == NO) {
        ONEControlRoomLogInfo(@"call businessDisplayerWillShow failed, sel theRootDisplayerDidShow is not imp");
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [instance performSelector:selector];
#pragma clang diagnostic pop
}

//触发多余的展示动作【已经展示的状态下再次触发】
- (void)businessDisplayerShowRedundantTrigger:(NSString *)businessName {
    id instance = [self businessHandlerInstance:businessName];
    if (instance == nil) {
        ONEControlRoomLogInfo(@"call businessDisplayerShowRedundantTrigger failed, because can not found instance");
        return;
    }
    
    SEL selector = @selector(theRootDisplayerRedundantShowAction);
    if ([instance respondsToSelector:selector] == NO) {
        ONEControlRoomLogInfo(@"call businessDisplayerShowRedundantTrigger failed, sel theRootDisplayerDidShow is not imp");
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [instance performSelector:selector];
#pragma clang diagnostic pop
}

//容器通知业务 【将要】隐藏组件界面控制器
- (void)businessDisplayerWillHide:(NSString *)businessName {
    id instance = [self businessHandlerInstance:businessName];
    if (instance == nil) {
        ONEControlRoomLogInfo(@"call businessDisplayerWillHide failed, because can not found instance");
        return;
    }
    
    SEL selector = @selector(theRootDisplayerWillHide);
    if ([instance respondsToSelector:selector] == NO) {
        ONEControlRoomLogInfo(@"call businessDisplayerWillShow failed, sel theRootDisplayerWillHide is not imp");
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [instance performSelector:selector];
#pragma clang diagnostic pop
}

//容器通知业务 【已经】隐藏组件界面控制器
- (void)businessDisplayerDidHide:(NSString *)businessName {
    id instance = [self businessHandlerInstance:businessName];
    if (instance == nil) {
        ONEControlRoomLogInfo(@"call businessDisplayerDidHide failed, because can not found instance");
        return;
    }
    
    SEL selector = @selector(theRootDisplayerDidHide);
    if ([instance respondsToSelector:selector] == NO) {
        ONEControlRoomLogInfo(@"call businessDisplayerWillShow failed, sel theRootDisplayerDidHide is not imp");
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [instance performSelector:selector];
#pragma clang diagnostic pop
}

@end
