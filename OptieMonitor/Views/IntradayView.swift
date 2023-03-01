//
//  QuotesView.swift
//  OMSwiftUI
//
//  Created by André Hartman on 01/07/2020.
//  Copyright © 2020 André Hartman. All rights reserved.
//
import SwiftUI

struct IntradayView: View {
    @EnvironmentObject var model: ViewModel
    @State private var showGraphSheet = false
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(
                        header: HeaderView(),
                        footer: FooterView(footerLines: model.intraday.footer)
                    ) { ForEach(model.intraday.list, id: \.id) {
                        line in
                        RowView(line: line)
                    }
                    }
                }
                .listStyle(GroupedListStyle())
                .environment(\.defaultMinListRowHeight, 10)
                .navigationBarTitle("Intraday (\(UIApplication.appVersion!))", displayMode: .inline)
                .navigationBarItems(
                    leading:
                    Button(action: { showGraphSheet.toggle() })
                        { Image(systemName: "chart.bar") },
                    trailing:
                    Button(action: { Task {
                        await model.getJsonData(action: "cleanOrder")
                    }})
                        { Image(systemName: "arrow.clockwise") }
                )
                .refreshable {
                    await model.getJsonData(action: "currentOrder")
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                Task {
                    print("IntradayView:50")
                    await model.getJsonData(action: "currentOrder")
                }
            } else {
                print("ScenePhase: unexpected state")
            }
        }
        .alert(isPresented: self.$model.isMessage) {
            Alert(title: Text("AEX"),
                  message: Text(model.message ?? ""),
                  dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showGraphSheet) {
            IntraGraphView()
        }
    }
}

/*
 struct IntradayView_Previews: PreviewProvider {
 static let viewModel = ViewModel()
 static var previews: some View {
 IntradayView().environmentObject(viewModel)
 }
 }
 */
