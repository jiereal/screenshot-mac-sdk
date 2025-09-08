#pragma once
using namespace node_util;

class CScreenshotEventHandler : public node_util::EventHandler
{
private:
	/* data */
public:
	CScreenshotEventHandler()
	{
	};
	~CScreenshotEventHandler()
	{
	};
	SINGLETON_DEFINE(CScreenshotEventHandler);

	static void OnSnipFinishCallback(int ret);

private:
	void Node_OnSnipFinishCallback(const node_util::BaseCallbackPtr& bcb, int ret);

public:
	static node_util::BaseCallbackPtr _snip_finish_bcb;
};
