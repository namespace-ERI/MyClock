import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var manager: TimerManager
    
    private var formattedTime: String {
        let minutes = Int(manager.timeRemaining) / 60
        let seconds = Int(manager.timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var stateText: String {
        if manager.currentMode == .shortBreak { return "Break Time" }
        return manager.isRunning ? "Focusing..." : "Ready to Flow"
    }
    
    var body: some View {
        VStack(spacing: 25) {
            // 状态
            Text(stateText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(manager.currentMode == .focus ? Color(red: 0.29, green: 0.85, blue: 0.59) : Color.orange)
                .padding(.top, 15)
            
            // 时间
            Text(formattedTime)
                .font(.system(size: 70, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.white)
                .contentTransition(.numericText())
                .animation(.default, value: manager.timeRemaining)
                .onTapGesture { manager.toggleTimer() }

            // 滑块区域
            if !manager.isRunning && manager.currentMode == .focus {
                MinimalSlider(
                    value: $manager.targetDurationMinutes,
                    range: 1...90,
                    accentColor: Color(red: 0.29, green: 0.85, blue: 0.59)
                )
                .padding(.horizontal, 40)
                .transition(.opacity)
            } else {
                Spacer().frame(height: 20)
            }
            
            // 底部按钮控制区
            HStack(spacing: 30) {
                // 1. 左侧：重置按钮 (Reset)
                // 只有在计时运行中，或者是休息模式时显示
                if manager.isRunning || manager.currentMode == .shortBreak {
                    Button(action: { manager.reset() }) {
                        Image(systemName: "stop.fill")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                } else {
                    // 占位符，保持中间的播放按钮居中
                    Color.clear.frame(width: 50, height: 50)
                }
                
                // 2. 中间：播放/暂停按钮 (Play/Pause)
                Button(action: { manager.toggleTimer() }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: manager.isRunning ? "pause.fill" : "play.fill")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                    }
                }
                .buttonStyle(.plain)
                
                // 3. 右侧：跳过按钮 (Skip) - 新增功能
                // 当处于专注模式且正在运行，或者处于休息模式时显示
                if manager.isRunning || manager.currentMode == .shortBreak {
                    Button(action: { manager.skip() }) {
                        Image(systemName: "forward.end.fill") // 跳过图标
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                } else {
                    // 占位符，保持对称
                    Color.clear.frame(width: 50, height: 50)
                }
            }
            .padding(.bottom, 15)
            // 给按钮容器加个固定高度，防止动画时跳动
            .frame(height: 70)
        }
        .frame(height: 290)
    }
}
