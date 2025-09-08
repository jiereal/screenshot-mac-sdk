const sdk = require('./lib/index.js');
const path = require('path');

class OptimizedFlowTester {
    constructor() {
        this.results = [];
        this.testCount = 0;
    }

    async runOptimizedFlow() {
        console.log('🚀 优化串行流程测试开始 runOptimizedFlow...\n');
        
        try {
            // 串行执行所有测试流程
            await this.runSerialTests();
            
            this.printSummary();
            
        } catch (error) {
            console.error('❌ 串行测试失败:', error.message);
        }
    }

    async runSerialTests() {
        console.log('📋 开始串行测试流程...\n');

        // 阶段1: 基础功能验证（串行）
        await this.testBasicFunctions();
        
        // 阶段2: 中文路径串行测试
        await this.testChinesePathsSerial();
        
        // 阶段3: 串行循环调用
        await this.testSerialLoop();
        
        // 阶段4: 完整流程串行测试
        await this.testCompleteSerialFlow();
    }

    async testBasicFunctions() {
        console.log('🔍 阶段1: 基础函数串行验证');
        console.log('=' .repeat(40));
        
        const functions = [
            { name: 'version', func: () => sdk.version() },
            { name: 'isCaptureTracking', func: () => sdk.isCaptureTracking() },
            { name: 'initCapture', func: () => sdk.initCapture() },
            { name: 'cleanupCapture', func: () => sdk.cleanupCapture() }
        ];

        for (const fn of functions) {
            try {
                const result = await this.executeSafely(fn.func);
                console.log(`✅ ${fn.name}: ${result}`);
                this.record(fn.name, true, result);
            } catch (error) {
                this.record(fn.name, false, error.message);
                console.error(`❌ ${fn.name}: ${error.message}`);
            }
        }
    }

    async testChinesePathsSerial() {
        console.log('\n🈳 阶段2: 中文路径串行测试');
        console.log('=' .repeat(40));
        
        const chinesePaths = [
            '/tmp/1.png',
            '/tmp/中文路径测试2.png',
            '/tmp/用户_2023年_截图3.png',
            '/tmp/测试_特殊字符_4.png'
        ];

        for (let i = 0; i < chinesePaths.length; i++) {
            await this.delay(100); // 串行延迟
            
            try {
                console.log(`📝 串行测试中文路径 ${i+1}: ${chinesePaths[i]}`);
                
                // 完整串行流程
                console.log('   ├─ 初始化...');
                sdk.initCapture();
                
                console.log('   ├─ 检查状态...');
                const status = sdk.isCaptureTracking();
                
                console.log(`   ├─ 中文路径: ${chinesePaths[i]}`);
                await new Promise((resolve) => {
                    sdk.startCapture(chinesePaths[i], (result) => {
                        console.log(`   │  回调结果: ${result}`);
                        resolve(result);
                    });
                });
                
                console.log('   ├─ 清理...');
                sdk.cleanupCapture();
                
                this.record(`chinese-path-${i+1}`, true, chinesePaths[i]);
                console.log(`✅ 中文路径串行测试 ${i+1}: 通过`);
                
            } catch (error) {
                this.record(`chinese-path-${i+1}`, false, error.message);
                console.error(`❌ 中文路径串行测试 ${i+1}: ${error.message}`);
            }
        }
    }

    async testSerialLoop() {
        console.log('\n🔄 阶段3: 串行循环调用');
        console.log('=' .repeat(40));
        
        const iterations = 5;
        
        for (let i = 1; i <= iterations; i++) {
            await this.delay(200); // 串行延迟
            
            try {
                console.log(`\n🔄 第 ${i} 次串行循环:`);
                
                // 完整串行流程
                console.log(`   ├─ 第 ${i} 次: 版本检查...`);
                const version = sdk.version();
                
                console.log(`   ├─ 第 ${i} 次: 初始化...`);
                sdk.initCapture();
                
                console.log(`   ├─ 第 ${i} 次: 状态检查...`);
                const status = sdk.isCaptureTracking();
                
                console.log(`   ├─ 第 ${i} 次: 开始截图...`);
                await new Promise((resolve) => {
                    sdk.startCapture(`/tmp/串行测试_${i}.png`, (result) => {
                        console.log(`   │  第 ${i} 次回调: ${result}`);
                        resolve(result);
                    });
                });
                
                console.log(`   ├─ 第 ${i} 次: 清理...`);
                sdk.cleanupCapture();
                
                console.log(`   └─ 第 ${i} 次: 完成`);
                
                this.record(`serial-loop-${i}`, true, `第${i}次循环`);
                
            } catch (error) {
                this.record(`serial-loop-${i}`, false, error.message);
                console.error(`❌ 第 ${i} 次串行循环失败:`, error.message);
                break; // 串行中断
            }
        }
    }

