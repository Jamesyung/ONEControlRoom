//
//  BusinessHandlerTemplate.h
//  ONEControlRoom
//
//  Created by yanglihua on 16/11/7.
//  Copyright © 2016年 Hangzhou TaiXuan Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

//向业务组件分发消息
//组件处理类 重写
/*
 *  目前支持分发的UIApplicationDelegate方法
 *  （1）application:didFinishLaunchingWithOptions:
 *  （2）applicationWillResignActive:
 *  （3）applicationDidEnterBackground:
 *  （4）applicationWillEnterForeground:
 *  （5）applicationDidBecomeActive:
 *  （6）applicationWillTerminate:
 *  （7）application:willFinishLaunchingWithOptions:
 *  （8）(iOS9.0之前)application:openURL:sourceApplication:annotation:以及(iOS9.0之后)application:openURL:options:
 *
 *  推送通知
 *  （1）application:didRegisterForRemoteNotificationsWithDeviceToken:
 *  （2）（iOS10之前，收到通知）application:didReceiveRemoteNotification:
 *  （3）（iOS10新增：前台收到推送通知）userNotificationCenter:willPresentNotification:withCompletionHandler:
 *  （4）（iOS10新增：后台点击推送通知）userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:
 */
@protocol ONEControlRoomDistributionMessage <NSObject>

@optional
//对应 application:willFinishLaunchingWithOptions:方法，并且先于其调用
- (void)distributionMsgForWillFinishLaunching;

//对应 application:didFinishLaunchingWithOptions:方法，并且先于其调用
- (void)distributionMsgForDidFinishLaunching:(NSDictionary *)launchOptions;

//即将废弃
//对应 application:didFinishLaunchingWithOptions:方法，并且先于其调用
- (void)distributionMsgForDidFinishLaunching;

//对应 applicationWillResignActive:方法，并且先于其调用
- (void)distributionMsgForWillResignActive;

//对应 applicationDidEnterBackground:方法，并且先于其调用
- (void)distributionMsgForDidEnterBackground;

//对应 applicationWillEnterForeground:方法，并且先于其调用
- (void)distributionMsgForWillEnterForeground;

//对应 applicationDidBecomeActive:方法，并且先于其调用
- (void)distributionMsgForDidBecomeActive;

//对应 applicationWillTerminate:方法，并且先于其调用
- (void)distributionMsgForWillTerminate;

//对应 (iOS9.0之前)application:openURL:sourceApplication:annotation:以及(iOS9.0之后)application:openURL:options:方法，并且先于其调用
- (void)distributionMsgForHandleOpenURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;

//对应 application:didRegisterForRemoteNotificationsWithDeviceToken: 并且先于其调用
- (void)distributionMsgForRegistereRemoteNotifications:(NSData *)deviceToken;

//适用于iOS10之前
//对应 application:didReceiveRemoteNotification: 并且先于其调用
- (void)distributionMsgForReceiveRemoteNotification:(NSDictionary *)userInfo;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

//iOS10新增：处理前台收到推送通知的代理方法
//对应 userNotificationCenter:willPresentNotification:withCompletionHandler: 并且先于其调用
- (void)distributionMsgForWillPresentNotification:(UNNotification *)notification
                            withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler;

//iOS10新增：处理后台点击推送通知的代理方法
//对应 userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: 并且先于其调用
- (void)distributionMsgForDidReceiveNotificationResponse:(UNNotificationResponse *)response
                                   withCompletionHandler:(void (^)())completionHandler;

#endif

@end


/**
 *  业务组件处理类必要接口
 */
@protocol BusinessHandlerInterface <NSObject>

@required

//业务组件，初始化方法
//组件处理类 重写
- (instancetype)init;

@end



/**
 *  业务组件处理类模板【* 推荐每个业务组件继承模板类 *】
 *  根据不同业务，组件可选择性重写
 */
@interface BusinessHandlerTemplate : NSObject <ONEControlRoomDistributionMessage,BusinessHandlerInterface>

@end




/**
 *  主界面展示核心业务组件（模块） 回调
 *
 *  使用者:ONEControlRoom回调核心业务
 *  实现者:组件（需要展示在主界面的核心模块）
 */
@protocol BusinessRootDisplayerDelegate <NSObject>

@optional

/**
 *  初始化门面方法
 *  由组件（需要展示在主界面的核心模块）实现
 *
 *  @return 界面控制器 UIViewController
 */
- (UIViewController *)initialRootDisplayer;


/**
 *  将要展示组件 界面控制器
 */
- (void)theRootDisplayerWillShow;

/**
 *  已经展示组件 界面控制器
 */
- (void)theRootDisplayerDidShow;

/**
 *  触发多余的展示动作【已经展示的状态下再次触发】
 */
- (void)theRootDisplayerRedundantShowAction;

/**
 *  将要隐藏组件 界面控制器
 */
- (void)theRootDisplayerWillHide;

/**
 *  已经隐藏组件 界面控制器
 */
- (void)theRootDisplayerDidHide;

@end
