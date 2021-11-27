//
//  InterGraph.swift
//  OMSwiftUI
//
//  Created by André Hartman on 14/10/2020.
//  Copyright © 2020 André Hartman. All rights reserved.
//
import Charts
import SwiftUI
import SwiftUICharts

struct InterGraphView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var showGraphView: Bool

    let data = makeData()
    let extraLineData = makeExtra()

    var body: some View {
        NavigationView {
            StackedBarChart(chartData: data)
                .extraLine(chartData: data,
                           legendTitle: "Index",
                           datapoints: extraLineData,
                           style: extraLineStyle)
                .xAxisGrid(chartData: data)
                .xAxisLabels(chartData: data)
                .yAxisGrid(chartData: data)
                .yAxisLabels(chartData: data)
                .extraYAxisLabels(chartData: data, colourIndicator: .style(size: 12))
                .legends(chartData: data, columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())])
                .padding(.horizontal,10)
                //.frame(minWidth: 150, maxWidth: 400, minHeight: 150, idealHeight: 500, maxHeight: 600, alignment: .center)
                .navigationBarTitle("Interday waarde", displayMode: .inline)
                .navigationBarItems(leading:
                    Button(action: { showGraphView = false })
                        { Image(systemName: "table") })
        }
    }

    private var extraLineStyle: ExtraLineStyle {
        ExtraLineStyle(lineColour: ColourStyle(colour: .black),
                       lineType: .line,
                       lineSpacing: .bar,
                       yAxisTitle: "Index",
                       yAxisNumberOfLabels: 10,
                       animationType: .raise,
                       baseline: .minimumValue)
    }

    static func makeData() -> StackedBarChartData {
        enum Group {
            case call
            case put

            var data: GroupingData {
                switch self {
                case .call:
                    return GroupingData(title: "Call", colour: ColourStyle(colour: .red))
                case .put:
                    return GroupingData(title: "Put", colour: ColourStyle(colour: .blue))
                }
            }
        }

        let data = ViewModel().interday.interGraph
        let groups = [Group.call.data, Group.put.data]
        let gridStyle = GridStyle(numberOfLines: 5,
                                  lineColour: Color.gray.opacity(0.75))

        return StackedBarChartData(dataSets: data,
                                   groups: groups,
                                   barStyle: BarStyle(barWidth: 0.5),
                                   chartStyle: BarChartStyle(
                                       xAxisGridStyle: gridStyle,
                                       xAxisLabelsFrom: .dataPoint(rotation: .degrees(-90)),
                                       yAxisGridStyle: gridStyle,
                                       yAxisNumberOfLabels: 10,
                                       baseline: .zero))
    }

    static func makeExtra() -> [ExtraLineDataPoint] {
        return ViewModel().interday.extraLine
    }
}

/*
 struct InterGraphView_Previews: PreviewProvider {
     static var previews: some View {
         InterGraphView()
     }
 }
 */
