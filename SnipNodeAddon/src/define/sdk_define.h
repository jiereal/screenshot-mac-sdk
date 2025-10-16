#pragma once

#ifndef IN
#define IN
#endif

#ifndef OUT
#define OUT
#endif


#define DISALLOW_COPY_AND_ASSIGN(TypeName) \
	TypeName(const TypeName&); \
	void operator=(const TypeName&)
