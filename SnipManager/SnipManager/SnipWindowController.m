//
//  SnipWindowController.m
//  Snip
//
//  Created by rz on 15/1/31.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import "SnipWindowController.h"
#import "SnipWindow.h"
#import "SnipUtil.h"
#import "SFSnipView.h"
#import "AutoHeightTextView.h"
#import "SnipManager.h"
#import "SFRectPathView.h"
#import "SFTextPathView.h"
#import "NSImage+save.h"

const int kAdjustKnown = 8;

@interface SnipWindowController ()
//@property SnipWindow *window;
@property(nonatomic, weak) SFSnipView *snipView;
@property (nonatomic,strong)NSImage *originImage;
@property (nonatomic,strong)NSImage *darkImage;
@property(nonatomic, assign) NSRect captureWindowRect;
@property(nonatomic, assign) NSRect dragWindowRect;

@property (nonatomic, assign)NSRect lastRect;
@property (nonatomic, assign)NSPoint startPoint;
@property (nonatomic, assign)NSPoint endPoint;
@property (nonatomic, assign)NSInteger dragDirection;

@property (nonatomic, assign)NSPoint rectBeginPoint;
@property (nonatomic, assign)NSPoint rectEndPoint;
@property (nonatomic,assign,readwrite)BOOL rectDrawing;

@property(nonatomic,strong) NSMutableArray *linePoints;
// text edit
@property(nonatomic, strong) AutoHeightTextView *editTextView;
@end

@implementation SnipWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)onKeyDown:(NSEvent*)event{
    if( [self.snipView onKeyDown:event]){
        [self.snipView setNeedsDisplayInRect:[self.window convertRectFromScreen:self.captureWindowRect]];
        return YES;
    }
    return NO;
}

- (void)doSnapshot:(NSScreen *)screen
{
    // 获取所有OnScreen的窗口
    //kCGWindowListExcludeDesktopElements
    
    CGImageRef imgRef = [SnipUtil screenShot:screen];
    
    NSLog(@"snimwindowcontroller.m 71");
    NSRect mainFrame = [screen frame];
    self.originImage = [[NSImage alloc] initWithCGImage:imgRef size:mainFrame.size];
    self.darkImage = [[NSImage alloc] initWithCGImage:imgRef size:mainFrame.size];
    CGImageRelease(imgRef);
    NSLog(@"snimwindowcontroller.m 76");
    // 对darkImage做暗化处理
    [self.darkImage lockFocus];
    [[NSColor colorWithCalibratedWhite:0 alpha:0.33] set];
    NSRectFillUsingOperation([SnipUtil rectToZero:mainFrame], NSCompositeSourceAtop);
    [self.darkImage unlockFocus];
    NSLog(@"snimwindowcontroller.m 82");
}

- (void)captureAppScreen
{
    NSScreen *screen = self.window.screen;
    NSPoint mouseLocation = [NSEvent mouseLocation];
    //NSLog(@"screen:%@ mouse:%@",NSStringFromRect(screen.frame),NSStringFromPoint(mouseLocation));
    NSRect screenFrame = [screen frame];
    self.captureWindowRect = screenFrame;
    double minArea = screenFrame.size.width * screenFrame.size.height;
    for (NSDictionary *dir in [SnipManager sharedInstance].arrayRect) {
        CGRect windowRect;
        CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef) dir[(id) kCGWindowBounds], &windowRect);
        NSRect rect = [SnipUtil cgWindowRectToScreenRect:windowRect];
        int layer = 0;
        CFNumberRef numberRef = (__bridge CFNumberRef) dir[(id) kCGWindowLayer];
        CFNumberGetValue(numberRef, kCFNumberSInt32Type, &layer);
        if (layer < 0) continue;
        if ([SnipUtil isPoint:mouseLocation inRect:rect]) {
            if (layer == 0) {
                self.captureWindowRect = rect;
                break;
            }
            else {
                if (rect.size.width * rect.size.height < minArea) {
                    self.captureWindowRect = rect;
                    minArea = rect.size.width * rect.size.height;
                    break;
                }
                
            }
        }
        
    }
    //NSLog(@"capture-----%@",NSStringFromRect(self.captureWindowRect));
    if ([SnipUtil isPoint:mouseLocation inRect:screenFrame]) {
        [self redrawView:self.originImage];
    }
    else {
        [self redrawView:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMouseLocationChange object:nil userInfo:@{@"context":self}];
    }
}

