#include "pch.h"
#include "screenshot_event_handler.h"
#include "version.h"  // 包含生成的头文件

// 基于nodejs 12.x； NODE_MODULE_VERSION = 80
// 参考文档 https://nodejs.org/dist/latest-v12.x/docs/api/addons.html

NAMESPACE_SCREENSHOTSDK_BEGIN

void InitCapture(const FunctionCallbackInfo<Value>& args)
{
    printf("jiereal InitCapture");
	/*
	CHECK_ARGS_COUNT(2);

	auto status = napi_ok;
	node_util::UTF8String resource_path;
	GET_ARGS_VALUE(isolate, 0, UTF8String, resource_path);

	node_util::UTF8String lang_path;
	GET_ARGS_VALUE(isolate, 1, UTF8String, lang_path);
	*/
}

void CleanupCapture(const FunctionCallbackInfo<Value>& args)
{
	stopSnipping();
}

void StartCapture(const FunctionCallbackInfo<Value>& args)
{
	CHECK_ARGS_COUNT(2);

    printf("jiereal StartCapture");
	auto status = napi_ok;
	node_util::UTF8String image_path;
	GET_ARGS_VALUE(isolate, 0, UTF8String, image_path);

	String::Utf8Value image_path_utf8(isolate, Local<String>::Cast(args[0]));

	Local<Function> cb = args[1].As<Function>();
	if (cb.IsEmpty())
		return;

	Persistent<Function> pcb;
	pcb.Reset(isolate, cb);
	Local<Object> obj = args.This();
	Persistent<Object> pdata;
	pdata.Reset(isolate, obj);
	CScreenshotEventHandler::_snip_finish_bcb = node_util::BaseCallbackPtr(new node_util::BaseCallback());
	CScreenshotEventHandler::_snip_finish_bcb->callback_.Reset(isolate, pcb);
	CScreenshotEventHandler::_snip_finish_bcb->data_.Reset(isolate, pdata);
    printf("jiereal startSnipping");
	// startSnipping(image_path.get(), image_path.length(), CScreenshotEventHandler::OnSnipFinishCallback);
	startSnipping(*image_path_utf8, image_path_utf8.length(), CScreenshotEventHandler::OnSnipFinishCallback);
}

void IsCaptureTracking(const FunctionCallbackInfo<Value>& args)
{
	CHECK_ARGS_COUNT(0);

	bool ret = isInSnipping();
	args.GetReturnValue().Set(Boolean::New(isolate, ret));
}


static void Version(const FunctionCallbackInfo<Value>& args) {
  Isolate* isolate = args.GetIsolate();
  
  // 返回静态版本号字符串
  args.GetReturnValue().Set(
    String::NewFromUtf8(isolate, MODULE_VERSION).ToLocalChecked());
}

NAMESPACE_SCREENSHOTSDK_END

void init(Local<Object> exports)
{
	NODE_SET_METHOD(exports, "initCapture", ScreenshotSdk::InitCapture);
	NODE_SET_METHOD(exports, "cleanupCapture", ScreenshotSdk::CleanupCapture);
	NODE_SET_METHOD(exports, "startCapture", ScreenshotSdk::StartCapture);
	NODE_SET_METHOD(exports, "isCaptureTracking", ScreenshotSdk::IsCaptureTracking);
	NODE_SET_METHOD(exports, "version", ScreenshotSdk::Version);
}

// NODE_MODULE(screenshot_sdk, init)

// 以下是创建上下文感知插件
extern "C" NODE_MODULE_EXPORT void
NODE_MODULE_INITIALIZER(Local<Object> exports,
    Local<Value> module,
    Local<Context> context) {
    /* Perform addon initialization steps here. */
    init(exports);
}

NODE_MODULE_CONTEXT_AWARE(NODE_GYP_MODULE_NAME, NODE_MODULE_INITIALIZER)
