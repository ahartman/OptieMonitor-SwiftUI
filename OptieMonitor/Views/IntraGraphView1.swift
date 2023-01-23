//
//  IntraGraphView1.swift
//  OptieMonitor
//
//  Created by André Hartman on 20/01/2023.
//

import Charts
import SwiftUI

struct IntraGraphView1: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var showGraphView: Bool

    let data: [ToyShape] = [
        .init(type: "Call", time: Calendar.current.date(from: DateComponents(hour: 9))!, value: -2),
        .init(type: "Put", time: Calendar.current.date(from: DateComponents(hour: 9))!, value: 1),
        .init(type: "Call", time: Calendar.current.date(from: DateComponents(hour: 11))!, value: 0.5),
        .init(type: "Put", time: Calendar.current.date(from: DateComponents(hour: 11))!, value: -1),
        .init(type: "Call", time: Calendar.current.date(from: DateComponents(hour: 15))!, value: 1),
        .init(type: "Put", time: Calendar.current.date(from: DateComponents(hour: 15))!, value: 1)
    ]

    var body: some View {
        // let data = makeData()

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
            /*
             .chartXAxis {
                 AxisMarks(values: xValues()) { value in
                     AxisGridLine()
                     AxisValueLabel(format: .dateTime.hour(.twoDigits(amPM: .omitted)))
                 }
             }
              */
            .chartXAxisLabel("Tijd", position: .bottom)
            .chartYAxis {}
            .chartYAxisLabel("Mutatie in €", position: .leading)
            .chartForegroundStyleScale([
                "Call": .green, "Put": .purple
            ])
            .padding(20.0)
            .navigationBarTitle("Intraday waarde en index", displayMode: .inline)
            .navigationBarItems(leading:
                Button(action: { showGraphView = false })
                    { Image(systemName: "table") })
        }
    }

    func makeData() -> [ToyShape1] {
        var data = [ToyShape1]()
        data.append(ToyShape1(color: "Green", hour: TimeString("09.30"), type: "Call", value: -2.2))
        data.append(ToyShape1(color: "Green", hour: TimeString("09.30"), type: "Put", value: 1.78))
        data.append(ToyShape1(color: "Orange", hour: TimeString("10.45"), type: "Call", value: 3.0))
        data.append(ToyShape1(color: "Orange", hour: TimeString("10.45"), type: "Put", value: -1))
        // print(data)
        return data
    }

    func xValues() -> [Date] {
        var hours = [Date]()
        let calendar = Calendar.current
        for hour in stride(from: 9, to: 18, by: 1) {
            hours.append(calendar.date(from: DateComponents(hour: hour))!)
        }
        return hours
    }

    func TimeString(_ original: String) -> Date {
        print("timestring")
        let formatter = DateFormatter()
        formatter.isLenient = true
        formatter.dateFormat = "hh:mm"
        let date = formatter.date(from: original)
        return date!
    }
}

/*
 struct IntraGraphView1_Previews: PreviewProvider {
     static var previews: some View {
         IntraGraphView()
     }
 }
  */

struct ToyShape: Identifiable {
    var type: String
    var time: Date
    var value: Double
    var id = UUID()
}

struct ToyShape1: Identifiable {
    var color: String
    var hour: Date
    var type: String
    var value: Double
    var id = UUID()
}
