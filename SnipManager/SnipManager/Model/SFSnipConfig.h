//
//  SFSnipConfig.h
//  Snip
//
//  Created by 吴晓明 on 2019/1/28.
//  Copyright © 2019 顺丰科技. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, CAPTURE_STATE)
{
    CAPTURE_STATE_IDLE,
    CAPTURE_STATE_HILIGHT,
    CAPTURE_STATE_FIRSTMOUSEDOWN,
    CAPTURE_STATE_READYADJUST,
    CAPTURE_STATE_ADJUST,
    CAPTURE_STATE_EDIT,
    CAPTURE_STATE_DRAGITEM,
    CAPTURE_STATE_DONE,
};

typedef NS_ENUM(NSInteger, DRAW_TYPE)
{
    DRAW_TYPE_RECT,
    DRAW_TYPE_ELLIPSE,
    DRAW_TYPE_ARROW,
    DRAW_TYPE_POINT,
    DRAW_TYPE_MOSAIC,
    DRAW_TYPE_TEXT
};

typedef NS_ENUM(NSInteger, CAPTURE_ITEM_STATE)
{
    CAPTURE_ITEM_STATE_IDLE,
    CAPTURE_ITEM_STATE_HILIGHT,
    CAPTURE_ITEM_STATE_FIRSTMOUSEDOWN,
    CAPTURE_ITEM_STATE_READYADJUST,
    CAPTURE_ITEM_STATE_ADJUST,
    CAPTURE_ITEM_STATE_EDIT,
    CAPTURE_ITEM_STATE_READY_DRAG,
    CAPTURE_ITEM_STATE_DRAG,
};

#define kNotifyCaptureEnd               @"kNotifyCaptureEnd"
#define kNotifyMouseLocationChange      @"kNotifyMouseLocationChange"

extern const double kBORDER_LINE_WIDTH;
extern const int kBORDER_LINE_COLOR;
extern const int kKEY_ESC_CODE;
extern const int kKEY_DELETE_CODE;
extern const int kDRAG_POINT_NUM;
extern const int kDRAG_POINT_LEN;

@protocol SFMouseEventProtocol <NSObject>

- (void)mouseDown:(NSEvent *)theEvent;

- (void)mouseUp:(NSEvent *)theEvent;

- (void)mouseDragged:(NSEvent *)theEvent;

- (void)mouseMoved:(NSEvent *)theEvent;

-(BOOL)onKeyDown:(NSEvent*)event;

@end

