//
//  BusinessWhiteListItem.h
//  ELife
//
//  Created by yanglihua on 16/8/12.
//  Copyright © 2016年 Hangzhou TaiXuan Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  业务白名单
 */
@interface BusinessWhiteListItem : NSObject

//业务名称
@property (nonatomic, strong) NSString *businessName;

//业务描述
@property (nonatomic, strong) NSString *businessDesc;

+ (BusinessWhiteListItem *)toObject:(NSDictionary *)json;

@end
