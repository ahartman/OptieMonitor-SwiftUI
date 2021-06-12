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
                    List{
                        Section(
                            header: HeaderView(),
                            footer: FooterView(footerLines: self.viewModel.intraFooter)
                        )
                        {ForEach(self.viewModel.intraLines, id:\.id) {quote in
                            RowView(quote: quote)}}
                    }
                    .listStyle(GroupedListStyle())
                    .environment(\.defaultMinListRowHeight, 10)
                    .navigationBarTitle("Intraday (\(UIApplication.appVersion!))", displayMode: .inline)
                    .navigationBarItems(
                        trailing:
                            Button(action: {self.showGraphView.toggle()})
                                {Image(systemName: "chart.bar")}
                    )
                    .onTapGesture(count: 1)
                        {viewModel.generateData(action: "currentOrder")}
                    .onLongPressGesture(minimumDuration: 1)
                        {viewModel.generateData(action: "cleanOrder")}
                }
            }
            .onChange(of: scenePhase) { (phase) in
                switch phase {
                case .active:
                    viewModel.generateData(action: "currentOrder")
                case .background:
                    _ = 0
                case .inactive:
                    _ = 0
                @unknown default: print("ScenePhase: unexpected state")
                }
            }
            .alert(isPresented: self.$viewModel.isMessage) {
                Alert(title: Text("AEX"),
                      message: Text(self.viewModel.message ?? ""),
                      dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showGraphView) {
                IntraGraphView(showGraphView: self.$showGraphView)}
    }
}


struct IntradayView_Previews: PreviewProvider {
    static let viewModel = ViewModel()
    static var previews: some View {
        IntradayView().environmentObject(viewModel)
    }
}
