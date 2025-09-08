//
//  NSImage+save.h
//  SnipManager
//
//  Created by CHENZUOHUA on 2021/1/12.
//  Copyright © 2021 isee15. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (save)
- (NSBitmapImageRep *)unscaledBitmapImageRep;
@end

NS_ASSUME_NONNULL_END
