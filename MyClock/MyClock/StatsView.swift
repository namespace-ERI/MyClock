import SwiftUI

enum StatsMode: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
}

struct StatsView: View {
    @EnvironmentObject var manager: TimerManager
    @State private var selectedMode: StatsMode = .week
    @State private var currentDate: Date = Date()
    @State private var showDatePicker = false
    @State private var selectedHeatmapDate: Date? = nil
    
    var body: some View {
        VStack(spacing: 15) {
            // --- 顶部导航栏 ---
            ZStack {
                Button(action: { showDatePicker.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(showDatePicker ? Color(red: 0.29, green: 0.85, blue: 0.59) : .gray)
                        
                        Text(dateTitle)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .monospacedDigit()
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showDatePicker) {
                    DatePicker("", selection: $currentDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .frame(width: 200)
                        .padding()
                }
                
                HStack {
                    Button(action: { moveDate(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.gray)
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Button(action: { moveDate(by: 1) }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 14, weight: .bold))
                                .frame(width: 24, height: 24)
                        }
                        .buttonStyle(.plain)
                        
                        if !isCurrentContext {
                            Button(action: {
                                withAnimation {
                                    currentDate = Date()
                                    selectedHeatmapDate = nil
                                }
                            }) {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                    .foregroundColor(Color(red: 0.29, green: 0.85, blue: 0.59))
                                    .font(.system(size: 16))
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(.plain)
                            .help("Return to Current")
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
            .padding(.horizontal, 25)
            .padding(.top, 15)
            
            // --- 总数据概览 ---
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayTitle)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .animation(.easeInOut(duration: 0.2), value: displayTitle)
                    
                    Text(displayValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.default, value: displayValue)
                }
                
                Spacer()
                
                CustomSegmentedControl(selection: $selectedMode, options: StatsMode.allCases)
                    .onChange(of: selectedMode) { _ in
                        selectedHeatmapDate = nil
                    }
            }
            .padding(.horizontal, 25)
            
            // --- 内容区 ---
            ZStack {
                switch selectedMode {
                case .day: DayView(date: currentDate)
                case .week: WeekView(date: currentDate)
                case .month: MonthView(currentDate: currentDate, selectedDate: $selectedHeatmapDate)
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: selectedMode)
            .id(currentDate)
            .transition(.asymmetric(insertion: .opacity, removal: .opacity))
            .animation(.easeInOut(duration: 0.2), value: currentDate)
            .frame(maxHeight: .infinity)
            
            Spacer()
        }
        .frame(height: 310)
    }
    
    // MARK: - Logic
    var isCurrentContext: Bool {
        let calendar = Calendar.autoupdatingCurrent
        let now = Date()
        switch selectedMode {
        case .day: return calendar.isDateInToday(currentDate)
        case .week: return calendar.isDate(currentDate, equalTo: now, toGranularity: .weekOfYear)
        case .month: return calendar.isDate(currentDate, equalTo: now, toGranularity: .month)
        }
    }
    
    func moveDate(by value: Int) {
        let calendar = Calendar.autoupdatingCurrent
        var component: Calendar.Component = .day
        let amount = value
        
        switch selectedMode {
        case .day: component = .day
        case .week: component = .weekOfYear
        case .month: component = .month
        }
        
        if let newDate = calendar.date(byAdding: component, value: amount, to: currentDate) {
            currentDate = newDate
            selectedHeatmapDate = nil
        }
    }
    
    var dateTitle: String {
        let formatter = DateFormatter()
        let calendar = Calendar.autoupdatingCurrent
        
        if calendar.isDateInToday(currentDate) { return "Today" }
        
        switch selectedMode {
        case .day:
            formatter.dateFormat = "MMM d, yyyy"
        case .week:
            formatter.dateFormat = "MMM d"
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)
            components.weekday = 2
            if let startOfWeek = calendar.date(from: components),
               let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) {
                return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
            }
            return "This Week"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
        }
        return formatter.string(from: currentDate)
    }
    
    var displayTitle: String {
        if selectedMode == .month, let date = selectedHeatmapDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return "FOCUS (\(formatter.string(from: date)))"
        }
        
        switch selectedMode {
        case .day: return "DAILY FOCUS"
        case .week: return "WEEKLY FOCUS"
        case .month: return "MONTHLY FOCUS"
        }
    }
    
    var displayValue: String {
        if selectedMode == .month, let date = selectedHeatmapDate {
            let mins = manager.getMinutes(for: date)
            return formatDuration(mins)
        }
        
        switch selectedMode {
        case .day:
            return formatDuration(manager.getMinutes(for: currentDate))
        case .week:
            return formatDuration(manager.getMinutesForWeek(containing: currentDate))
        case .month:
            // 【修改点】现在获取的是分钟数(Int)，并调用格式化函数
            let totalMins = manager.getMinutesForMonth(containing: currentDate)
            return formatDuration(totalMins)
        }
    }
    
    // 核心格式化逻辑
    func formatDuration(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) m"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours) h"
            } else {
                return "\(hours)h \(mins)m"
            }
        }
    }
}