- (void)redrawView:(NSImage *)image
{
    self.captureWindowRect = NSIntersectionRect(self.captureWindowRect, self.window.frame);
    if (image != nil && (int) self.lastRect.origin.x == (int) self.captureWindowRect.origin.x
        && (int) self.lastRect.origin.y == (int) self.captureWindowRect.origin.y
        && (int) self.lastRect.size.width == (int) self.captureWindowRect.size.width
        && (int) self.lastRect.size.height == (int) self.captureWindowRect.size.height) {
        return;
    }
    if (self.snipView.image == nil && image == nil) return;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.snipView setImage:image];
        NSRect rect = [self.window convertRectFromScreen:self.captureWindowRect];
        [self.snipView setDrawingRect:rect];
        [self.snipView setNeedsDisplay:YES];
        self.lastRect = self.captureWindowRect;
        //NSLog(@"redraw hilight:[%@]", NSStringFromRect(rect));
    });
    
}

- (NSPoint)dragPointCenter:(int)index
{
    double x = 0, y = 0;
    switch (index) {
        case 0:
            x = NSMinX(self.captureWindowRect);
            y = NSMaxY(self.captureWindowRect);
            break;
        case 1:
            x = NSMidX(self.captureWindowRect);
            y = NSMaxY(self.captureWindowRect);
            break;
        case 2:
            x = NSMaxX(self.captureWindowRect);
            y = NSMaxY(self.captureWindowRect);
            break;
        case 3:
            x = NSMinX(self.captureWindowRect);
            y = NSMidY(self.captureWindowRect);
            break;
        case 4:
            x = NSMaxX(self.captureWindowRect);
            y = NSMidY(self.captureWindowRect);
            break;
        case 5:
            x = NSMinX(self.captureWindowRect);
            y = NSMinY(self.captureWindowRect);
            break;
        case 6:
            x = NSMidX(self.captureWindowRect);
            y = NSMinY(self.captureWindowRect);
            break;
        case 7:
            x = NSMaxX(self.captureWindowRect);
            y = NSMinY(self.captureWindowRect);
            break;
            
        default:
            break;
    }
    return NSMakePoint(x, y);
}


- (int)dragDirectionFromPoint:(NSPoint)point
{
    if (NSWidth(self.captureWindowRect) <= kAdjustKnown * 2 || NSHeight(self.captureWindowRect) <= kAdjustKnown * 2) {
        if (NSPointInRect(point, self.captureWindowRect)) {
            return 8;
        }
    }
    NSRect innerRect = NSInsetRect(self.captureWindowRect, kAdjustKnown, kAdjustKnown);
    if (NSPointInRect(point, innerRect)) {
        return 8;
    }
    NSRect outerRect = NSInsetRect(self.captureWindowRect, -kAdjustKnown, -kAdjustKnown);
    if (!NSPointInRect(point, outerRect)) {
        return -1;
    }
    double minDistance = kAdjustKnown * kAdjustKnown;
    int ret = -1;
    for (int i = 0; i < 8; i++) {
        NSPoint dragPoint = [self dragPointCenter:i];
        double distance = [SnipUtil pointDistance:dragPoint toPoint:point];
        if (distance < minDistance) {
            minDistance = distance;
            ret = i;
        }
    }
    return ret;
}

- (void)setupToolClick
{
    __weak typeof(self) weakSelf = self;
    self.snipView.toolContainer.toolClick = ^(long index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf endEditText];
        [strongSelf processItemClickAtIndex:index];
    };
    
}

