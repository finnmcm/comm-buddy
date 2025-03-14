//
//  DTCProjectApp.swift
//  DTCProject
//
//  Created by Finn McMillan on 2/18/25.
//

import SwiftUI
import SwiftData

@main
struct DTCProjectApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Settings.self])
            let container = try! ModelContainer(for: schema)
            return container
        }()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Settings.self)
                .onAppear {
                      //  ensureDefaultSettings()
                                }
        }
    }
    private func ensureDefaultSettings() {
            let context = sharedModelContainer.mainContext
        let fetchDescriptor = FetchDescriptor<Settings>()

            if (try? context.fetch(fetchDescriptor))?.isEmpty ?? true {
                let defaultSettings = Settings(yesSound: "yes-female", noSound: "no-female", yesIcon: "yes-face", noIcon: "no-face")
                context.insert(defaultSettings)
                print("YES !")
                try? context.save()
            }
        }
}
