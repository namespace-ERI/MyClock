# MyClock

[English Version Below](#english-version)

<video src="video.mov" controls=""></video>

---

⚠️声明：本项目完全由Gemini在 2h 内搭建，包括代码、导出、README 和 logo，初始UI风格和基础功能参考了小红书博主“卡夫卡”，ID为“174973146”

## 🇨🇳 中文版本 

**MyClock** 是一个专为 macOS 设计的极简番茄工作法计时器。它驻留在你的菜单栏中，提供丝滑的原生体验、强大的数据统计以及完全自定义的设置，帮助你保持专注并追踪工作效率。

### ✨ 主要特性

* **原生体验**：基于 SwiftUI 和 AppKit 开发，完美契合 macOS 设计语言，支持深色模式。
* **无干扰设计**：
  * **隐藏 Dock 图标**：应用作为“代理程序 (Agent)”运行，仅驻留在顶部菜单栏，不占用 Dock 栏空间，保持桌面极致整洁。
  * **状态栏常驻**：图标与倒计时直接显示在顶部，随时查看剩余时间。
* **极简控制**：
  * 通过拖动滑块快速设置专注时长（1-90分钟）。
  * 带有触感反馈（Haptics）的调节体验。
  * 支持“跳过”功能，自动记录实际专注时长。
* **可视化统计**：
  * **Day 视图**：详细的时间轴记录列表。
  * **Week 视图**：动态比例柱状图，一目了然。
  * **Month 视图**：GitHub 风格的热力图（Heatmap），支持点击日期查看历史详情。
  * **日历导航**：支持左右切换日期，或通过日历选择器精确定位。
* **高效交互**：
  * **全局快捷键**：默认 `Cmd + E` 随时开始/暂停（支持自定义）。
  * **自动流程**：专注结束自动进入休息模式，休息结束自动回到待机。
* **数据安全**：所有数据存储在本地（`~/Documents/flowclone_history.json`），无需联网，安全可靠。

### 📥 安装与使用

#### 直接安装

1.  下载本项目 Release 中的 **`MyClock.dmg`** 文件。
2.  双击打开 `.dmg`，将 **MyClock** 图标拖入 **Applications (应用程序)** 文件夹。
3.  双击启动应用（此时系统可能会提示“无法打开”或“身份不明的开发者”，请点击“完成”关闭弹窗）。
4.  **⚠️ 首次授权步骤**：
    * 打开 Mac 的 **系统设置 (System Settings)**。
    * 进入 **隐私与安全性 (Privacy & Security)**。
    * 向下滑动页面至“安全性”区域。
    * 你会看到一条提示：“已阻止使用‘MyClock’，因为它来自身份不明的开发者”。
    * 点击右侧的 **“仍要打开” (Open Anyway)** 按钮。
    * 在弹出的确认框中输入密码或指纹，并点击 **“打开”**。
    * 以后即可直接双击正常使用。

#### 使用指南

* 点击菜单栏的小图标（闹钟/咖啡杯）即可唤出主界面。
* **开始/暂停**：点击播放按钮或按下全局快捷键。
* **设置**：点击界面右上角的齿轮图标，可设置“开机自启”、“快捷键”、“默认时长”及“提示音效”。
* **注意**：设置了未超过5min的专注不计入总时长

### 📂 文件结构说明

如果您是开发者，以下是源代码核心文件的作用说明：

| 文件名                     | 作用描述                                                     |
| :------------------------- | :----------------------------------------------------------- |
| **MyClockApp.swift**       | **程序入口**。负责管理 `AppDelegate`，初始化菜单栏图标（Status Bar Item）和弹窗（Popover），处理应用启动和退出逻辑。 |
| **TimerManager.swift**     | **核心逻辑大脑**。管理计时器状态、倒计时逻辑、数据模型定义 (`SessionRecord`) 以及数据的本地持久化存储 (JSON读写)。 |
| **ControlsView.swift**     | **主控界面**。包含倒计时大数字显示、自定义滑块 (MinimalSlider) 以及 播放/暂停/跳过/重置 按钮组。 |
| **StatsView.swift**        | **统计界面**。包含 Day/Week/Month 三种视图的切换逻辑、日历导航系统以及热力图的渲染逻辑。 |
| **SettingsView.swift**     | **设置界面**。管理用户偏好设置（如开机自启、时长设置），使用 `AppStorage` 存储配置。 |
| **CustomComponents.swift** | **UI 组件库**。包含自定义的滑块 (带触感反馈)、分段控制器 (Segmented Control)、步进器 (Stepper) 以及快捷键录制器。 |
| **GlobalHotKey.swift**     | **底层工具类**。使用 macOS Carbon API 实现全局键盘事件监听，支持后台触发快捷键。 |

### 🔨 本地构建

1.  确保安装了 Xcode 14.0 或更高版本。
2.  打开 `MyClock.xcodeproj`。
3.  等待 Swift Package 依赖解析完成（本项目无第三方依赖，纯原生）。
4.  *(可选)* 若要修改 Dock 显示行为，请在 `Info.plist` 中调整 `Application is agent (UIElement)`。
5.  按下 `Cmd + R` 运行，或选择 Product -> Archive 进行打包。

---

<a id="english-version"></a>

⚠️ **Disclaimer:**
 This project was built entirely by **Gemini** within **2 hours**, including the code, export, README, and logo. The initial UI style and basic features were inspired by the Xiaohongshu creator **“卡夫卡”** (ID: **174973146**).

## 🇺🇸 English Version

**MyClock** is a minimalist Pomodoro timer designed specifically for macOS. Living in your menu bar, it offers a silky-smooth native experience, powerful statistics, and full customization to help you stay focused and track your productivity.

### ✨ Key Features

* **Native Experience**: Built with SwiftUI and AppKit, perfectly blending with macOS design language (Dark Mode supported).
* **Distraction-Free Design**:
  * **Dock-less**: Runs as an Agent App (`LSUIElement`), living exclusively in the menu bar without cluttering your Dock.
  * **Status Bar Info**: Icon and countdown timer are always visible at the top of your screen.
* **Minimalist Control**:
  * Drag the slider to quickly set focus duration (1-90 mins).
  * Slider interactions include Haptic Feedback.
  * "Skip" functionality that records actual focus time automatically.
* **Visual Statistics**:
  * **Day View**: Detailed timeline list of your sessions.
  * **Week View**: Dynamic bar chart for weekly overview.
  * **Month View**: GitHub-style Heatmap with interactive date selection.
  * **Calendar Navigation**: Switch dates/weeks/months easily or jump to a specific date via the calendar picker.
* **Efficiency First**:
  * **Global Shortcut**: Start/Pause anytime with `Cmd + E` (customizable).
  * **Auto Flow**: Automatically starts a break after focus, and resets after the break.
* **Data Privacy**: All data is stored locally (`~/Documents/flowclone_history.json`). No internet connection required.

### 📥 Installation & Usage

#### Install via DMG

1.  Download the **`MyClock.dmg`** file from the Releases section.
2.  Open the `.dmg` and drag the **MyClock** app into your **Applications** folder.
3.  Double-click to launch (close the warning dialog if it says it cannot be opened).
4.  **⚠️ Granting Permission (First Launch Only)**:
    * Open **System Settings** -> **Privacy & Security**.
    * Scroll down to the "Security" section.
    * Look for a message saying "MyClock was blocked because it is not from an identified developer".
    * Click the **"Open Anyway"** button.
    * Confirm by entering your password or Touch ID and clicking **"Open"**.
    * Subsequent launches can be done normally.

#### User Guide

* Click the menu bar icon (Timer/Coffee Cup) to open the main window.
* **Start/Pause**: Click the play button or use the global hotkey.
* **Settings**: Click the gear icon to configure "Launch at Login", "Global Shortcuts", "Default Durations", and "Sound Effects".
* **Note**: Focus sessions shorter than 5 minutes are not counted toward the total duration.

### 📂 File Structure Explained

For developers, here is an overview of the source code structure:

| File Name                  | Description                                                  |
| :------------------------- | :----------------------------------------------------------- |
| **MyClockApp.swift**       | **App Entry Point**. Manages the `AppDelegate`, initializes the Menu Bar Item and Popover window, and handles app lifecycle. |
| **TimerManager.swift**     | **Core Logic**. Handles timer state, countdown logic, data models (`SessionRecord`), and local data persistence (JSON I/O). |
| **ControlsView.swift**     | **Main Interface**. Contains the countdown display, custom slider (MinimalSlider), and playback controls (Play/Pause/Skip/Reset). |
| **StatsView.swift**        | **Statistics Interface**. Manages the logic for Day/Week/Month views, calendar navigation, and heatmap rendering. |
| **SettingsView.swift**     | **Settings Interface**. Manages user preferences using `AppStorage`. |
| **CustomComponents.swift** | **UI Components**. Contains custom-built UI elements like the Haptic Slider, Segmented Control, Stepper, and Shortcut Recorder. |
| **GlobalHotKey.swift**     | **Utility Class**. Implements global keyboard shortcut monitoring using the macOS Carbon API. |

### 🔨 Build from Source

1.  Ensure you have Xcode 14.0 or later installed.
2.  Open `MyClock.xcodeproj`.
3.  Wait for indexing (No 3rd-party dependencies required).
4.  Press `Cmd + R` to run, or select Product -> Archive to build a release version.

---

© 2025 MyClock Project.
