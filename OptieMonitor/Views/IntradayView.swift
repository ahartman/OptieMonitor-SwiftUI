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
 
    var body: some View {
        GeometryReader{ geometry in
            NavigationView {
                List{
                    Section(header: HeaderView(geometry: geometry),
                            footer: FooterView(footerLine: self.viewModel.interFooter, geometry: geometry))
                    {ForEach(self.viewModel.intraInterLines, id:\.id) {quote in
                        RowView(quote: quote, geometry: geometry)}}
                    Section(header:  Text("Vandaag").modifier(TextModifier()),footer: FooterView(footerLine: self.viewModel.intraFooter, geometry: geometry))
                    {ForEach(self.viewModel.intraLines, id:\.id) {quote in
                        RowView(quote: quote, geometry: geometry)}}
                }
                .listStyle(GroupedListStyle())
                .environment(\.defaultMinListRowHeight, 10)
                .navigationBarTitle("Intraday (\(UIApplication.appVersion!))", displayMode: .inline)
                .navigationBarItems(
                    trailing:
                        Button(
                            action:
                                {self.showGraphView.toggle()})
                            {Image(systemName: "chart.bar")}
                )
                .onTapGesture(count: 1)
                    {viewModel.generateData(action: "currentOrder")}
                .onLongPressGesture(minimumDuration: 1)
                    {viewModel.generateData(action: "cleanOrder")}
                .alert(isPresented: self.$viewModel.isMessage) {
                    Alert(title: Text("AEX"),
                          message: Text(self.viewModel.message),
                          dismissButton: .default(Text("OK")))}
            }
            .sheet(isPresented: $showGraphView) {
                IntraGraphView(showGraphView: self.$showGraphView)}
        }
    }
}

struct IntradayView_Previews: PreviewProvider {
    static let viewModel = ViewModel()
    static var previews: some View {
        IntradayView().environmentObject(viewModel)
    }
}

