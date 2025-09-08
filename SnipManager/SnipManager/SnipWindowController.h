//
//  SnipWindowController.h
//  Snip
//
//  Created by rz on 15/1/31.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "SFSnipConfig.h"

@interface SnipWindowController : NSWindowController <NSWindowDelegate, SFMouseEventProtocol>

- (void)startCaptureWithScreen:(NSScreen *)screen;

@end
