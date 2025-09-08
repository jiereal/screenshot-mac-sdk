//
//  DrawPathView.m
//  Snip
//
//  Created by isee15 on 15/2/5.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import "DrawPathView.h"
#import "SnipUtil.h"
#import "SnipManager.h"
#import "SFRectPathView.h"
#import "SFEllipsePathView.h"
#import "SFArrowPathView.h"
#import "SFTextPathView.h"

@interface DrawPathView ()<SFPathViewDelegate>


@end

@implementation DrawPathView

- (instancetype)init
{
    if (self = [super init]) {
        _rectArray = [NSMutableArray array];
    }
    return self;
}

- (NSRect)rectFromScreen:(NSRect)rect
{
    NSRect rectRet = [self.window convertRectFromScreen:rect];
    rectRet.origin.x -= self.frame.origin.x;
    rectRet.origin.y -= self.frame.origin.y;
    return rectRet;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_EDIT) {
        [self drawCommentInRect:self.bounds];
        if (self.currentInfo) {
            [self.currentInfo.tintColor set];
            [self drawShape:self.currentInfo inBackground:NO];
        }
    }
}

-(BOOL)onKeyDown:(NSEvent*)event{
    BOOL ignore = NO;
    
    if ([event keyCode] == kKEY_DELETE_CODE) {
        for (SFDrawPathInfo *info in self.rectArray) {
            if (info.drawHostView
                && info.captureState != CAPTURE_STATE_IDLE) {
                [info.drawHostView removeFromSuperview];
                [self.rectArray removeObject:info];
                [self setNeedsDisplay:YES];
                
                ignore = YES;
                break;
            }
        }
        
    }
    
    return ignore;
}

-(void)onMouseDrag:(SFBasePathView*)pathView{
    [SnipManager sharedInstance].captureState = CAPTURE_STATE_DRAGITEM;
}

-(void)onMouseUp:(SFBasePathView*)pathView{
    if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_DRAGITEM) {
        [SnipManager sharedInstance].captureState = CAPTURE_STATE_EDIT;
    }
}

-(void)onDoubleClick:(SFBasePathView *)pathView{
    if (pathView.pathInfo.drawType == DRAW_TYPE_TEXT) {
        [SnipManager sharedInstance].captureState = CAPTURE_STATE_EDIT;
        pathView.pathInfo.captureState = CAPTURE_ITEM_STATE_EDIT;
        self.currentInfo.captureState = CAPTURE_ITEM_STATE_IDLE;
        self.currentInfo = pathView.pathInfo;
    }
}

- (void)drawCommentInRect:(NSRect)imageRect
{
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:imageRect];
    [path addClip];
    
    for (SFDrawPathInfo *info in self.rectArray) {
        [info.tintColor set];
        [self drawShape:info inBackground:NO];
    }
}

- (void)drawFinishCommentInRect:(NSRect)imageRect
{
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:imageRect];
    [path addClip];
    
    for (SFDrawPathInfo *info in self.rectArray) {
        [info.tintColor set];
        [self drawShape:info inBackground:YES];
    }
}

- (void)drawShape:(SFDrawPathInfo *)info inBackground:(BOOL)bIn
{
    NSRect rect = NSMakeRect(info.startPoint.x, info.startPoint.y, info.endPoint.x - info.startPoint.x, info.endPoint.y - info.startPoint.y);

    if (bIn) {
        rect = [self.window convertRectFromScreen:rect];
    }
    else {
        rect = [self rectFromScreen:rect];
    }
    
    switch (info.drawType) {
        case DRAW_TYPE_RECT:{
            rect = [SnipUtil uniformRect:rect];
            if (rect.size.width * rect.size.width < 1e-2) return;
            SFRectPathView *pathView = info.drawHostView;
            if (!pathView) {
                pathView = [[SFRectPathView alloc] init];
                pathView.pathInfo = info;
                info.captureState = CAPTURE_ITEM_STATE_EDIT;
                info.drawHostView = pathView;
                pathView.delegate = self;
            }
            if (!pathView.superview) {
                [self addSubview:info.drawHostView];
            }
            info.drawHostView.frame = rect;
            break;
        }
        case DRAW_TYPE_ELLIPSE:{
            rect = [SnipUtil uniformRect:rect];
            if (rect.size.width * rect.size.width < 1e-2) return;
            SFEllipsePathView *pathView = info.drawHostView;
            if (!pathView) {
                pathView = [[SFEllipsePathView alloc] init];
                pathView.pathInfo = info;
                info.captureState = CAPTURE_ITEM_STATE_EDIT;
                info.drawHostView = pathView;
                 pathView.delegate = self;
            }
            if (!pathView.superview) {
                [self addSubview:info.drawHostView];
            }
            info.drawHostView.frame = rect;
        }
            break;
        case DRAW_TYPE_ARROW: {
            rect.size.height = sqrt(rect.size.width * rect.size.width + rect.size.height * rect.size.height);
            rect.size.width = 50;
            SFArrowPathView *pathView = info.drawHostView;
            if (!pathView) {
                pathView = [[SFArrowPathView alloc] init];
                pathView.pathInfo = info;
                info.captureState = CAPTURE_ITEM_STATE_EDIT;
                info.drawHostView = pathView;
                 pathView.delegate = self;
            }
            if (!pathView.superview) {
                [self addSubview:info.drawHostView];
            }
            info.drawHostView.frame = rect;
        }
            break;
        case DRAW_TYPE_TEXT: {
           
            SFTextPathView *pathView = info.drawHostView;
            if (!pathView) {
                rect.origin.y -= 12;
                rect.size.height = 24;
                rect.size.width = rect.size.width > 0 ? : 120;
                pathView = [[SFTextPathView alloc] initWithFrame:rect];
                
                [self addSubview:pathView];
                pathView.pathInfo = info;
                info.captureState = CAPTURE_ITEM_STATE_EDIT;
                info.drawHostView = pathView;
                pathView.delegate = self;
            }
            if (!pathView.superview) {
                [self addSubview:info.drawHostView];
            }
        }
            break;
        case DRAW_TYPE_POINT:
        case DRAW_TYPE_MOSAIC:{

            NSBezierPath *pointPath = [NSBezierPath bezierPath];
            CGFloat lineWidth = info.drawType == DRAW_TYPE_POINT ? 4 : 15;
            [pointPath setLineWidth:lineWidth];
            [pointPath setLineCapStyle:NSRoundLineCapStyle];
            [pointPath setLineJoinStyle:NSRoundLineJoinStyle];
            NSValue *lastPoint;
            for(NSValue *value in info.points)
            {
                NSPoint point = value.pointValue;
                NSLog(@"point:%@",NSStringFromPoint(point));
                NSRect rect = NSMakeRect(point.x, point.y, 1,1);
                if (bIn) {
                    rect = [self.window convertRectFromScreen:rect];
                }
                else {
                    rect = [self rectFromScreen:rect];
                }
                NSLog(@"rect.point:%@",NSStringFromPoint(rect.origin));
                if (lastPoint == nil) {
                    [pointPath moveToPoint:rect.origin];
                    lastPoint = value;
                }
                else {
                    [pointPath lineToPoint:rect.origin];
                }
            }
            [info.tintColor set];
            [pointPath stroke];
        }
            break;
        default:
            break;
    }

}

@end
