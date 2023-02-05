//
//  Models.swift
//  OMSwiftUI
//
//  Created by André Hartman on 02/07/2020.
//  Copyright © 2020 André Hartman. All rights reserved.
//
import SwiftUI
//import SwiftUICharts

var intraFooter: [FooterLine] = []
var interFooter: [FooterLine] = []
var caption: String = ""
var quoteDatetime: Date? = nil
var quoteDatetimeText: String = ""
var dataStale: Bool = true
var notificationSetStale: Bool = false

var intrayScale = YScale(yMin: 0.0, yMax: 0.0)
var interyScale = YScale(yMin: 0.0, yMax: 0.0)

// set data path
#if targetEnvironment(simulator)
//let dataURL = "http://cake.local/orders.json?id=ahartman&action="
let dataURL = "https://nastifou.synology.me:1010/orders.json?id=ahartman&action="
#else
//let dataURL = "http://cake.local/orders.json?id=ahartman&action="
let dataURL = "https://nastifou.synology.me:1010/orders.json?id=ahartman&action="
#endif

struct YScale {
    var yMin: Double
    var yMax: Double
}

struct IncomingData: Decodable {
    let message: String?
    let datetime: Date
    let notificationSettings: NotificationSetting
    let intradays: [IncomingLine]
    let interdays: [IncomingLine]
    let caption: String

    enum CodingKeys: String, CodingKey {
        case message, datetime, notificationSettings, caption
        case intradays = "intraday"
        case interdays = "interday"
    }
}

struct IncomingLine: Decodable {
    var id: Int
    var datetime: Date
    var datetimeQuote: String
    var callValue: Double
    var putValue: Double
    var indexValue: Int
    var nrContracts: Double

    enum CodingKeys: String, CodingKey {
        case id, datetime, nrContracts
        case datetimeQuote = "datetimeSQL"
        case callValue = "callPrice"
        case putValue = "putPrice"
        case indexValue = "index1"
    }
}

struct NotificationSetting: Codable {
    var frequency: Int = 0
    var severity: Int = 0
    var sound: Bool = false

    enum CodingKeys: String, CodingKey {
        case frequency = "notifyFrequency"
        case severity = "notifySeverity"
        case sound = "notifySound"
    }
}

struct DisplayData {
    var list = [TableLine]()
    var footer = [FooterLine]()
    var graph = [GraphLine]()
    var yValues = [Double]()
}

struct GraphLine: Hashable {
    var dateTime: Date
    var type: String
    var value: Double
    var index: Int
}

struct TableLine {
    var id: Int = 0
    var datetimeText: String = ""
    var callPriceText: String = ""
    var callDeltaText: String = ""
    var callDeltaColor = UIColor.black
    var putPriceText: String = ""
    var putDeltaText: String = ""
    var putDeltaColor = UIColor.black
    var orderValueText: String = ""
    var orderValueColor = UIColor.black
    var indexText: String = ""
}

struct FooterLine: Hashable {
    let id = UUID()
    var label: String = ""
    var callPercent: String = ""
    var putPercent: String = ""
    var orderPercent: String = ""
    var index: Int = 0
}

// Extensions
extension Formatter {
    static var amount2: NumberFormatter {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 2
        nf.locale = Locale(identifier: "nl_BE")
        nf.numberStyle = .currency
        return nf
    }

    static var amount0: NumberFormatter {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 0
        nf.locale = Locale(identifier: "nl_BE")
        nf.numberStyle = .currency
        return nf
    }

    static var delta: NumberFormatter {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 2
        nf.locale = Locale(identifier: "nl_BE")
        nf.numberStyle = .decimal
        return nf
    }

    static var intDelta: NumberFormatter {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 0
        nf.positivePrefix = nf.plusSign
        nf.numberStyle = .decimal
        return nf
    }

    static var percentage: NumberFormatter {
        let nf = NumberFormatter()
        nf.positivePrefix = nf.plusSign
        nf.numberStyle = .percent
        return nf
    }
}

extension UIColor {
    class var omGreen: UIColor {
        return UIColor(red: 81/255, green: 199/255, blue: 69/255, alpha: 1.0)
    }
}

// Modifiers
struct TextModifier: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: 0, maxWidth: .infinity)
            .font(.footnote)
    }
}

struct StaleModifier: ViewModifier {
    @EnvironmentObject var viewModel: ViewModel
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: 0, maxWidth: .infinity)
            .foregroundColor(dataStale ? .red : .secondary)
            .font(.footnote.weight(dataStale ? .bold : .regular))
    }
}
