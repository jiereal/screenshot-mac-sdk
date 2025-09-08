//
//  SFImageButton.h
//  Snip
//
//  Created by 吴晓明 on 2019/1/28.
//  Copyright © 2019 顺丰科技. All rights reserved.
//


#import "SFImageButton.h"

@implementation SFImageButton

- (void)mouseDown:(NSEvent *)theEvent{
    [NSApp sendAction:self.action to:self.target from:self];
}

@end
