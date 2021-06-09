//
//  FooterView2.swift
//  OptieMonitor
//
//  Created by André Hartman on 04/06/2021.
//


import SwiftUI

/*struct FooterView: View {
 // footerLine is passed as argument as it can be intraFooter or interfooter
 var footerLines: [FooterLine]
 var geometry: GeometryProxy

 var body: some View {
 FooterRowView(footerLine: footerLines.first!, geometry: geometry)
 FooterRowView(footerLine: footerLines.last!, geometry: geometry)
 }
 }
 */

struct FooterView: View {
    // footerLine is passed as argument as it can be intraFooter or interfooter
    var footerLines: [FooterLine]
    var geometry: GeometryProxy

    var body: some View {
        VStack {
            ForEach(footerLines, id: \.self) {footerLine in
                FooterRowView(footerLine: footerLine, geometry: geometry)
            }
        }
    }
}

struct FooterRowView: View {
    var footerLine: FooterLine
    var geometry: GeometryProxy

    var body: some View {
        HStack {
            Text(self.footerLine.label).modifier(TextModifier())
            Text("\(self.footerLine.callPercent)").modifier(TextModifier())
            if(geometry.size.width > geometry.size.height ) {
                Text("").modifier(TextModifier())
            }
            Text("\(self.footerLine.putPercent)").modifier(TextModifier())
            if(geometry.size.width > geometry.size.height ) {
                Text("").modifier(TextModifier())
            }
            Text("\(self.footerLine.orderPercent)").modifier(TextModifier())
            Text("\(self.footerLine.index)").modifier(TextModifier())
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
