//
//  SFSnipView.m
//  Snip
//
//  Created by rz on 15/1/31.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import "SFSnipView.h"
#import "NSColor+Helper.h"
#import "SimpleLabelView.h"
#import "SFSnipConfig.h"
#import "SnipManager.h"
#import "SnipUtil.h"

const int kDRAG_POINT_NUM = 8;
const int kDRAG_POINT_LEN = 5;

@interface SFSnipView ()
@property SimpleLabelView *tipView;
@property BOOL shouldClear;

@end

@implementation SFSnipView


/** 清除截图的贝塞尔曲线 */
- (void)removeDrawPath {
    self.shouldClear = YES;
    [self setNeedsDisplay:YES];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{

    if (self = [super initWithCoder:coder]) {
        //_rectArray = [NSMutableArray array];
        self.shouldClear = NO;
    }
    return self;
}

- (void)setupTrackingArea:(NSRect)rect
{
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:rect options:NSTrackingMouseMoved | NSTrackingActiveAlways owner:self userInfo:nil];
    NSLog(@"track init:%@", NSStringFromRect(self.frame));
    [self addTrackingArea:self.trackingArea];
}

- (void)setupTool
{
    self.toolContainer = [[SFToolContainer alloc] initWithScreen:self.window.screen];
    [self addSubview:self.toolContainer];
    [self hideToolkit];

    self.tipView = [[SimpleLabelView alloc] init];
    [self addSubview:self.tipView];
    [self hideTip];
}

- (void)setupDrawPath
{
    self.shouldClear = NO;
    if (self.pathView != nil) return;
    NSLog(@"setupDrawPath");
    self.pathView = [[DrawPathView alloc] init];
    [self addSubview:self.pathView];
    NSRect imageRect = NSIntersectionRect(self.drawingRect, self.bounds);
    [self.pathView setFrame:imageRect];
    [self.pathView setHidden:NO];
}

- (void)showToolkit
{
    NSLog(@"show toolkit:%@",self);
    NSRect imageRect = NSIntersectionRect(self.drawingRect, self.bounds);
    CGFloat y = imageRect.origin.y - CONTAINER_DEFAULT_HEIGHT - 4;
    CGFloat x = imageRect.origin.x + imageRect.size.width;
    y = MAX(y, 0);
    CGFloat margin = ITEM_DEFAULT_MARGIN ;
    CGFloat toolWidth = ITEM_DEFAULT_WIDTH * self.toolContainer.itemCount + margin * (self.toolContainer.itemCount + 1) - 18;
    if (x < toolWidth) x = toolWidth;
    if (!NSEqualRects(self.toolContainer.frame,NSMakeRect(x - toolWidth, y, toolWidth, ITEM_DEFAULT_HEIGHT))) {
        [self.toolContainer setFrame:NSMakeRect(x - toolWidth, y, toolWidth, CONTAINER_DEFAULT_HEIGHT)];
    }
    if (self.toolContainer.isHidden) {
        [self.toolContainer setHidden:NO];
    }
}

- (void)hideToolkit
{
    [self.toolContainer setHidden:YES];
}

- (void)showTip
{
    NSPoint mouseLocation = [NSEvent mouseLocation];
    NSRect frame = self.window.frame;
    if (mouseLocation.x > frame.origin.x + frame.size.width - 100) {
        mouseLocation.x -= 100;
    }
    if (mouseLocation.x < frame.origin.x) {
        mouseLocation.x = frame.origin.x;
    }
    if (mouseLocation.y > frame.origin.y + frame.size.height - 26) {
        mouseLocation.y -= 26;
    }
    if (mouseLocation.y < frame.origin.y) {
        mouseLocation.y = frame.origin.y;
    }
    
    NSRect rect = NSMakeRect(mouseLocation.x, mouseLocation.y, 100, 25);
    NSRect imageRect = NSIntersectionRect(self.drawingRect, self.bounds);
    self.tipView.text = [NSString stringWithFormat:@"%.0fX%.0f", imageRect.size.width,  imageRect.size.height];
    [self.tipView setFrame:[self.window convertRectFromScreen:rect]];
    [self.tipView setNeedsDisplay:YES];
    [self.tipView setHidden:NO];
}

- (void)hideTip
{
    [self.tipView setHidden:YES];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)hideSubViews {
    [self hideToolkit];
    [self hideTip];
}


- (void)drawRect:(NSRect)dirtyRect
{
    NSDisableScreenUpdates();
    [super drawRect:dirtyRect];
    /*if (self.window.screen)
    {
        [[NSColor whiteColor] set];
        for (NSDictionary *dir in [SnipManager sharedInstance].arrayRect) {
            CGRect windowRect;
            CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef) dir[(id) kCGWindowBounds], &windowRect);
            NSRect rect = [SnipUtil cgWindowRectToWindowRect:windowRect inScreen:self.window.screen];
            NSBezierPath *rectPath = [NSBezierPath bezierPath];
            [rectPath setLineWidth:0.5];
            [rectPath appendBezierPathWithRect:rect];
            [rectPath stroke];
        }
    }*/

    if (self.image) {
        NSRect imageRect = NSIntersectionRect(self.drawingRect, self.bounds);
        [self.image drawInRect:imageRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
        if (self.shouldClear) {
            [[NSColor clearColor] set];
        }else {
            [[NSColor colorFromInt:kBORDER_LINE_COLOR] set];
        }
        NSBezierPath *rectPath = [NSBezierPath bezierPath];
        [rectPath setLineWidth:kBORDER_LINE_WIDTH];
        [rectPath removeAllPoints];
        [rectPath appendBezierPathWithRect:imageRect];
        [rectPath stroke];
        if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_ADJUST) {
            if (self.shouldClear) {
                [[NSColor clearColor] set];
            }else {
                [[NSColor whiteColor] set];
            }
            for (int i = 0; i < kDRAG_POINT_NUM; i++) {
                NSBezierPath *adjustPath = [NSBezierPath bezierPath];
                [adjustPath removeAllPoints];
                [adjustPath appendBezierPathWithOvalInRect:[SnipUtil pointRect:i inRect:imageRect]];
                [adjustPath fill];
            }
        }
//        else if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_EDIT) {
//            [self drawCommentInRect:imageRect];
//            if (self.currentInfo) {
//                NSRect rect = NSMakeRect(self.currentInfo.startPoint.x, self.currentInfo.startPoint.y, self.currentInfo.endPoint.x-self.currentInfo.startPoint.x, self.currentInfo.endPoint.y-self.currentInfo.startPoint.y);
//                rect = [SnipUtil uniformRect:rect];
//                rect = [self.window convertRectFromScreen:rect];
//                NSBezierPath *rectPath = [NSBezierPath bezierPath];
//                [rectPath setLineWidth:1.5];
//                [rectPath appendBezierPathWithRect:rect];
//                [rectPath stroke];
//            }
//        }
    }
    if (self.toolContainer != nil && !self.toolContainer.isHidden) {
        [self showToolkit];
    }
    // Drawing code here.
    NSEnableScreenUpdates();
}

-(BOOL)onKeyDown:(NSEvent*)event{
    if( [self.pathView onKeyDown:event]){

        if (self.pathView.rectArray.count == 0) {
            [self.toolContainer setItem:ActionBack enabled:NO];
        }
        
        [self.toolContainer setNeedsDisplay:YES];
        
        return YES;
    }
    return NO;
}

@end
