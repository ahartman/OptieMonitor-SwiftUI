//
//  IntraGraphView1.swift
//  OptieMonitor
//
//  Created by André Hartman on 20/01/2023.
//

import Charts
import SwiftUI

struct IntraGraphView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var showGraphView: Bool
 
    var body: some View {
        NavigationView {
            Chart {
                ForEach(viewModel.intradayGraph, id: \.self) { line in
                    BarMark(
                        x: .value("Uur", line.dateTime),
                        y: .value("Mutatie in €", line.value)
                    )
                    .foregroundStyle(by: .value("Type Color", line.type))
                }
            }
            .chartXAxis() {
                AxisMarks(values: xValues()) { _ in
                    AxisGridLine()
                    AxisValueLabel(centered: false, collisionResolution: .automatic)
                }
            }
            .chartXAxisLabel("Tijd", position: .bottom)
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .currency(code: "EUR").precision(.fractionLength(0)))
                }
            }
            .chartYAxisLabel("Mutatie in €", position: .leading)
            .chartForegroundStyleScale(
                ["Call": .green, "Put": .purple]
            )
            .padding(20.0)
            .navigationBarTitle("Intraday waarde en index", displayMode: .inline)
            .navigationBarItems(leading:
                Button(action: { showGraphView = false })
                    { Image(systemName: "table") })
        }
    }

    func xValues() -> [Date] {
        var localHours = [Date]()
        let calendar = Calendar.current
        let date = quoteDatetime ?? Date()
        var components = calendar.dateComponents(in: TimeZone.current, from: date)
        components.minute = 0
        components.second = 0

        for hour in stride(from: 9, through: 18, by: 1) {
            components.hour = hour
            localHours.append(calendar.date(from: components)!)
        }
        return localHours
    }
}

/*
 struct IntraGraphView1_Previews: PreviewProvider {
     static var previews: some View {
         IntraGraphView()
     }
 }
 */
