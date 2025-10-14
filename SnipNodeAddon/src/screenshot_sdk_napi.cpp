#include "pch.h"
#include "screenshot_event_handler_napi.h"
#include "version.h"
#include "napi_helper.h"
#include <napi.h>
#include <chrono>
#include <thread>
#include <iostream>


// 外部函数声明（来自 SnipManager.framework）- 修复符号名
extern "C"
{
    void startSnipping(const char *image_path, int path_length, void (*callback)(int));
    void stopSnipping();
    bool isInSnipping();
}

namespace ScreenshotSdk
{

    Napi::Value InitCapture(const Napi::CallbackInfo &info)
    {
        Napi::Env env = info.Env();
        

        // 记录参数信息
        printf("[NAPI] InitCapture: Called with %zu parameters\n", info.Length());
        for (size_t i = 0; i < info.Length(); ++i)
        {
            Napi::Value val = info[i];
            std::string type = val.IsString() ? "string" : val.IsNumber() ? "number"
                                                       : val.IsBoolean()  ? "boolean"
                                                       : val.IsFunction() ? "function"
                                                                          : "other";
            
        }

        printf("[NAPI] InitCapture: Initializing screenshot capture system...\n");
        
        return env.Undefined();
    }

    Napi::Value CleanupCapture(const Napi::CallbackInfo &info)
    {
        Napi::Env env = info.Env();
        

        printf("[NAPI] CleanupCapture: Cleaning up screenshot capture system...\n");
        printf("[NAPI] CleanupCapture: Calling stopSnipping()...\n");

        try
        {
            stopSnipping();
            printf("[NAPI] CleanupCapture: stopSnipping() completed successfully\n");
        }
        catch (const std::exception &e)
        {
            printf("[NAPI] CleanupCapture: Error in stopSnipping: %s\n", e.what());
        }

        
        return env.Undefined();
    }

    Napi::Value StartCapture(const Napi::CallbackInfo &info)
    {

        std::cout << "123" << std::endl;
        Napi::Env env = info.Env();
        
        // 参数验证和记录
        fprintf(stderr, "[NAPI] StartCapture: Called with %zu parameters\n", info.Length());


       
        NAPI_CHECK_ARGS_COUNT(info, 2);

        // 记录第一个参数（路径）
        std::string image_path;
        NAPI_GET_ARGS_VALUE_STRING(info, 0, image_path);
        

        // 验证和记录第二个参数（回调）
        if (!info[1].IsFunction())
        {
            
            Napi::TypeError::New(env, "第二个参数必须是函数")
                .ThrowAsJavaScriptException();
            return env.Undefined();
        }

        Napi::Function callback = info[1].As<Napi::Function>();
        fprintf(stderr, "[NAPI] StartCapture: Callback provided\n");


        // 清理之前的回调资源
        if (CScreenshotEventHandler::_snip_finish_bcb)
        {
            fprintf(stderr, "[NAPI] StartCapture: Cleaning up previous callback...\n");
            CScreenshotEventHandler::_snip_finish_bcb->callback.Reset();
            CScreenshotEventHandler::_snip_finish_bcb->data.Reset();
        }

        // 创建新的回调
        CScreenshotEventHandler::_snip_finish_bcb = std::make_shared<napi_util::BaseCallback>();
        CScreenshotEventHandler::_snip_finish_bcb->callback = Napi::Persistent(callback);
        CScreenshotEventHandler::_snip_finish_bcb->data = Napi::Persistent(info.This().As<Napi::Object>());

        fprintf(stderr, "[NAPI] StartCapture: Starting capture with path: %s (length: %zu)\n",
                image_path.c_str(), image_path.length());

        // 调用底层函数 - 添加错误处理
        try
        {
            fprintf(stderr, "[NAPI] StartCapture: Calling startSnipping()...\n");
            startSnipping(image_path.c_str(), (int)image_path.length(), CScreenshotEventHandler::OnSnipFinishCallback);
            fprintf(stderr, "[NAPI] StartCapture: startSnipping() completed successfully\n");
        }
        catch (const std::exception &e)
        {
            fprintf(stderr, "[NAPI] StartCapture: Error in startSnipping: %s\n", e.what());
        }

        return env.Undefined();
    }

    Napi::Value IsCaptureTracking(const Napi::CallbackInfo &info)
    {
        Napi::Env env = info.Env();
        

        printf("[NAPI] IsCaptureTracking: Checking capture status...\n");

        // 调用底层状态检查 - 添加错误处理
        bool ret = false;
        try
        {
            printf("[NAPI] IsCaptureTracking: Calling isInSnipping()...\n");
            ret = isInSnipping();
            printf("[NAPI] IsCaptureTracking: isInSnipping() returned: %s\n", ret ? "true" : "false");
        }
        catch (const std::exception &e)
        {
            printf("[NAPI] IsCaptureTracking: Error in isInSnipping: %s\n", e.what());
            printf("[NAPI] IsCaptureTracking: Returning false due to error\n");
        }

        printf("[NAPI] IsCaptureTracking: Final capture status = %s\n", ret ? "true" : "false");
        
        return Napi::Boolean::New(env, ret);
    }

    Napi::Value Version(const Napi::CallbackInfo &info)
    {
        Napi::Env env = info.Env();
        

        printf("[NAPI] Version: Retrieving module version...\n");

        const char *version = MODULE_VERSION;
        printf("[NAPI] Version: Module version = %s\n", version);

        
        return Napi::String::New(env, version);
    }

    // NAPI 模块初始化
    Napi::Object Init(Napi::Env env, Napi::Object exports)
    {
        

        printf("[NAPI] Init: Initializing module exports...\n");
        printf("[NAPI] Init: Registering functions:\n");

        const char *functions[] = {"initCapture", "cleanupCapture", "startCapture", "isCaptureTracking", "version"};
        for (const char *func : functions)
        {
            printf("[NAPI] Init: - %s\n", func);
        }

        exports.Set("initCapture", Napi::Function::New(env, InitCapture));
        exports.Set("cleanupCapture", Napi::Function::New(env, CleanupCapture));
        exports.Set("startCapture", Napi::Function::New(env, StartCapture));
        exports.Set("isCaptureTracking", Napi::Function::New(env, IsCaptureTracking));
        exports.Set("version", Napi::Function::New(env, Version));

        printf("[NAPI] Init: All functions registered successfully\n");
        
        return exports;
    }

}

// NAPI 模块初始化函数（必须在命名空间外部）
Napi::Object InitModule(Napi::Env env, Napi::Object exports)
{
    
    printf("[NAPI] InitModule: Module initialization started...\n");

    auto result = ScreenshotSdk::Init(env, exports);

    printf("[NAPI] InitModule: Module initialization completed\n");
    
    return result;
}

// NAPI 模块注册
NODE_API_MODULE(screenshot_sdk, InitModule)