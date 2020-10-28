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
            generateData(action: "currentOrder")
        }
        @Published var intraLines: [TableLine] = []
        @Published var interLines: [TableLine] = []
        @Published var intraFooter = FooterLine()
        @Published var interFooter = FooterLine()
        @Published var intraInterLines: [TableLine] = []
        @Published var intraGraph = [String:Any]()
        @Published var interGraph = [String:Any]()
        @Published var caption: String = ""
        @Published var message: String = ""
        {didSet{isMessage = true}}
        @Published var isMessage: Bool = false
        @Published var datetimeText: String = ""
        @Published var dataStale: Bool = false
        @Published var notificationSet = NotificationSetting()
        {didSet{notificationSetStale = true}}

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

            for (index, line) in lines.enumerated() {
                var lineFormatted = TableLine()
                if(index == 0){
                    firstLine = line
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
        
        func generateData(action: String) -> Void {
            dataStale = true
            JSONclass().getJsonData(action: action) { result in
                switch result{
                case .success(let result):
                    self.interLines = self.formatTableView(lines: result.interday)
                    self.interFooter = self.formatFooter(lines: result.interday)
                    self.interGraph = self.formatInterGraph(lines: result.interday)

                    self.intraLines = self.formatTableView(lines: result.intraday)
                    self.intraFooter = self.formatFooter(lines: result.intraday)
                    self.intraInterLines = []
                    self.intraInterLines.append(self.interLines.first!)
                    self.intraInterLines.append(self.interLines.last!)
                    self.intraGraph = self.formatIntraGraph(lines: result.intraday)

                    self.caption = result.caption
                    self.datetimeText = self.formatDate(dateIn: result.datetime)
                    self.message = result.message ?? ""
                    self.notificationSet = result.notificationSettings

                    self.dataStale = false
                    self.isMessage = false
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
    }

    class JSONclass{
        func getJsonData(action: String, completion: @escaping (Result<RestData, NetworkError>) -> Void) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let url = URL(string: dataURL + action)!
            print("JsonData from: \(url)")

            URLSession.shared.dataTask(with: url) {data, response, error in
                DispatchQueue.main.async{
                    //print("JSON String: \(String(data: data!, encoding: .utf8))")
                    if let incoming = data {
                        do {
                            let incomingData = try decoder.decode(RestData.self, from: incoming)
                            print(incomingData)
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
