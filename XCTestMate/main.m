//
//  main.m
//  XCTestMate
//
//  Created by Yan Li on 4/1/14.
//  Copyright (c) 2014 eyeplum. All rights reserved.
//

#import "XTMAppDelegate.h"

int main(int argc, const char * argv[]) {
    XTMAppDelegate *appDelegate = [[XTMAppDelegate alloc] init];
    NSApplication *application = [[NSApplication alloc] init];
    [application setDelegate:appDelegate];
    [application run];
    
    return 0;
}