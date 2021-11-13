//
//  HeaderView.swift
//  OMSwiftUI
//
//  Created by André Hartman on 04/08/2020.
//  Copyright © 2020 André Hartman. All rights reserved.
//
import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.verticalSizeClass) var sizeClass

    var body: some View {
        VStack {
            Text("\(caption)")
                .modifier(StaleModifier())
                .padding(.bottom)
            HStack {
                Text("\(datetimeText)")
                    .modifier(TextModifier())
                Text("Call")
                    .modifier(TextModifier())
                if sizeClass == .compact {
                    Text("∂")
                        .modifier(TextModifier())
                }
                Text("Put")
                    .modifier(TextModifier())
                if sizeClass == .compact {
                    Text("∂")
                        .modifier(TextModifier())
                }
                Text("€")
                    .modifier(TextModifier())
                Text("Index")
                    .modifier(TextModifier())
            }
        }
    }
}

/*
 struct HeaderView_Previews: PreviewProvider {
 static let viewModel = ViewModel()
 static var previews: some View {
 HeaderView().environmentObject(viewModel)
 }
 }
 */
