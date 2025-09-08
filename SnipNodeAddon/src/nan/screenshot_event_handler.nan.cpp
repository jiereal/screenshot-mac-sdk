#include "pch.h"

#include "screenshot_event_handler.h"

node_util::BaseCallbackPtr CScreenshotEventHandler::_snip_finish_bcb;

void CScreenshotEventHandler::OnSnipFinishCallback(int ret)
{
	node_util::node_async_call::async_call([=]() {
		CScreenshotEventHandler::GetInstance()->Node_OnSnipFinishCallback(_snip_finish_bcb, ret);
	});
}

void CScreenshotEventHandler::Node_OnSnipFinishCallback(const node_util::BaseCallbackPtr& bcb, int ret)
{
	Isolate *isolate = Isolate::GetCurrent();
	HandleScope scope(isolate);
	const unsigned argc = 1;
	Local<Value> argv[argc] = { node_util::nim_napi_new_int32(isolate, ret) };
	bcb->callback_.Get(isolate)->Call(isolate->GetCurrentContext(), bcb->data_.Get(isolate), argc, argv);
}
