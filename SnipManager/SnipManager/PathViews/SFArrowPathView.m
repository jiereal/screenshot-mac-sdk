//
//  SFArrowPathView.m
//  Snip
//
//  Created by 吴晓明 on 2019/2/15.
//  Copyright © 2019 顺丰科技. All rights reserved.
//

#import "SFArrowPathView.h"
#import "SnipUtil.h"

@implementation SFArrowPathView

-(instancetype)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self) {
        self.wantsLayer = YES;
    }
    return self;
}

-(void)mouseDragged:(NSEvent *)event{
  
    [super mouseDragged:event];
    
    CGFloat angle = atan2(self.pathInfo.startPoint.x - self.pathInfo.endPoint.x,self.pathInfo.endPoint.y - self.pathInfo.startPoint.y);
    self.layer.anchorPoint = CGPointMake(0.5, 0);
    [self.layer setAffineTransform:CGAffineTransformMakeRotation(angle)];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect pathRect = CGRectInset(self.bounds, kDRAG_POINT_LEN + kBORDER_LINE_WIDTH, kDRAG_POINT_LEN + kBORDER_LINE_WIDTH);
    pathRect.origin.x = isinf(pathRect.origin.x) ? 0 : pathRect.origin.x;
    pathRect.origin.y = isinf(pathRect.origin.y) ? 0 : pathRect.origin.y;

    [self.pathInfo.tintColor set];

    NSBezierPath *linePath = [NSBezierPath bezierPath];
    [linePath setLineCapStyle:NSRoundLineCapStyle];
    [linePath setLineJoinStyle:NSRoundLineJoinStyle];
    
    CGFloat pointX = dirtyRect.size.width / 2;
    CGFloat pointY = CGRectGetMaxY(pathRect);
    [linePath moveToPoint:NSMakePoint(pointX , CGRectGetMinY(pathRect))];
    CGFloat offsetScale = dirtyRect.size.height / 150;
    offsetScale = MIN(offsetScale, 1);
    CGFloat offsetX1 = offsetScale * 5;
    CGFloat offsetX2 = offsetScale * 13;
    CGFloat offsetY1 = offsetScale * 25;
    CGFloat offsetY2 = offsetScale * 30;
    [linePath lineToPoint:NSMakePoint(pointX + offsetX1, pointY - offsetY1)];
    [linePath lineToPoint:NSMakePoint(pointX + offsetX2, pointY - offsetY2)];
    [linePath lineToPoint:NSMakePoint(pointX , pointY )];
    [linePath lineToPoint:NSMakePoint(pointX - offsetX2, pointY - offsetY2)];
    [linePath lineToPoint:NSMakePoint(pointX - offsetX1, pointY - offsetY1)];
    [linePath lineToPoint:NSMakePoint(pointX , CGRectGetMinY(pathRect))];

    [linePath setLineWidth:kBORDER_LINE_WIDTH];
    [linePath lineToPoint:NSMakePoint(dirtyRect.size.width / 2 , pathRect.size.height)];
    [linePath fill];
    [linePath stroke];
    
    [linePath closePath];
    
//    if (self.pathInfo.captureState != CAPTURE_ITEM_STATE_IDLE) {
//        {
//            NSBezierPath *adjustPath = [NSBezierPath bezierPath];
//            [adjustPath setLineWidth:kBORDER_LINE_WIDTH];
//            [adjustPath removeAllPoints];
//            NSRect ovalRect =  [SnipUtil pointRect:1 inRect:pathRect];
//            [adjustPath appendBezierPathWithOvalInRect:ovalRect];
//            
//            [NSColor.whiteColor set];
//            [adjustPath fill];
//            
//            [self.pathInfo.tintColor set];
//            [adjustPath stroke];
//        }
//        {
//            NSBezierPath *adjustPath = [NSBezierPath bezierPath];
//            [adjustPath setLineWidth:kBORDER_LINE_WIDTH];
//            [adjustPath removeAllPoints];
//            NSRect ovalRect =  [SnipUtil pointRect:6 inRect:pathRect];
//            [adjustPath appendBezierPathWithOvalInRect:ovalRect];
//            
//            [NSColor.whiteColor set];
//            [adjustPath fill];
//            
//            [self.pathInfo.tintColor set];
//            [adjustPath stroke];
//        }
//    }

    
//    NSAffineTransform *af = [NSAffineTransform transform];
//    [af translateXBy:x0 yBy:y0];
//    [af rotateByRadians:atan2(y1 - y0, x1 - x0)];
//    [linePath transformUsingAffineTransform:af];
//    [linePath fill];
//    [linePath stroke];

    CGFloat angle = atan2(self.pathInfo.startPoint.x - self.pathInfo.endPoint.x,self.pathInfo.endPoint.y - self.pathInfo.startPoint.y);
    self.layer.anchorPoint = CGPointMake(0.5, 0);
    [self.layer setAffineTransform:CGAffineTransformMakeRotation(angle)];

}

@end
