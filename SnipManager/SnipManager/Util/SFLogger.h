//
//  SFLogger.h
//  SnipManager
//
//  统一日志工具，替代裸 NSLog
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SFLogLevel) {
    SFLogLevelDebug = 0,
    SFLogLevelInfo,
    SFLogLevelWarn,
    SFLogLevelError
};

static inline NSString * _Nonnull SFLogLevelString(SFLogLevel level) {
    static NSArray *names = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = @[@"DEBUG", @"INFO", @"WARN", @"ERROR"];
    });
    return names[level];
}

#define SFLogInternal(level, module, fmt, ...) \
    do { \
        NSString *now = [[NSDateFormatter new] stringFromDate:[NSDate date]]; \
        NSString *thread = [[NSThread currentThread] isMainThread] ? @"main" : @"bg"; \
        NSString *msg = [NSString stringWithFormat:(fmt), ##__VA_ARGS__]; \
        NSLog(@"[%@] [%@] [%@:%@] %@", \
              now, \
              SFLogLevelString(level), \
              module, \
              thread, \
              msg); \
    } while (0)

#define SFLogDebug(module, fmt, ...) SFLogInternal(SFLogLevelDebug, module, fmt, ##__VA_ARGS__)
#define SFLogInfo(module, fmt, ...)  SFLogInternal(SFLogLevelInfo,  module, fmt, ##__VA_ARGS__)
#define SFLogWarn(module, fmt, ...)  SFLogInternal(SFLogLevelWarn,  module, fmt, ##__VA_ARGS__)
#define SFLogError(module, fmt, ...) SFLogInternal(SFLogLevelError, module, fmt, ##__VA_ARGS__)