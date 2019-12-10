//
//  MissionsManager.swift
//  STPR
//
//  Created by Artur Chabera on 04/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Combine

protocol MissionsManager {
    func missionPublisher() -> AnyPublisher<[Mission], Error>
    func sessionPublisher(userId: String) -> AnyPublisher<[DocumentedMissionSession], Error>
    func updateSession(_ missionSession: MissionSession, userId: String, sessionId: String) -> AnyPublisher<String, Error>
    func createSession(_ missionSession: MissionSession, userId: String) -> AnyPublisher<String, Error>
}

final class FirestoreMissionsManager: MissionsManager {
    enum DatabaseReferences: DocumentReferenceConvertible {
        case missions
        case missionSessions(userId: String)
        case singleMissionSession(userId: String, missionId: String)

        var referencePath: String {
            switch self {
            case .missionSessions(let userId):
                return "\(DatabaseEndpoint.userSession.rawValue)/\(userId)/\(DatabaseEndpoint.missionSession.rawValue)"
            case .missions:
                return DatabaseEndpoint.missions.rawValue
            case .singleMissionSession(let userId, let missionId):
                if missionId.isEmpty {
                    return "\(DatabaseEndpoint.userSession.rawValue)/\(userId)/\(DatabaseEndpoint.missionSession.rawValue)"
                } else {
                    return "\(DatabaseEndpoint.userSession.rawValue)/\(userId)/\(DatabaseEndpoint.missionSession.rawValue)/\(missionId)"
                }
            }
        }
    }

    private let database: DatabaseManager
    init(database: DatabaseManager) {
        self.database = database
    }

    func sessionPublisher(userId: String) -> AnyPublisher<[DocumentedMissionSession], Error> {
       database
           .collectionPublisher(for: DatabaseReferences.missionSessions(userId: userId), includeMetadata: false)
           .map { snapshot in
               let missionSession: [MissionSession] = snapshot.documents.compactMap { try? $0.decode() }
               return zip(snapshot.documents.compactMap{ $0.documentID }, missionSession)
                   .compactMap { DocumentedMissionSession(documentId: $0, missionSession: $1) }
           }.eraseToAnyPublisher()
   }

    func missionPublisher() -> AnyPublisher<[Mission], Error> {
        database
            .collectionPublisher(for: DatabaseReferences.missions, includeMetadata: false)
            .map { $0.documents.compactMap { try? $0.decode() } }
            .eraseToAnyPublisher()
    }

    func createSession(_ missionSession: MissionSession, userId: String) -> AnyPublisher<String, Error> {
        Just(missionSession)
            .setFailureType(to: Error.self)
            .compactMap { $0.toJson() }
            .flatMap {
                self.database
                    .create(
                        reference: DatabaseReferences.singleMissionSession(userId: userId, missionId: ""),
                        with: $0
                    )
        }.eraseToAnyPublisher()
    }

    func updateSession(_ missionSession: MissionSession, userId: String, sessionId: String) -> AnyPublisher<String, Error> {
        Just(missionSession)
            .setFailureType(to: Error.self)
            .compactMap { $0.toJson() }
            .flatMap {
                self.database
                    .update(
                        reference: DatabaseReferences.singleMissionSession(userId: userId, missionId: sessionId),
                        with: $0,
                        merge: true
                )
        }.eraseToAnyPublisher()
    }
}
