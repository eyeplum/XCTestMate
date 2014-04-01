//
//  main.m
//  XCTestMate
//
//  Created by Yan Li on 4/1/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import <sys/event.h>


static NSString * const kSchemeArgName = @"-scheme";
static NSString * schemeName;

static void SocketCallback (
        CFSocketRef socketRef,
        CFSocketCallBackType callBackType,
        CFDataRef address,
        const void * data,
        void * info);


int main(int argc, const char * argv[]) {
    @autoreleasepool {

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

        NSString *dirName = [[NSFileManager defaultManager] currentDirectoryPath];

        int queue = kqueue();
        int dirFD = open(dirName.fileSystemRepresentation, O_RDONLY);

        struct kevent event;
        EV_SET(
        &event,
        dirFD,
        EVFILT_VNODE,
        EV_ADD | EV_CLEAR | EV_ENABLE,
        NOTE_WRITE,
        0,
        (__bridge_retained void *)dirName);

        kevent(queue, &event, 1, NULL, 0, NULL);

        CFSocketContext context = { 0, (void *)&queue, NULL, NULL, NULL};

        CFSocketRef socket = CFSocketCreateWithNative(
                kCFAllocatorDefault,
                queue,
                kCFSocketReadCallBack,
                SocketCallback,
                &context);

        CFRunLoopSourceRef runLoopSource = CFSocketCreateRunLoopSource(
                kCFAllocatorDefault,
                socket,
                0);

        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
        CFRelease(runLoopSource);

        [[NSRunLoop currentRunLoop] run];

    }
    return 0;
}


static void SocketCallback(
        CFSocketRef socketRef,
        CFSocketCallBackType callBackType,
        CFDataRef address,
        const void * data,
        void * info) {

    int queue = *(int *)info;

    struct kevent event;
    kevent(queue, NULL, 0, &event, 1, NULL);

    NSLog(@"xcodebuild test -scheme %@", schemeName);
}