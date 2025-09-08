//
//  SFTextPathView.m
//  Snip
//
//  Created by 吴晓明 on 2019/2/20.
//  Copyright © 2019 顺丰科技. All rights reserved.
//

#import "SFTextPathView.h"
#import "AutoHeightTextView.h"

@interface SFTextPathView ()<NSTextFieldDelegate,NSTextViewDelegate>{
    NSFont *_font;
    NSColor *_textColor;
    
}

@property(nonatomic, strong) NSTextField *textField;
@property(nonatomic, strong) AutoHeightTextView *editTextView;

@end

@implementation SFTextPathView

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self) {
        _string = @"";
        [self addSubview:self.editTextView];
//        self.layer.borderColor = [NSColor redColor].CGColor;

    }
    return self;
}

-(NSFont *)font{
    if (!_font) {
        _font = [NSFont systemFontOfSize:16];
    }
    return _font;
}

-(NSColor *)textColor{
    if (!_textColor) {
        _textColor = [NSColor redColor];
    }
    return _textColor;
}

-(void)setTextColor:(NSColor *)textColor{
    _textColor = textColor;
    _textField.textColor = textColor;
    _editTextView.textColor = textColor;
}
-(void)setString:(NSString *)string{
    _string = string;
    _textField.stringValue = string ? : @"";
    _editTextView.string = string ? : @"";
}

-(NSTextField *)textField{
    if (!_textField) {
        NSTextField *label = [[NSTextField alloc] initWithFrame:self.bounds];
        label.maximumNumberOfLines = 0;
        label.bezeled = NO;
        label.backgroundColor = [NSColor clearColor];
        label.editable = NO;
        label.stringValue = self.string ? : @"";
        if (self.pathInfo) {
            label.textColor = self.pathInfo.tintColor;
        }else{
            label.textColor = self.textColor ? : [NSColor redColor];
        }
        
        label.font = self.font;
        _textField = label;
    }
    return _textField;
}

-(AutoHeightTextView *)editTextView{
    if (!_editTextView) {
        AutoHeightTextView *editTextView = [[AutoHeightTextView alloc] initWithFrame:self.bounds];
        editTextView.backgroundColor = [NSColor clearColor];
        editTextView.wantsLayer = YES;
        editTextView.layer.borderColor = [NSColor redColor].CGColor;
        editTextView.layer.borderWidth = 1;
        editTextView.layer.shadowOffset = NSZeroSize;
        editTextView.font = self.font;
        editTextView.textColor = self.textColor;
        editTextView.insertionPointColor = self.pathInfo.tintColor;
        editTextView.textContainerInset = CGSizeMake(0, 0);
        editTextView.delegate = self;
        _editTextView = editTextView;
    }
    return _editTextView;
}

-(void)setFont:(NSFont *)font{
    _editTextView.font = font;
    _textField.font = font;
}

-(void)setPathInfo:(SFDrawPathInfo *)pathInfo{
    [super setPathInfo:pathInfo];
    _editTextView.insertionPointColor = pathInfo.tintColor;
    _editTextView.textColor = pathInfo.tintColor;
    _textField.textColor = pathInfo.tintColor;
    
}

- (void)textDidChange:(NSNotification *)notification{
    if (![notification.object isEqual:self.editTextView]) {
        return;
    }
    _string = self.editTextView.string;
    [self resetSize];
}

-(void)onStatusChanged:(CAPTURE_ITEM_STATE)status{
    if (status == CAPTURE_ITEM_STATE_IDLE) {
        [_editTextView removeFromSuperview];
        self.textField.stringValue = self.editTextView.string ? : @"";
        [self addSubview:self.textField];
        [self resetSize];
    }else if (status == CAPTURE_ITEM_STATE_EDIT) {
        [_textField removeFromSuperview];
        [self addSubview:self.editTextView];
        self.editTextView.string = _textField.stringValue ? : @"";
        [self.editTextView setSelectedRange:NSMakeRange(self.editTextView.string.length,0)];
        [self.window makeFirstResponder:self.editTextView];
        [self resetSize];
    }
}

-(void)resetSize{
    CGSize size = [self.string ? : @"" boundingRectWithSize:CGSizeMake(FLT_MAX, FLT_MAX)
                                                         options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin)
                                                      attributes:@{NSFontAttributeName: self.font}
                                                         context:nil].size;
    NSRect frame = self.frame;
    frame.size.height = MAX(24, size.height + 10);
    frame.size.width = MAX(120, size.width + 10);
    self.frame = frame;
    
    frame.origin.x = 0;
    frame.origin.y = 0.1;
    frame.size.height = size.height;
    self.editTextView.frame = frame;
    self.textField.frame = frame;
}

-(void)mouseEntered:(NSEvent *)event{

    self.pathInfo.captureState = CAPTURE_ITEM_STATE_READY_DRAG;
    NSCursor *cursor = self.dragCursor;
    [cursor set];
    
}

-(void)mouseMoved:(NSEvent *)event{
    
}

@end
