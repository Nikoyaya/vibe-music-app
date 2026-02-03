# Vibe Music App

<p align="center">
  <img src="assets/images/icons/icon.png" alt="Vibe Music App Icon" width="100" height="100">
</p>

[English](README_EN.md) | [简体中文](README.md) | [繁體中文](README_ZH_TW.md)

一款基于 Flutter 开发的现代化音乐播放器应用，用于连接和播放 Vibe Music Server 中的音乐。

## 功能特点

- **🎵 音频播放**：支持播放、暂停、上一曲、下一曲等基本操作
- **📱 响应式设计**：完美适配不同屏幕尺寸的设备
- **🔄 播放控制**：支持循环播放、随机播放等多种播放模式
- **❤️ 收藏功能**：支持收藏和取消收藏歌曲
- **🔍 搜索功能**：支持搜索歌曲
- **📋 播放列表**：显示和管理当前播放列表
- **🎨 美观界面**：现代化的 UI 设计，流畅的动画效果
- **🌐 网络连接**：连接到 Vibe Music Server 获取音乐数据
- **👤 用户认证**：支持用户登录和注册功能
- **👨‍💼 管理员功能**：支持管理员管理用户和歌曲
- **📱 设备信息**：支持获取设备信息
- **💾 本地数据库**：支持本地存储数据

## 技术栈

- **框架**：Flutter 3.0+
- **语言**：Dart
- **音频播放**：just_audio + audioplayers
- **状态管理**：GetX (get)
- **网络请求**：dio
- **图片加载**：cached_network_image
- **环境变量**：flutter_dotenv
- **动画效果**：Flutter 内置动画 + shimmer
- **图标**：flutter_svg
- **本地存储**：shared_preferences + sqflite
- **路径管理**：path_provider + path
- **图片选择**：image_picker
- **轮播图**：carousel_slider
- **日志**：logger
- **音频会话**：audio_session
- **启动页**：flutter_native_splash
- **设备信息**：device_info_plus
- **代码生成**：freezed
- **数据库**：floor + sqflite
- **网络连接检测**：connectivity_plus
- **桌面窗口管理**：bitsdojo_window

## App 展示

### 移动端截图

以下是应用在移动设备上的截图：

| 首页 | 播放器页面 | 收藏页面 |
|------|------------|----------|
| <img src="screenshots/flutter_01.png" width="200" alt="首页截图" /> | <img src="screenshots/flutter_02.png" width="200" alt="播放器页面截图" /> | <img src="screenshots/flutter_03.png" width="200" alt="收藏页面截图" /> |

## 安装和运行

### 前提条件

- Flutter SDK 3.0 或更高版本
- Dart SDK 3.0 或更高版本
- Android Studio 或 VS Code（推荐）
- 模拟器或真实设备

### 步骤

1. **克隆仓库**

```bash
git clone https://gitee.com/jason_kwok35/vibe-music-app
cd vibe_music_app
```

2. **安装依赖**

```bash
flutter pub get
```

3. **配置环境变量**

- 复制 `.env.example` 文件为 `.env`
- 根据实际情况修改 `.env` 文件中的配置

4. **运行应用**

```bash
# 在模拟器或连接的设备上运行
flutter run

# 运行特定设备
flutter run -d <device-id>
```



## 配置说明

### 环境变量 (.env)

项目使用 `.env` 文件管理环境变量，主要配置项包括：

```env
# API 基础 URL
BASE_URL=http://your-server-address:8080

# API 超时时间（毫秒）
API_TIMEOUT=30000

# 基础 IP 地址（用于替换响应中的图片 URL）
BASE_IP=http://your-server-address
```

### 构建配置

#### Android

- **最小 SDK 版本**：21
- **目标 SDK 版本**：根据 Flutter 配置
- **构建类型**：支持 debug 和 release 模式

#### iOS

- **最低 iOS 版本**：11.0
- **构建配置**：支持 debug 和 release 模式

#### Web

- **构建配置**：支持 debug 和 release 模式

#### Linux

- **构建配置**：支持 debug 和 release 模式

#### macOS

- **构建配置**：支持 debug 和 release 模式

#### Windows

- **构建配置**：支持 debug 和 release 模式

## 构建和部署

### 构建 APK

```bash
# 构建 release 版本的 APK
flutter build apk --release

# 构建拆分 APK（更小的体积）
flutter build apk --split-per-abi
```

### 构建 iOS

```bash
# 构建 release 版本的 iOS 应用
flutter build ios --release
```

### 构建 Web

```bash
# 构建 Web 版本
flutter build web
```

### 构建 Linux

```bash
# 构建 Linux 版本
flutter build linux
```

### 构建 macOS

```bash
# 构建 macOS 版本
flutter build macos
```

### 构建 Windows

```bash
# 构建 Windows 版本
flutter build windows
```

## 开发指南

### 代码风格

- 遵循 Flutter 官方代码风格指南
- 使用 `flutter format` 格式化代码
- 使用 `flutter analyze` 进行代码分析

### 项目架构

本项目采用 MVC 架构模式组织代码结构：

- **Model（模型）**：定义数据结构，如 `song_model.dart`、`user_model.dart`
- **View（视图）**：页面 UI 实现，位于各页面的 `widgets/view.dart` 中
- **Controller（控制器）**：业务逻辑处理，位于各页面的 `widgets/controller.dart` 中

### 调试技巧

- 使用 VS Code 或 Android Studio 的 Flutter 插件进行调试
- 使用 `flutter run --debug` 运行调试版本
- 使用 `app_logger.dart` 中的日志工具输出调试信息
- 查看 `debug_output.txt` 获取运行时调试信息

### 常见问题

1. **构建失败**：检查 Flutter SDK 版本和依赖配置
2. **网络请求失败**：检查 `.env` 文件中的 BASE_URL 配置
3. **音频播放失败**：检查音频文件格式和网络连接
4. **内存不足**：尝试清理缓存和优化代码
5. **第二次启动应用时播放时长显示为0**：参考 BUG_REPORT.md 中的已知问题
6. **播放列表删除歌曲后 UI 不更新**：参考 BUG_REPORT.md 中的已知问题

## 任务管理

项目使用 `TODO_LIST.md` 文件管理开发任务，包括：

- 🏗️ 开发任务
- 🐛 修复任务
- 🎨 UI/UX 优化
- 📱 平台适配
- 🚀 性能优化
- 📝 文档任务

每个任务都有状态说明和优先级标识。

## 贡献指南

1. **Fork 仓库**
2. **创建分支**：`git checkout -b feature/your-feature`
3. **提交更改**：`git commit -m "Add your feature"`
4. **推送分支**：`git push origin feature/your-feature`
5. **创建 Pull Request**

## 许可证

本项目采用自定义的非商业使用许可证 - 详情请参阅 [LICENSE](LICENSE) 文件

### 许可证特点

- **非商业使用**：仅允许个人、教育、研究等非商业用途
- **商业使用禁止**：禁止用于任何商业目的
- **归因要求**：再分发时必须包含许可证文件并保留版权声明
- **免责声明**：软件按"原样"提供，不提供任何保证

## 联系方式

- **Gitee 项目地址**：https://gitee.com/jason_kwok35/vibe-music-app
- **Gitee 问题反馈**：https://gitee.com/jason_kwok35/vibe-music-app/issues
- **GitHub 项目地址**：https://github.com/Nikoyaya/vibe-music-app
- **GitHub 问题反馈**：https://github.com/Nikoyaya/vibe-music-app/issues

## 感谢

感谢所有为这个项目做出贡献的人！

---

**享受音乐，享受生活！🎧**