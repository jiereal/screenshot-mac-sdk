//
//  NSImage+save.m
//  SnipManager
//
//  Created by CHENZUOHUA on 2021/1/12.
//  Copyright © 2021 isee15. All rights reserved.
//

#import "NSImage+save.h"

@implementation NSImage (save)


- (NSBitmapImageRep *)unscaledBitmapImageRep {
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                               initWithBitmapDataPlanes:NULL
                                             pixelsWide:self.size.width
                                             pixelsHigh:self.size.height
                                          bitsPerSample:8
                                        samplesPerPixel:4
                                               hasAlpha:YES
                                               isPlanar:NO
                                         colorSpaceName:NSDeviceRGBColorSpace
                                            bytesPerRow:0
                                           bitsPerPixel:0];
    rep.size = self.size;

   [NSGraphicsContext saveGraphicsState];
   [NSGraphicsContext setCurrentContext:
            [NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];

    [self drawAtPoint:NSMakePoint(0, 0)
             fromRect:NSZeroRect
            operation:NSCompositeSourceOver
             fraction:1.0];

    [NSGraphicsContext restoreGraphicsState];
    return rep;
}

@end
