//
//  GalileoTextUIView.swift
//  STPR
//
//  Created by Marcel Mierzejewski on 11/10/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import SwiftUI

struct InformationTextView: View {
    enum TextContent {
        case sateliteSystem, myGalileoApp
    }

    let content: TextContent

    private var bodyText: String {
        switch content {
        case .myGalileoApp:
            return "myGalileoAppFull".localized()
        case .sateliteSystem:
            return "galileoSatelitesFull".localized()
        }
    }

    private var navigationTitle: String {
        switch content {
        case .myGalileoApp:
            return "MyGalileoApp"
        case .sateliteSystem:
            return "galileoSatelites".localized()
        }
    }

    var body: some View {
        ///Wrapping text in List is required workaround for vertical scrolling
        List {
            Text(bodyText)
                .font(.body)
                .multilineTextAlignment(.leading)
                .padding()
        }
        .navigationBarTitle(navigationTitle)
    }
}

struct InformationTextView_Previews: PreviewProvider {
    static var previews: some View {
        InformationTextView(content: .sateliteSystem)
    }
}
