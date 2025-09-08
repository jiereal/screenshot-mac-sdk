#ifndef NODE_EVENTHANDLER_H
#define NODE_EVENTHANDLER_H

#include <node.h>
#include <unordered_map>
#include "node_helper.h"

using v8::Persistent;
using v8::Object;
using v8::Function;
namespace node_util
{
class EventHandler
{
private:
    /* data */
public:
    EventHandler(/* args */){};
    ~EventHandler(){};

    void AddEventHandler(const utf8_string &eventName, Persistent<Object> &obj, Persistent<Function> &callback);

protected:
    std::unordered_map<utf8_string, BaseCallbackPtr> callbacks_;
};
}
#endif // NODE_EVENTHANDLER_H