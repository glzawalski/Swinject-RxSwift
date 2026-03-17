import Foundation

struct Repo: Decodable, Identifiable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let stargazersCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case description
        case stargazersCount = "stargazers_count"
    }
}

struct RepoSearchResponse: Decodable {
    let items: [Repo]
}
