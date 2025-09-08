//
//  SnipManager.h
//  Snip
//
//  Created by rz on 15/1/31.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "SFSnipConfig.h"



typedef void(^SFCaptureHandler)(NSImage *image,BOOL needSave,BOOL isHighResolution);

@interface SnipManager : NSObject

@property (nonatomic,strong)NSMutableArray *windowControllerArray;

@property (nonatomic,strong)NSMutableArray *arrayRect;

@property (nonatomic,assign)CAPTURE_STATE captureState;

@property (nonatomic,assign)DRAW_TYPE drawType;

@property (nonatomic,assign)BOOL isWorking;

@property(nonatomic,copy)SFCaptureHandler captureHandler;

+ (instancetype)sharedInstance;

- (void)startCaptureWithCallBack:(SFCaptureHandler)captureHandler;

- (void)startCaptureSavePath:(NSString *)path callBack:(void(^)(NSImage *image,BOOL needSave, BOOL success))captureHandler;

- (void)endCaptureWithImage:(NSImage*)image needSave:(BOOL)needSave isHighResolution:(BOOL)isHighResolution;

- (void)cancelCapture;

-(BOOL)onKeyDown:(NSEvent*)event;

@end
