//
//  SFDrawPathInfo.m
//  Snip
//
//  Created by 吴晓明 on 2019/1/28.
//  Copyright © 2019 顺丰科技. All rights reserved.
//

#import "SFDrawPathInfo.h"
#import "SnipUtil.h"

@implementation SFDrawPathInfo

- (instancetype)initWith:(NSPoint)startPoint andEndPoint:(NSPoint)endPoint andType:(DRAW_TYPE)drawType
{
    if (self = [super init]) {
        _startPoint = startPoint;
        _endPoint = endPoint;
        _drawType = drawType;
    }
    return self;
}

- (instancetype)initWith:(NSPoint)startPoint andEndPoint:(NSPoint)endPoint andText:(NSString *)text andType:(DRAW_TYPE)drawType
{
    if (self = [super init]) {
        _startPoint = startPoint;
        _endPoint = endPoint;
        _editText = text;
        _drawType = drawType;
    }
    return self;
}

- (instancetype)initWith:(NSArray *)points andType:(DRAW_TYPE)drawType
{
    if (self = [super init]) {
        _points = [points copy];
        _drawType = drawType;
    }
    return self;
}

-(NSColor*)tintColor{
    if (!_tintColor) {
        if (self.drawType == DRAW_TYPE_MOSAIC) {
             _tintColor = [NSColor colorWithPatternImage:[SnipUtil imageWithName:@"ScreenCapture_Path_Mosaic" ofType:@"png"]];
        }else{
             _tintColor = [NSColor redColor];
        }
    }
    return _tintColor;
}
@end
