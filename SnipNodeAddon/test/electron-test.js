const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const screenshot = require('../lib/index.js');

class ElectronScreenshotTester {
    constructor() {
        this.mainWindow = null;
        this.testResults = [];
    }

    async createWindow() {
        this.mainWindow = new BrowserWindow({
            width: 1000,
            height: 700,
            webPreferences: {
                webSecurity: false,
                nodeIntegration: true,
                contextIsolation: true,
                preload: path.join(__dirname, 'preload.js')
            }
        });

        await this.mainWindow.loadFile('electron-renderer.html');
        this.mainWindow.webContents.openDevTools();
    }

    // IPC 处理函数
    setupIPC() {
        // 基础测试
        ipcMain.handle('get-version', () => {
            try {
                return { success: true, data: screenshot.version() };
            } catch (error) {
                return { success: false, error: error.message };
            }
        });

        ipcMain.handle('get-status', () => {
            try {
                return { success: true, data: screenshot.isCaptureTracking() };
            } catch (error) {
                return { success: false, error: error.message };
            }
        });

        // 初始化截图
        ipcMain.handle('init-capture', () => {
            try {
                screenshot.initCapture();
                return { success: true, message: '截图初始化成功' };
            } catch (error) {
                return { success: false, error: error.message };
            }
        });

        // 开始截图
        ipcMain.handle('start-capture', async (event, savePath) => {
            try {
                const result = await new Promise((resolve) => {
                    screenshot.startCapture(savePath, (ret) => {
                        resolve(ret);
                    });
                });
                return { success: true, data: result };
            } catch (error) {
                return { success: false, error: error.message };
            }
        });

        // 清理截图
        ipcMain.handle('cleanup-capture', () => {
            try {
                screenshot.cleanupCapture();
                return { success: true, message: '截图清理成功' };
            } catch (error) {
                return { success: false, error: error.message };
            }
        });

        // 运行完整测试流程
        ipcMain.handle('run-full-test', async () => {
            return await this.runFullTest();
        });

        // 运行中文路径测试
        ipcMain.handle('run-chinese-test', async () => {
            return await this.runChinesePathTest();
        });

        // 运行循环测试
        ipcMain.handle('run-loop-test', async () => {
            return await this.runLoopTest();
        });
    }

    // 完整测试流程
    async runFullTest() {
        const results = [];

        try {
            // 1. 版本检查
            const version = screenshot.version();
            results.push({ step: '版本检查', status: 'success', result: version });

            // 2. 状态检查
            const status = screenshot.isCaptureTracking();
            results.push({ step: '状态检查', status: 'success', result: status });

            // 3. 初始化
            screenshot.initCapture();
            results.push({ step: '初始化', status: 'success', message: '成功' });

            // 4. 截图
            const savePath = path.join(__dirname, 'test-output', 'full-test.png');
            const captureResult = await new Promise((resolve) => {
                screenshot.startCapture(savePath, (ret) => {
                    resolve(ret);
                });
            });
            results.push({ step: '截图', status: 'success', result: captureResult, path: savePath });

            // 5. 清理
            screenshot.cleanupCapture();
            results.push({ step: '清理', status: 'success', message: '完成' });

            return { success: true, results };
        } catch (error) {
            results.push({ step: '测试流程', status: 'error', message: error.message });
            return { success: false, results };
        }
    }

    // 中文路径测试
    async runChinesePathTest() {
        const results = [];
        const chinesePaths = [
            path.join(__dirname, 'test-output', '中文测试1.png'),
            path.join(__dirname, 'test-output', '用户_2023年_截图.png'),
            path.join(__dirname, 'test-output', '测试_特殊字符.png')
        ];

        for (let i = 0; i < chinesePaths.length; i++) {
            try {
                screenshot.initCapture();

                const captureResult = await new Promise((resolve) => {
                    screenshot.startCapture(chinesePaths[i], (ret) => {
                        resolve(ret);
                    });
                });

                screenshot.cleanupCapture();

                results.push({
                    step: `中文路径${i + 1}`,
                    status: 'success',
                    path: chinesePaths[i],
                    result: captureResult
                });
            } catch (error) {
                results.push({
                    step: `中文路径${i + 1}`,
                    status: 'error',
                    path: chinesePaths[i],
                    message: error.message
                });
            }
        }

        return { success: true, results };
    }

    // 循环测试
    async runLoopTest() {
        const results = [];
        const iterations = 5;

        for (let i = 1; i <= iterations; i++) {
            try {
                screenshot.initCapture();

                const savePath = path.join(__dirname, 'test-output', `loop-test-${i}.png`);
                const captureResult = await new Promise((resolve) => {
                    screenshot.startCapture(savePath, (ret) => {
                        resolve(ret);
                    });
                });

                screenshot.cleanupCapture();

                results.push({
                    step: `第${i}次循环`,
                    status: 'success',
                    path: savePath,
                    result: captureResult
                });
            } catch (error) {
                results.push({
                    step: `第${i}次循环`,
                    status: 'error',
                    message: error.message
                });
                break;
            }
        }

        return { success: true, results };
    }

    async initialize() {
        // 确保输出目录存在
        const { execSync } = require('child_process');
        try {
            execSync('mkdir -p test-output');
        } catch (e) {
            // 目录已存在或创建失败
        }

        this.setupIPC();
        await this.createWindow();
    }
}

// 应用生命周期
app.whenReady().then(async () => {
    const tester = new ElectronScreenshotTester();
    await tester.initialize();
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', async () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        const tester = new ElectronScreenshotTester();
        await tester.initialize();
    }
});