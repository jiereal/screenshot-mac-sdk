# 旧版 Nan 实现代码

此目录包含从 nan 迁移到 NAPI 之前的原始实现文件。

## 文件说明

- `screenshot_sdk.nan.cpp` - 原始的 nan 版本截图 SDK 实现
- `screenshot_event_handler.nan.h/cpp` - 原始的 nan 版本事件处理器

## 迁移状态

✅ 已成功迁移到 NAPI：
- 新位置: `../screenshot_sdk_napi.cpp`
- 新位置: `../screenshot_event_handler_napi.h/cpp`

## 保留原因

这些文件作为历史参考保留，用于：
1. 代码审查和对比
2. 回滚需要（如果需要）
3. 学习参考

## 注意

这些文件不再参与构建过程，仅作为历史文档保存。