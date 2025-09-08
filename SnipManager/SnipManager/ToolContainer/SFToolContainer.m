//
//  SFToolContainer.m
//  Snip
//
//  Created by 吴晓明 on 2019/1/28.
//  Copyright © 2019 顺丰科技. All rights reserved.
//

#import "SFToolContainer.h"
#import "SFImageButton.h"
#import "SnipUtil.h"

@interface SFToolContainer ()

@property(nonatomic, strong) SFImageButton *rectButton;
@property(nonatomic, strong) SFImageButton *ellipseButton;
@property(nonatomic, strong) SFImageButton *arrowButton;
@property(nonatomic, strong) SFImageButton *textButton;
@property(nonatomic, strong) SFImageButton *penButton;
@property(nonatomic, strong) SFImageButton *mosaicButton;
@property(nonatomic, strong) SFImageButton *backButton;
@property(nonatomic, strong) SFImageButton *splitButton;
@property(nonatomic, strong) SFImageButton *saveButton;
@property(nonatomic, strong) SFImageButton *cancelButton;
@property(nonatomic, strong) SFImageButton *okButton;

@property(nonatomic, strong) NSArray<SFImageButton *> *tools;

@property(nonatomic, strong) NSScreen *screen;

@end

@implementation SFToolContainer

-(NSImage *)imageWithName:(NSString *)imageName ofType:(NSString *)type{
    return [SnipUtil imageWithName:imageName ofType:type inScreen:_screen];
}

-(instancetype)initWithScreen:(NSScreen*)screen{
    self = [super init];
    if (self) {
        _screen = screen;
        [self setUP];
    }
    return self;
}
- (instancetype)init{
    if (self = [super init]) {
        [self setUP];
    }
    return self;
}

-(void)setUP{
    NSImage *image = [self imageWithName:@"ScreenCapture_toolbar_rect_ineffect" ofType:@"tiff"];
    _rectButton = [SnipUtil createButton:image withAlternate:nil];
    _rectButton.tag = ActionShapeRect;
    
    image = [self imageWithName:@"ScreenCapture_toolbar_ellipse_ineffect" ofType:@"tiff"];
    _ellipseButton = [SnipUtil createButton:image withAlternate:nil];
    _ellipseButton.tag = ActionShapeEllipse;
    
    image = [self imageWithName:@"ScreenCapture_toolbar_arrow_ineffect" ofType:@"tiff"];
    _arrowButton = [SnipUtil createButton:image withAlternate:nil];
    _arrowButton.tag = ActionShapeArrow;
    
    image = [self imageWithName:@"ScreenCapture_toolbar_text_ineffect" ofType:@"tiff"];
    _textButton = [SnipUtil createButton:image withAlternate:nil];
    _textButton.tag = ActionEditText;
    
    image = [self imageWithName:@"ScreenCapture_toolbar_pen_ineffect" ofType:@"tiff"];
    _penButton = [SnipUtil createButton:image withAlternate:nil];
    _penButton.tag = ActionEditPen;
    
    image = [self imageWithName:@"ScreenCapture_toolbar_mosaic_ineffect" ofType:@"tiff"];
    _mosaicButton = [SnipUtil createButton:image withAlternate:nil];
    _mosaicButton.tag = ActionMosaic;
    
    image = [self imageWithName:@"ScreenCapture_toolbar_splitter" ofType:@"png"];
    _splitButton = [SnipUtil createButton:image withAlternate:nil];
    _splitButton.tag = ActionUnknow;
    
    image = [self imageWithName:@"ScreenCapture_toolbar_cross_normal" ofType:@"tiff"];
    _cancelButton = [SnipUtil createButton:image withAlternate:nil];
    _cancelButton.tag = ActionCancel;
    
    image = [self imageWithName:@"ScreenCapture_toolbar_tick_normal" ofType:@"tiff"];
    _okButton = [SnipUtil createButton:image withAlternate:nil];
    _okButton.tag = ActionOK;
    
    image = [self imageWithName:@"ScreenCapture_toolbar_action_back" ofType:@"png"];
    _backButton = [SnipUtil createButton:image withAlternate:nil];
    _backButton.tag = ActionBack;
    _backButton.enabled = NO;
    
    image = [self imageWithName:@"ScreenCapture_toolbar_action_save" ofType:@"png"];
    _saveButton = [SnipUtil createButton:image withAlternate:nil];
    _saveButton.tag = ActionSave;
    
    _tools = @[_rectButton,_ellipseButton,_arrowButton,_penButton,_mosaicButton,_textButton,_splitButton,_backButton, _saveButton,_cancelButton,_okButton];
    for (SFImageButton *btn in _tools) {
        btn.target = self;
        btn.action = @selector(onToolClick:);
        [self addSubview:btn];
    }
}

