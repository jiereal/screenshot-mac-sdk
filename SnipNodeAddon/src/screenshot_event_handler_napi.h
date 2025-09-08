#pragma once
#include "napi_helper.h"

class CScreenshotEventHandler
{
private:
    /* data */
public:
    CScreenshotEventHandler() {};
    ~CScreenshotEventHandler() {};
    
    // 饿汉模式单例
    static CScreenshotEventHandler* GetInstance()
    {
        static CScreenshotEventHandler instance;
        return &instance;
    }
    
    CScreenshotEventHandler(const CScreenshotEventHandler&) = delete;
    CScreenshotEventHandler& operator=(const CScreenshotEventHandler&) = delete;

    static void OnSnipFinishCallback(int ret);

private:
    void Node_OnSnipFinishCallback(const napi_util::BaseCallbackPtr& bcb, int ret);

public:
    static napi_util::BaseCallbackPtr _snip_finish_bcb;
};
