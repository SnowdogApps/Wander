//
//  AboutUsView.swift
//  STPR
//
//  Created by Marcel Mierzejewski on 24/10/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import SwiftUI

struct AboutUsView: View {
    var body: some View {
        VStack {
            Image("snowdog_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Text("snowdogInfo")
                .padding(.top, 16)
            Spacer()
        }
        .padding()
        .navigationBarTitle("aboutSnowdog")
    }
}

struct AboutUsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutUsView()
    }
}
