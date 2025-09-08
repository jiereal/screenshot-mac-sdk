// scripts/prebuild.js
const fs = require('fs');
const path = require('path');

// 读取 package.json
const pkgPath = path.join(__dirname, '..', 'package.json');
const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));

// 生成包含版本号的头文件
const headerContent = `#ifndef VERSION_H
#define VERSION_H

#define MODULE_VERSION "${pkg.version}"

#endif // VERSION_H
`;

// 写入头文件
fs.writeFileSync(path.join(__dirname, '..', 'src', 'version.h'), headerContent);