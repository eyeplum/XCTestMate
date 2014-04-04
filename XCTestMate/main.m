//
//  main.m
//  XCTestMate
//
//  Created by Yan Li on 4/1/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//


static NSString * const kSchemeArgName = @"-scheme";

static void kFSEventCallback(ConstFSEventStreamRef streamRef,
                           void *clientCallBackInfo,
                           size_t numEvents,
                           void *eventPaths,
                           const FSEventStreamEventFlags eventFlags[],
                           const FSEventStreamEventId eventIds[]);


int main(int argc, const char * argv[]) {
    @autoreleasepool {

        NSString *watchPath = [[NSFileManager defaultManager] currentDirectoryPath];

        NSString *schemeName;
        NSArray *args = [[NSProcessInfo processInfo] arguments];
        BOOL isArgsValid = NO;
        if (args.count > 2) {
            if ([args[1] isEqualToString:kSchemeArgName]) {
                schemeName = args[2];
                isArgsValid = YES;
            }
        }

        if (!isArgsValid) {
            printf("Usage: testmate -scheme YOUR_SCHEME\n");
            return 0;
        }
        
        FSEventStreamContext context = {0, (__bridge void *)schemeName, NULL, NULL, NULL};
        FSEventStreamRef eventStream = FSEventStreamCreate(kCFAllocatorDefault,
                                                           &kFSEventCallback,
                                                           &context,
                                                           (__bridge CFArrayRef) @[watchPath],
                                                           kFSEventStreamEventIdSinceNow,
                                                           0.0,
                                                           kFSEventStreamCreateFlagNone);
        
        FSEventStreamScheduleWithRunLoop(eventStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        FSEventStreamStart(eventStream);
        
        [[NSRunLoop currentRunLoop] run];

    }
    return 0;
}


static void kFSEventCallback(ConstFSEventStreamRef streamRef,
                             void *clientCallBackInfo,
                             size_t numEvents,
                             void *eventPaths,
                             const FSEventStreamEventFlags eventFlags[],
                             const FSEventStreamEventId eventIds[]) {
    
    NSString *schemeName = (__bridge NSString *)clientCallBackInfo;
    NSLog(@"xcodebuild test -scheme %@", schemeName);
}