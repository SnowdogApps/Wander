//
//  SettingsView.swift
//  STPR
//
//  Created by Marcel Mierzejewski on 11/10/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @EnvironmentObject var store: SettingStore

    weak var delegate: AppCoordinatorDelegate?

    private var versionNumber: String {
        guard
            let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            fatalError("There is no valid version number in info.plist")
        }
        return versionNumber
    }

    private var termsUrl: URL {
        guard
            let stringUrl = Bundle.main.infoDictionary?["Terms URL"] as? String,
            let url = URL(string: stringUrl) else {
            fatalError("There is no Terms URL in info.plist or the URL is invalid")
        }
        return url
    }

    private var privacyUrl: URL {
        guard
            let stringUrl = Bundle.main.infoDictionary?["Privacy URL"] as? String,
            let url = URL(string: stringUrl) else {
            fatalError("There is no Privacy URL in info.plist or the URL is invalid")
        }
        return url
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("aboutUs")) {
                        NavigationLink(destination: AboutUsView()) {
                            Text("aboutSnowdog")
                        }
                    }
                    Section(header: Text("myProfile".localized())) {
                        NavigationLink(destination: EditProfileView().environmentObject(store)) {
                            Text("editProfile".localized())
                        }
                    }

                    Section(header: Text("aboutUs".localized())) {
                        NavigationLink(destination: WebView(url: termsUrl)
                            .navigationBarTitle("termsUnderline")) {
                                Text("termsUnderline")
                        }
                        NavigationLink(destination: WebView(url: privacyUrl)
                            .navigationBarTitle("privacyUnderline")) {
                                Text("privacyUnderline")
                        }
                        NavigationLink(destination: InformationTextView(content: .myGalileoApp)) {
                            Text("aboutMGAComp")
                        }
                        NavigationLink(destination: InformationTextView(content: .sateliteSystem)) {
                            Text("aboutGSS")
                        }
                    }

                    if store.isUserLogged {
                        Section {
                            Button("logout") {
                                self.store.signOut()
                                self.delegate?.logout()
                            }
                        }
                    }

                    Section {
                        Group {
                            Text("finalFootnote".localized())
                                .font(.footnote)
                                .multilineTextAlignment(.center)

                            Text(versionNumber)
                                .font(.footnote)
                                .padding()
                        }
                    }
                }
            }
            .onAppear(perform: store.fetch)
            .navigationBarTitle("settings".localized())
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
