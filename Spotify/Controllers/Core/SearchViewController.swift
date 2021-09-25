//
//  SearchViewController.swift
//  Spotify
//  오류 생겨도 너무 힘들어하지 말고 원인을 찾고 잘 풀어보자 모든 것이 학습의 일환이다.
//  Created by haju Kim on 2021/09/08.
//

import SafariServices
import UIKit

//->검색기능 제공
class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    let searchController: UISearchController = {
        let results = UIViewController()
        results.view.backgroundColor = .red
        let vc = UISearchController(searchResultsController: SearchResultsViewController())
        vc.searchBar.placeholder = "음원, 아티스트, 앨범"
        vc.searchBar.searchBarStyle = .minimal
        // -> 탭할때 서치바 변경
        vc.definesPresentationContext = true
        return vc
    }()
    
    private let collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem (layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 7, bottom: 2, trailing: 7)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(150)),
                subitem: item,
                count: 2
            )
            group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
            
            return NSCollectionLayoutSection(group: group)
        })
    )
    private var categories = [Category]()
    
    // MARK: -Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        view.addSubview(collectionView)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        APICaller.shared.getCategories{ [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.categories = categories
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController,
              let query = searchBar.text,
         !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        resultsController.delegate = self
        
        APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let results):
                    resultsController.update(with: results)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
       
    }
}

extension SearchViewController: SearchResultsViewControllerDelegate {
    func didTapResult(_ result: SearchResult) {
        //->위 항목의 역할: 사용자가 검색 결과를 클릭하면 해당 음원으로 연결 가능.
        switch result {
        case .artist(let model):
            guard let url = URL(string: model.external_urls["spotify"] ?? "") else {
                return
            }
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
            
        case .album(let model):
           let vc = AlbumViewController(album: model)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            
        case .track(let model):
            PlaybackPresenter.shared.startPlayback(
                from: self, track: model
            )
        case .playlist(let model):
            let vc = PlaylistViewController(playlist: model)
             vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier,
                                                            for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = categories[indexPath.row]
        cell.configure(
            with: CategoryCollectionViewCellViewModel(
                title: category.name,
                artworkURL: URL(string: category.icons.first?.url ?? "")
            ))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let category = categories[indexPath.row]
        let vc = CategoryViewController(category: category)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
