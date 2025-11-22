import SwiftUI
import AppKit

@main
struct MyClockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings { EmptyView() }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var timerManager = TimerManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 360)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: ContentView().environmentObject(timerManager))
        self.popover = popover
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            // 1. 始终使用同一个图标，防止宽度变化导致的窗口跳动
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
            button.imagePosition = .imageLeft
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
            button.action = #selector(togglePopover(_:))
        }
        
        updateStatusItem()
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateStatusItem()
        }
        
        GlobalHotKeyManager.shared.register()
        GlobalHotKeyManager.shared.onTrigger = { [weak self] in
            self?.timerManager.toggleTimer()
            DispatchQueue.main.async { self?.updateStatusItem() }
        }
    }
    
    func updateStatusItem() {
        guard let button = statusItem?.button else { return }
        
        let isRunning = timerManager.isRunning
        let isPopoverOpen = popover?.isShown ?? false
        
        // 2. 移除图标切换逻辑，永远保持 "timer"，解决 "跳动" 问题
        // 之前的 cup.and.saucer 比 timer 宽，所以会导致锚点位移
        
        // 文字逻辑保持不变
        if isRunning {
            let mins = Int(timerManager.timeRemaining) / 60
            let secs = Int(timerManager.timeRemaining) % 60
            button.title = String(format: " %02d:%02d", mins, secs)
        } else if isPopoverOpen {
            let targetMins = Int(timerManager.targetDurationMinutes)
            button.title = String(format: " %02d:00", targetMins)
        } else {
            button.title = ""
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem?.button {
            if let popover = popover {
                if popover.isShown {
                    popover.performClose(sender)
                } else {
                    updateStatusItem()
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                    popover.contentViewController?.view.window?.makeKey()
                }
            }
        }
    }
}
