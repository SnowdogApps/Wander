//
//  MLModelManager.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/1/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Combine
import Foundation
import CoreML

protocol MLModelManagerType {
    func fetchModel(using url: URL) -> AnyPublisher<MLModel, Error>
}

final class MLModelManager: MLModelManagerType {
    private let fileManager: FileManager
    private let session: URLSession

    init(fileManager: FileManager, session: URLSession) {
        self.fileManager = fileManager
        self.session = session
    }

    func fetchModel(using url: URL) -> AnyPublisher<MLModel, Error> {
        Future<URL, Error> { promise in
            self.session.downloadTask(with: url) { localURL, _, error in
                if let url = localURL {
                    promise(.success(url))
                } else if let error = error {
                    promise(.failure(error))
                }
            }.resume()
        }
        .tryMap { try MLModel.compileModel(at: $0) }
        .flatMap { self.moveToApplicationFolder(from: $0, using: url.lastPathComponent) }
        .tryMap { try MLModel(contentsOf: $0) }
        .eraseToAnyPublisher()
    }

    private func moveToApplicationFolder(from compiledURL: URL, using name: String) -> AnyPublisher<URL, Error> {
        Future { promise in
            do {
                let appSupportDirectory = try self.fileManager.url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: compiledURL,
                    create: true
                )

                let permanentURL = appSupportDirectory.appendingPathComponent(name)

                if self.fileManager.fileExists(atPath: permanentURL.absoluteString) {
                    _ = try self.fileManager.replaceItemAt(permanentURL, withItemAt: compiledURL)
                } else {
                    try self.fileManager.copyItem(at: compiledURL, to: permanentURL)
                }
                promise(.success(permanentURL))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
