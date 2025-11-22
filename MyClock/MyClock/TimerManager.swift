import SwiftUI
import Combine

enum TimerMode {
    case focus
    case shortBreak
}

struct SessionRecord: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let duration: TimeInterval
}

class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval
    @Published var isRunning: Bool = false
    
    @Published var targetDurationMinutes: Double = 25 {
        didSet {
            if !isRunning && currentMode == .focus {
                timeRemaining = targetDurationMinutes * 60
            }
        }
    }
    
    @Published var currentMode: TimerMode = .focus
    @Published var sessions: [SessionRecord] = []
    
    private var timer: AnyCancellable?
    private let dataFileName = "flowclone_history.json"
    
    init() {
        let defaultDuration = UserDefaults.standard.double(forKey: "defaultFocusDuration")
        let initialDuration = defaultDuration > 0 ? defaultDuration : 25.0
        
        self.targetDurationMinutes = initialDuration
        self.timeRemaining = initialDuration * 60
        
        loadSessions()
    }
    
    func toggleTimer() {
        if isRunning { pause() } else { start() }
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.completeSession()
                }
            }
    }
    
    func pause() {
        isRunning = false
        timer?.cancel()
    }
    
    func reset() {
        pause()
        currentMode = .focus
        
        let defaultDuration = UserDefaults.standard.double(forKey: "defaultFocusDuration")
        let finalDuration = defaultDuration > 0 ? defaultDuration : 25.0
        
        self.targetDurationMinutes = finalDuration
        withAnimation {
            timeRemaining = finalDuration * 60
        }
    }
    
    func skip() {
        completeSession()
    }
    
    private func completeSession() {
        pause()
        
        let soundEnabled = UserDefaults.standard.object(forKey: "enableEndSound") as? Bool ?? true
        if soundEnabled {
            NSSound(named: "Glass")?.play()
        }
        
        if currentMode == .focus {
            let totalSeconds = targetDurationMinutes * 60
            let elapsedSeconds = max(0, totalSeconds - timeRemaining)
            
            if elapsedSeconds >= 300 {
                let record = SessionRecord(date: Date(), duration: elapsedSeconds)
                sessions.append(record)
                saveSessions()
            }
            
            let breakDuration = UserDefaults.standard.double(forKey: "shortBreakDuration")
            let finalBreak = breakDuration > 0 ? breakDuration : 5.0
            
            currentMode = .shortBreak
            timeRemaining = finalBreak * 60
            start()
        } else {
            currentMode = .focus
            let defaultDuration = UserDefaults.standard.double(forKey: "defaultFocusDuration")
            let finalDuration = defaultDuration > 0 ? defaultDuration : 25.0
            targetDurationMinutes = finalDuration
            timeRemaining = finalDuration * 60
        }
    }
    
    // MARK: - Data Persistence
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func getFileUrl() -> URL {
        return getDocumentsDirectory().appendingPathComponent(dataFileName)
    }
    
    private func saveSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            try data.write(to: getFileUrl(), options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Failed to save data: \(error.localizedDescription)")
        }
    }
    
    private func loadSessions() {
        let url = getFileUrl()
        if let data = try? Data(contentsOf: url) {
            if let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data) {
                self.sessions = decoded
                return
            }
        }
        
        if let oldData = UserDefaults.standard.data(forKey: "FlowCloneSessions"),
           let decoded = try? JSONDecoder().decode([SessionRecord].self, from: oldData) {
            self.sessions = decoded
            saveSessions()
        }
    }
    
    // MARK: - Stats Helpers
    
    func getMinutes(for date: Date) -> Int {
        let calendar = Calendar.autoupdatingCurrent
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return 0 }
        
        let daySessions = sessions.filter { $0.date >= startOfDay && $0.date < endOfDay }
        let totalSeconds = daySessions.reduce(0) { $0 + $1.duration }
        return Int(totalSeconds / 60)
    }
    
    var todayTotalMinutes: Int {
        return getMinutes(for: Date())
    }
    
    func getIntensity(for date: Date) -> Double {
        let mins = getMinutes(for: date)
        let maxMinutes: Double = 240
        var intensity = Double(mins) / maxMinutes
        if intensity > 0 && intensity < 0.2 { intensity = 0.2 }
        return min(intensity, 1.0)
    }
    
    func getMinutesForWeek(containing date: Date) -> Int {
        let calendar = Calendar.autoupdatingCurrent
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        components.weekday = 2 // Monday
        guard let startOfWeek = calendar.date(from: components) else { return 0 }
        
        var total = 0
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                total += getMinutes(for: day)
            }
        }
        return total
    }
    
    // 【修改点】这里改为了返回 Int (分钟)，而不是 Double (小时)
    func getMinutesForMonth(containing date: Date) -> Int {
        let calendar = Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let startOfMonth = calendar.date(from: components) else { return 0 }
        guard let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else { return 0 }
        
        let monthSessions = sessions.filter { $0.date >= startOfMonth && $0.date < endOfMonth }
        let totalSeconds = monthSessions.reduce(0) { $0 + $1.duration }
        return Int(totalSeconds / 60) // 返回分钟数
    }
    
    // Helper for WeekView chart
    func getDataForDayOfWeek(dayIndex: Int) -> (minutes: Int, isToday: Bool) {
        let calendar = Calendar.autoupdatingCurrent
        let today = Date()
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2
        guard let startOfWeek = calendar.date(from: components) else { return (0, false) }
        guard let targetDate = calendar.date(byAdding: .day, value: dayIndex, to: startOfWeek) else { return (0, false) }
        let isToday = calendar.isDateInToday(targetDate)
        let startOfDay = calendar.startOfDay(for: targetDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return (0, isToday) }
        let daySessions = sessions.filter { $0.date >= startOfDay && $0.date < endOfDay }
        let totalSeconds = daySessions.reduce(0) { $0 + $1.duration }
        return (Int(totalSeconds / 60), isToday)
    }
    
    var currentWeekTotalMinutes: Int {
        var total = 0
        for i in 0..<7 { total += getDataForDayOfWeek(dayIndex: i).minutes }
        return total
    }
    
    var currentMonthTotalMinutes: String {
        let calendar = Calendar.autoupdatingCurrent
        let now = Date()
        let currentMonthSessions = sessions.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
        let totalSeconds = currentMonthSessions.reduce(0) { $0 + $1.duration }
        let hours = Double(totalSeconds) / 3600.0
        return String(format: "%.1f", hours)
    }
}
