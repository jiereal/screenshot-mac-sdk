#pragma once

#ifndef IN
#define IN
#endif

#ifndef OUT
#define OUT
#endif

#define NAMESPACE_SCREENSHOTSDK_BEGIN	namespace ScreenshotSdk{
#define NAMESPACE_SCREENSHOTSDK_END	} // namespace ScreenshotSdk

#define DISALLOW_COPY_AND_ASSIGN(TypeName) \
	TypeName(const TypeName&); \
	void operator=(const TypeName&)
