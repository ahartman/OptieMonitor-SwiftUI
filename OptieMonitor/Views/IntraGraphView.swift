//
//  IntraGraphView.swift
//  OMSwiftUI
//
//  Created by André Hartman on 14/10/2020.
//  Copyright © 2020 André Hartman. All rights reserved.
//
import SwiftUI
import Charts
import Shapes

struct IntraGraphView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var showGraphView: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Chart(data: viewModel.intraday.graph["call"] as! [CGFloat])
                    .chartStyle(LineChartStyle(.line, lineColor: .green, lineWidth: 2))
                Chart(data: viewModel.intraday.graph["put"] as! [CGFloat])
                    .chartStyle(LineChartStyle(.line, lineColor: .blue, lineWidth: 2))
                Chart(data: viewModel.intraday.graph["total"] as! [CGFloat])
                    .chartStyle(LineChartStyle(.line, lineColor: .red, lineWidth: 3))
                Chart(data: [CGFloat(0.5),CGFloat(0.5)])
                    .chartStyle( LineChartStyle(.line, lineColor: .black, lineWidth: 1))
                    .background(
                        Color.gray.opacity(0.1)
                            .overlay(
                                GridPattern(horizontalLines: 5)
                                    .inset(by: 1)
                                    .stroke(Color.red.opacity(0.2), style: .init(lineWidth: 1, lineCap: .round))
                            )
                    )
            }
            .cornerRadius(16)
            .padding()
            .navigationBarTitle("Grafiek", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {showGraphView = false})
                                        {Image(systemName: "table")})
        }    }
}
/*
 struct IntraGraphView_Previews: PreviewProvider {
 static var previews: some View {
 IntraGraphView()
 }
 }
 */
