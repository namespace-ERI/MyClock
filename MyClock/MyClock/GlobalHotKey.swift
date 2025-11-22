import Carbon
import SwiftUI

class GlobalHotKeyManager {
    static let shared = GlobalHotKeyManager()
    private var eventHandler: EventHandlerRef?
    var onTrigger: (() -> Void)?
    
    @AppStorage("globalHotkeyEnabled") private var isEnabled = true
    @AppStorage("customHotKeyCode") private var customKeyCode = 14 // 默认是 14 (E键)
    
    private var hotKeyRef: EventHotKeyRef?
    
    private init() {}
    
    func register() {
        // 1. 清理旧的
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
        }
        
        // 2. 注册新的 (读取用户设置的 KeyCode)
        let hotKeyID = EventHotKeyID(signature: 1, id: 1)
        // 默认 Command (cmdKey) + 用户自定义键
        RegisterEventHotKey(UInt32(customKeyCode), UInt32(cmdKey), hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        
        // 3. 只有第一次需要安装 Handler
        if eventHandler == nil {
            let eventSpec = [
                EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
            ]
            
            InstallEventHandler(GetApplicationEventTarget(), { (_, _, _) -> OSStatus in
                if GlobalHotKeyManager.shared.isEnabled {
                    DispatchQueue.main.async {
                        GlobalHotKeyManager.shared.onTrigger?()
                    }
                }
                return noErr
            }, 1, eventSpec, nil, &eventHandler)
        }
    }
    
    // 提供一个重新注册的方法，供 SettingsView 修改快捷键后调用
    func reRegister() {
        register()
    }
}
