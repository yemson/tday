//
//  AddTodoModalView.swift
//  todaily
//
//  Created by 이예민 on 2022/01/18.
//

import SwiftUI

struct TodoSetting: View {
    
    @StateObject var delegate = NotificationDelegate()
    
    var body: some View {
        VStack {
            Button("Schedule Notification") {
                let content = UNMutableNotificationContent()
                content.title = "티디"
                content.subtitle = "당근 사기"
                content.sound = UNNotificationSound.default
                
                // show this notification five seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                
                // choose a random identifier
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                // add our notification request
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
}
