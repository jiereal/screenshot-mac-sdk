#include "pch.h"
#include "screenshot_event_handler_napi.h"
#include "version.h"
#include "napi_helper.h"
#include <napi.h>

// 外部函数声明（来自 SnipManager.framework）
extern "C" {
    void startSnipping(const char* image_path, int path_length, void (*callback)(int));
    void stopSnipping();
    bool isInSnipping();
}

NAMESPACE_SCREENSHOTSDK_BEGIN
Napi::Value InitCapture(const Napi::CallbackInfo& info)
{
    Napi::Env env = info.Env();
    printf("jiereal InitCapture (NAPI)\n");
    
    // 这里可以添加初始化逻辑
    // NAPI_CHECK_ARGS_COUNT(info, 2); // 如果需要参数检查
    
    // 示例：获取字符串参数
    // std::string resource_path = napi_util::GetStringFromValue(info[0]);
    // std::string lang_path = napi_util::GetStringFromValue(info[1]);
    
    return env.Undefined();
}

Napi::Value CleanupCapture(const Napi::CallbackInfo& info)
{
    Napi::Env env = info.Env();
    stopSnipping();
    return env.Undefined();
}

Napi::Value StartCapture(const Napi::CallbackInfo& info)
{
    Napi::Env env = info.Env();
    NAPI_CHECK_ARGS_COUNT(info, 2);
    
    printf("jiereal StartCapture (NAPI)\n");
    
    // 获取图片路径参数
    std::string image_path;
    NAPI_GET_ARGS_VALUE_STRING(info, 0, image_path);
    
    // 获取回调函数
    if (!info[1].IsFunction()) {
        Napi::TypeError::New(env, "第二个参数必须是函数")
            .ThrowAsJavaScriptException();
        return env.Undefined();
    }
    
    Napi::Function callback = info[1].As<Napi::Function>();
    
    // 保存回调引用到全局变量
    CScreenshotEventHandler::_snip_finish_bcb = std::make_shared<napi_util::BaseCallback>();
    CScreenshotEventHandler::_snip_finish_bcb->callback = Napi::Persistent(callback);
    CScreenshotEventHandler::_snip_finish_bcb->data = Napi::Persistent(info.This().As<Napi::Object>());
    
    printf("jiereal startSnipping (NAPI)\n");
    startSnipping(image_path.c_str(), image_path.length(), CScreenshotEventHandler::OnSnipFinishCallback);
    
    return env.Undefined();
}

Napi::Value IsCaptureTracking(const Napi::CallbackInfo& info)
{
    Napi::Env env = info.Env();
    NAPI_CHECK_ARGS_COUNT(info, 0);
    
    bool ret = isInSnipping();
    return Napi::Boolean::New(env, ret);
}

Napi::Value Version(const Napi::CallbackInfo& info)
{
    Napi::Env env = info.Env();
    return Napi::String::New(env, MODULE_VERSION);
}

// NAPI 模块初始化
Napi::Object Init(Napi::Env env, Napi::Object exports)
{
    exports.Set("initCapture", Napi::Function::New(env, InitCapture));
    exports.Set("cleanupCapture", Napi::Function::New(env, CleanupCapture));
    exports.Set("startCapture", Napi::Function::New(env, StartCapture));
    exports.Set("isCaptureTracking", Napi::Function::New(env, IsCaptureTracking));
    exports.Set("version", Napi::Function::New(env, Version));
    
    return exports;
}

NAMESPACE_SCREENSHOTSDK_END

// NAPI 模块初始化函数（必须在命名空间外部）
Napi::Object InitModule(Napi::Env env, Napi::Object exports)
{
    return ScreenshotSdk::Init(env, exports);
}

// NAPI 模块注册
NODE_API_MODULE(screenshot_sdk, InitModule)