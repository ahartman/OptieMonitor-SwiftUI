    //
    //  UserSettings.swift
    //  OMSwiftUI
    //
    //  Created by André Hartman on 05/07/2020.
    //  Copyright © 2020 André Hartman. All rights reserved.
    //
    import Foundation
    import SwiftUI

    class ViewModel: ObservableObject {
        @Published var intraLines: [TableLine] = []
        init(){
            generateData(action: "currentOrder")
        }
        @Published var interLines: [TableLine] = []
        @Published var intraFooter = FooterLine()
        @Published var interFooter = FooterLine()
        @Published var intraInterLines: [TableLine] = []
        @Published var intraGraph = [String:Any]()
        @Published var interGraph = [String:Any]()

        @Published var caption: String = ""
        @Published var message: String = ""
        @Published var isMessage: Bool = false
        @Published var datetimeText: String = ""
        @Published var dataStale: Bool = false
        @Published var notificationSet = NotificationSetting()
        {didSet{notificationSetStale = true}}

        func generateData(action: String) -> Void {
            getJsonData(action: action) { result in
                switch result{
                case .success(let result):
                    self.intraLines = self.formatTableView(lines: result.intraday)
                    self.interLines = self.formatTableView(lines: result.interday)
                    self.intraGraph = self.formatIntraGraph(lines: result.intraday)
                    self.interGraph = self.formatInterGraph(lines: result.interday)
                    self.intraFooter = self.formatFooter(lines: result.intraday)
                    self.interFooter = self.formatFooter(lines: result.interday)

                    self.intraInterLines = []
                    self.intraInterLines.append(self.interLines.first!)
                    self.intraInterLines.append(self.interLines.last!)

                    self.caption = result.caption
                    self.datetimeText = self.formatDate(dateIn: result.datetime)
                    self.message = result.message ?? ""
                    if(self.message.count > 0) {self.isMessage = true}
                    self.notificationSet = result.notificationSettings
                   self.dataStale = false
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
        func formatFooter(lines: [QuoteLine]) -> FooterLine {
            let firstLine = lines.first
            let lastLine = lines.last
            var footer = FooterLine(callPercent:"",putPercent:"",orderPercent:"",index:"")

            footer.callPercent = Formatter.percentage.string(for: (lastLine!.callValue/firstLine!.callValue)-1)!
            footer.putPercent = Formatter.percentage.string(for: (lastLine!.putValue/firstLine!.putValue)-1)!
            let tempLast = (lastLine!.callValue + lastLine!.putValue) * lastLine!.nrContracts
            let tempFirst = (firstLine!.callValue + firstLine!.putValue) * firstLine!.nrContracts
            footer.orderPercent = Formatter.percentage.string(for: (tempLast/tempFirst)-1)!
            footer.index = String(lastLine!.indexValue)
            return footer
        }
        func formatTableView(lines: [QuoteLine]) -> [TableLine]{
            var temp: Double
            var tempInt: Int
            var firstLine = QuoteLine(id: 0, datetime: Date(), datetimeQuote: "", callValue: 0.0, putValue: 0.0, indexValue: 0, nrContracts: 0.0)

            var linesFormatted = [TableLine]()
            var switchFirst: Bool = true

            for line in lines {
                var lineFormatted = TableLine()
                if(switchFirst){
                    firstLine = line
                    switchFirst = false

                    temp = (line.callValue + line.putValue) * line.nrContracts
                    lineFormatted.orderValueText = Formatter.amount0.string(for: temp)!
                    lineFormatted.orderValueColor = .black
                    tempInt = line.indexValue
                    lineFormatted.indexText = Formatter.intDelta.string(for: tempInt)!
                } else {
                    temp = (line.callValue - firstLine.callValue + line.putValue - firstLine.putValue) * line.nrContracts
                    lineFormatted.orderValueText = ((temp == 0) ? "" : Formatter.amount0.string(for: temp))!
                    lineFormatted.orderValueColor = setColor(delta: temp)
                    tempInt = line.indexValue - firstLine.indexValue
                    lineFormatted.indexText = (tempInt == 0) ? "" : Formatter.intDelta.string(for: tempInt)!
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
        func getJsonData(action: String, completion: @escaping (Result<RestData, NetworkError>) -> Void) {
            print("JsonData")
            dataStale = true
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let url = URL(string: dataURL + action + "&apns=" + deviceTokenString)!
            //print(url)

            URLSession.shared.dataTask(with: url) {data, response, error in
                DispatchQueue.main.async{
                    if let incoming = data {
                        do {
                            let incomingData = try decoder.decode(RestData.self, from: incoming)
                            //print(incomingData)
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
        func postJsonData(data: NotificationSetting){
            if(notificationSetStale){
                postJSONData(action: "notificationSettings", data: data)
                notificationSetStale = false
            }
        }
        func postJSONData(action: String, data: NotificationSetting) {
            var request = URLRequest(url: URL(string: dataURL + action)!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            guard let payload = try? JSONEncoder().encode(data) else {
                return
            }
            let task = URLSession.shared.uploadTask(with: request, from: payload) { data, response, error in
                if let error = error {
                    print ("error: \(error)")
                    return
                }
                guard let response = response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    print ("server error")
                    return
                }
                if let mimeType = response.mimeType,
                   mimeType == "application/json",
                   let data = data,
                   let dataString = String(data: data, encoding: .utf8) {
                    print ("response to POST: \(dataString)")
                }
            }
            task.resume()
        }
    }
    enum NetworkError:Error {
        case badURL, requestFailed, unknown
    }