-(void)processItemClickAtIndex:(NSInteger)index{
    switch (index) {
        case ActionShapeRect:
            [SnipManager sharedInstance].drawType = DRAW_TYPE_RECT;
            [SnipManager sharedInstance].captureState = CAPTURE_STATE_EDIT;
            [self.snipView setupDrawPath];
            [self.snipView setNeedsDisplay:YES];
            break;
        case ActionShapeEllipse:
            [SnipManager sharedInstance].drawType = DRAW_TYPE_ELLIPSE;
            [SnipManager sharedInstance].captureState = CAPTURE_STATE_EDIT;
            [self.snipView setupDrawPath];
            [self.snipView setNeedsDisplay:YES];
            break;
        case ActionShapeArrow:
            [SnipManager sharedInstance].drawType = DRAW_TYPE_ARROW;
            [SnipManager sharedInstance].captureState = CAPTURE_STATE_EDIT;
            [self.snipView setupDrawPath];
            [self.snipView setNeedsDisplay:YES];
            break;
        case ActionEditPen:
        case ActionMosaic:{
            if (index == ActionMosaic) {
                [SnipManager sharedInstance].drawType = DRAW_TYPE_MOSAIC;
            }else{
                [SnipManager sharedInstance].drawType = DRAW_TYPE_POINT;
            }
            [SnipManager sharedInstance].captureState = CAPTURE_STATE_EDIT;
            [self.snipView setupDrawPath];
            [self.snipView setNeedsDisplay:YES];
        }
            break;
        case ActionEditText:
            [SnipManager sharedInstance].drawType = DRAW_TYPE_TEXT;
            [SnipManager sharedInstance].captureState = CAPTURE_STATE_EDIT;
            [self.snipView setupDrawPath];
            [self.snipView setNeedsDisplay:YES];
            break;
        case ActionBack:
            [self onBack];
            break;
        case ActionCancel:
            [[SnipManager sharedInstance] cancelCapture];
            break;
        case ActionOK:{
            __block NSRect rect = self.captureWindowRect;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self onOKWithRect:rect];
            });
        }
            break;
        case ActionSave:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self onSave];
            });
        }
            break;
        default:
            break;
    }
}

- (void)startCaptureWithScreen:(NSScreen *)screen
{
    [self doSnapshot:screen];
    
    NSLog(@"snimwindowcontroller.m 297");
    [self.window setBackgroundColor:[NSColor colorWithPatternImage:self.darkImage]];
    NSRect screenFrame = [screen frame];
    screenFrame.size.width /= 1;
    screenFrame.size.height /= 1;
    [self.window setFrame:screenFrame display:YES animate:NO];
    
    NSLog(@"snimwindowcontroller.m 303");
    self.snipView = self.window.contentView;
    ((SnipWindow *) self.window).mouseDelegate = self;
    [self.snipView setupTrackingArea:self.window.screen.frame];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyMouseChange:) name:kNotifyMouseLocationChange object:nil];
    [self showWindow:nil];
    //[self.window makeKeyAndOrderFront:nil];
    [self captureAppScreen];
    NSLog(@"snimwindowcontroller.m 313");
}

- (void)onNotifyMouseChange:(NSNotification *)notify
{
    if (notify.userInfo[@"context"] == self) return;
    NSPoint mouseLocation = [NSEvent mouseLocation];
    if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_HILIGHT && self.window.isVisible && [SnipUtil isPoint:mouseLocation inRect:self.window.screen.frame]) {
        
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^() {
            __typeof__(self) strongSelf = weakSelf;
            [strongSelf showWindow:nil];
            //[self.window makeKeyAndOrderFront:nil];
            [strongSelf captureAppScreen];
        });
        
    }
}

-(void)onClick:(SFBasePathView*)pathView{
    self.rectDrawing = NO;
    for (SFDrawPathInfo *info in self.snipView.pathView.rectArray) {
        if (![pathView.pathInfo isEqual:info]) {
            info.captureState = CAPTURE_ITEM_STATE_IDLE;
        }
    }
}

-(void)onDoubleClick:(SFBasePathView *)pathView{
    
}

