//
//  IntraGraphView.swift
//  OMSwiftUI
//
//  Created by André Hartman on 14/10/2020.
//  Copyright © 2020 André Hartman. All rights reserved.
//
import SwiftUI
import SwiftUICharts

struct IntraGraphView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var showGraphView: Bool

    let data: MultiLineChartData = makeData()
    let extraLineData = makeExtra()
    static var yLabelsNumber = 10

    var body: some View {
        NavigationView {
            VStack {
                MultiLineChart(chartData: data)
                    .extraLine(chartData: data,
                               legendTitle: "Index",
                               datapoints: extraLineData,
                               style: extraLineStyle)
                    // .pointMarkers(chartData: data)
                    .xAxisGrid(chartData: data)
                    .yAxisGrid(chartData: data)
                    .xAxisLabels(chartData: data)
                    .yAxisLabels(chartData: data, specifier: "%.2f")
                    .extraYAxisLabels(chartData: data, colourIndicator: .style(size: 12))
                    .legends(chartData: data, columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())])
                    .id(data.id)
                    .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 500, maxHeight: 600, alignment: .center)
                    .navigationBarTitle("Intraday waarde", displayMode: .inline)
                    .navigationBarItems(leading:
                        Button(action: { showGraphView = false })
                            { Image(systemName: "table") })
            }
        }
    }

    private var extraLineStyle: ExtraLineStyle {
        ExtraLineStyle(lineColour: ColourStyle(colour: .black),
                       lineType: .line,
                       lineSpacing: .line,
                       yAxisTitle: "Index",
                       yAxisNumberOfLabels: IntraGraphView.yLabelsNumber,
                       animationType: .raise,
                       baseline: .minimumValue)
    }

    static func makeData() -> MultiLineChartData {
        let data = ViewModel().intraday.graphDataL
        let gridStyle = GridStyle(numberOfLines: yLabelsNumber,
                                  lineColour: Color.gray.opacity(0.75))

        return MultiLineChartData(dataSets: data,
                                  chartStyle: LineChartStyle(xAxisGridStyle: gridStyle,
                                                             xAxisLabelsFrom: .dataPoint(rotation: .degrees(-90)),
                                                             xAxisTitle: "Datums",
                                                             yAxisGridStyle: gridStyle,
                                                             yAxisNumberOfLabels: yLabelsNumber,
                                                             yAxisTitle: "Mutatie in €",
                                                             baseline: .minimumValue,
                                                             topLine: .maximumValue))
    }

    static func makeExtra() -> [ExtraLineDataPoint] {
        return ViewModel().intraday.extraLine
    }
}

/*
 struct IntraGraphView_Previews: PreviewProvider {
     @EnvironmentObject var viewModel: ViewModel
     @Binding var showGraphView: Bool

     static var previews: some View {
         IntraGraphView( showGraphView = false )
             .preferredColorScheme(.dark)
     }
 }
 */
