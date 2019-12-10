//
//  Firebase.swift
//  STPR
//
//  Created by Artur Chabera on 06/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Firebase

extension DocumentSnapshot {
    private func jsonData() -> Data? {
        data().flatMap { try? JSONSerialization.data(withJSONObject: $0, options: .sortedKeys) }
    }
    
    func decode<T: Decodable>() throws -> T? {
        let json = try data()
            .flatMap { try JSONSerialization.data(withJSONObject: $0, options: .sortedKeys) } ?? Data()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode(T.self, from: json)
    }
}

extension Encodable {
    func toJson() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        return json as? [String: Any]
    }
}
