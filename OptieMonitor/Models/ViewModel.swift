//
//  UserSettings.swift
//  OMSwiftUI
//
//  Created by André Hartman on 05/07/2020.
//  Copyright © 2020 André Hartman. All rights reserved.
//
import SwiftUI

class ViewModel: ObservableObject {
    init(){
        if let data = UserDefaults.standard.data(forKey: "OptieMonitor") {
            //print("UserDefaults saved data found")
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let savedData = try decoder.decode(RestData.self, from: data)
                unpackJSON(result: savedData)
            } catch {
                print("JSON error from UserDefaults:", error)
            }
        }
        generateData(action: "currentOrder")
    }

    @Published var intraday = QuotesList()
    @Published var interday = QuotesList()
    @Published var isMessage: Bool = false
    @Published var notificationSet = NotificationSetting()
    {didSet{
        notificationSetStale = true

    }}
    var message: String?
    {didSet{
        if message != nil {
            isMessage = true
        }
    }}

    func formatDate(dateIn: Date) -> String {
        let formatter = DateFormatter()
        let dateMidnight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        formatter.dateFormat = (dateIn < dateMidnight!) ? "dd-MM" :  "HH:mm"
        return formatter.string(for: dateIn)!
    }
    func formatInterGraph(lines: [QuoteLine]) -> [String: Any] {
        var columns: [[CGFloat]] = []

        let verticalScalar = 1.0
        let maxValue = lines.compactMap({($0.callValue + $0.putValue) * $0.nrContracts}).max()!/(2 * verticalScalar)
        for line in lines.reversed() {
            let callValue = CGFloat(line.callValue*line.nrContracts/maxValue)
            let putValue = CGFloat(line.putValue*line.nrContracts/maxValue)
            columns.append([callValue,putValue])
        }

        let lineIndex = lines.compactMap({Double($0.indexValue) - Double(lines[0].indexValue)})
        let rangeOfIndex = 0.5 / max(abs(lineIndex.max()!),abs(lineIndex.min()!))
        let index = lineIndex.compactMap({CGFloat($0 * rangeOfIndex + 0.5)})

        return (["columns": columns, "line": index])
    }
    func formatIntraGraph(lines: [QuoteLine]) -> [String:Any] {
        let lineCalls = lines.compactMap({$0.callValue - lines[0].callValue})
        let linePuts = lines.compactMap({$0.putValue - lines[0].putValue})
        let lineTotals = lines.compactMap({$0.callValue + $0.putValue - lines[0].callValue - lines[0].putValue})

        let maxOfValues = 0.5 / max(
            abs(lineCalls.max()!),
            abs(linePuts.max()!),
            abs(lineTotals.max()!),
            abs(lineCalls.min()!),
            abs(linePuts.min()!),
            abs(lineTotals.min()!)
        )

        let calls = lineCalls.compactMap({CGFloat($0 * maxOfValues + 0.5)})
        let puts = linePuts.compactMap({CGFloat($0 * maxOfValues + 0.5)})
        let totals = lineTotals.compactMap({CGFloat($0 * maxOfValues + 0.5)})
        return (["call": calls, "put": puts, "total": totals])
    }
    func formatFooter(lines: [QuoteLine], openLine: QuoteLine, sender: String = "") -> [FooterLine] {
        let firstLine = lines.first
        let lastLine = lines.last
        var footer = [FooterLine]()

        let tempLast = (lastLine!.callValue + lastLine!.putValue) * lastLine!.nrContracts
        let tempFirst = (firstLine!.callValue + firstLine!.putValue) * firstLine!.nrContracts
        footer.append(FooterLine(
            label: sender == "intra" ? "Nu": "",
            callPercent: Formatter.percentage.string(for: (lastLine!.callValue/firstLine!.callValue)-1)!,
            putPercent: Formatter.percentage.string(for: (lastLine!.putValue/firstLine!.putValue)-1)!,
            orderPercent: Formatter.percentage.string(for: (tempLast/tempFirst)-1)!,
            index: String(lastLine!.indexValue)
        ))

        if sender == "intra" {
            let tempLast1 = (lastLine!.callValue + lastLine!.putValue) * lastLine!.nrContracts
            let tempFirst1 = (openLine.callValue + openLine.putValue) * openLine.nrContracts
            footer.append(FooterLine(
                label: sender == "intra" ? "Order" : "",
                callPercent: Formatter.percentage.string(for: (lastLine!.callValue/openLine.callValue)-1)!,
                putPercent: Formatter.percentage.string(for: (lastLine!.putValue/openLine.putValue)-1)!,
                orderPercent: Formatter.percentage.string(for: (tempLast1/tempFirst1)-1)!,
                index: String(openLine.indexValue)
            ))
        }
        return footer
    }
    func formatList(lines: [QuoteLine]) -> [TableLine]{
        var temp: Double
        var firstLine = QuoteLine(id: 0, datetime: Date(), datetimeQuote: "", callValue: 0.0, putValue: 0.0, indexValue: 0, nrContracts: 0.0)
        var linesFormatted = [TableLine]()

        for (index, line) in lines.enumerated() {
            var lineFormatted = TableLine()
            if(index == 0){
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
    func setColor(delta: Double) -> UIColor{
        var deltaColor = UIColor.black
        if(delta > 0){
            deltaColor = .red
        } else if(delta < 0){
            deltaColor = .omGreen
        }
        return deltaColor
    }
    // =========================
    func generateData(action: String) -> Void {
        dataStale = true
        isMessage = false
        JSONclass().getJsonData(action: action) { [self] incomingData in
            switch incomingData{
            case .success(let incomingData):
                unpackJSON(result: incomingData)
                dataStale = false
                notificationSetStale = false
            case .failure(let error):
                switch error{
                case .badURL:
                    print("Bad URL")
                case .requestFailed:
                    print("Request failed")
                case .unknown:
                    print("Unknown error")
                }
            }
        }
    }
    func unpackJSON(result: RestData) -> Void {
        intraday.list = formatList(lines: result.intradays)
        intraday.footer = formatFooter(lines: result.intradays, openLine: result.interdays.first!, sender: "intra")
        intraday.graph = formatIntraGraph(lines: result.intradays)

        interday.list = formatList(lines: result.interdays)
        interday.footer = formatFooter(lines: result.interdays, openLine: result.interdays.first!)
        interday.graph = formatInterGraph(lines: result.interdays)

        caption = result.caption
        datetimeText = formatDate(dateIn: result.datetime)
        message = result.message
        notificationSet = result.notificationSettings
    }
}

// =================================
class JSONclass{
    func getJsonData(action: String, completion: @escaping (Result<RestData, NetworkError>) -> Void) {
        let url = URL(string: dataURL + action)!
        print("JsonData from: \(url)")

        URLSession.shared.dataTask(with: url) {data, response, error in
            DispatchQueue.main.async{
                //print("JSON String: \(String(data: data!, encoding: .utf8))")
                if let incoming = data {
                    do {
                        UserDefaults.standard.set(incoming, forKey: "OptieMonitor") // persist in UserDefaults
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let incomingData = try decoder.decode(RestData.self, from: incoming)
                        completion(.success(incomingData))
                    } catch {
                        print("JSON error:", error)
                    }
                } else if error != nil {
                    completion(.failure(.requestFailed))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }.resume()
    }
/*
    func getJsonData(action: String) async -> RestData?  {
        let url = URL(string: dataURL + action)!
        print("JsonData from: \(url)")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            UserDefaults.standard.set(data, forKey: "OptieMonitor") // persist in UserDefaults
            let incomingData = try decoder.decode(RestData.self, from: data)
            return incomingData
        } catch {
            print("Failed to fetch")
            return nil
        }
    }
 */

    func postJSONData<T: Codable>(_ value: T, action: String) {
        let url = URL(string: dataURL + action)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var jsonData = Data()
        do {
            jsonData = try JSONEncoder().encode(value)
        }
        catch {
            print("Encoding problem")
        }

        let task = URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
            if let error = error {
                print ("Error: \(error)")
            }
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                print ("Server error")
                return
            }
            if let mimeType = response.mimeType,
               mimeType == "application/json",
               let data = data,
               let dataString = String(data: data, encoding: .utf8) {
                print ("Response to POST: \(dataString)")
            }
        }
        task.resume()
    }
}
enum NetworkError:Error {
    case badURL, requestFailed, unknown
}
