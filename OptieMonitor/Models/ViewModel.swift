//
//  UserSettings.swift
//  OMSwiftUI
//
//  Created by André Hartman on 05/07/2020.
//  Copyright © 2020 André Hartman. All rights reserved.
//
import SwiftUI
import SwiftUICharts

@MainActor
class ViewModel: ObservableObject {
    @Published var intraday = QuotesList()
    @Published var interday = QuotesList()
    @Published var isMessage: Bool = false
    @Published var notificationSet = NotificationSetting()
    { didSet {
        notificationSetStale = true

    }}
    var message: String?
    { didSet {
        if message != nil {
            isMessage = true
        }
    }}

    init() {
        if let data = UserDefaults.standard.data(forKey: "OptieMonitor") {
            // print("UserDefaults saved data found")
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let savedData = try decoder.decode(RestData.self, from: data)
                unpackJSON(result: savedData)
            } catch {
                print("JSON error from UserDefaults:", error)
            }
        }
        Task {
            await getJsonData(action: "currentOrder")
        }
    }

    func formatDate(dateIn: Date) -> String {
        let formatter = DateFormatter()
        let dateMidnight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        formatter.dateFormat = (dateIn < dateMidnight!) ? "dd-MM" : "HH:mm"
        return formatter.string(for: dateIn)!
    }

    func formatInterGraph(lines: [QuoteLine]) -> (StackedBarDataSets, [ExtraLineDataPoint]) {
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

        var dataSets = [StackedBarDataSet]()
        var extraLineData = [ExtraLineDataPoint]()
        for line in lines {
            let dataSet = StackedBarDataSet(dataPoints: [
                            StackedBarDataPoint(value: line.callValue * line.nrContracts,group: Group.call.data),
                            StackedBarDataPoint(value: line.putValue * line.nrContracts,group: Group.put.data )],
                            setTitle: line.datetimeQuote)
            dataSets.append(dataSet)
            extraLineData.append(ExtraLineDataPoint(value: Double(line.indexValue)))
        }
        let interGraphData = StackedBarDataSets(dataSets: dataSets)

        return (interGraphData, extraLineData)
    }

    func formatIntraGraph(lines: [QuoteLine]) -> [String: Any] {
        let lineCalls = lines.compactMap { $0.callValue - lines[0].callValue }
        let linePuts = lines.compactMap { $0.putValue - lines[0].putValue }
        let lineTotals = lines.compactMap { $0.callValue + $0.putValue - lines[0].callValue - lines[0].putValue }

        let maxOfValues = 0.5/max(
            abs(lineCalls.max()!),
            abs(linePuts.max()!),
            abs(lineTotals.max()!),
            abs(lineCalls.min()!),
            abs(linePuts.min()!),
            abs(lineTotals.min()!)
        )

        let calls = lineCalls.compactMap { CGFloat($0 * maxOfValues + 0.5) }
        let puts = linePuts.compactMap { CGFloat($0 * maxOfValues + 0.5) }
        let totals = lineTotals.compactMap { CGFloat($0 * maxOfValues + 0.5) }
        return (["call": calls, "put": puts, "total": totals])
    }

    func formatFooter(lines: [QuoteLine], openLine: QuoteLine, sender: String = "") -> [FooterLine] {
        let firstLine = lines.first
        let lastLine = lines.last
        var footer = [FooterLine]()

        let tempLast = (lastLine!.callValue + lastLine!.putValue) * lastLine!.nrContracts
        let tempFirst = (firstLine!.callValue + firstLine!.putValue) * firstLine!.nrContracts
        footer.append(FooterLine(
            label: sender == "intra" ? "Nu" : "",
            callPercent: Formatter.percentage.string(for: (lastLine!.callValue/firstLine!.callValue) - 1)!,
            putPercent: Formatter.percentage.string(for: (lastLine!.putValue/firstLine!.putValue) - 1)!,
            orderPercent: Formatter.percentage.string(for: (tempLast/tempFirst) - 1)!,
            index: String(lastLine!.indexValue)
        ))

        if sender == "intra" {
            let tempLast1 = (lastLine!.callValue + lastLine!.putValue) * lastLine!.nrContracts
            let tempFirst1 = (openLine.callValue + openLine.putValue) * openLine.nrContracts
            footer.append(FooterLine(
                label: sender == "intra" ? "Order" : "",
                callPercent: Formatter.percentage.string(for: (lastLine!.callValue/openLine.callValue) - 1)!,
                putPercent: Formatter.percentage.string(for: (lastLine!.putValue/openLine.putValue) - 1)!,
                orderPercent: Formatter.percentage.string(for: (tempLast1/tempFirst1) - 1)!,
                index: String(openLine.indexValue)
            ))
        }
        return footer
    }

    func formatList(lines: [QuoteLine]) -> [TableLine] {
        var temp: Double
        var firstLine = QuoteLine(id: 0, datetime: Date(), datetimeQuote: "", callValue: 0.0, putValue: 0.0, indexValue: 0, nrContracts: 0.0)
        var linesFormatted = [TableLine]()

        for (index, line) in lines.enumerated() {
            var lineFormatted = TableLine()
            if index == 0 {
                firstLine = line
                temp = (line.callValue + line.putValue) * line.nrContracts
                lineFormatted.orderValueText = Formatter.amount0.string(for: temp)!
                lineFormatted.orderValueColor = .black
                lineFormatted.indexText = String(line.indexValue)
            } else {
                temp = (line.callValue - firstLine.callValue + line.putValue - firstLine.putValue) * line.nrContracts
                lineFormatted.orderValueText = ((temp == 0) ? "" : Formatter.amount0.string(for: temp))!
                lineFormatted.orderValueColor = setColor(delta: temp)
                let tempInt = line.indexValue - firstLine.indexValue
                lineFormatted.indexText = (tempInt == 0) ? "" : Formatter.intDelta.string(for: line.indexValue - firstLine.indexValue)!
            }
            lineFormatted.id = line.id
            lineFormatted.datetimeText = line.datetimeQuote
            lineFormatted.callPriceText = Formatter.amount2.string(for: line.callValue)!
            temp = line.callValue - firstLine.callValue
            lineFormatted.callDeltaText = (temp == 0) ? "" : Formatter.amount2.string(for: temp)!
            lineFormatted.callDeltaColor = setColor(delta: temp)
            lineFormatted.putPriceText = Formatter.amount2.string(from: NSNumber(value: line.putValue))!
            temp = line.putValue - firstLine.putValue
            lineFormatted.putDeltaText = (temp == 0) ? "" : Formatter.amount2.string(for: temp)!
            lineFormatted.putDeltaColor = setColor(delta: temp)
            linesFormatted.append(lineFormatted)
        }
        return linesFormatted
    }

    func setColor(delta: Double) -> UIColor {
        var deltaColor = UIColor.black
        if delta > 0 {
            deltaColor = .red
        } else if delta < 0 {
            deltaColor = .omGreen
        }
        return deltaColor
    }

    // =========================
    func unpackJSON(result: RestData) {
        intraday.list = formatList(lines: result.intradays)
        intraday.footer = formatFooter(lines: result.intradays, openLine: result.interdays.first!, sender: "intra")
        intraday.graphLine = formatIntraGraph(lines: result.intradays)

        interday.list = formatList(lines: result.interdays)
        interday.footer = formatFooter(lines: result.interdays, openLine: result.interdays.first!)
        let (temp1, temp2) = formatInterGraph(lines: result.interdays)
        interday.interGraph = temp1
        interday.extraLine = temp2

        caption = result.caption
        message = result.message
        notificationSet = result.notificationSettings
        datetimeText = formatDate(dateIn: result.datetime)
    }

    func getJsonData(action: String) async {
        dataStale = true
        isMessage = false
        let url = URL(string: dataURL + action)!
        print("JsonData from: \(url)")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            UserDefaults.standard.set(data, forKey: "OptieMonitor") // persist in UserDefaults
            let incomingData = try decoder.decode(RestData.self, from: data)
            unpackJSON(result: incomingData)
            dataStale = false
            notificationSetStale = false
        } catch {
            print("Failed to fetch")
        }
    }

    func postJSONData<T: Codable>(_ value: T, action: String) async -> Void {
        let url = URL(string: dataURL + action)!
        let session = URLSession.shared
        let encoder = JSONEncoder()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var jsonData = Data()
        do {
            jsonData = try encoder.encode(value)
        } catch {
            print("Encoding problem")
        }
        do {
            _ = try await session.upload(for: request, from: jsonData)
        } catch {
            print("Posting problem")
        }
    }
}
