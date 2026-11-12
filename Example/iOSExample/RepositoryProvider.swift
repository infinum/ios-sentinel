//
//  RepositoryProvider.swift
//  Example-iOS
//
//  Created by Nikola Simunko on 13.10.2026..
//

import Foundation
import Pulse

/// Fetches this repository from GitHub, so `APIMockingTool` has a request to answer.
enum RepositoryProvider {

    static let url = URL(string: "https://api.github.com/repos/infinum/ios-sentinel")!

    /// A one-line description of the response, or of why the request failed.
    static func fetch() async -> String {
        // Created after Sentinel is set up, so its `.default` configuration already includes mocking.
        let session = URLSessionProxy(configuration: .default)
        do {
            let (data, response) = try await session.data(for: URLRequest(url: url))
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard let repository = try? JSONDecoder().decode(Repository.self, from: data) else {
                return "\(statusCode): \(String(decoding: data.prefix(200), as: UTF8.self))"
            }
            return "\(statusCode): ★ \(repository.stargazersCount) · \(repository.description ?? "No description")"
        } catch {
            return "Failed: \(error.localizedDescription)"
        }
    }
}

private struct Repository: Decodable {

    let description: String?
    let stargazersCount: Int

    enum CodingKeys: String, CodingKey {
        case description
        case stargazersCount = "stargazers_count"
    }
}
