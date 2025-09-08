//
//  SFDrawPathInfo.h
//  Snip
//
//  Created by 吴晓明 on 2019/1/28.
//  Copyright © 2019 顺丰科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFSnipConfig.h"

@interface SFDrawPathInfo : NSObject

@property (nonatomic, assign)NSPoint startPoint;
@property (nonatomic, assign)NSPoint endPoint;
@property (nonatomic, assign)DRAW_TYPE drawType;
@property (nonatomic, assign)CAPTURE_ITEM_STATE captureState;
@property(nonatomic, copy) NSArray *points;
@property(nonatomic, copy) NSString *editText;

@property(nonatomic, copy) NSColor *tintColor;

@property (nonatomic, weak)NSView *drawHostView;

- (instancetype)initWith:(NSPoint)startPoint andEndPoint:(NSPoint)endPoint andType:(DRAW_TYPE)drawType;
- (instancetype)initWith:(NSPoint)startPoint andEndPoint:(NSPoint)endPoint andText:(NSString *)text andType:(DRAW_TYPE)drawType;
- (instancetype)initWith:(NSArray *)points andType:(DRAW_TYPE)drawType;

@end
