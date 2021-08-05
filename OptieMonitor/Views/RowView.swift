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
            Text(quote.datetimeText)
                .modifier(TextModifier())
            Text(quote.callPriceText)
                .modifier(TextModifier())
            if sizeClass == .compact {
            Text(quote.callDeltaText)
                    .modifier(TextModifier())
                    .foregroundColor(Color(quote.callDeltaColor))
            }
            Text(quote.putPriceText)
                .modifier(TextModifier())
            if sizeClass == .compact {
             Text(quote.putDeltaText)
                    .modifier(TextModifier())
                    .foregroundColor(Color(quote.putDeltaColor))
            }
            Text(quote.orderValueText)
                .modifier(TextModifier())
                .foregroundColor(Color(quote.orderValueColor))

            Text(quote.indexText)
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
