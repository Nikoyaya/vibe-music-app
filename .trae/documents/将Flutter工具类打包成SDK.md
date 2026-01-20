# 将Flutter工具类打包成SDK的详细方案

## 1. 项目分析

### 现有工具类结构：

* `lib/src/utils/deviceInfoUtils/` - 设备信息工具（包含平台特定实现）

* `lib/src/utils/app_logger.dart` - 应用日志工具

* `lib/src/utils/sp_util.dart` - SharedPreferences工具

### 依赖分析：

* device\_info\_plus: ^12.3.0

* shared\_preferences: ^2.5.3

* logger: ^2.0.2+1

* dio: 5.8.0+1

## 2. 实现步骤

### 步骤1: 创建新的Flutter Package项目

```bash
flutter create --template=package vibe_utils
cd vibe_utils
```

### 步骤2: 重构目录结构

```
vibe_utils/
├── lib/
│   ├── vibe_utils.dart        # 主入口文件
│   ├── device_info/
│   │   ├── android_device_info.dart
│   │   ├── ios_device_info.dart
│   │   ├── web_device_info.dart
│   │   ├── device_info_manager.dart
│   │   └── device_info.dart
│   ├── app_logger.dart
│   └── sp_util.dart
├── test/
├── example/                   # 示例应用
└── pubspec.yaml
```

### 步骤3: 配置pubspec.yaml

```yaml
name: vibe_utils
description: A collection of utility classes for Vibe Music App
version: 1.0.0
environment:
  sdk: '>=3.0.0 <4.0.0'
dependencies:
  flutter:
    sdk: flutter
  device_info_plus: ^12.3.0
  shared_preferences: ^2.5.3
  logger: ^2.0.2+1
  dio: ^5.8.0
```

### 步骤4: 创建主入口文件

在 `lib/vibe_utils.dart` 中导出所有工具类：

```dart
export 'device_info/device_info.dart';
export 'app_logger.dart';
export 'sp_util.dart';
```

### 步骤5: 迁移工具类代码

* 将现有工具类代码复制到新包中

* 调整导入路径

* 确保代码符合包的结构

### 步骤6: 添加示例应用

在 `example/lib/main.dart` 中创建使用示例：

```dart
import 'package:flutter/material.dart';
import 'package:vibe_utils/vibe_utils.dart';

void main() {
  // 示例用法
  AppLogger.init();
  AppLogger.d('Test log');
  
  runApp(MyApp());
}
```

### 步骤7: 测试和验证

```bash
cd vibe_utils
flutter test
flutter pub publish --dry-run
```

### 步骤8: 发布包

```bash
flutter pub publish
```

## 3. 使用方法

在其他项目中添加依赖：

```yaml
dependencies:
  vibe_utils: ^1.0.0
```

导入并使用：

```dart
import 'package:vibe_utils/vibe_utils.dart';

// 使用示例
await DeviceInfoManager.getDeviceInfo();
AppLogger.d('Hello World');
await SpUtil.putString('key', 'value');
```

## 4. 注意事项

1. **依赖管理**：确保包的依赖版本与原项目兼容
2. **平台特定代码**：确保设备信息工具在所有平台上正常工作
3. **测试覆盖**：为工具类添加适当的测试
4. **文档**：添加README.md和代码注释
5. **版本控制**：遵循语义化版本规范

## 5. 优势

* 代码复用：工具类可以在多个项目中使用

* 维护性：集中管理工具类，便于更新和维护

* 模块化：将功能拆分为独立模块，提高代码质量

* 可测试性：独立的包结构便于单元测试

