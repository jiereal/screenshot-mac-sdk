//
//  SFEllipsePathView.m
//  Snip
//
//  Created by 吴晓明 on 2019/2/15.
//  Copyright © 2019 顺丰科技. All rights reserved.
//

#import "SFEllipsePathView.h"
#import "SnipUtil.h"

@implementation SFEllipsePathView

-(void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    
    NSRect pathRect = CGRectInset(self.bounds, kDRAG_POINT_LEN + kBORDER_LINE_WIDTH, kDRAG_POINT_LEN + kBORDER_LINE_WIDTH);
    pathRect.origin.x = isinf(pathRect.origin.x) ? 0 : pathRect.origin.x;
    pathRect.origin.y = isinf(pathRect.origin.y) ? 0 : pathRect.origin.y;
//
//    if (self.pathInfo.captureState != CAPTURE_ITEM_STATE_IDLE) {
//        NSColor *borderColor = [self.pathInfo.tintColor colorWithAlphaComponent:0.6];
//        [borderColor set];
//
//        NSBezierPath *rectPath = [NSBezierPath bezierPath];
//        [rectPath setLineWidth:1];
//        [rectPath removeAllPoints];
//        [rectPath appendBezierPathWithRect:pathRect];
//        [rectPath stroke];
//    }

    NSBezierPath *ellipsePath = [NSBezierPath bezierPath];
    [ellipsePath setLineWidth:kBORDER_LINE_WIDTH];
    [ellipsePath removeAllPoints];
    
    [self.pathInfo.tintColor set];
    [ellipsePath appendBezierPathWithOvalInRect:pathRect];
    [ellipsePath stroke];
//
//    if (self.pathInfo.captureState != CAPTURE_ITEM_STATE_IDLE) {
//        for (int i = 0; i < kDRAG_POINT_NUM; i++) {
//
//            NSBezierPath *adjustPath = [NSBezierPath bezierPath];
//            [adjustPath setLineWidth:kBORDER_LINE_WIDTH];
//            [adjustPath removeAllPoints];
//            NSRect ovalRect =  [SnipUtil pointRect:i inRect:pathRect];
//            [adjustPath appendBezierPathWithOvalInRect:ovalRect];
//
//            [NSColor.whiteColor set];
//            [adjustPath fill];
//
//            [self.pathInfo.tintColor set];
//            [adjustPath stroke];
//            
//        }
//    }

}

@end
