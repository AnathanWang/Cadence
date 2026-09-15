//
//  CadenceApp.swift
//  Cadence
//
//  Created by Arseny Solyanov on 9/15/26.
//

import SwiftUI
import SwiftData

@main
struct CadenceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Habir.self)
    }
}
