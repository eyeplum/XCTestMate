//
//  XTMAppDelegate.m
//  XCTestMate
//
//  Created by Yan Li on 4/4/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "XTMAppDelegate.h"

static NSString * const kSchemeArgName = @"-scheme";
static void kFSEventCallback(ConstFSEventStreamRef streamRef,
                             void *clientCallBackInfo,
                             size_t numEvents,
                             void *eventPaths,
                             const FSEventStreamEventFlags eventFlags[],
                             const FSEventStreamEventId eventIds[]);

@interface XTMAppDelegate ()

@property (nonatomic, strong) NSString *testCommand;

@end

@implementation XTMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
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
        return;
    }
    
    self.testCommand = [NSString stringWithFormat:@"xcodebuild test -scheme %@", schemeName];
    
    FSEventStreamContext context = {0, (__bridge void *) self, NULL, NULL, NULL};
    FSEventStreamRef eventStream = FSEventStreamCreate(kCFAllocatorDefault,
                                                       &kFSEventCallback,
                                                       &context,
                                                       (__bridge CFArrayRef) @[watchPath],
                                                       kFSEventStreamEventIdSinceNow,
                                                       0.0,
                                                       kFSEventStreamCreateFlagUseCFTypes);
    
    FSEventStreamScheduleWithRunLoop(eventStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(eventStream);
}


static void kFSEventCallback(ConstFSEventStreamRef streamRef,
                             void *clientCallBackInfo,
                             size_t numEvents,
                             void *eventPaths,
                             const FSEventStreamEventFlags eventFlags[],
                             const FSEventStreamEventId eventIds[]) {
    
    XTMAppDelegate *appDelegate = (__bridge XTMAppDelegate *) clientCallBackInfo;
    [appDelegate handleFileStreamEventWithPaths:(__bridge NSArray *) ((CFArrayRef) eventPaths)];
}


- (void)handleFileStreamEventWithPaths:(NSArray *)paths {
    NSLog(@"%@", paths);
    system([self.testCommand UTF8String]);
}

@end
