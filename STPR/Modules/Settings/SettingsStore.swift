//
//  SettingsStore.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/23/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Foundation
import Combine

final class SettingStore: ObservableObject {
    private var username: String = ""
    @Published var newUsername: String = ""
    @Published var userDefaultsChanged: Void = ()

    private let authManager: AuthManagerType
    private let userManager: UserManager
    private var cancellables: Set<AnyCancellable> = []

    init(authManager: AuthManagerType, userManager: UserManager) {
        self.authManager = authManager
        self.userManager = userManager
        
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .receive(on: DispatchQueue.main)
            .assign(to: \.userDefaultsChanged, on: self)
            .store(in: &cancellables)
    }

    var isUserLogged: Bool { authManager.currentUser != nil }

    func save() {
        guard let userId = GlobalSettings.userId, !userId.isEmpty else {
            return
        }

        if username != newUsername {
            userManager
                .sessionPublisher(userId: userId)
                .compactMap { $0 }
                .flatMap { session -> AnyPublisher<UserSession?, Error> in
                    var newSession = session
                    newSession.username = self.newUsername
                    return self.userManager.updateSession(newSession, for: userId)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { self.username = $0?.username ?? "" }
            )
            .store(in: &cancellables)
        }
    }

    func fetch() {
        guard let userId = GlobalSettings.userId, !userId.isEmpty else {
            return
        }

        userManager
            .sessionPublisher(userId: userId)
            .flatMap { _ in self.userManager.sessionPublisher(userId: userId) }
            .replaceError(with: nil)
            .compactMap { $0 }
            .map { $0.username }
            .handleEvents(receiveOutput: { self.username = $0 })
            .receive(on: DispatchQueue.main)
            .assign(to: \.newUsername, on: self)
            .store(in: &cancellables)
    }

    func signOut() {
        authManager.signOut()
        GlobalSettings.userId = ""
        GlobalSettings.isUserBoarded = false
    }
}
