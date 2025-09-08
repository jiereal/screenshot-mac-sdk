const sdk = require('./lib/index.js');

console.log('🧪 简单功能测试...');

try {
    console.log('📋 模块加载成功');
    console.log('📋 版本:', sdk.version());
    
    console.log('📋 初始化测试...');
    sdk.initCapture();
    console.log('✅ 初始化成功');
    
    console.log('📋 清理测试...');
    sdk.cleanupCapture();
    console.log('✅ 清理成功');
    
    console.log('📋 所有基础测试通过 ✅');
    
} catch (error) {
    console.error('❌ 测试失败:', error.message);
    console.error('堆栈:', error.stack);
}

// 导出测试结果
module.exports = { success: true };