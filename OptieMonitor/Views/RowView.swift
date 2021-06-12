//
//  InterdayRowView.swift
//  OMSwiftUI
//
//  Created by André Hartman on 06/07/2020.
//  Copyright © 2020 André Hartman. All rights reserved.
//
import SwiftUI

struct RowView: View {
    @Environment(\.verticalSizeClass) var sizeClass
    var quote: TableLine
     
    var body: some View {
        HStack {
            Text(self.quote.datetimeText)
                .modifier(TextModifier())
            Text(self.quote.callPriceText)
                .modifier(TextModifier())
            if sizeClass == .compact {
            Text(self.quote.callDeltaText)
                    .modifier(TextModifier())
                    .foregroundColor(Color(self.quote.callDeltaColor))
            }
            Text(self.quote.putPriceText)
                .modifier(TextModifier())
            if sizeClass == .compact {
             Text(self.quote.putDeltaText)
                    .modifier(TextModifier())
                    .foregroundColor(Color(self.quote.putDeltaColor))
            }
            Text(self.quote.orderValueText)
                .modifier(TextModifier())
                .foregroundColor(Color(self.quote.orderValueColor))

            Text(self.quote.indexText)
                .modifier(TextModifier())
        }
    }
}
/*
 struct InterdayRowView_Previews: PreviewProvider {
 static var previews: some View {
 InterdayRowView()
 }
 }
 */