// --- Subviews (保持不变) ---

struct DayView: View {
    @EnvironmentObject var manager: TimerManager
    let date: Date
    
    var sessions: [SessionRecord] {
        let calendar = Calendar.autoupdatingCurrent
        return manager.sessions
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        if sessions.isEmpty {
            VStack {
                Image(systemName: "deskclock")
                    .font(.largeTitle)
                    .foregroundColor(.gray.opacity(0.3))
                Text("No focus data")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxHeight: .infinity)
        } else {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    ForEach(sessions) { session in
                        HStack {
                            Circle().fill(Color(red: 0.29, green: 0.85, blue: 0.59)).frame(width: 6, height: 6)
                            Text(session.date, style: .time).font(.system(size: 13, design: .monospaced)).foregroundColor(.gray)
                            Spacer()
                            Text("\(Int(session.duration / 60)) min").font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 10)
            }
            .frame(maxHeight: .infinity)
        }
    }
}

struct WeekView: View {
    @EnvironmentObject var manager: TimerManager
    let date: Date
    let weekDays = ["M", "T", "W", "T", "F", "S", "S"]
    let maxChartHeight: CGFloat = 130
    
    private var weeklyChartData: [(minutes: Int, isToday: Bool)] {
        let calendar = Calendar.autoupdatingCurrent
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        components.weekday = 2
        let startOfWeek = calendar.date(from: components) ?? date
        
        return (0..<7).map { i in
            let day = calendar.date(byAdding: .day, value: i, to: startOfWeek) ?? Date()
            let mins = manager.getMinutes(for: day)
            let isRealToday = calendar.isDateInToday(day)
            return (mins, isRealToday)
        }
    }
    
    private var scaleBase: CGFloat {
        let maxMinutes = weeklyChartData.map { CGFloat($0.minutes) }.max() ?? 0
        return max(maxMinutes, 60.0)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(0..<7) { index in
                let data = weeklyChartData[index]
                let barHeight = (CGFloat(data.minutes) / scaleBase) * maxChartHeight
                
                VStack(spacing: 6) {
                    Spacer()
                    RoundedRectangle(cornerRadius: 4)
                        .fill(data.isToday ? Color(red: 0.29, green: 0.85, blue: 0.59) : Color.gray.opacity(0.3))
                        .frame(height: data.minutes > 0 ? max(4, barHeight) : 4)
                        .frame(maxWidth: 20)
                    Text(weekDays[index]).font(.caption2).foregroundColor(data.isToday ? .white : .gray)
                }
            }
        }
        .padding(.horizontal, 25)
        .padding(.bottom, 10)
        .frame(height: 160)
    }
}

struct MonthView: View {
    @EnvironmentObject var manager: TimerManager
    let currentDate: Date
    @Binding var selectedDate: Date?
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(generateMonthGrid(), id: \.self) { date in
                let intensity = manager.getIntensity(for: date)
                let isToday = Calendar.autoupdatingCurrent.isDateInToday(date)
                let isSelected = selectedDate != nil && Calendar.autoupdatingCurrent.isDate(date, inSameDayAs: selectedDate!)
                let isCurrentMonth = Calendar.autoupdatingCurrent.isDate(date, equalTo: currentDate, toGranularity: .month)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(intensity == 0 ? Color.white.opacity(0.1) : Color(red: 0.29, green: 0.85, blue: 0.59).opacity(0.3 + intensity * 0.7))
                    .opacity(isCurrentMonth ? 1.0 : 0.3)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(
                                isSelected ? Color(red: 0.29, green: 0.85, blue: 0.59) : (isToday ? Color.white.opacity(0.8) : Color.clear),
                                lineWidth: isSelected ? 2 : (isToday ? 1.5 : 0)
                            )
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            if let current = selectedDate, Calendar.autoupdatingCurrent.isDate(current, inSameDayAs: date) {
                                selectedDate = nil
                            } else {
                                selectedDate = date
                            }
                        }
                    }
            }
        }
        .padding(.horizontal, 25)
    }
    
    func generateMonthGrid() -> [Date] {
        let calendar = Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        let startOfMonth = calendar.date(from: components) ?? currentDate
        
        var startWeekComp = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startOfMonth)
        startWeekComp.weekday = 2
        let startGridDate = calendar.date(from: startWeekComp) ?? startOfMonth
        
        var dates: [Date] = []
        for i in 0..<35 {
            if let d = calendar.date(byAdding: .day, value: i, to: startGridDate) {
                dates.append(d)
            }
        }
        return dates
    }
}
