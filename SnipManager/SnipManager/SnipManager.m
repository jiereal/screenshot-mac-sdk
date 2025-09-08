//
//  SnipManager.m
//  Snip
//
//  Created by rz on 15/1/31.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import "SnipManager.h"
#import "SnipWindowController.h"
#import "SFSnipView.h"
#import "SnipWindow.h"
#import "SnipUtil.h"

const double kBORDER_LINE_WIDTH = 2.0;
const int kBORDER_LINE_COLOR = 0x1191FE;
const int kKEY_DELETE_CODE = 51;
const int kKEY_ESC_CODE = 53;

@interface SnipManager ()

@end

@implementation SnipManager

+ (instancetype)sharedInstance
{
    static SnipManager *sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void) {
        sharedSingleton = [[self alloc] init];
        sharedSingleton.windowControllerArray = [NSMutableArray array];
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:sharedSingleton
                                                               selector:@selector(screenChanged:)
                                                                   name:NSWorkspaceActiveSpaceDidChangeNotification
                                                                 object:[NSWorkspace sharedWorkspace]];
        [[NSNotificationCenter defaultCenter] addObserver:sharedSingleton selector:@selector(screenChanged:) name:NSApplicationDidChangeScreenParametersNotification object:nil];
    });
    return sharedSingleton;
}

- (void)dealloc
{
    NSLog(@"SnipManager dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

- (void)screenChanged:(NSNotification *)notify
{
    NSLog(@"--space changed--%@", notify.userInfo);
    if (self.isWorking) {
        [self cancelCapture];
    }
}

- (void)clearController
{
    if (_windowControllerArray) {
        [_windowControllerArray removeAllObjects];
    }
}

- (void)startCaptureSavePath:(NSString *)path callBack:(void(^)(NSImage *image,BOOL needSave, BOOL success))captureHandler {
    NSURL *pathUrl;
    if (path != nil && path.length > 1) {
        if (![path containsString:@"file://"]) {
            pathUrl = [NSURL URLWithString: [[NSString stringWithFormat:@"file://%@", path] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    __block BOOL success = NO;
    NSLog(@"--------- URL : %@ ---------- ", pathUrl);
    [self startCaptureWithCallBack:^(NSImage *image, BOOL needSave, BOOL isHighResolution) {
        NSLog(@"--------- URL : %@ ---------- ");
        success = image != nil;
        if (image != nil && pathUrl != nil && needSave == NO) {
            NSLog(@"--------- 准备保存 ---------- %@",pathUrl);
            CGImageRef cgRef = [image CGImageForProposedRect:NULL
                                                          context:nil
                                                            hints:nil];
            
            if (cgRef != nil) {
                NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
                [newRep setSize:[image size]];
                NSData *imageData = [newRep representationUsingType:NSPNGFileType properties:nil];
                [imageData writeToURL:pathUrl atomically:YES];
            }else {
                success = NO;
            }
        }
        !captureHandler ?: captureHandler(image, needSave, success);
    }];
}

-(void)startCaptureWithCallBack:(SFCaptureHandler)captureHandler{
    
    NSLog(@"startCaptureWithCallBack 97");
    if (self.isWorking) {
        return;
    }
    
    self.captureHandler = captureHandler;
    
    self.isWorking = YES;
    self.arrayRect = [NSMutableArray array];
    //CFArrayRef windowArray = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    NSArray *windows = (__bridge NSArray *) CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    NSUInteger count = [windows count];
    NSLog(@"startCaptureWithCallBack 109");
    for (NSUInteger i = 0; i < count; i++) {
        NSDictionary *windowDescriptionDictionary = windows[i];
//        CGRect bounds;
//        CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef) windowDescriptionDictionary[(id) kCGWindowBounds], &bounds);
        //NSLog(@"------%@",NSStringFromRect(bounds));
        [self.arrayRect addObject:windowDescriptionDictionary];
    }
    //CFRelease(windowArray);
    
    NSLog(@"startCaptureWithCallBack 119");
    for (NSInteger index = [NSScreen screens].count - 1; index >=0; index--) {
//        SnipWindowController *snipController = [[SnipWindowController alloc] initWithWindowNibName:@"SnipWindowController"];
        NSScreen *screen = [NSScreen screens][index];
        SnipWindowController *snipController = [[SnipWindowController alloc] init];
        SnipWindow *snipWindow = [[SnipWindow alloc] initWithContentRect:[screen frame] styleMask:NSNonactivatingPanelMask backing:NSBackingStoreBuffered defer:NO screen:screen];
        snipController.window = snipWindow;
        SFSnipView *snipView = [[SFSnipView alloc] initWithFrame:NSMakeRect(0, 0, [screen frame].size.width, [screen frame].size.height)];
        snipWindow.contentView = snipView;
        [self.windowControllerArray addObject:snipController];
        self.captureState = CAPTURE_STATE_HILIGHT;
        [snipController startCaptureWithScreen:screen];
    }
}

- (void)endCaptureWithImage:(NSImage*)image needSave:(BOOL)needSave isHighResolution:(BOOL)isHighResolution{
    
    if (!self.isWorking) {
        return;
    }
    self.isWorking = NO;
    for (SnipWindowController *windowController in self.windowControllerArray) {
        [windowController.window orderOut:nil];
    }
    [self clearController];
    NSLog(@"post endcapture:%@", kNotifyCaptureEnd);
    if (self.captureHandler) {
        self.captureHandler(image,needSave,isHighResolution);
    }
    self.captureHandler = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyCaptureEnd object:nil userInfo:image == nil ? nil : @{@"image" : image}];
}

- (void)cancelCapture{
    [self endCaptureWithImage:nil needSave:NO isHighResolution:NO];
}

@end
