/*
* Copyright (c) 2017 Agora.io
* All rights reserved.
* Proprietry and Confidential -- Agora.io
*/

/*
*  Created by Wang Yongli, 2017
*/

#include "node_async_queue.h"
#include <uv.h>
#include <functional>

namespace node_util
{

node_async_call node_async_call::s_instance_;

node_async_call::node_async_call()
{
    node_queue_.reset(new async_queue<task_type>(uv_default_loop(), std::bind(&node_async_call::run_task, this, std::placeholders::_1)));
    printf("node_async_queue 23");
}

node_async_call::~node_async_call()
{
}

} // namespace nim_node
