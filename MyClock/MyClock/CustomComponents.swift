import SwiftUI
import Carbon
import AppKit

// MARK: - 1. 自定义极简滑块 (无声音，带触感反馈)
struct MinimalSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var accentColor: Color
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let percent = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
            
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1)).frame(height: 4)
                Capsule().fill(accentColor).frame(width: width * percent, height: 4)
                Circle().fill(Color.white).frame(width: 16, height: 16)
                    .shadow(radius: 2)
                    .offset(x: width * percent - 8)
                    .gesture(
                        DragGesture()
                            .onChanged { gestureValue in
                                let newPercent = min(max(0, gestureValue.location.x / width), 1)
                                let rawValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(newPercent)
                                let newValue = round(rawValue)
                                
                                if newValue != self.value {
                                    self.value = newValue
                                    NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
                                }
                            }
                    )
            }
            .frame(height: geo.size.height)
        }
        .frame(height: 20)
    }
}

// MARK: - 2. 自定义分段控制器 (缩小宽度)
struct CustomSegmentedControl: View {
    @Binding var selection: StatsMode
    var options: [StatsMode]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) { selection = option }
                }) {
                    Text(option.rawValue)
                        .font(.system(size: 11, weight: .medium)) // 稍微缩小字体
                        .foregroundColor(selection == option ? .black : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(red: 0.29, green: 0.85, blue: 0.59))
                                .opacity(selection == option ? 1 : 0)
                                .padding(2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
        // 【修改点】宽度从 160 减小到 130，为左侧标题腾出空间
        .frame(width: 130, height: 26)
    }
}

// MARK: - 3. 自定义步进器
struct CustomStepper: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double = 1
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { if value > range.lowerBound { value -= step } }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(value > range.lowerBound ? .white : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            Text("\(Int(value)) min")
                .font(.system(size: 14, weight: .medium).monospacedDigit())
                .foregroundColor(.white)
                .frame(minWidth: 50, alignment: .center)
            Button(action: { if value < range.upperBound { value += step } }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(value < range.upperBound ? .white : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - 4. 快捷键录制器
struct ShortcutRecorder: View {
    @Binding var key: String
    @State private var isRecording = false
    @State private var monitor: Any?
    
    var body: some View {
        Button(action: {
            if isRecording { stopRecording() } else { startRecording() }
        }) {
            HStack {
                Text(isRecording ? "Press key..." : "⌘ \(key)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(isRecording ? Color.black : .white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 6).fill(isRecording ? Color(red: 0.29, green: 0.85, blue: 0.59) : Color.white.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(red: 0.29, green: 0.85, blue: 0.59), lineWidth: isRecording ? 0 : 1))
        }
        .buttonStyle(.plain)
        .onDisappear { stopRecording() }
    }
    
    private func startRecording() {
        isRecording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command) || event.modifierFlags.contains(.shift) || event.modifierFlags.contains(.control) || event.modifierFlags.contains(.option) {}
            if let char = event.characters?.uppercased(), !char.isEmpty {
                if char.rangeOfCharacter(from: .alphanumerics) != nil {
                    self.key = char
                    UserDefaults.standard.set(Int(event.keyCode), forKey: "customHotKeyCode")
                    GlobalHotKeyManager.shared.reRegister()
                    stopRecording()
                    return nil
                }
            }
            return event
        }
    }
    
    private func stopRecording() {
        isRecording = false
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
