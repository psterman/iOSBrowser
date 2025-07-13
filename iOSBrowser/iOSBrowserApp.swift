//
//  iOSBrowserApp.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/13.
//

import SwiftUI

@main
struct iOSBrowserApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
