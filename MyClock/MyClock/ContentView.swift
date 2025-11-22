import SwiftUI

struct ContentView: View {
    // 0 = Controls, 1 = Stats, 2 = Settings
    @State private var selectedTab = 0
    @EnvironmentObject var manager: TimerManager
    
    var body: some View {
        VStack(spacing: 0) {
            // 如果是设置页面
            if selectedTab == 2 {
                // 直接传入一个闭包，当点击返回时，把 selectedTab 设回 0
                SettingsView(onBack: {
                    withAnimation { selectedTab = 0 }
                })
                .transition(.move(edge: .trailing))
            } else {
                // 标准页面 (Controls / Stats)
                VStack(spacing: 0) {
                    HStack {
                        HStack(spacing: 0) {
                            TabButton(title: "Controls", isSelected: selectedTab == 0) {
                                withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 0 }
                            }
                            TabButton(title: "Stats", isSelected: selectedTab == 1) {
                                withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 1 }
                            }
                        }
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                        .padding(12)
                        
                        Spacer()
                        
                        // 齿轮按钮
                        Button(action: {
                            withAnimation { selectedTab = 2 }
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 12)
                        
                        Button("Quit") {
                            NSApplication.shared.terminate(nil)
                        }
                        .buttonStyle(.plain)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.trailing, 15)
                    }
                    
                    ZStack {
                        if selectedTab == 0 {
                            ControlsView()
                        } else if selectedTab == 1 {
                            StatsView()
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
        .frame(width: 300, height: 360)
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
        // 全局动画配置，让页面切换更流畅
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13))
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .gray)
                .frame(width: 70)
                .padding(.vertical, 6)
                .background(isSelected ? Color.gray.opacity(0.3) : Color.clear)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}
