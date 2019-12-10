//
//  AuthManager.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/2/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import FirebaseAuth
import Combine

protocol AuthManagerType: AnyObject {
    var currentUser: User? { get }
    func login(email: String, password: String) -> AnyPublisher<User, Error>
    func signUp(email: String, password: String) -> AnyPublisher<User, Error>
    func resetPassword(for email: String) -> AnyPublisher<Bool, Error>
    func loginAsGuest() -> AnyPublisher<User, Error>
    func signOut()
}

final class FirebaseAuthManager: AuthManagerType {
    var currentUser: User? { Auth.auth().currentUser }

    func login(email: String, password: String) -> AnyPublisher<User, Error> {
        Future { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let user = result?.user {
                    promise(.success(user))
                }
            }
        }.eraseToAnyPublisher()
    }

    func loginAsGuest() -> AnyPublisher<User, Error> {
        Future { promise in
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let user = result?.user {
                    promise(.success(user))
                }
            }
        }.eraseToAnyPublisher()
    }

    func signUp(email: String, password: String) -> AnyPublisher<User, Error> {
        Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let user = result?.user {
                    promise(.success(user))
                }
            }
        }.eraseToAnyPublisher()
    }

    func resetPassword(for email: String) -> AnyPublisher<Bool, Error> {
        Future { promise in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                error.map { promise(.failure($0)) } ?? promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }

    func signOut() {
        try? Auth.auth().signOut()
    }
}
