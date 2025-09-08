//
//  SFBasePathView.m
//  Snip
//
//  Created by 吴晓明 on 2019/1/28.
//  Copyright © 2019 isee15. All rights reserved.
//

#import "SFBasePathView.h"
#import "ESCursors.h"

@interface SFBasePathView ()

@property(nonatomic, strong) NSTrackingArea *trackingArea;

@end

@implementation SFBasePathView

-(void)dealloc{
     [self removeObserver:self forKeyPath:@"pathInfo.captureState"];
    [NSCursor.arrowCursor set];
    [[self window] enableCursorRects];
    [[self window] resetCursorRects];
}

-(instancetype)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self addObserver:self forKeyPath:@"pathInfo.captureState" options:(NSKeyValueObservingOptionNew  )  context:nil];
        [self setupTrackingArea:self.frame];
        
    }
    return self;
}

-(void)setFrame:(NSRect)frame{
    [super setFrame:frame];
//    NSLog(@"SFBasePathView setFrame:%@",NSStringFromRect(frame));
}

-(NSCursor*)dragCursor{
    if (!_dragCursor) {
        _dragCursor = [ESCursors crossCursorForAngle:0 withSize:20];
    }
    return _dragCursor;
}

- (void)setupTrackingArea:(NSRect)rect
{
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.frame options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect | NSTrackingMouseMoved) owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (void)resetCursorRects
{
    [super resetCursorRects];
    [self addCursorRect:self.bounds cursor:self.dragCursor];
}

-(void)mouseEntered:(NSEvent *)event{
    [self ajustCursor:event];
}

-(void)ajustCursor:(NSEvent *)event{
    NSRect pathRect = CGRectInset(self.bounds, 20, 20);
    NSPoint point = [self.window.contentView convertPoint:event.locationInWindow toView:self];
    if (!NSPointInRect(point, pathRect)) {
        self.pathInfo.captureState = CAPTURE_ITEM_STATE_READY_DRAG;
        NSCursor *cursor = self.dragCursor;
        [cursor set];
    }else{
        self.pathInfo.captureState = CAPTURE_ITEM_STATE_IDLE;
        NSCursor *cursor = NSCursor.arrowCursor;
        [cursor set];
    }
}

-(void)mouseMoved:(NSEvent *)event{
    [self ajustCursor:event];
}

-(void)mouseExited:(NSEvent *)event{
    [[self window] enableCursorRects];
    [[self window] resetCursorRects];
}

-(void)mouseDown:(NSEvent *)event{
    [[self window] disableCursorRects];
    if (event.clickCount == 2) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onDoubleClick:)]) {
            [self.delegate onDoubleClick:self];
            return;
        }
        
    }
    [super mouseDown:event];
}

-(void)mouseUp:(NSEvent *)event{
    
    if (event.clickCount == 2) {
        return;
    }
    
    [super mouseUp:event];

    if (self.delegate && [self.delegate respondsToSelector:@selector(onMouseUp:)]) {
        [self.delegate onMouseUp:self];
    }
}

-(void)mouseDragged:(NSEvent *)event{
//    NSLog(@"SFBasePathView event : %@",event);
    
    if (self.pathInfo.captureState == CAPTURE_ITEM_STATE_READY_DRAG) {
        self.pathInfo.captureState = CAPTURE_ITEM_STATE_DRAG;
    }
    if (self.pathInfo.captureState != CAPTURE_ITEM_STATE_DRAG) {
        [super mouseDragged:event];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(onMouseDrag:)]) {
        [self.delegate onMouseDrag:self];
    }
    
    NSRect frame = self.frame;
    NSPoint frameStartPoint = self.frame.origin;
    frameStartPoint.x += event.deltaX;
    frameStartPoint.y -= event.deltaY;
    frame.origin = frameStartPoint;
    
    NSPoint startPoint = self.pathInfo.startPoint;
    startPoint.x += event.deltaX;
    startPoint.y -= event.deltaY;
    
    NSPoint endPoint = self.pathInfo.endPoint;
    endPoint.x += event.deltaX;
    endPoint.y -= event.deltaY;
    
    self.pathInfo.startPoint = startPoint;
    self.pathInfo.endPoint = endPoint;
    
    self.frame = frame;
}

-(void)onStatusChanged:(CAPTURE_ITEM_STATE)status{
    
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"pathInfo.captureState"]) {
        [self onStatusChanged:self.pathInfo.captureState];
    }
}

@end
