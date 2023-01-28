//
//  FooterView2.swift
//  OptieMonitor
//
//  Created by André Hartman on 04/06/2021.
//
import SwiftUI

struct FooterView: View {
    // footerLine is passed as argument as it can be intraFooter or interfooter
    var footerLines: [FooterLine]

    var body: some View {
        VStack {
            ForEach(Array(footerLines.enumerated()), id: \.element) { index, footerLine in
                if index == 1 {
                    Divider()
                }
                FooterRowView(footerLine: footerLine)
            }
        }
    }
}

struct FooterRowView: View {
    @Environment(\.verticalSizeClass) var sizeClass
    var footerLine: FooterLine

    var body: some View {
        HStack {
            Text(footerLine.label).modifier(TextModifier())
            Text("\(footerLine.callPercent)").modifier(TextModifier())
            if sizeClass == .compact {
                Text("").modifier(TextModifier())
            }
            Text("\(footerLine.putPercent)").modifier(TextModifier())
            if sizeClass == .compact {
                Text("").modifier(TextModifier())
            }
            Text("\(footerLine.orderPercent)").modifier(TextModifier())
            Text("\(footerLine.index)").modifier(TextModifier())
        }
    }
}

/*
 struct FooterView_Previews: PreviewProvider {
 static var previews: some View {
 FooterView()
 }
 }
 */
