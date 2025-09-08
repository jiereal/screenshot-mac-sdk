#include "node_event_handler.h"

namespace node_util
{
void EventHandler::AddEventHandler(const utf8_string &eventName, Persistent<Object> &obj, Persistent<Function> &callback)
{
    BaseCallbackPtr cb = BaseCallbackPtr(new BaseCallback());
    cb->callback_.Reset(Isolate::GetCurrent(), callback);
    cb->data_.Reset(Isolate::GetCurrent(), obj);

	if (callbacks_.end() == callbacks_.find(eventName))
	{
		callbacks_.emplace(eventName, cb);
	}
	else
	{
		callbacks_[eventName] = cb;
	}
}
}