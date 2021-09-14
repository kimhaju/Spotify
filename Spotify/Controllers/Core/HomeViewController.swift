//
//  ViewController.swift
//  Spotify
//
//  Created by haju Kim on 2021/09/08.
//

import UIKit

//->노래에 대한 정보
enum BrowseSectionType {
    //->직접 코딩하기보다는 열거형으로 간편하게 할수 있다.
    case newReleases(viewModels: [NewReleaseCellViewModel]) // 1
    case featuredPlaylists(viewsModels: [FeaturedPlaylistCellViewModel]) // 2
    case recommendedTracks(viewsModels: [RecommendedTrackCellViewModel]) // 3
}

class HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView =  UICollectionView (
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            return HomeViewController.createSectionLayout(section: sectionIndex)
        }
    )
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var sections = [BrowseSectionType]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Browse"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem (
            image: UIImage(systemName: "gear"),
            style: .done,
            target: self,
            action: #selector(didTapSettings)
        )
        configureCollectionView()
        view.addSubview(spinner)
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }
    
    //->5가지 임의의 추천을 받기
    private func fetchData() {
        //->디스패치된 동시작업을 그룹화? 찾아봐야 겠다.
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        print("데이터 매칭 시작")
        
        var newRealeses: NewRealsesResponse?
        var featuredPlaylist: FeaturedPlayListsResponse?
        var recommendations: RecommendationsResponse?
        
        // 신규 음악
        APICaller.shared.getNewReleases { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                newRealeses = model
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        //-> 추천 재생 목록
        APICaller.shared.getFeaturedPlayLists{ result in
            defer {
                group.leave()
            }

            switch result {
            case .success(let model):
                featuredPlaylist = model
                
            case .failure(let error): print(error.localizedDescription)
            }
        }
        
        // 추천 트랙
        APICaller.shared.getRecommededGenres { result in
            switch result {
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                //-> 링크에서 가져오는 수는 5개이하인데 그 수를 맞추지 않아서 못찾는 경우도 있었음
                while seeds.count < 5 {
                    if let random = genres.randomElement() {
                        seeds.insert(random)
                    }
                }
                APICaller.shared.getRecommendations(genres: seeds) { recommendedResult in
                    defer {
                        group.leave()
                    }
                    
                    switch recommendedResult {
                    case .success(let model):
                        recommendations = model
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                 
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        group.notify(queue: .main) {
            guard let newAlbums = newRealeses?.albums.items,
                  let playlists = featuredPlaylist?.playlists.items,
                  let trakcs = recommendations?.tracks else {
//                fatalError("모델이 존재하지 않습니다.")
                return
            }
            print("뷰 모델 구성")
            self.configureModels(
                newAlbums: newAlbums,
                playlists: playlists,
                tracks: trakcs
            )
        }
    }
    
    private func configureModels(
        newAlbums: [Album],
        playlists: [Playlist],
        tracks: [AudioTrack]
    ) {
        // 모델 구성
    
        sections.append(.newReleases(viewModels: newAlbums.compactMap({
            return NewReleaseCellViewModel(
                name: $0.name,
                artworkURL: URL(string: $0.images.first?.url ?? ""),
                numberOfTracks: $0.total_tracks,
                artistName: $0.artists.first?.name ?? "-"
            )
        })))
        sections.append(.featuredPlaylists(viewsModels: playlists.compactMap({
            return FeaturedPlaylistCellViewModel(name:  $0.name,
                                                 artworkURL: URL(string: $0.images.first?.url ?? ""),
                                                 creatorName: $0.owner.display_name
            )
        })))
        
        sections.append(.recommendedTracks(viewsModels: tracks.compactMap({
            return RecommendedTrackCellViewModel(name: $0.name,
                                                 artistName: $0.artists.first?.name ?? "-",
                                                 artworkURL: URL(string: $0.album.images.first?.url ?? ""))
        })))
        
        collectionView.reloadData()
    }
    
    
    @objc func didTapSettings() {
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
        case .newReleases( let viewModels):
            return viewModels.count
        case .featuredPlaylists( let viewModels):
            return viewModels.count
        case .recommendedTracks( let viewModels):
            return viewModels.count
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let type = sections[indexPath.section]
        
        switch type {
        case .newReleases( let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                for: indexPath
            ) as? NewReleaseCollectionViewCell else {
                return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
            return cell
            
        case .featuredPlaylists( let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier,
                for: indexPath
            ) as? FeaturedPlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
           
        case .recommendedTracks( let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
                for: indexPath
            ) as? RecommendedTrackCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
            
        }
        
        
    }
    
   static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        switch section {
        case 0:
            // 아이템
            let item =  NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            // 그룹
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(360)
                ),
                subitem:item,
                count: 3
            )
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(360)
                ),
                subitem: verticalGroup,
                count: 1
            )
            
            // 섹션
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
            
        case 1:
            // 아이템
            let item =  NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(200)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            // 그룹
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(400)
                ),
                subitem: item,
                count: 2
            )
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(400)
                ),
                subitem: verticalGroup,
                count: 1
            )
            
            // 섹션
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            return section
            
        case 2:
            // 아이템
            let item =  NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            // 그룹
          
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(80)
                ),
                subitem: item,
                count: 1
            )
            
            // 섹션
            let section = NSCollectionLayoutSection(group: group)
            return section
            
        default:
            // 아이템
            let item =  NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            // 그룹
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(390)
                ),
                subitem:item,
                count: 1
            )
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }
}

