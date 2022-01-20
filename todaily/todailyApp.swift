//
//  todailyApp.swift
//  todaily
//
//  Created by 이예민 on 2022/01/17.
//

import SwiftUI

@main
struct todailyApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
