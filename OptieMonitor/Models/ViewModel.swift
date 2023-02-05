//
//  UserSettings.swift
//  OMSwiftUI
//
//  Created by André Hartman on 05/07/2020.
//  Copyright © 2020 André Hartman. All rights reserved.
//
import SwiftUI

@MainActor
class ViewModel: ObservableObject {
    @Published var intraday = DisplayData()
    @Published var interday = DisplayData()
    @Published var intradayGraph = [GraphLine]()
    @Published var interdayGraph = [GraphLine]()
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
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let savedData = try decoder.decode(IncomingData.self, from: data)
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

    func formatGraph(lines: [IncomingLine], sender: String = "") -> ([GraphLine], [Double]) {
        var localGraphLines = [GraphLine]()
        var yMin = 0.0
        var yMax = 0.0
        let rounding = (sender == "intra") ? 250.0 : 1000.0
        let firstCallValue = (sender == "intra") ? lines[0].callValue : 0
        let firstPutValue = (sender == "intra") ? lines[0].putValue : 0

        for line in lines {
            let callValue = (line.callValue - firstCallValue) * line.nrContracts
            let putValue = (line.putValue - firstPutValue) * line.nrContracts

            localGraphLines.append(GraphLine(
                dateTime: line.datetime,
                type: "Call",
                value: callValue,
                index: line.indexValue)
            )
            localGraphLines.append(GraphLine(
                dateTime: line.datetime,
                type: "Put",
                value: putValue,
                index: line.indexValue)
            )

            yMax = max(yMax, callValue, putValue, callValue + putValue)
            yMin = min(yMin, callValue, putValue, callValue + putValue)
        }
        yMax = (yMax/rounding).rounded(.awayFromZero) * rounding
        yMin = (yMin/rounding).rounded(.awayFromZero) * rounding
        let yValues = stride(from: yMin, through: yMax, by: rounding).map { $0 }
        return (localGraphLines, yValues)
    }

    func formatFooter(lines: [IncomingLine], sender: String = "") -> [FooterLine] {
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
            index: lastLine!.indexValue))

        if sender == "intra" {
            let tempLast1 = (lastLine!.callValue + lastLine!.putValue) * lastLine!.nrContracts
            //let tempFirst1 = (openLine.callValue + openLine.putValue) * openLine.nrContracts
            let tempFirst1 = (firstLine!.callValue + firstLine!.putValue) * firstLine!.nrContracts
            footer.append(FooterLine(
                label: sender == "intra" ? "Order" : "",
                callPercent: Formatter.percentage.string(for: (lastLine!.callValue/firstLine!.callValue) - 1)!,
                putPercent: Formatter.percentage.string(for: (lastLine!.putValue/firstLine!.putValue) - 1)!,
                orderPercent: Formatter.percentage.string(for: (tempLast1/tempFirst1) - 1)!,
                index: firstLine!.indexValue))
        }
        return footer
    }

    func formatList(lines: [IncomingLine]) -> [TableLine] {
        var temp: Double
        var firstLine = IncomingLine(id: 0, datetime: Date(), datetimeQuote: "", callValue: 0.0, putValue: 0.0, indexValue: 0, nrContracts: 0.0)
        var localLines = [TableLine]()

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
            localLines.append(lineFormatted)
        }
        return localLines
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
    func unpackJSON(result: IncomingData) {
        intraday.list = formatList(lines: result.intradays)
        intraday.footer = formatFooter(lines: result.intradays, sender: "intra")
        (intraday.graph, intraday.yValues) = formatGraph(lines: result.intradays, sender: "intra")

        interday.list = formatList(lines: result.interdays)
        interday.footer = formatFooter(lines: result.interdays)
        (interday.graph, interday.yValues) = formatGraph(lines: result.interdays)

        caption = result.caption
        message = result.message
        notificationSet = result.notificationSettings
        quoteDatetime = result.datetime
        quoteDatetimeText = formatDate(dateIn: result.datetime)
    }

    func getJsonData(action: String) async {
        dataStale = true
        isMessage = false
        let url = URL(string: dataURL + action)!
        print("Fetching JsonData from: \(url)")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            UserDefaults.standard.set(data, forKey: "OptieMonitor") // persist in UserDefaults
            let incomingData = try decoder.decode(IncomingData.self, from: data)
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
