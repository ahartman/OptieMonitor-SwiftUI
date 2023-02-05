//
//  InterGraph.swift
//  OMSwiftUI
//
//  Created by André Hartman on 14/10/2020.
//  Copyright © 2020 André Hartman. All rights reserved.
//
import Charts
import SwiftUI

struct InterGraphView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var showGraphView: Bool

    var body: some View {
        NavigationView {
            Chart {
                ForEach(viewModel.interday.graph, id: \.self) { element in
                    BarMark(
                        x: .value("Datum", element.dateTime),
                        y: .value("Waarde in €", element.value)
                    )
                    .foregroundStyle(by: .value("Type Color", element.type))
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel(
                        format: .dateTime.day(.twoDigits).month(.twoDigits),
                        centered: false,
                        collisionResolution: .automatic
                    )
                }
            }
            .chartXAxisLabel("Datum", position: .bottom)
            .chartYAxis {
                AxisMarks(preset: .aligned, position: .leading, values: viewModel.interday.yValues) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .currency(code: "EUR").precision(.fractionLength(0)))
                }
            }
            .chartYAxisLabel("Waarde in €", position: .leading)
            .chartForegroundStyleScale(
                ["Call": .green, "Put": .purple]
            )
            .padding(20.0)
            .navigationBarTitle("Interday waarde ", displayMode: .inline)
            .navigationBarItems(leading:
                Button(action: { showGraphView = false })
                    { Image(systemName: "table") })
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
