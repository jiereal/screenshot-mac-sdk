//
//  DrawPathView.h
//  Snip
//
//  Created by isee15 on 15/2/5.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFDrawPathInfo.h"

@interface DrawPathView : NSView
@property NSMutableArray *rectArray;
@property SFDrawPathInfo *currentInfo;

- (void)drawFinishCommentInRect:(NSRect)imageRect;

-(BOOL)onKeyDown:(NSEvent*)event;

@end
