//
//  IntraGraphView1.swift
//  OptieMonitor
//
//  Created by André Hartman on 20/01/2023.
//

import Charts
import SwiftUI

struct IntraGraphView: View {
    @EnvironmentObject var model: ViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Chart {
                ForEach(model.intraday.grafiekWaarden.filter { $0.type != "Index" }, id: \.self) { element in
                    BarMark(
                        x: .value("Uur", element.datumTijd),
                        y: .value("Mutatie in €", element.waarde)
                    )
                    .foregroundStyle(by: .value("Type Color", element.type))
                }
                ForEach(model.intraday.grafiekWaarden.filter { $0.type == "Index" }, id: \.self) { element in
                    LineMark(
                        x: .value("Uur", element.datumTijd),
                        y: .value("Index", element.waarde)
                    )
                    .foregroundStyle(by: .value("Type Color", element.type))
                }
            }

            .chartXAxis {
                AxisMarks(values: xValues()) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour().locale(Locale(identifier: "en-GB")), centered: false, collisionResolution: .greedy)

                }
            }
            .chartXAxisLabel("Tijd", position: .bottom)

            .chartYAxis {
                AxisMarks(preset: .aligned, position: .leading, values: model.intraday.grafiekAssen["Euro"] ?? [0.0]) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .currency(code: "EUR").precision(.fractionLength(0)), centered: false)
                }
                AxisMarks(preset: .aligned, position: .trailing, values: model.intraday.grafiekAssen["Index"] ?? [0.0]) { _ in
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartYAxisLabel("Mutatie in €", position: .leading)

            .chartForegroundStyleScale(
                ["Call": .green, "Put": .purple, "Index": .blue]
            )

            .padding(20.0)
            .navigationBarTitle("Intraday waarde en index", displayMode: .inline)
            .navigationBarItems(leading:
                Button(action: { dismiss() })
                    { Image(systemName: "table") }
            )
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
