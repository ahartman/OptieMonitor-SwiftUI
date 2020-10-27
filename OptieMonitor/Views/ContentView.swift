//
//  ContentView.swift
//  OptieMonitor
//
//  Created by André Hartman on 27/10/2020.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
            TabView {
            IntradayView()
                .tabItem{
                    Image(systemName: "calendar.circle")
                    Text("Intraday")
                }
            InterdayView()
                .tabItem{
                    Image(systemName: "calendar.circle.fill")
                    Text("Interday")
                }
            SettingsView()
                .tabItem{
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static let viewModel = ViewModel()
    static var previews: some View {
        ContentView().environmentObject(viewModel)
    }
}
