//
//  SnipView.h
//  Snip
//
//  Created by rz on 15/1/31.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFDrawPathInfo.h"
#import "SFToolContainer.h"
#import "DrawPathView.h"

@interface SFSnipView : NSView
@property(nonatomic, strong) NSImage *image;
@property(nonatomic, assign) NSRect drawingRect;
@property(nonatomic, strong) DrawPathView *pathView;

@property(nonatomic, strong) NSTrackingArea *trackingArea;
//@property NSMutableArray *rectArray;
//@property DrawPathInfo *currentInfo;
@property(nonatomic, strong) SFToolContainer *toolContainer;

- (void)setupTrackingArea:(NSRect)rect;

/** 清除截图的贝塞尔曲线 */
- (void)removeDrawPath;

- (void)setupTool;

- (void)setupDrawPath;

- (void)showToolkit;

- (void)hideToolkit;

- (void)showTip;

- (void)hideTip;

- (void)hideSubViews;

- (BOOL)onKeyDown:(NSEvent*)event;

@end
