//
//  DatabaseManager.swift
//  STPR
//
//  Created by Artur Chabera on 05/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Combine
import Firebase

protocol DocumentReferenceConvertible {
    var referencePath: String { get }
}

enum DatabaseEndpoint: String {
    case missions = "missions_v2"
    case userSession = "users_v2"
    case missionSession = "mission_session"
}

protocol DatabaseManager {
    func collectionPublisher(for reference: DocumentReferenceConvertible, includeMetadata: Bool) -> AnyPublisher<QuerySnapshot, Error>
    func documentPublisher(for reference: DocumentReferenceConvertible, includeMetadata: Bool) -> AnyPublisher<DocumentSnapshot, Error>
    func update(reference: DocumentReferenceConvertible, with data: [String: Any], merge: Bool) -> AnyPublisher<String, Error>
    func create(reference: DocumentReferenceConvertible, with data: [String: Any]) -> AnyPublisher<String, Error>
}

final class FirestoreManager: DatabaseManager {
    private let database: Firestore
    
    init(database: Firestore = Firestore.firestore()) {
        self.database = database
    }

    /// Creating a new document
    /// - Parameter data: Data serialized to [String: Any] format
    /// - Parameter reference: enumerated doc reference
    /// - Parameter merge: merge with current session data or overwite
    func create(reference: DocumentReferenceConvertible, with data: [String : Any]) -> AnyPublisher<String, Error> {
        Future { promise in
            let document = self.database.collection(reference.referencePath).document()
            document.setData(data, merge: true) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(document.documentID))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// Updating existing document
    /// - Parameter data: Data serialized to [String: Any] format
    /// - Parameter reference: enumerated doc reference
    /// - Parameter merge: merge with current session data or overwite
    func update(reference: DocumentReferenceConvertible, with data: [String: Any], merge: Bool) -> AnyPublisher<String, Error> {
        Future { promise in
            let document = self.database.document(reference.referencePath)
            document.setData(data, merge: merge) { error in
                if let error = error{
                    promise(.failure(error))
                } else {
                    promise(.success(document.documentID))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// Publisher for collections in Firebase
    ///
    /// - Parameters:
    ///   - reference: Reference to a document in Firebase database
    ///   - includeMetadataChanges: ability to listen also for changes in metadata
    func collectionPublisher(for reference: DocumentReferenceConvertible, includeMetadata: Bool) -> AnyPublisher<QuerySnapshot, Error> {
        let changesSubject = PassthroughSubject<QuerySnapshot, Error>()
        database
            .collection(reference.referencePath)
            .addSnapshotListener(includeMetadataChanges: includeMetadata) { snapshot, error in
                if let error = error {
                    changesSubject.send(completion: .failure(error))
                } else {
                    snapshot.map { changesSubject.send($0) }
                }
            }
        return changesSubject.eraseToAnyPublisher()
    }

    /// Publisher for documents in Firebase
    ///
    /// - Parameters:
    ///   - reference: Reference to a document in Firebase database
    ///   - includeMetadataChanges: ability to listen also for changes in metadata
    func documentPublisher(for reference: DocumentReferenceConvertible, includeMetadata: Bool) -> AnyPublisher<DocumentSnapshot, Error> {
        let changesSubject = PassthroughSubject<DocumentSnapshot, Error>()
        database
            .document(reference.referencePath)
            .addSnapshotListener(includeMetadataChanges: includeMetadata) { snapshot, error in
                if let error = error {
                    changesSubject.send(completion: .failure(error))
                } else {
                    snapshot.map { changesSubject.send($0) }
                }
            }
        return changesSubject.eraseToAnyPublisher()
    }
}
