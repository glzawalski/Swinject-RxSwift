import RxSwift
import RxCocoa
import Foundation

protocol GitHubAPI {
    func searchSwiftRepos(page: Int) -> Observable<[Repo]>
}

final class GitHubAPIClient: GitHubAPI {
    func searchSwiftRepos(page: Int) -> Observable<[Repo]> {
        let url = URL(string:
        "https://api.github.com/search/repositories?q=language:swift&sort=stars&page=\(page)&per_page=10")!

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        return URLSession.shared.rx
            .data(request: request)
            .map { data in
                try JSONDecoder().decode(RepoSearchResponse.self, from: data)
            }
            .map { $0.items }
    }
}
