#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// 获取根目录路径
function getRootDir() {
    return path.dirname(__filename);
}

// 清理并构建SnipManager项目
function buildSnipManager() {
    const rootDir = getRootDir();
    const frameworksProjectDir = path.join(rootDir, '..', 'SnipManager');
    const projectPath = path.join(frameworksProjectDir, 'SnipManager.xcodeproj');
    
    console.log('Root directory:', rootDir);
    console.log('Building SnipManager project...');
    
    try {
        // 清理并构建项目
        execSync(`xcodebuild -project "${projectPath}" -target SnipManager -configuration Release clean build`, {
            stdio: 'inherit',
            cwd: frameworksProjectDir
        });
        console.log('SnipManager build completed successfully');
    } catch (error) {
        console.error('SnipManager build failed:', error.message);
        process.exit(1);
    }
}

// 复制框架文件到statics目录
function copyFrameworkFiles() {
    const rootDir = getRootDir();
    const staticsDir = path.join(rootDir, 'statics');
    const frameworksProjectDir = path.join(rootDir, '..', 'SnipManager');
    const frameworksBuildDir = path.join(frameworksProjectDir, 'build', 'Release');
    
    // 删除并重新创建statics目录
    if (fs.existsSync(staticsDir)) {
        fs.rmSync(staticsDir, { recursive: true, force: true });
    }
    fs.mkdirSync(staticsDir, { recursive: true });
    
    console.log('Copying framework files...');
    
    try {
        // 复制SnipManager.framework
        const frameworkSrc = path.join(frameworksBuildDir, 'SnipManager.framework');
        const frameworkDest = path.join(staticsDir, 'SnipManager.framework');
        
        if (fs.existsSync(frameworkSrc)) {
            execSync(`cp -r "${frameworkSrc}" "${staticsDir}"`, { stdio: 'inherit' });
            console.log('SnipManager.framework copied successfully');
        } else {
            throw new Error(`Framework not found at: ${frameworkSrc}`);
        }
        
        // 复制SnipManager.framework.dSYM
        const dSymSrc = path.join(frameworksBuildDir, 'SnipManager.framework.dSYM');
        const dSymDest = path.join(staticsDir, 'SnipManager.framework.dSYM');
        
        if (fs.existsSync(dSymSrc)) {
            execSync(`cp -r "${dSymSrc}" "${staticsDir}"`, { stdio: 'inherit' });
            console.log('SnipManager.framework.dSYM copied successfully');
        } else {
            console.warn('Warning: dSYM file not found, skipping...');
        }
        
    } catch (error) {
        console.error('Error copying framework files:', error.message);
        process.exit(1);
    }
}

// 主函数
function main() {
    console.log('Starting pre-build process...');

    // 检查平台
    if (process.platform !== 'darwin') {
        console.error('错误：此脚本仅支持macOS平台');
        return;
    }
    
    try {
        // 构建SnipManager项目
        buildSnipManager();
        
        // 复制框架文件
        copyFrameworkFiles();
        
        console.log('Pre-build process completed successfully!');
    } catch (error) {
        console.error('Pre-build process failed:', error.message);
        process.exit(1);
    }
}

// 执行主函数
if (require.main === module) {
    main();
}

module.exports = { buildSnipManager, copyFrameworkFiles };