- (void)mouseDown:(NSEvent *)event
{
    if ([event clickCount] == 2) {
        NSLog(@"double click");
        if ([SnipManager sharedInstance].captureState != CAPTURE_STATE_HILIGHT) {
            [self onOKWithRect:self.captureWindowRect];
        }
    }
    
    NSPoint mouseLocation = [NSEvent mouseLocation];
    
    if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_HILIGHT) {
        NSLog(@"mouse down :%@", NSStringFromPoint([NSEvent mouseLocation]));
        [SnipManager sharedInstance].captureState = CAPTURE_STATE_FIRSTMOUSEDOWN;
        self.startPoint = [NSEvent mouseLocation];
        [self.snipView setupTool];
        [self setupToolClick];
    }
    else if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_ADJUST) {
        NSLog(@"mouse drag down :%@", NSStringFromPoint([NSEvent mouseLocation]));
        self.startPoint = [NSEvent mouseLocation];
        self.captureWindowRect = [SnipUtil uniformRect:self.captureWindowRect];
        self.dragWindowRect = self.captureWindowRect;
        self.dragDirection = [self dragDirectionFromPoint:[NSEvent mouseLocation]];
        if (NSPointInRect(mouseLocation, self.dragWindowRect)) {
            [self.snipView hideToolkit];
        }
    }
    
    if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_EDIT
        && !NSPointInRect(mouseLocation, self.snipView.toolContainer.frame)) {
        
        if (NSPointInRect(mouseLocation, self.captureWindowRect)) {
            if (DRAW_TYPE_TEXT == [SnipManager sharedInstance].drawType) {
                SFDrawPathInfo *currentInfo = self.snipView.pathView.currentInfo;
                if  (currentInfo.drawHostView.superview != nil) {
                    [self endEditText];
                    return;
                }
            }
            self.rectBeginPoint = mouseLocation;
            
            self.linePoints = [NSMutableArray array];
            
            BOOL mouseInHostView = NO;
            for (SFDrawPathInfo *info in self.snipView.pathView.rectArray) {
                NSPoint point = [self.window.contentView convertPoint:event.locationInWindow toView:self.snipView.pathView];
                if (info.drawHostView
                    && NSPointInRect(point, info.drawHostView.frame)) {
                    if ((info.captureState == CAPTURE_ITEM_STATE_READY_DRAG
                         || info.drawType == DRAW_TYPE_TEXT)) {
                        mouseInHostView = YES;
                        return;
                    }
                    
                }else{
                    info.captureState = CAPTURE_ITEM_STATE_IDLE;
                }
            }
            
            self.rectDrawing = YES;
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_FIRSTMOUSEDOWN
        || [SnipManager sharedInstance].captureState == CAPTURE_STATE_READYADJUST) {
        [SnipManager sharedInstance].captureState = CAPTURE_STATE_ADJUST;
        [self.snipView setNeedsDisplay:YES];
    }
    if ([SnipManager sharedInstance].captureState != CAPTURE_STATE_EDIT) {
        [self.snipView showToolkit];
        [self.snipView hideTip];
        [self.snipView setNeedsDisplay:YES];
    }
    else {
        if (self.rectDrawing) {
            self.rectDrawing = NO;
            self.rectEndPoint = [NSEvent mouseLocation];
            SFDrawPathInfo *currentInfo = self.snipView.pathView.currentInfo;
            if ([SnipManager sharedInstance].drawType == DRAW_TYPE_POINT
                || [SnipManager sharedInstance].drawType == DRAW_TYPE_MOSAIC) {
                [self addPathInfo:[[SFDrawPathInfo alloc] initWith:[self.linePoints copy] andType:[SnipManager sharedInstance].drawType]];
            }
            else {
                if (currentInfo) {
                    [self addPathInfo:currentInfo];
                }else{
                    currentInfo = [[SFDrawPathInfo alloc] initWith:self.rectBeginPoint andEndPoint:self.rectEndPoint andType:[SnipManager sharedInstance].drawType];
                    [self addPathInfo:currentInfo];
                    self.snipView.pathView.currentInfo = currentInfo;
                    
                }
            }
            if ([SnipManager sharedInstance].drawType != DRAW_TYPE_TEXT){
                self.snipView.pathView.currentInfo.captureState = CAPTURE_ITEM_STATE_IDLE;
                [self.snipView.pathView.currentInfo.drawHostView setNeedsDisplay:YES];
                self.snipView.pathView.currentInfo = nil;
            }
            
        }
    }
    
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_FIRSTMOUSEDOWN
        || [SnipManager sharedInstance].captureState == CAPTURE_STATE_READYADJUST) {
        [SnipManager sharedInstance].captureState = CAPTURE_STATE_READYADJUST;
        self.endPoint = [NSEvent mouseLocation];
        
        self.captureWindowRect = NSUnionRect(NSMakeRect(self.startPoint.x, self.startPoint.y, 1, 1), NSMakeRect(self.endPoint.x, self.endPoint.y, 1, 1));
        self.captureWindowRect = NSIntersectionRect(self.captureWindowRect, self.window.frame);
        NSLog(@"mouse drag :%@", NSStringFromRect(self.captureWindowRect));
        [self redrawView:self.originImage];
    }
    else if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_EDIT) {
        if (self.rectDrawing) {
            self.rectEndPoint = [NSEvent mouseLocation];
            if ([SnipManager sharedInstance].drawType == DRAW_TYPE_POINT
                || [SnipManager sharedInstance].drawType == DRAW_TYPE_MOSAIC) {
                [self.linePoints addObject:[NSValue valueWithPoint:self.rectEndPoint]];
                SFDrawPathInfo *pathInfo = self.snipView.pathView.currentInfo;
                if (!pathInfo || pathInfo.drawType != [SnipManager sharedInstance].drawType) {
                    pathInfo = [[SFDrawPathInfo alloc] initWith:[self.linePoints copy] andType:[SnipManager sharedInstance].drawType];
                    self.snipView.pathView.currentInfo = pathInfo;
                }else{
                    pathInfo.points = [self.linePoints copy];
                }
                
            }
            else {
                SFDrawPathInfo *pathInfo = self.snipView.pathView.currentInfo;
                if (!pathInfo
                    || pathInfo.drawType != [SnipManager sharedInstance].drawType) {
                    pathInfo = [[SFDrawPathInfo alloc] initWith:self.rectBeginPoint andEndPoint:self.rectEndPoint andType:[SnipManager sharedInstance].drawType];
                    self.snipView.pathView.currentInfo = pathInfo;
                }else{
                    //                    NSLog(@"self.rectBeginPoint:%@",NSStringFromPoint(self.rectBeginPoint));
                    pathInfo.startPoint = self.rectBeginPoint;
                    pathInfo.endPoint = self.rectEndPoint;
                }
            }
            
            [self.snipView.pathView setNeedsDisplay:YES];
        }
    }
    else if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_ADJUST) {
        if (self.dragDirection == -1) return;
        NSLog(@"adjust drag dir:%d", self.dragDirection);
        NSPoint mouseLocation = [NSEvent mouseLocation];
        self.endPoint = mouseLocation;
        CGFloat deltaX = self.endPoint.x - self.startPoint.x;
        CGFloat deltaY = self.endPoint.y - self.startPoint.y;
        NSRect rect = self.dragWindowRect;
        switch (self.dragDirection) {
            case 8: {
                rect = NSOffsetRect(rect, self.endPoint.x - self.startPoint.x, self.endPoint.y - self.startPoint.y);
                if (!NSContainsRect(self.window.frame, rect)) {
                    NSRect rcOrigin = self.window.frame;
                    if (rect.origin.x < rcOrigin.origin.x) {
                        rect.origin.x = rcOrigin.origin.x;
                    }
                    if (rect.origin.y < rcOrigin.origin.y) {
                        rect.origin.y = rcOrigin.origin.y;
                    }
                    if (rect.origin.x > rcOrigin.origin.x + rcOrigin.size.width - rect.size.width) {
                        rect.origin.x = rcOrigin.origin.x + rcOrigin.size.width - rect.size.width;
                    }
                    if (rect.origin.y > rcOrigin.origin.y + rcOrigin.size.height - rect.size.height) {
                        rect.origin.y = rcOrigin.origin.y + rcOrigin.size.height - rect.size.height;
                    }
                    self.endPoint = NSMakePoint(self.startPoint.x + rect.origin.x - self.dragWindowRect.origin.x, self.startPoint.y + rect.origin.y - self.dragWindowRect.origin.y);
                }
            }
                break;
            case 7: {
                rect.origin.y += deltaY;
                rect.size.width += deltaX;
                rect.size.height -= deltaY;
                
            }
                break;
            case 6: {
                rect.origin.y += deltaY;
                rect.size.height -= deltaY;
            }
                break;
            case 5: {
                rect.origin.x += deltaX;
                rect.origin.y += deltaY;
                rect.size.width -= deltaX;
                rect.size.height -= deltaY;
            }
                break;
            case 4: {
                rect.size.width += deltaX;
            }
                break;
            case 3: {
                rect.origin.x += deltaX;
                rect.size.width -= deltaX;
            }
                break;
            case 2: {
                rect.size.width += deltaX;
                rect.size.height += deltaY;
            }
                break;
            case 1: {
                rect.size.height += deltaY;
            }
                break;
            case 0: {
                rect.origin.x += deltaX;
                rect.size.width -= deltaX;
                rect.size.height += deltaY;
            }
                break;
            default:
                break;
        }
        self.dragWindowRect = rect;
        if ((int) rect.size.width == 0) rect.size.width = 1;
        if ((int) rect.size.height == 0) rect.size.height = 1;
        self.captureWindowRect = [SnipUtil uniformRect:rect];
        self.startPoint = self.endPoint;
        NSLog(@"adjust drag :%@", NSStringFromRect(self.dragWindowRect));
        [self.snipView showTip];
        [self redrawView:self.originImage];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_HILIGHT) {
        [self captureAppScreen];
    }
}

