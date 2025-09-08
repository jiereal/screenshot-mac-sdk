//
//  SFBasePathView.h
//  Snip
//
//  Created by 吴晓明 on 2019/1/28.
//  Copyright © 2019 isee15. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFDrawPathInfo.h"

@class SFBasePathView;

@protocol SFPathViewDelegate <NSObject>

-(void)onDoubleClick:(SFBasePathView*)pathView;
-(void)onClick:(SFBasePathView*)pathView;
-(void)onMouseDrag:(SFBasePathView*)pathView;
-(void)onMouseUp:(SFBasePathView*)pathView;

@end

@interface SFBasePathView : NSView

@property(nonatomic,strong)NSCursor *dragCursor;
/**
 绘图item的path信息
 */
@property(nonatomic,strong)SFDrawPathInfo *pathInfo;

@property(nonatomic,weak)id<SFPathViewDelegate> delegate;

-(void)onStatusChanged:(CAPTURE_ITEM_STATE)status;

@end

