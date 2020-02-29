#ifdef DEBUG
    #define NSLog(fmt, ...) NSLog((@"[CozyBadges] [%s:%d] " fmt), __FILE__, __LINE__, ##__VA_ARGS__)
#else
    #define NSLog(fmt, ...)
#endif