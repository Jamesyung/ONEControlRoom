//
//  BusinessWhiteListItem.m
//  ELife
//
//  Created by yanglihua on 16/8/12.
//  Copyright © 2016年 Hangzhou TaiXuan Network Technology Co., Ltd. All rights reserved.
//

#import "BusinessWhiteListItem.h"
#import "DCKeyValueObjectMapping.h"

@implementation BusinessWhiteListItem

+ (BusinessWhiteListItem *)toObject:(NSDictionary *)json {
    DCKeyValueObjectMapping * parser = [DCKeyValueObjectMapping mapperForClass:[BusinessWhiteListItem class]];
    return [parser parseDictionary:json];
}

@end
