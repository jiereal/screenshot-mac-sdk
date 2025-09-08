//
//  SnipUtil.m
//  Snip
//
//  Created by rz on 15/1/31.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import "SnipUtil.h"
#import "SFSnipConfig.h"

@implementation SnipUtil
+ (CGImageRef)screenShot:(NSScreen *)screen
{
    CFArrayRef windowsRef = CGWindowListCreate(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);

    NSRect rect = [screen frame];
    NSRect mainRect = [NSScreen mainScreen].frame;
    for (NSScreen *subScreen in [NSScreen screens]) {
        if ((int) subScreen.frame.origin.x == 0 && (int) subScreen.frame.origin.y == 0) {
            mainRect = subScreen.frame;
        }
    }
    rect = NSMakeRect(rect.origin.x, (mainRect.size.height) - (rect.origin.y + rect.size.height), rect.size.width, rect.size.height);

    NSLog(@"screenShot: %@", NSStringFromRect(rect));
    CGImageRef imgRef = CGWindowListCreateImageFromArray(rect, windowsRef, kCGWindowImageDefault);
    CFRelease(windowsRef);
    NSLog(@"sniputil.m 29");
    return imgRef;
}

+ (BOOL)isPoint:(NSPoint)point inRect:(NSRect)rect
{
    //if (NSPointInRect(point, rect))
    //NSLog(@"point:%@ in rect:%@",NSStringFromPoint(point),NSStringFromRect(rect));
    return NSPointInRect(point, rect);
}

+ (double)pointDistance:(NSPoint)p1 toPoint:(NSPoint)p2
{
    return (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y);
}

+ (NSRect)pointRect:(int)index inRect:(NSRect)rect
{
    double x = 0, y = 0;
    switch (index) {
        case 0:
            x = NSMinX(rect);
            y = NSMaxY(rect);
            break;
        case 1:
            x = NSMidX(rect);
            y = NSMaxY(rect);
            break;
        case 2:
            x = NSMaxX(rect);
            y = NSMaxY(rect);
            break;
        case 3:
            x = NSMinX(rect);
            y = NSMidY(rect);
            break;
        case 4:
            x = NSMaxX(rect);
            y = NSMidY(rect);
            break;
        case 5:
            x = NSMinX(rect);
            y = NSMinY(rect);
            break;
        case 6:
            x = NSMidX(rect);
            y = NSMinY(rect);
            break;
        case 7:
            x = NSMaxX(rect);
            y = NSMinY(rect);
            break;
            
        default:
            break;
    }
    return NSMakeRect(x - kDRAG_POINT_LEN, y - kDRAG_POINT_LEN, kDRAG_POINT_LEN * 2, kDRAG_POINT_LEN * 2);
}

+ (NSRect)uniformRect:(NSRect)rect
{
    double x = rect.origin.x;
    double y = rect.origin.y;
    double w = rect.size.width;
    double h = rect.size.height;
    if (w < 0) {
        x += w;
        w = -w;
    }
    if (h < 0) {
        y += h;
        h = -h;
    }
    return NSMakeRect(x, y, w, h);
}

+ (NSRect)rectToZero:(NSRect)rect
{
    return NSOffsetRect(rect, -rect.origin.x, -rect.origin.y);
}

+ (NSRect)cgWindowRectToScreenRect:(CGRect)windowRect
{
    NSRect mainRect = [NSScreen mainScreen].frame;
    //NSRect snipRect = screen.frame;
    for (NSScreen *screen in [NSScreen screens]) {
        if ((int) screen.frame.origin.x == 0 && (int) screen.frame.origin.y == 0) {
            mainRect = screen.frame;
        }
    }
    NSRect rect = NSMakeRect(windowRect.origin.x, mainRect.size.height - windowRect.size.height - windowRect.origin.y, windowRect.size.width, windowRect.size.height);
    return rect;
}

+ (SFImageButton *)createButton:(NSImage *)image withAlternate:(NSImage *)alter
{
    SFImageButton *button = [[SFImageButton alloc] init];
    //button.bordered = NO;
    //button.bezelStyle = NSShadowlessSquareBezelStyle;
    [button setImage:image];
    //[button setAlternateImage:alter];
    return button;
}

+(NSImage *)imageWithName:(NSString *)imageName ofType:(NSString *)type inScreen:(NSScreen*)screen{
    NSBundle *bundle = [NSBundle bundleForClass: NSClassFromString(@"SnipManager")];
    NSString *imageSubPath = [NSString stringWithFormat:@"SnipManager.bundle/%@",imageName];
    NSInteger scale = screen ? screen.backingScaleFactor : [NSScreen mainScreen].backingScaleFactor;

    NSString *imagePath = [bundle pathForResource:imageSubPath ofType:type];
    NSImage *image = nil;
    if ([type isEqualToString:@"png"] && scale > 1  ) {
        NSString *bigImageName = [NSString stringWithFormat:@"%@@2x",imageSubPath];
        NSString *bigImagePath = [bundle pathForResource:bigImageName ofType:type];
        if ([[NSFileManager defaultManager] fileExistsAtPath:bigImagePath]) {
            image = [[NSImage alloc] initWithContentsOfFile:bigImagePath];
        }
    }
    if (!image) {
        image = [[NSImage alloc] initWithContentsOfFile:imagePath];
    }
    return image;
}

+(NSImage *)imageWithName:(NSString *)imageName ofType:(NSString *)type{
    return [self imageWithName:imageName ofType:type inScreen:[NSScreen mainScreen]];
}

@end