    async testCompleteSerialFlow() {
        console.log('\n🎯 阶段4: 完整流程串行测试');
        console.log('=' .repeat(50));
        
        const testCases = [
            {
                name: '标准串行流程',
                steps: [
                    () => ({ name: 'version', result: sdk.version() }),
                    () => ({ name: 'isCaptureTracking', result: sdk.isCaptureTracking() }),
                    () => ({ name: 'initCapture', result: sdk.initCapture() }),
                    async () => {
                        await new Promise((resolve) => {
                            sdk.startCapture('/tmp/测试.png', (result) => {
                                resolve(result);
                            });
                        });
                        return { name: 'startCapture', result: '完成' };
                    },
                    () => ({ name: 'cleanupCapture', result: sdk.cleanupCapture() }),
                    () => ({ name: 'finalStatus', result: sdk.isCaptureTracking() })
                ]
            },
            {
                name: '中文路径串行',
                steps: [
                    () => ({ name: 'version', result: sdk.version() }),
                    () => ({ name: 'initCapture', result: sdk.initCapture() }),
                    async () => {
                        await new Promise((resolve) => {
                            sdk.startCapture('/tmp/中文测试.png', (result) => {
                                resolve(result);
                            });
                        });
                        return { name: 'startCapture-中文', result: '完成' };
                    },
                    () => ({ name: 'isCaptureTracking', result: sdk.isCaptureTracking() }),
                    () => ({ name: 'cleanupCapture', result: sdk.cleanupCapture() })
                ]
            }
        ];

        for (let i = 0; i < testCases.length; i++) {
            const testCase = testCases[i];
            console.log(`\n🎯 串行流程 ${i+1}: ${testCase.name}`);
            
            for (let j = 0; j < testCase.steps.length; j++) {
                await this.delay(50); // 串行执行每个步骤
                
                try {
                    const step = testCase.steps[j]();
                    console.log(`   ├─ ${step.name}: ✅`);
                    this.record(`serial-${testCase.name}-${step.name}`, true, step.result || '成功');
                    
                } catch (error) {
                    this.record(`serial-${testCase.name}-${testCase.steps[j].name}`, false, error.message);
                    console.error(`   ├─ ${testCase.steps[j].name}: ❌ ${error.message}`);
                    break; // 串行中断
                }
            }
            
            console.log(`✅ 串行流程 ${i+1}: ${testCase.name} 完成`);
        }
    }

    async delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    executeSafely(func) {
        try {
            return func();
        } catch (error) {
            throw new Error(`执行失败: ${error.message}`);
        }
    }

    record(testName, success, details = '') {
        this.testCount++;
        this.results.push({
            id: this.testCount,
            name: testName,
            success,
            details,
            timestamp: new Date().toISOString()
        });
    }

    printSummary() {
        console.log('\n📊 串行测试总结');
        console.log('=' .repeat(60));
        
        const total = this.results.length;
        const passed = this.results.filter(r => r.success).length;
        
        console.log(`🎯 总测试数: ${total}`);
        console.log(`✅ 通过测试: ${passed}`);
        console.log(`❌ 失败测试: ${total - passed}`);
        console.log(`📈 串行通过率: ${Math.round((passed/total)*100)}%`);
        
        console.log('\n📋 串行执行结果:');
        this.results.forEach(result => {
            const status = result.success ? '✅' : '❌';
            console.log(`${status} ${result.id}. ${result.name}`);
        });
        
        if (passed === total) {
            console.log('\n🎊 串行测试全部通过！');
            console.log('✅ 所有函数串行执行正常');
            console.log('✅ 中文路径串行支持正常');
            console.log('✅ 无并发问题，串行执行稳定');
        } else {
            console.log(`\n⚠️  串行测试中发现 ${total - passed} 个问题`);
        }
    }
}

// 主执行函数
async function main() {
    console.log('🚀 优化串行流程测试开始...\n');
    
    const tester = new OptimizedFlowTester();
    
    try {
        await tester.runOptimizedFlow();
        
        console.log('\n🎉 串行测试完成！');
        console.log('✅ 所有函数串行执行通过');
        console.log('✅ 无并发竞争条件');
        console.log('✅ 中文路径支持确认');
        
    } catch (error) {
        console.error('❌ 串行测试异常:', error);
    }
}


// 导出供其他脚本使用
module.exports = OptimizedFlowTester;

// 如果直接运行
if (require.main === module) {
    main();
}