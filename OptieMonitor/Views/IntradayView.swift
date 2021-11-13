//
//  QuotesView.swift
//  OMSwiftUI
//
//  Created by André Hartman on 01/07/2020.
//  Copyright © 2020 André Hartman. All rights reserved.
//
import SwiftUI

struct IntradayView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var showGraphView = false
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(
                        header: HeaderView(),
                        footer: FooterView(footerLines: viewModel.intraday.footer)
                    )
                        { ForEach(viewModel.intraday.list, id: \.id) { quote in
                            RowView(quote: quote)
                        }}
                }
                .listStyle(GroupedListStyle())
                .environment(\.defaultMinListRowHeight, 10)
                .navigationBarTitle("Intraday (\(UIApplication.appVersion!))", displayMode: .inline)
                .navigationBarItems(
                    leading:
                    Button(action: { showGraphView.toggle() })
                        { Image(systemName: "chart.bar") },
                    trailing:
                    Button(action: { Task {
                        await viewModel.getJsonData(action: "cleanOrder")
                    }})
                        { Image(systemName: "arrow.clockwise") }
                )
                .refreshable {
                    await viewModel.getJsonData(action: "currentOrder")
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                Task {
                    await viewModel.getJsonData(action: "currentOrder")
                }
            } else {
                print("ScenePhase: unexpected state")
            }
        }
        .alert(isPresented: self.$viewModel.isMessage) {
            Alert(title: Text("AEX"),
                  message: Text(viewModel.message ?? ""),
                  dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showGraphView) {
            IntraGraphView(showGraphView: $showGraphView)
        }
    }
}

struct IntradayView_Previews: PreviewProvider {
    static let viewModel = ViewModel()
    static var previews: some View {
        Group {
            IntradayView().environmentObject(viewModel).previewInterfaceOrientation(.landscapeRight)
        }
    }
}
