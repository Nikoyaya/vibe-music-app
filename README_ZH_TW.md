# Vibe Music App

<p align="center">
  <img src="assets/images/icons/icon.png" alt="Vibe Music App Icon" width="100" height="100">
</p>

<p align="center">
[English](README_EN.md) | [简体中文](README.md) | [繁體中文](README_ZH_TW.md)
</p>

一款基於 Flutter 開發的現代化音樂播放器應用，用於連接和播放 Vibe Music Server 中的音樂。

## 功能特點

- **🎵 音頻播放**：支援播放、暫停、上一曲、下一曲等基本操作
- **📱 響應式設計**：完美適配不同螢幕尺寸的設備
- **🔄 播放控制**：支援循環播放、隨機播放等多種播放模式
- **❤️ 收藏功能**：支援收藏和取消收藏歌曲
- **🔍 搜索功能**：支援搜索歌曲
- **📋 播放列表**：顯示和管理當前播放列表
- **🎨 美觀介面**：現代化的 UI 設計，流暢的動畫效果
- **🌐 網路連接**：連接到 Vibe Music Server 獲取音樂數據
- **👤 使用者認證**：支援使用者登入和註冊功能
- **👨‍💼 管理員功能**：支援管理員管理使用者和歌曲
- **📱 設備資訊**：支援獲取設備資訊
- **💾 本地資料庫**：支援本地儲存數據

## 技術堆疊

- **框架**：Flutter 3.0+
- **語言**：Dart
- **音頻播放**：just_audio + audioplayers
- **狀態管理**：GetX (get)
- **網路請求**：dio
- **圖片載入**：cached_network_image
- **環境變數**：flutter_dotenv
- **動畫效果**：Flutter 內建動畫 + shimmer
- **圖示**：flutter_svg
- **本地儲存**：shared_preferences + sqflite
- **路徑管理**：path_provider + path
- **圖片選擇**：image_picker
- **輪播圖**：carousel_slider
- **日誌**：logger
- **音頻會話**：audio_session
- **啟動頁**：flutter_native_splash
- **設備資訊**：device_info_plus
- **程式碼生成**：freezed
- **資料庫**：floor + sqflite
- **網路連接檢測**：connectivity_plus
- **桌面視窗管理**：bitsdojo_window

## App 展示

### 行動端截圖

以下是應用在行動設備上的截圖：

| 首頁 | 播放器頁面 | 收藏頁面 |
|------|------------|----------|
| <img src="screenshots/flutter_01.png" width="200" alt="首頁截圖" /> | <img src="screenshots/flutter_02.png" width="200" alt="播放器頁面截圖" /> | <img src="screenshots/flutter_03.png" width="200" alt="收藏頁面截圖" /> |

## 安裝和執行

### 前提條件

- Flutter SDK 3.0 或更高版本
- Dart SDK 3.0 或更高版本
- Android Studio 或 VS Code（推薦）
- 模擬器或真實設備

### 步驟

1. **克隆倉庫**

```bash
git clone https://gitee.com/jason_kwok35/vibe-music-app
cd vibe_music_app
```

2. **安裝依賴**

```bash
flutter pub get
```

3. **配置環境變數**

- 複製 `.env.example` 檔案為 `.env`
- 根據實際情況修改 `.env` 檔案中的配置

4. **執行應用**

```bash
# 在模擬器或連接的設備上執行
flutter run

# 執行特定設備
flutter run -d <device-id>
```



## 配置說明

### 環境變數 (.env)

專案使用 `.env` 檔案管理環境變數，主要配置項包括：

```env
# API 基礎 URL
BASE_URL=http://your-server-address:8080

# API 超時時間（毫秒）
API_TIMEOUT=30000

# 基礎 IP 地址（用於替換響應中的圖片 URL）
BASE_IP=http://your-server-address
```

### 構建配置

#### Android

- **最小 SDK 版本**：21
- **目標 SDK 版本**：根據 Flutter 配置
- **構建類型**：支援 debug 和 release 模式

