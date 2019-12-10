//
//  EditProfileView.swift
//  STPR
//
//  Created by Marcel Mierzejewski on 28/10/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import SwiftUI

struct ActivityView: UIViewRepresentable {
    typealias UIViewType = UIActivityIndicatorView

    func makeUIView(context: UIViewRepresentableContext<ActivityView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .large)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityView>) {
        uiView.startAnimating()
    }
}

struct EditProfileView: View {
    @EnvironmentObject var store: SettingStore
    @Environment(\.presentationMode) var presentation

    var body: some View {
        ZStack {
            List {
                HStack {
                    Spacer()
                    Image("user")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .clipped()
                        .listRowInsets(EdgeInsets())
                    Spacer()
                }


                VStack(alignment: .leading) {
                    LabelTextField(
                        name: $store.newUsername,
                        label: "username",
                        placeHolder: "yourUsername"
                    ).disabled(store.newUsername.isEmpty)
                }
                .padding(.top, 20)
                .listRowInsets(EdgeInsets())
            }

            if store.newUsername.isEmpty {
                ActivityView()
            }
        }
        .navigationBarTitle(Text("myProfile"), displayMode: .inline)
        .navigationBarItems(trailing:
            Button("save") {
                self.store.save()
                self.presentation.wrappedValue.dismiss()
            }.disabled(store.newUsername.isEmpty)
        )
    }
}

struct LabelTextField : View {
    @Binding var name: String
    var label: LocalizedStringKey
    var placeHolder: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
            TextField(placeHolder, text: $name)
                .padding()
        }
        .padding(.horizontal, 16)
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
