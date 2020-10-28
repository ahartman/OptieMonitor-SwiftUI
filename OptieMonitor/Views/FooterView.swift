//
//  FooterView.swift
//  OMSwiftUI
//
//  Created by André Hartman on 04/08/2020.
//  Copyright © 2020 André Hartman. All rights reserved.
//
import SwiftUI

struct FooterView: View {
    // footerLine is passed as argument as it can be intraFooter or interfooter
    var footerLine: FooterLine
    var geometry: GeometryProxy

    var body: some View {
        HStack {
            Text("").modifier(TextModifier())
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
