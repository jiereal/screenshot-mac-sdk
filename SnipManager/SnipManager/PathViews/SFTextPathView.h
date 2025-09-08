//
//  SFTextPathView.h
//  Snip
//
//  Created by 吴晓明 on 2019/2/20.
//  Copyright © 2019 顺丰科技. All rights reserved.
//

#import "SFBasePathView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SFTextPathView : SFBasePathView

@property(nonatomic,strong)NSFont *font;
@property(nonatomic,strong)NSColor *textColor;
@property(nonatomic,strong)NSString *string;


@end

NS_ASSUME_NONNULL_END