- (void)endEditText
{
    if (DRAW_TYPE_TEXT == [SnipManager sharedInstance].drawType) {
        SFDrawPathInfo *currentInfo = self.snipView.pathView.currentInfo;
        if (currentInfo.drawHostView.superview != nil) {
            self.rectDrawing = NO;
            currentInfo.captureState = CAPTURE_STATE_IDLE;
            self.rectEndPoint = CGPointMake(self.rectBeginPoint.x + currentInfo.drawHostView.frame.size.width, self.rectBeginPoint.y - currentInfo.drawHostView.frame.size.height);
        }
        self.snipView.pathView.currentInfo = nil;
    }
}

-(void)addPathInfo:(SFDrawPathInfo*)pathInfo{
    [self.snipView.pathView.rectArray addObject:pathInfo];
    [self.snipView setNeedsDisplayInRect:[self.window convertRectFromScreen:self.captureWindowRect]];
    [self.snipView.toolContainer setItem:ActionBack enabled:YES];
    [self.snipView.pathView setNeedsDisplay:YES];
    [self.snipView.toolContainer setNeedsDisplay:YES];
}
-(BOOL)removeLastPathInfo{
    
    if (self.snipView.pathView.rectArray.count > 0) {
        self.snipView.pathView.currentInfo = nil;
        SFDrawPathInfo* lastPathInfo = self.snipView.pathView.rectArray.lastObject;
        if (lastPathInfo.drawHostView) {
            [lastPathInfo.drawHostView removeFromSuperview];
        }
        [self.snipView.pathView.rectArray removeLastObject];
        [self.snipView setNeedsDisplayInRect:[self.window convertRectFromScreen:self.captureWindowRect]];
        
        if (self.snipView.pathView.rectArray.count == 0) {
            [self.snipView.toolContainer setItem:ActionBack enabled:NO];
        }
        
        [self.snipView.pathView setNeedsDisplay:YES];
        [self.snipView.toolContainer setNeedsDisplay:YES];
        
        return YES;
    }
    return NO;
}
-(void)onBack{
    [self removeLastPathInfo];
}

