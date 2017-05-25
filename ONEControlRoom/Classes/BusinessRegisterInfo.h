//
//  BusinessRegisterInfo.h
//  ELife
//
//  Created by yanglihua on 16/8/12.
//  Copyright © 2016年 Hangzhou TaiXuan Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  业务模块注册信息
 *  注册时，需要传递的必要参数
 */
@interface BusinessRegisterInfo : NSObject

/**
 *  注册业务名称
 */
@property (nonatomic, strong) NSString *businessName;

/**
 *  业务组件入口类
 */
@property (nonatomic, strong) NSString *handlerClassName;

/**
 *  入口类实例
 */
@property (nonatomic, strong) id handlerInstance;

@end
