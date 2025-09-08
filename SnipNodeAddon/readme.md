# 项目介绍报告

## 1. 业务目标

本项目是一个为 macOS 平台开发的 Node.js 原生插件，旨在提供系统级的屏幕截图功能。它允许开发者在 Node.js 或 Electron 应用中集成专业的截图工具，支持用户进行屏幕区域选择、标注和保存等操作。

## 2. 核心功能

- **屏幕截图**：启动并控制 macOS 系统的截图功能
- **截图回调**：提供截图完成后的回调处理机制
- **截图状态管理**：检测和控制截图状态（如是否正在进行截图）
- **跨平台集成**：作为 Node.js 插件，方便集成到 Electron 等跨平台应用中

## 3. 整体架构

### 3.1 技术架构

项目采用 Node.js 原生插件架构，使用 C++ 编写核心功能，并通过 Node.js 的 N-API 接口暴露给 JavaScript 环境。

主要组件包括：
1. **Node.js 插件层** (`src/screenshot_sdk.cpp`)：实现 Node.js 与原生代码的桥接
2. **事件处理层** (`src/screenshot_event_handler.cpp`)：处理异步回调和事件循环
3. **原生功能层** (`SnipManager.framework`)：提供 macOS 平台的截图实现
4. **工具层** (`src/node_*`)：提供 Node.js 异步调用和事件处理的辅助工具

### 3.2 依赖关系

- **Node.js 原生插件框架**：使用 node-gyp 构建系统
- **macOS 原生框架**：依赖 SnipManager.framework 提供截图功能
- **Electron 支持**：可通过 @electron/rebuild 进行 Electron 版本适配

## 4. 数据实体

### 4.1 主要数据结构

1. **截图回调函数** (`snipFinishCallBack`)：截图完成后的回调接口
2. **截图配置** (`SFSnipConfig`)：截图功能的配置参数
3. **截图管理器** (`SnipManager`)：管理截图状态和操作的核心对象

### 4.2 数据流向

```
JavaScript 调用 -> Node.js 插件 -> SnipManager.framework -> macOS 系统截图 -> 回调处理 -> JavaScript 回调
```

## 5. 业务流程

### 5.1 初始化流程

1. JavaScript 层调用 `initCapture()` 初始化截图环境
2. 插件层准备必要的资源和回调机制

### 5.2 截图启动流程

1. JavaScript 调用 `startCapture(imagePath, callback)`
2. 插件层接收参数并设置回调函数
3. 调用 `startSnipping()` 启动 SnipManager 的截图功能
4. macOS 系统显示截图选择界面供用户操作

### 5.3 截图完成流程

1. 用户完成截图操作或取消截图
2. SnipManager 调用 C++ 层注册的回调函数
3. C++ 层通过 Node.js 异步机制将结果传递给 JavaScript 回调
4. JavaScript 层处理截图结果（保存图片或执行其他操作）

### 5.4 清理流程

1. JavaScript 调用 `cleanupCapture()` 清理截图资源
2. 插件层调用 `stopSnipping()` 停止截图功能