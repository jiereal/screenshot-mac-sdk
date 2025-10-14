const { contextBridge, ipcRenderer } = require('electron');
const path = require('path')
// 暴露安全的 API 给渲染进程
contextBridge.exposeInMainWorld('electronAPI', {
    // 基础功能
    getVersion: () => ipcRenderer.invoke('get-version'),
    getStatus: () => ipcRenderer.invoke('get-status'),
    initCapture: () => ipcRenderer.invoke('init-capture'),
    startCapture: (savePath) => ipcRenderer.invoke('start-capture', savePath),
    cleanupCapture: () => ipcRenderer.invoke('cleanup-capture'),
    
    // 测试套件
    runFullTest: () => ipcRenderer.invoke('run-full-test'),
    runChineseTest: () => ipcRenderer.invoke('run-chinese-test'),
    runLoopTest: () => ipcRenderer.invoke('run-loop-test'),
    pathJoin: (...args) => {
        return path.join(__dirname, ...args)
    }
});