#### iOS

- **最低 iOS 版本**：11.0
- **構建配置**：支援 debug 和 release 模式

#### Web

- **構建配置**：支援 debug 和 release 模式

#### Linux

- **構建配置**：支援 debug 和 release 模式

#### macOS

- **構建配置**：支援 debug 和 release 模式

#### Windows

- **構建配置**：支援 debug 和 release 模式

## 構建和部署

### 構建 APK

```bash
# 構建 release 版本的 APK
flutter build apk --release

# 構建拆分 APK（更小的體積）
flutter build apk --split-per-abi
```

### 構建 iOS

```bash
# 構建 release 版本的 iOS 應用
flutter build ios --release
```

### 構建 Web

```bash
# 構建 Web 版本
flutter build web
```

### 構建 Linux

```bash
# 構建 Linux 版本
flutter build linux
```

### 構建 macOS

```bash
# 構建 macOS 版本
flutter build macos
```

### 構建 Windows

```bash
# 構建 Windows 版本
flutter build windows
```

## 開發指南

### 程式碼風格

- 遵循 Flutter 官方程式碼風格指南
- 使用 `flutter format` 格式化程式碼
- 使用 `flutter analyze` 進行程式碼分析

### 專案架構

本專案採用 MVC 架構模式組織程式碼結構：

- **Model（模型）**：定義數據結構，如 `song_model.dart`、`user_model.dart`
- **View（視圖）**：頁面 UI 實現，位於各頁面的 `widgets/view.dart` 中
- **Controller（控制器）**：業務邏輯處理，位於各頁面的 `widgets/controller.dart` 中

### 調試技巧

- 使用 VS Code 或 Android Studio 的 Flutter 插件進行調試
- 使用 `flutter run --debug` 執行調試版本
- 使用 `app_logger.dart` 中的日誌工具輸出調試資訊
- 查看 `debug_output.txt` 獲取運行時調試資訊

### 常見問題

1. **構建失敗**：檢查 Flutter SDK 版本和依賴配置
2. **網路請求失敗**：檢查 `.env` 檔案中的 BASE_URL 配置
3. **音頻播放失敗**：檢查音頻檔案格式和網路連接
4. **記憶體不足**：嘗試清理緩存和優化程式碼
5. **第二次啟動應用時播放時長顯示為0**：參考 BUG_REPORT.md 中的已知問題
6. **播放列表刪除歌曲後 UI 不更新**：參考 BUG_REPORT.md 中的已知問題

## 任務管理

專案使用 `TODO_LIST.md` 檔案管理開發任務，包括：

- 🏗️ 開發任務
- 🐛 修復任務
- 🎨 UI/UX 優化
- 📱 平台適配
- 🚀 效能優化
- 📝 文檔任務

每個任務都有狀態說明和優先級標識。

## 貢獻指南

1. **Fork 倉庫**
2. **創建分支**：`git checkout -b feature/your-feature`
3. **提交更改**：`git commit -m "Add your feature"`
4. **推送分支**：`git push origin feature/your-feature`
5. **創建 Pull Request**

## 許可證

本專案採用自訂的非商業使用許可證 - 詳情請參閱 [LICENSE](LICENSE) 檔案

### 許可證特點

- **非商業使用**：僅允許個人、教育、研究等非商業用途
- **商業使用禁止**：禁止用於任何商業目的
- **歸因要求**：再分發時必須包含許可證檔案並保留版權聲明
- **免責聲明**：軟體按「原樣」提供，不提供任何保證

## 聯繫方式

- **Gitee 專案地址**：https://gitee.com/jason_kwok35/vibe-music-app
- **Gitee 問題反饋**：https://gitee.com/jason_kwok35/vibe-music-app/issues
- **GitHub 專案地址**：https://github.com/Nikoyaya/vibe-music-app
- **GitHub 問題反饋**：https://github.com/Nikoyaya/vibe-music-app/issues

## 感謝

感謝所有為這個專案做出貢獻的人！

---

**享受音樂，享受生活！🎧**