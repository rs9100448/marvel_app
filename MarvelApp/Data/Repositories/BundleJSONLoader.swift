//
//  BundleJSONLoader.swift
//  MarvelApp
//
//  Small helper that decodes a bundled JSON resource into a Decodable type.
//  Centralising this keeps repositories thin and makes error handling uniform.
//

import Foundation

enum DataError: Error, LocalizedError {
    case resourceNotFound(String)
    case decodingFailed(String, underlying: Error)

    var errorDescription: String? {
        switch self {
        case let .resourceNotFound(name):
            return "Could not find bundled resource \(name)."
        case let .decodingFailed(name, underlying):
            return "Failed to decode \(name): \(underlying.localizedDescription)"
        }
    }
}

enum BundleJSONLoader {
    nonisolated static func load<T: Decodable>(_ type: T.Type, from resource: String, in bundle: Bundle = .main) throws -> T {
        guard let url = bundle.url(forResource: resource, withExtension: "json") else {
            throw DataError.resourceNotFound("\(resource).json")
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as DataError {
            throw error
        } catch {
            throw DataError.decodingFailed("\(resource).json", underlying: error)
        }
    }
}
