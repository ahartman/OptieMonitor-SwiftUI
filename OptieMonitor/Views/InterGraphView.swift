//
//  InterGraph.swift
//  OMSwiftUI
//
//  Created by André Hartman on 14/10/2020.
//  Copyright © 2020 André Hartman. All rights reserved.
//
import SwiftUI
import Charts
import Shapes

struct InterGraphView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var showGraphView: Bool

    var body: some View {
        GeometryReader{ geometry in
            NavigationView {
                HStack{
                   ZStack {
                        Chart(data: self.viewModel.interGraph["columns"] as! [[CGFloat]])
                            .chartStyle(
                                StackedColumnChartStyle(colors: [.green, .blue])
                            )
                            .background(
                                Color.gray.opacity(0.1)
                                    .overlay(
                                        GridPattern(horizontalLines: 5)
                                            .inset(by: 1)
                                            .stroke(Color.red.opacity(0.2), style: .init(lineWidth: 1, lineCap: .round))
                                    )
                            )
                        Chart(data: [CGFloat(0.5),CGFloat(0.5)])
                            .chartStyle(
                                LineChartStyle(.line, lineColor: .black, lineWidth: 1)
                            )
                        Chart(data: self.viewModel.interGraph["line"] as! [CGFloat])
                            .chartStyle(
                                LineChartStyle(.line, lineColor: .red, lineWidth: 2)
                            )
                    }
                    .cornerRadius(16)
                   .padding()
                }
                .navigationBarTitle("Grafiek", displayMode: .inline)
                .navigationBarItems(trailing:
                                        Button(action: {
                                            self.showGraphView = false
                                        })
                                        {Image(systemName: "table")})
           }
        }
    }
}

/*
 struct InterGraphView_Previews: PreviewProvider {
 static var previews: some View {
 InterGraphView()
 }
 }
 */