// 处理选择的截图
-(NSImage *)capturedImageWithRect:(NSRect)rect {
    
    NSRect newRect = NSIntersectionRect(rect, self.window.frame);
    newRect = [self.window convertRectFromScreen:newRect];
    //blurry mess up
    newRect = NSIntegralRect(newRect);
    /// 隐藏截图工具条
    [self.snipView hideSubViews];
    
    [self.originImage lockFocus];
    NSBitmapImageRep *bits = [[NSBitmapImageRep alloc] initWithFocusedViewRect:newRect];
    [self.originImage unlockFocus];
    
    if (bits.size.height == 0) {
        // initWithFocusedViewRect在10.14会为空，参考issues https://github.com/MiMo42/MMTabBarView/pull/67 by 陈作华20190606
        [self.snipView removeDrawPath];
        NSBitmapImageRep* const imageRep = [self.snipView bitmapImageRepForCachingDisplayInRect:newRect];
        [self.snipView cacheDisplayInRect:newRect toBitmapImageRep:imageRep];
        NSImage *returnImg = [[NSImage alloc] initWithSize:imageRep.size];
        [returnImg addRepresentation:imageRep];
        
        return returnImg;
    }
    
    NSDictionary *imageProps = @{NSImageCompressionFactor : @(1.0)};
    NSData *imageData = [bits representationUsingType:NSJPEGFileType properties:imageProps];
    NSImage *backgroundImage = [[NSImage alloc] initWithData:imageData];
    
    NSImage *pasteImage = nil;
    if (self.snipView.pathView.rectArray.count > 0) {
        self.snipView.pathView.layer.backgroundColor = [NSColor colorWithPatternImage:backgroundImage].CGColor;
        pasteImage = [[NSImage alloc] initWithSize:rect.size];
        [pasteImage lockFocus];
        CGContextRef ctx = [NSGraphicsContext currentContext].CGContext;
        [self.snipView.pathView.layer renderInContext:ctx];
        [pasteImage unlockFocus];
    }else{
        pasteImage = backgroundImage;
    }
    return pasteImage;
}

