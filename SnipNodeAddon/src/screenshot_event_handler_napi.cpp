#include "pch.h"
#include "screenshot_event_handler_napi.h"
#include "napi_helper.h"
#include <napi.h>
#include <functional>

// 异步回调队列
#include "node_async_queue.h"

// 全局 napi 回调指针
napi_util::BaseCallbackPtr CScreenshotEventHandler::_snip_finish_bcb = nullptr;

void CScreenshotEventHandler::OnSnipFinishCallback(int ret)
{
    // 仅当回调已注册时才推送异步任务
    if (!_snip_finish_bcb) {
        return;
    }
    node_util::node_async_call::async_call([=]() {
        CScreenshotEventHandler::GetInstance()->Node_OnSnipFinishCallback(_snip_finish_bcb, ret);
    });
}

void CScreenshotEventHandler::Node_OnSnipFinishCallback(const napi_util::BaseCallbackPtr& bcb, int ret)
{
    if (!bcb || bcb->callback.IsEmpty()) {
        return;
    }
    
    try {
        // 在正确的上下文中调用 JavaScript 回调
        Napi::Env env = bcb->callback.Env();
        Napi::HandleScope scope(env);
        
        // 准备回调参数
        std::vector<napi_value> args = {
            Napi::Number::New(env, ret)
        };
        
        // 调用 JavaScript 回调函数
        bcb->callback.Call(args);
    }
    catch (const std::exception& e) {
        // 处理异常，避免崩溃
        fprintf(stderr, "Error in Node_OnSnipFinishCallback: %s\n", e.what());
    }
}

// NAPI 版本的辅助函数
namespace napi_util {

// 线程安全的异步回调执行
void ExecuteCallbackInMainThread(std::function<void()> callback)
{
    node_util::node_async_call::async_call([callback]() {
        callback();
    });
}

} // namespace napi_util