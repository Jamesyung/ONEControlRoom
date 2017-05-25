//
//  ONEControlRoom.h
//  ELife
//
//  Created by yanglihua on 16/8/12.
//  Copyright © 2016年 Hangzhou TaiXuan Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusinessHandlerTemplate.h"

/**
 *  业务控制室
 *
 *  每个项目划分成多个独立的业务组件(模块)；每个独立的业务组件(模块)拥有自己的代码库和工程（可以运行起来）；
 *  业务控制室的目的就是将独立的业务模块(组件)加载到App主工程，并且将AppDelegate的方法分发消息给业务组件(模块)
 *  每个业务组件必须包含一个统一处理回调事件的入口，这里指的就是业务组件处理类(入口类)
 *
 *  1.（App启动前）首先业务组件需要在控制室注册（通常使用+(void)load方法）
 *  2.控制室在App启动的时候，去创建业务实例
 *  3.AppDelegate分发消息给业务组件
 *
 *  处理类(入口类)的作用：
 *  控制室会通过处理类(入口类)来回调每一个组件，具体需要实现的方法：参见模板BusinessHandlerTemplate
 *
 *  关于分发消息给业务组件:
 *  UIApplication必须以AppDelegate作为delegateClass，包含ONEControlRoomDistributionMessage对应UIApplicationDelegate的方法
 *  业务控制室将UIApplicationDelegate方法分发给业务组件处理类(入口类)
 *
 *  关于为什么推荐不使用UIApplicationNotification:
 *  1.考虑到业务线统一分发管理，因此不推荐使用UIApplicationNotification来监听应用事件。
 *  2.包括openURL/receiveRemoteNotification等均没有
 *  3.代码移植便捷。每个业务线的appDelegate内代码直接移植至ONEControlRoomDistributionMessage对应方法即可。
 *
 */
@interface ONEControlRoom : NSObject

+ (instancetype)sharedInstance;

/**
 *  注册
 *  模块(组件)入口类 +(void)load 调用此方法进行注册
 *
 *  @param businessName 业务名称（由业务模块约定，并且已经加入白名单）
 *  @param className 处理类(入口类)名
 *
 *  @return 是否成功
 */
- (BOOL)registerBusiness:(NSString *)businessName class:(NSString *)className;

@end



/**
 *
 *  主界面展示核心业务组件（模块）
 *
 *  设计原则
 *  应用尽量使用容器+组件（需要展示在主界面的核心模块）方式进行设计
 *  按照苹果界面设计准则，通常是以UIViewController作为门面进行展示
 *  推荐使用容器统一管理核心业务的门面，包括何时创建、回调当前展示状态等等
 *
 *  举例
 *  小泰乐活目前展示框架是UITabBarController+UINavigationController
 *  3个核心业务（夺宝、商城、直播）+1个我的组成主界面。后面可以再扩展
 *  3个核心+1个我的，它们的门面均是一个UINavigationController
 *  它们由1个容器UITabBarController来管理。
 *
 *  注意点
 *  1.请尽量使用容器来管理，常用的例如UITabBarController
 *  2.以下所有方法只由容器来调用
 *  3.容器决定何时创建，因此那些组件需要提供初始化门面方法
 *  4.容器会通过BusinessRootDisplayerDelegate来回调那些核心业务组件，得到当前展示的状态
 *  5.初始化门面方法，返回UIViewController类型
 *
 */
@interface ONEControlRoom (RootDisplayer)

/**
 *  创建组件界面控制器
 *
 *  @param businessName 业务名称
 *
 *  @return 组件界面控制器 UIViewController
 */
- (UIViewController *)createRootDisplayerOfBusiness:(NSString *)businessName;

/**
 *  容器通知业务 【将要】展示组件界面控制器
 *
 *  @param businessName 业务名称
 */
- (void)businessDisplayerWillShow:(NSString *)businessName;

/**
 *  容器通知业务 【已经】展示组件界面控制器
 *
 *  @param businessName 业务名称
 */
- (void)businessDisplayerDidShow:(NSString *)businessName;

/**
 *  容器通知业务 触发多余的展示动作【已经展示的状态下再次触发】
 *
 *  @param businessName 业务名称
 */
- (void)businessDisplayerShowRedundantTrigger:(NSString *)businessName;

/**
 *  容器通知业务 【将要】隐藏组件界面控制器
 *
 *  @param businessName 业务名称
 */
- (void)businessDisplayerWillHide:(NSString *)businessName;

/**
 *  容器通知业务 【已经】隐藏组件界面控制器
 *
 *  @param businessName 业务名称
 */
- (void)businessDisplayerDidHide:(NSString *)businessName;

@end
