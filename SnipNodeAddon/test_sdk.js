const sdk = require('./lib/index.js');
const path = require('path');
const fs = require('fs');

class SDKTest {
    constructor() {
        this.testResults = [];
        this.testImagePath = path.join(__dirname, 'test_capture.png');
    }

    async runAllTests() {
        console.log('🚀 开始测试 SnipNodeAddon NAPI 模块...\n');

        try {
            // 测试 1: 版本信息
            await this.testVersion();

            // 测试 2: 初始化
            await this.testInitCapture();

            // 测试 3: 状态检测
            await this.testIsCaptureTracking();

            // 测试 4: 清理功能
            await this.testCleanupCapture();

            // 测试 5: 开始截图（基础测试）
            await this.testStartCaptureBasic();

            console.log('\n📊 测试结果汇总:');
            console.log('=' .repeat(50));
            this.testResults.forEach((result, index) => {
                const status = result.passed ? '✅' : '❌';
                console.log(`${status} 测试 ${index + 1}: ${result.name}`);
                if (!result.passed && result.error) {
                    console.log(`   错误: ${result.error}`);
                }
            });

            const passed = this.testResults.filter(r => r.passed).length;
            const total = this.testResults.length;
            console.log(`\n🎯 通过率: ${passed}/${total} (${Math.round((passed/total)*100)}%)`);

        } catch (error) {
            console.error('❌ 测试执行失败:', error.message);
        }
    }

    async testVersion() {
        try {
            console.log('1. 测试版本信息...');
            const version = sdk.version();
            
            if (typeof version === 'string' && version.length > 0) {
                console.log(`   ✅ 版本号: ${version}`);
                this.recordTest('版本信息', true);
            } else {
                throw new Error('版本号格式不正确');
            }
        } catch (error) {
            console.log(`   ❌ 版本测试失败: ${error.message}`);
            this.recordTest('版本信息', false, error.message);
        }
    }

    async testInitCapture() {
        try {
            console.log('2. 测试初始化...');
            const result = sdk.initCapture();
            
            // initCapture 应该返回 undefined (无返回值)
            if (result === undefined) {
                console.log('   ✅ 初始化成功');
                this.recordTest('初始化', true);
            } else {
                throw new Error('初始化返回了意外的值');
            }
        } catch (error) {
            console.log(`   ❌ 初始化测试失败: ${error.message}`);
            this.recordTest('初始化', false, error.message);
        }
    }

    async testIsCaptureTracking() {
        try {
            console.log('3. 测试状态检测...');
            const isTracking = sdk.isCaptureTracking();
            
            if (typeof isTracking === 'boolean') {
                console.log(`   ✅ 状态检测: ${isTracking ? '正在捕获' : '未在捕获'}`);
                this.recordTest('状态检测', true);
            } else {
                throw new Error('状态检测返回了非布尔值');
            }
        } catch (error) {
            console.log(`   ❌ 状态检测测试失败: ${error.message}`);
            this.recordTest('状态检测', false, error.message);
        }
    }

    async testCleanupCapture() {
        try {
            console.log('4. 测试清理功能...');
            const result = sdk.cleanupCapture();
            
            // cleanupCapture 应该返回 undefined (无返回值)
            if (result === undefined) {
                console.log('   ✅ 清理成功');
                this.recordTest('清理功能', true);
            } else {
                throw new Error('清理返回了意外的值');
            }
        } catch (error) {
            console.log(`   ❌ 清理功能测试失败: ${error.message}`);
            this.recordTest('清理功能', false, error.message);
        }
    }

    async testStartCaptureBasic() {
        try {
            console.log('5. 测试开始截图（基础验证）...');
            
            // 创建一个简单的回调函数
            let callbackCalled = false;
            const testCallback = (result) => {
                callbackCalled = true;
                console.log(`   📞 回调被调用，结果: ${result}`);
            };

            // 测试参数验证
            try {
                sdk.startCapture('invalid/path', 'not_a_function');
                throw new Error('应该抛出参数错误');
            } catch (error) {
                if (error.message.includes('参数类型错误') || error.message.includes('必须是函数')) {
                    console.log('   ✅ 参数验证正确');
                } else {
                    throw error;
                }
            }

            console.log('   ⚠️  完整截图功能需要实际环境测试');
            this.recordTest('开始截图', true);

        } catch (error) {
            console.log(`   ❌ 开始截图测试失败: ${error.message}`);
            this.recordTest('开始截图', false, error.message);
        }
    }

    recordTest(name, passed, error = null) {
        this.testResults.push({
            name,
            passed,
            error
        });
    }

    // 创建测试用的临时目录
    ensureTestDir() {
        if (!fs.existsSync(__dirname)) {
            fs.mkdirSync(__dirname, { recursive: true });
        }
    }
}

// 运行测试
const test = new SDKTest();
test.runAllTests().catch(console.error);

// 导出测试类供其他脚本使用
module.exports = SDKTest;
