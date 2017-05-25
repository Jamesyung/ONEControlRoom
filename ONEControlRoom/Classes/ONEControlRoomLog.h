//
//  ONEControlRoomLog.h
//  ONEControlRoom
//
//  Created by yanglihua on 2017/4/25.
//  Copyright © 2017年 Hangzhou TaiXuan Network Technology Co., Ltd. All rights reserved.
//

#ifndef ONEControlRoomLog_h
#define ONEControlRoomLog_h

// 日志输出

#define ONEControlRoomLogError(fmt, ...) ONEControlRoomLog(@"【Error】%@", [NSString stringWithFormat:(fmt), ##__VA_ARGS__])
#define ONEControlRoomLogWarn(fmt, ...) ONEControlRoomLog(@"【Warn】%@", [NSString stringWithFormat:(fmt), ##__VA_ARGS__])
#define ONEControlRoomLogDebug(fmt, ...) ONEControlRoomLog(@"【Debug】%@", [NSString stringWithFormat:(fmt), ##__VA_ARGS__])
#define ONEControlRoomLogInfo(fmt, ...) ONEControlRoomLog(@"【Info】%@", [NSString stringWithFormat:(fmt), ##__VA_ARGS__])

#ifdef DEBUG
#define ONEControlRoomLog(format, ...) NSLog((@"\n【%s】【Line %d】" format), __func__, __LINE__, ##__VA_ARGS__)
#else
#define ONEControlRoomLog(...)
#endif

#endif /* ONEControlRoomLog_h */
