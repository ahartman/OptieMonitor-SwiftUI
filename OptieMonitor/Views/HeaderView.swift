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
    var geometry: GeometryProxy

    var body: some View {
        VStack {
            Text("\(self.viewModel.caption)")
                .modifier((StaleModifier()))
                .padding(.bottom)
            HStack {
                Text("\(self.viewModel.datetimeText)").modifier(TextModifier())
                Text("Call").modifier(TextModifier())
                if(geometry.size.width > geometry.size.height ) {
                    Text("∂").modifier(TextModifier())
                }
                Text("Put")
                    .modifier(TextModifier())
                if(geometry.size.width > geometry.size.height ) {
                    Text("∂").modifier(TextModifier())
                }
                Text("€").modifier(TextModifier())
                Text("Index").modifier(TextModifier())
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
