//
//  InterdayView.swift
//  OMSwiftUI
//
//  Created by André Hartman on 05/07/2020.
//  Copyright © 2020 André Hartman. All rights reserved.
//
import SwiftUI

struct InterdayView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var showGraphView = false

    var body: some View {
        NavigationView {
            List{
                Section(header: HeaderView(),
                        footer: FooterView(footerLines: viewModel.interday.footer))
                {
                    ForEach(self.viewModel.interday.list, id:\.id) {quote in
                        RowView(quote: quote)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.defaultMinListRowHeight, 10)
            .navigationBarTitle("Interday", displayMode: .inline)
            .navigationBarItems(
                trailing:
                    Button(action: {self.showGraphView.toggle()})
                        {Image(systemName: "chart.bar")}
            )
        }
        .sheet(isPresented: $showGraphView) {
            InterGraphView(showGraphView: self.$showGraphView)}
    }
}

struct InterdayView_Previews: PreviewProvider {
    static let viewModel = ViewModel()
    static var previews: some View {
        InterdayView().environmentObject(viewModel)
    }
}
