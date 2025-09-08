//
//  SnipTools.m
//  SnipManager
//
//  Created by CHENZUOHUA on 2020/12/29.
//  Copyright © 2020 吴晓明. All rights reserved.
//

#import "SnipTools.h"
#import "SnipManager.h"
// 截图回调包装
class CSnipCallback
{
public:
    CSnipCallback(void) : m_fnFinishCallback(0)
    {

    }

    ~CSnipCallback()
    {

    }

    void SetFinishCallback(snipFinishCallBack fnFinishCallback)
    {
        m_fnFinishCallback = fnFinishCallback;
    }

    void HandleFinishCallback(bool success)
    {
        if (0 != m_fnFinishCallback)
        {
            m_fnFinishCallback(success);
        }
    }

private:
    snipFinishCallBack m_fnFinishCallback;
};

// 单例
static CSnipCallback g_snipCallback;

void startSnipping(const char *savePath,int length, snipFinishCallBack callBack)
{
//    g_snipCallback.SetFinishCallback(callBack);
    NSLog(@"jiereal22 startSnipping");
    // 处理截图，传回image、sucess数据
    NSString *path = [[NSString alloc] initWithUTF8String:savePath];
    [[SnipManager sharedInstance] startCaptureSavePath:path callBack:^(NSImage *image, BOOL needSave, BOOL success) {
        // (0失败，1截图，2另存为)
        if (success == NO) {
            callBack(0);
        }else if (needSave) {
            callBack(2);
        }else {
            callBack(1);
        }
    }];
    
}

bool isInSnipping() {
    return [SnipManager sharedInstance].isWorking;
}

void stopSnipping() {
    [[SnipManager sharedInstance] cancelCapture];
}
    

