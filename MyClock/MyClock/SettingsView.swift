import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("globalHotkeyEnabled") private var globalHotkeyEnabled = true
    
    // 只保留结束提示音开关
    @AppStorage("enableEndSound") private var enableEndSound = true
    
    @AppStorage("shortBreakDuration") private var shortBreakDuration = 5.0
    @AppStorage("defaultFocusDuration") private var defaultFocusDuration = 25.0
    @AppStorage("hotkeyChar") private var hotkeyChar = "E"
    
    var onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Button(action: { onBack() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                }
                .buttonStyle(.plain)
                .frame(width: 44, height: 44, alignment: .leading)
                
                Spacer()
                Text("Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .background(Color.black.opacity(0.2))
            
            ScrollView {
                VStack(spacing: 20) {
                    // 1. 常规
                    SettingsGroup(title: "GENERAL") {
                        ToggleRow(title: "Launch at Login", isOn: $launchAtLogin)
                            .onChange(of: launchAtLogin) { _, newValue in
                                toggleLaunch(newValue)
                            }
                    }
                    
                    // 2. 声音 (SOUNDS)
                    SettingsGroup(title: "SOUNDS") {
                        ToggleRow(title: "Notification (Ding)", isOn: $enableEndSound)
                    }
                    
                    // 3. 计时器
                    SettingsGroup(title: "TIMER") {
                        HStack {
                            Text("Default Focus")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                            Spacer()
                            CustomStepper(value: $defaultFocusDuration, range: 1...90, step: 5)
                        }
                        
                        Divider().background(Color.gray.opacity(0.2))
                        
                        HStack {
                            Text("Break Duration")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                            Spacer()
                            CustomStepper(value: $shortBreakDuration, range: 1...15)
                        }
                    }
                    
                    // 4. 快捷键
                    SettingsGroup(title: "SHORTCUTS") {
                        ToggleRow(title: "Global Shortcut", isOn: $globalHotkeyEnabled)
                        
                        if globalHotkeyEnabled {
                            Divider().background(Color.gray.opacity(0.2))
                            
                            HStack {
                                Text("Customize")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                Spacer()
                                ShortcutRecorder(key: $hotkeyChar)
                            }
                            .frame(height: 30)
                        }
                    }
                    
                    Spacer()
                    
                    Text("FlowClone v1.6")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.4))
                        .padding(.top, 10)
                }
                .padding(20)
            }
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
    }
    
    func toggleLaunch(_ enabled: Bool) {
        do {
            if enabled { try SMAppService.mainApp.register() }
            else { try SMAppService.mainApp.unregister() }
        } catch { print(error) }
    }
}

// --- 辅助组件 ---

struct SettingsGroup<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray.opacity(0.7))
                .padding(.leading, 5)
            
            // 容器
            VStack(spacing: 12) {
                content
            }
            .padding(15)
            .frame(maxWidth: .infinity) // 确保容器占满宽度
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

// 【核心修改点】使用 HStack + Spacer 强制两端对齐
struct ToggleRow: View {
    var title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            // 左侧文字
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 14))
            
            Spacer() // 强行撑开
            
            // 右侧开关
            Toggle("", isOn: $isOn)
                .labelsHidden() // 隐藏 Toggle 自带的标签占位
                .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.29, green: 0.85, blue: 0.59)))
        }
    }
}
