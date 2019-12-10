//
//  UserManager.swift
//  STPR
//
//  Created by Artur Chabera on 09/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Combine

protocol UserManager {
    func sessionPublisher(userId: String) -> AnyPublisher<UserSession?, Error>
    func createSessionIfNeeded(_ session: UserSession, for userId: String) -> AnyPublisher<UserSession?, Error>
    func updateSession(_ session: UserSession, for userId: String) -> AnyPublisher<UserSession?, Error>
}

final class FirestoreUserManager: UserManager {
    enum DatabaseReferences: DocumentReferenceConvertible {
        case userSession(userId: String)
        case users
        case singleUser(userId: String)

        var referencePath: String {
            switch self {
            case .userSession(let userId), .singleUser(let userId):
                return "\(DatabaseEndpoint.userSession.rawValue)/\(userId)"
            case .users:
                return DatabaseEndpoint.userSession.rawValue
            }
        }
    }

    private let database: DatabaseManager
    init(database: DatabaseManager) {
        self.database = database
    }

    func sessionPublisher(userId: String) -> AnyPublisher<UserSession?, Error> {
        database
            .documentPublisher(for: DatabaseReferences.singleUser(userId: userId), includeMetadata: true)
            .map { try? $0.decode() }
            .eraseToAnyPublisher()
    }

    func createSessionIfNeeded(_ session: UserSession, for userId: String) -> AnyPublisher<UserSession?, Error> {
        sessionPublisher(userId: userId)
            .first()
            .flatMap { oldSession -> AnyPublisher<Bool, Error> in
                if oldSession == nil {
                    return self.database
                        .update(
                            reference: DatabaseReferences.singleUser(userId: userId),
                            with: session.toJson() ?? [:],
                            merge: false
                    )
                        .map { _ in true }
                        .eraseToAnyPublisher()
                } else {
                    return Just(false).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
        }.flatMap { _ in
            self.sessionPublisher(userId: userId).first()
        }.eraseToAnyPublisher()
    }

    func updateSession(_ session: UserSession, for userId: String) -> AnyPublisher<UserSession?, Error> {
        sessionPublisher(userId: userId)
            .first()
            .flatMap { _ in
                return self.database
                    .update(
                        reference: DatabaseReferences.singleUser(userId: userId),
                        with: session.toJson() ?? [:],
                        merge: true
                )
        }.flatMap { _ in
            self.sessionPublisher(userId: userId).first()
        }.eraseToAnyPublisher()
    }
}
