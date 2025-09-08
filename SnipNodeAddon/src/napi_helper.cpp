#include "napi_helper.h"
#include <string>

namespace napi_util
{

std::string GetStringFromValue(const Napi::Value& value)
{
    if (!value.IsString())
    {
        return "";
    }
    return value.As<Napi::String>().Utf8Value();
}

Napi::String CreateStringValue(Napi::Env env, const std::string& str)
{
    return Napi::String::New(env, str);
}

bool GetBoolFromValue(const Napi::Value& value)
{
    if (!value.IsBoolean())
    {
        return false;
    }
    return value.As<Napi::Boolean>().Value();
}

Napi::Boolean CreateBoolValue(Napi::Env env, bool value)
{
    return Napi::Boolean::New(env, value);
}

int32_t GetInt32FromValue(const Napi::Value& value)
{
    if (!value.IsNumber())
    {
        return 0;
    }
    return value.As<Napi::Number>().Int32Value();
}

Napi::Number CreateInt32Value(Napi::Env env, int32_t value)
{
    return Napi::Number::New(env, value);
}

Napi::Value GetObjectProperty(const Napi::Object& obj, const std::string& key)
{
    return obj.Get(key);
}

void SetObjectProperty(Napi::Object& obj, const std::string& key, const Napi::Value& value)
{
    obj.Set(key, value);
}

Napi::Array CreateStringArray(Napi::Env env, const std::list<std::string>& strings)
{
    Napi::Array array = Napi::Array::New(env, strings.size());
    uint32_t index = 0;
    for (const auto& str : strings)
    {
        array[index++] = Napi::String::New(env, str);
    }
    return array;
}

} // namespace napi_util