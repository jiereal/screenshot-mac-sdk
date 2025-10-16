#ifndef NODE_SDK_NAPI_HELPER_H
#define NODE_SDK_NAPI_HELPER_H

#include <napi.h>
#include <string>
#include <list>
#include <map>
#include <memory>

namespace napi_util
{

struct BaseCallback
{
    Napi::FunctionReference callback;
    Napi::ObjectReference data;
};

typedef std::shared_ptr<BaseCallback> BaseCallbackPtr;

// 饿汉模式单例宏
#define SINGLETON_DEFINE(TypeName)              \
static TypeName* GetInstance()                  \
{                                               \
    static TypeName type_instance;              \
    return &type_instance;                      \
}                                               \
                                                \
TypeName(const TypeName&) = delete;             \
TypeName& operator=(const TypeName&) = delete

// NAPI 宏定义
#define NAPI_METHOD(method) \
    static Napi::Value method(const Napi::CallbackInfo& info)

#define NAPI_METHOD_DEF(cls, method) \
    Napi::Value cls::method(const Napi::CallbackInfo& info)

#define NAPI_CHECK_ARGS_COUNT(info, expectedCount)                              \
    do                                                                     \
    {                                                                      \
        if (info.Length() != expectedCount)                                \
        {                                                                  \
            Napi::TypeError::New(info.Env(), "参数数量错误")              \
                .ThrowAsJavaScriptException();                             \
            return info.Env().Undefined();                                \
        }                                                                  \
    } while (0)

#define NAPI_GET_ARGS_VALUE_STRING(info, index, v)                              \
    do                                                                     \
    {                                                                      \
        if (!info[index].IsString())                                       \
        {                                                                  \
            Napi::TypeError::New(info.Env(), "参数类型错误，应为字符串")  \
                .ThrowAsJavaScriptException();                             \
            return info.Env().Undefined();                                \
        }                                                                  \
        v = info[index].As<Napi::String>().Utf8Value();                   \
    } while (0)

#define NAPI_GET_ARGS_VALUE_BOOL(info, index, v)                                \
    do                                                                     \
    {                                                                      \
        if (!info[index].IsBoolean())                                      \
        {                                                                  \
            Napi::TypeError::New(info.Env(), "参数类型错误，应为布尔值")   \
                .ThrowAsJavaScriptException();                            \
            return info.Env().Undefined();                                \
        }                                                                  \
        v = info[index].As<Napi::Boolean>().Value();                       \
    } while (0)

#define NAPI_GET_ARGS_VALUE_NUMBER(info, index, v)                              \
    do                                                                     \
    {                                                                      \
        if (!info[index].IsNumber())                                       \
        {                                                                  \
            Napi::TypeError::New(info.Env(), "参数类型错误，应为数字")     \
                .ThrowAsJavaScriptException();                            \
            return info.Env().Undefined();                                \
        }                                                                  \
        v = info[index].As<Napi::Number>().Int32Value();                   \
    } while (0)

#define NAPI_ASSEMBLE_BASE_CALLBACK(info, index)                                \
    do                                                                     \
    {                                                                      \
        if (!info[index].IsFunction())                                     \
        {                                                                  \
            Napi::TypeError::New(info.Env(), "参数类型错误，应为函数")     \
                .ThrowAsJavaScriptException();                            \
            return info.Env().Undefined();                                \
        }                                                                  \
    } while (0);                                                           \
    Napi::Function cb = info[index].As<Napi::Function>();                  \
    BaseCallbackPtr bcb = std::make_shared<BaseCallback>();                \
    bcb->callback = Napi::Persistent(cb);                                  \
    bcb->data = Napi::Persistent(info.This().As<Napi::Object>());

// 字符串处理辅助函数
std::string GetStringFromValue(const Napi::Value& value);
Napi::String CreateStringValue(Napi::Env env, const std::string& str);
bool GetBoolFromValue(const Napi::Value& value);
Napi::Boolean CreateBoolValue(Napi::Env env, bool value);
int32_t GetInt32FromValue(const Napi::Value& value);
Napi::Number CreateInt32Value(Napi::Env env, int32_t value);

// 对象操作辅助函数
Napi::Value GetObjectProperty(const Napi::Object& obj, const std::string& key);
void SetObjectProperty(Napi::Object& obj, const std::string& key, const Napi::Value& value);

// 数组操作辅助函数
Napi::Array CreateStringArray(Napi::Env env, const std::list<std::string>& strings);

} // namespace napi_util

#endif // NODE_SDK_NAPI_HELPER_H