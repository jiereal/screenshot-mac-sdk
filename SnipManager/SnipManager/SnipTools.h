//
//  SnipTools.h
//  SnipManager
//
//  Created by CHENZUOHUA on 2020/12/29.
//  Copyright © 2020 吴晓明. All rights reserved.
//

#ifndef __SNIP_TOOL_H__
#define __SNIP_TOOL_H__


#ifdef __cplusplus
extern"C"
{
#endif

/*
* 截图完成的回调(0失败，1截图，2另存为)
*/
typedef void(*snipFinishCallBack)(int success);

bool isInSnipping();

void startSnipping(const char *savePath,int length, snipFinishCallBack callBack);

void stopSnipping();




#ifdef __cplusplus
};
#endif //__cplusplus

#endif // __SNIP_TOOL_H__
