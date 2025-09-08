//
//  SFToolContainer.h
//  Snip
//
//  Created by 吴晓明 on 2019/1/28.
//  Copyright © 2019 顺丰科技. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef NS_ENUM(NSInteger, ActionType)
{
    ActionUnknow,
    ActionCancel,
    ActionOK,
    ActionShapeRect,
    ActionShapeEllipse,
    ActionShapeArrow,
    ActionEditPen,
    ActionMosaic,
    ActionEditText,
    ActionBack,
    ActionSave,
};

#define ITEM_DEFAULT_WIDTH                       28
#define ITEM_DEFAULT_HEIGHT                      26
#define ITEM_DEFAULT_MARGIN                      10
#define CONTAINER_DEFAULT_HEIGHT                 44


@interface SFToolContainer : NSView

@property(nonatomic,assign,readonly)NSInteger itemCount;

@property(nonatomic, copy) void (^toolClick)(NSInteger index);

-(instancetype)initWithScreen:(NSScreen*)screen;

-(void)setItem:(ActionType)itemType enabled:(BOOL)enabled;


@end
