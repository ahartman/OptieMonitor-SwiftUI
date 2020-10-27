//
//  OptieMonitorApp.swift
//  OptieMonitor
//
//  Created by André Hartman on 27/10/2020.
//

import SwiftUI

@main
struct OptieMonitorApp: App {
    var viewModel = ViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewModel)
        }
    }
}
