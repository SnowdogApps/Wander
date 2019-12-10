//
//  WebView.swift
//  STPR
//
//  Created by Marcel Mierzejewski on 11/10/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView(frame: .zero)
    }

    func updateUIView(_ view: WKWebView, context: UIViewRepresentableContext<WebView>) {
        let request = URLRequest(url: url)
        view.load(request)
    }
}
