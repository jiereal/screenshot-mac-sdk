const sdk = require('./lib/index.js');

console.log('=== 测试回调函数验证问题 ===');

// 测试1: 第一次调用
console.log('\n1. 第一次调用 - 正确回调:');
try {
    sdk.startCapture('/tmp/test1.png', function(result) {
        console.log('第一次回调结果:', result);
    });
    console.log('✅ 第一次调用成功');
} catch (e) {
    console.log('❌ 第一次调用失败:', e.message);
}

// 测试2: 第二次调用 - 检查回调类型
console.log('\n2. 第二次调用 - 检查回调:');
const callback2 = function(result2) {
    console.log('第二次回调结果:', result2);
};

console.log('回调2类型:', typeof callback2);
console.log('回调2是函数:', callback2 instanceof Function);

try {
    sdk.startCapture('/tmp/test2.png', callback2);
    console.log('✅ 第二次调用成功');
} catch (e) {
    console.log('❌ 第二次调用失败:', e.message);
}

// 测试3: 使用箭头函数
console.log('\n3. 第三次调用 - 箭头函数:');
const callback3 = (result3) => {
    console.log('第三次回调结果:', result3);
};

console.log('回调3类型:', typeof callback3);
console.log('回调3是函数:', callback3 instanceof Function);

try {
    sdk.startCapture('/tmp/test3.png', callback3);
    console.log('✅ 第三次调用成功');
} catch (e) {
    console.log('❌ 第三次调用失败:', e.message);
}

// 测试4: 使用bind函数
console.log('\n4. 第四次调用 - bind函数:');
const callback4 = function(result4) {
    console.log('第四次回调结果:', result4);
}.bind(this);

console.log('回调4类型:', typeof callback4);
console.log('回调4是函数:', callback4 instanceof Function);

try {
    sdk.startCapture('/tmp/test4.png', callback4);
    console.log('✅ 第四次调用成功');
} catch (e) {
    console.log('❌ 第四次调用失败:', e.message);
}

console.log('\n=== 测试完成 ===');