-(void)onSave{
    __block NSImage *pasteImage = [self capturedImageWithRect:self.captureWindowRect];
    if (!pasteImage) {
        return;
    }
    NSLog(@"保存对话框jiereal");
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard clearContents];
    [pasteBoard writeObjects:@[pasteImage]];
    
    [self.window orderOut:nil];
//  [[SnipManager sharedInstance] endCaptureWithImage:pasteImage needSave:YES isHighResolution:YES];
    
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.title = @"保存图片";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *imageName = [formatter stringFromDate:[NSDate date]];
    
    [panel setNameFieldStringValue:[NSString stringWithFormat:@"%@.png",imageName]];
    [panel setExtensionHidden:NO];
    [panel setCanCreateDirectories:YES];
    NSWindow *mainWindow =  NSApp.mainWindow;
    
    [panel beginSheetModalForWindow:mainWindow completionHandler:^(NSModalResponse result) {
        [mainWindow endSheet:panel];
        [[SnipManager sharedInstance] endCaptureWithImage:pasteImage needSave:YES isHighResolution:YES];
        if (result == NSModalResponseOK) {
            NSURL *urlPath = panel.URL;
            NSLog(@"保存地址：%@",urlPath);
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                CGImageRef cgRef = [pasteImage CGImageForProposedRect:NULL
//                                                              context:nil
//                                                                hints:nil];
//                if (cgRef != nil) {
//                    NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
//                    [newRep setSize:[pasteImage size]];
//                    NSData *imageData = [newRep representationUsingType:NSPNGFileType properties:nil];
//                    [imageData writeToURL:urlPath atomically:YES];
//                    CGImageRelease(cgRef);
//                }else {
//                    NSLog(@"保存失败");
//                }
                NSData *imageData = [pasteImage TIFFRepresentation];
                NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
                if (imageRep != nil && urlPath != nil) {
                    [imageRep setSize:[pasteImage size]];
                    NSData *imageData1 = [imageRep representationUsingType:NSPNGFileType properties:nil];
                    [imageData1 writeToURL:urlPath atomically:YES];
                }else {
                    NSLog(@"保存失败");
                }
            });
        }
    }];
}

- (void)onOKWithRect:(NSRect)rect {
    NSImage *pasteImage = [self capturedImageWithRect:rect];
    if (pasteImage != nil && pasteImage.size.width != 0) {
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [pasteBoard clearContents];
        [pasteBoard writeObjects:@[pasteImage]];
    }
    [self.window orderOut:nil];
    [[SnipManager sharedInstance] endCaptureWithImage:pasteImage needSave:NO isHighResolution:YES];
}

@end