-(NSInteger)itemCount{
    return _tools.count;
}

- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    
    NSBezierPath *bgPath = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:3 yRadius:3];
    [bgPath setClip];
    [[NSColor colorWithCalibratedRed:0.400 green:0.400 blue:0.400 alpha:1.00] setFill];
    NSRectFill(self.bounds);
}

- (void)setFrame:(NSRect)frame{
    [super setFrame:frame];
    
    CGFloat margin = ITEM_DEFAULT_MARGIN;
    NSInteger itemY = (frame.size.height - ITEM_DEFAULT_HEIGHT) / 2;
    NSInteger itemX = margin;
    for (SFImageButton *btn in self.tools) {
        CGFloat width = btn.tag == ActionUnknow ? 10 : ITEM_DEFAULT_WIDTH;
        [btn setFrame:NSMakeRect(itemX,itemY, width, ITEM_DEFAULT_HEIGHT)];
        itemX += width + margin ;
    }
}

-(void)setItem:(ActionType)itemType enabled:(BOOL)enabled{
    for (SFImageButton *btn in _tools) {
        if (btn.tag == itemType) {
            btn.enabled = enabled;
            break;
        }
    }
}

- (void)onToolClick:(NSControl *)sender{

    if (sender.tag == ActionUnknow) {
        return;
    }
    
    if (sender.tag == ActionBack) {
        if (self.toolClick) {
            self.toolClick([sender tag]);
        }
        return;
    }

    self.rectButton.image = [self imageWithName:@"ScreenCapture_toolbar_rect_ineffect" ofType:@"tiff"];
    self.ellipseButton.image = [self imageWithName:@"ScreenCapture_toolbar_ellipse_ineffect" ofType:@"tiff"];
    self.arrowButton.image = [self imageWithName:@"ScreenCapture_toolbar_arrow_ineffect" ofType:@"tiff"];
    self.textButton.image = [self imageWithName:@"ScreenCapture_toolbar_text_ineffect" ofType:@"tiff"];
    self.mosaicButton.image = [self imageWithName:@"ScreenCapture_toolbar_mosaic_ineffect" ofType:@"tiff"];
    self.penButton.image = [self imageWithName:@"ScreenCapture_toolbar_pen_ineffect" ofType:@"tiff"];
    
    if (sender == self.rectButton) {
        self.rectButton.image = [self imageWithName:@"ScreenCapture_toolbar_rect_effect" ofType:@"tiff"];
    }
    else if (sender == self.ellipseButton) {
        self.ellipseButton.image = [self imageWithName:@"ScreenCapture_toolbar_ellipse_effect" ofType:@"tiff"];
    }
    else if (sender == self.arrowButton) {
        self.arrowButton.image = [self imageWithName:@"ScreenCapture_toolbar_arrow_effect" ofType:@"tiff"];
    }
    else if (sender == self.textButton) {
        self.textButton.image = [self imageWithName:@"ScreenCapture_toolbar_text_effect" ofType:@"tiff"];
    }
    else if (sender == self.penButton) {
        self.penButton.image = [self imageWithName:@"ScreenCapture_toolbar_pen_effect" ofType:@"tiff"];
    }
    else if (sender == self.mosaicButton) {
        self.mosaicButton.image = [self imageWithName:@"ScreenCapture_toolbar_mosaic_effect" ofType:@"tiff"];
    }
    if (self.toolClick) {
        self.toolClick([sender tag]);
    }
}


@end
